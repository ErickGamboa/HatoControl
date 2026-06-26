import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Un animal con su peso actual (último pesaje) y su ganancia por día (entre
/// los dos últimos pesajes). Ambos null si no hay datos suficientes.
class AnimalConPeso {
  AnimalConPeso({
    required this.animal,
    required this.pesoActual,
    required this.gananciaDiaria,
  });
  final AnimalRow animal;
  final double? pesoActual;
  final double? gananciaDiaria; // kg/día entre los dos últimos pesajes
}

/// Un pesaje hecho hoy, con el lote del animal y la ganancia vs. el anterior.
class PesajeHoy {
  PesajeHoy({
    required this.id,
    required this.identificador,
    required this.loteId,
    required this.loteNombre,
    required this.peso,
    required this.fecha,
    required this.ganancia,
    required this.dias,
  });
  final String id; // id del pesaje (para poder eliminarlo)
  final String identificador;
  final String loteId;
  final String loteNombre;
  final double peso;
  final DateTime fecha;
  final double? ganancia; // total vs. el pesaje anterior; null = entrada
  final int? dias; // días entre el pesaje anterior y este; null = entrada

  /// Kilos ganados/perdidos por día. null si es entrada o si pasó menos de
  /// un día desde el pesaje anterior (no se puede promediar por día aún).
  double? get gananciaDiaria {
    if (ganancia == null || dias == null || dias! < 1) return null;
    return ganancia! / dias!;
  }
}

/// Un pesaje dentro del historial de un animal, con la ganancia respecto al
/// pesaje anterior y los días transcurridos.
class PesajeHistorial {
  PesajeHistorial({
    required this.fecha,
    required this.peso,
    required this.ganancia,
    required this.dias,
  });
  final DateTime fecha;
  final double peso;
  final double? ganancia; // vs. el pesaje anterior; null = primero (entrada)
  final int? dias; // días desde el pesaje anterior

  double? get gananciaDiaria {
    if (ganancia == null || dias == null || dias! < 1) return null;
    return ganancia! / dias!;
  }
}

/// Acceso a animales y pesajes (base local; el sync corre por separado).
class PesajesRepository {
  PesajesRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  /// Stream reactivo con los animales (no borrados) de un lote, cada uno con su
  /// peso actual (el pesaje más reciente). Se actualiza solo al cambiar datos.
  Stream<List<AnimalConPeso>> observarAnimalesDeLote(String loteId) {
    final consulta = db.select(db.animales)
      ..where((t) => t.loteId.equals(loteId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.identificador)]);

    return consulta.watch().asyncMap((animales) async {
      final resultado = <AnimalConPeso>[];
      for (final a in animales) {
        // Los dos pesajes más recientes del animal.
        final ultimos = await (db.select(db.pesajes)
              ..where((t) => t.animalId.equals(a.id) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
              ..limit(2))
            .get();

        final pesoActual = ultimos.isNotEmpty ? ultimos.first.peso : null;
        double? gananciaDiaria;
        if (ultimos.length == 2) {
          final dias = ultimos[0].fecha.difference(ultimos[1].fecha).inDays;
          if (dias >= 1) {
            gananciaDiaria = (ultimos[0].peso - ultimos[1].peso) / dias;
          }
        }
        resultado.add(AnimalConPeso(
          animal: a,
          pesoActual: pesoActual,
          gananciaDiaria: gananciaDiaria,
        ));
      }
      return resultado;
    });
  }

  /// Busca un animal por su identificador (arete) dentro de una finca.
  /// Devuelve null si no existe.
  Future<AnimalRow?> buscarAnimal(String fincaId, String identificador) {
    return (db.select(db.animales)
          ..where((t) =>
              t.fincaId.equals(fincaId) &
              t.identificador.equals(identificador) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Crea un animal nuevo en un lote y registra su primer pesaje (peso de
  /// entrada), todo en una transacción. Ambas filas quedan pendientes de subir.
  Future<void> crearAnimalConPesaje({
    required String fincaId,
    required String loteId,
    required String identificador,
    required double peso,
    required String registradoPor,
  }) async {
    final ahora = DateTime.now();
    final animalId = _uuid.v4();
    await db.transaction(() async {
      await db.into(db.animales).insert(AnimalesCompanion.insert(
            id: animalId,
            fincaId: fincaId,
            loteId: loteId,
            identificador: identificador,
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ));
      await db.into(db.pesajes).insert(PesajesCompanion.insert(
            id: _uuid.v4(),
            animalId: animalId,
            peso: peso,
            fecha: ahora,
            registradoPor: Value(registradoPor),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ));
    });
  }

  /// Stream con los pesajes de la finca registrados desde [desde] (inicio del
  /// día), cada uno con el lote del animal y la ganancia respecto al pesaje
  /// inmediatamente anterior. Más reciente primero.
  Stream<List<PesajeHoy>> observarPesajesDelDia(String fincaId, DateTime desde) {
    final consulta = db.select(db.pesajes).join([
      innerJoin(db.animales, db.animales.id.equalsExp(db.pesajes.animalId)),
      innerJoin(db.lotes, db.lotes.id.equalsExp(db.animales.loteId)),
    ])
      ..where(db.animales.fincaId.equals(fincaId) &
          db.pesajes.deletedAt.isNull() &
          db.pesajes.fecha.isBiggerOrEqualValue(desde))
      ..orderBy([OrderingTerm.desc(db.pesajes.fecha)]);

    return consulta.watch().asyncMap((filas) async {
      final resultado = <PesajeHoy>[];
      for (final fila in filas) {
        final p = fila.readTable(db.pesajes);
        final a = fila.readTable(db.animales);
        final l = fila.readTable(db.lotes);
        // Peso del pesaje inmediatamente anterior a este (de ese animal).
        final prev = await (db.select(db.pesajes)
              ..where((t) =>
                  t.animalId.equals(a.id) &
                  t.deletedAt.isNull() &
                  t.fecha.isSmallerThanValue(p.fecha))
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
        resultado.add(PesajeHoy(
          id: p.id,
          identificador: a.identificador,
          loteId: l.id,
          loteNombre: l.nombre,
          peso: p.peso,
          fecha: p.fecha,
          ganancia: prev == null ? null : p.peso - prev.peso,
          dias: prev == null ? null : p.fecha.difference(prev.fecha).inDays,
        ));
      }
      return resultado;
    });
  }

  /// Stream con el historial completo de pesajes de un animal, en orden
  /// cronológico (más antiguo primero), cada uno con su ganancia respecto al
  /// pesaje anterior y los días transcurridos.
  Stream<List<PesajeHistorial>> observarHistorial(String animalId) {
    final consulta = db.select(db.pesajes)
      ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.fecha)]);

    return consulta.watch().map((filas) {
      final resultado = <PesajeHistorial>[];
      for (var i = 0; i < filas.length; i++) {
        final p = filas[i];
        if (i == 0) {
          resultado.add(PesajeHistorial(
              fecha: p.fecha, peso: p.peso, ganancia: null, dias: null));
        } else {
          final prev = filas[i - 1];
          resultado.add(PesajeHistorial(
            fecha: p.fecha,
            peso: p.peso,
            ganancia: p.peso - prev.peso,
            dias: p.fecha.difference(prev.fecha).inDays,
          ));
        }
      }
      return resultado;
    });
  }

  /// Devuelve el peso del pesaje más reciente de un animal (o null si no tiene
  /// ninguno todavía). Sirve para calcular la ganancia respecto al anterior.
  Future<double?> ultimoPeso(String animalId) async {
    final fila = await (db.select(db.pesajes)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(1))
        .getSingleOrNull();
    return fila?.peso;
  }

  /// Elimina (borrado suave) un pesaje. Queda pendiente para sincronizar.
  Future<void> eliminarPesaje(String pesajeId) async {
    await (db.update(db.pesajes)..where((t) => t.id.equals(pesajeId))).write(
      PesajesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  /// Registra un pesaje para un animal existente.
  Future<void> agregarPesaje({
    required String animalId,
    required double peso,
    required String registradoPor,
  }) async {
    final ahora = DateTime.now();
    await db.into(db.pesajes).insert(PesajesCompanion.insert(
          id: _uuid.v4(),
          animalId: animalId,
          peso: peso,
          fecha: ahora,
          registradoPor: Value(registradoPor),
          createdAt: ahora,
          updatedAt: ahora,
          pendiente: const Value(true),
        ));
  }
}
