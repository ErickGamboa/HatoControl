import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../estadisticas/estadisticas_pesajes.dart';
import '../local/cambios_en_tablas.dart';
import '../local/database.dart';
import 'reglas_de_fechas.dart';
import 'ventas_repository.dart';

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
    required this.animalId,
    required this.identificador,
    required this.loteId,
    required this.loteNombre,
    required this.peso,
    required this.fecha,
    required this.ganancia,
    required this.dias,
    required this.pesoCompra,
    required this.precioKgCompra,
    required this.fechaCompra,
  });
  final String id; // id del pesaje (para poder eliminarlo); '' = sin peso
  final String animalId; // para corregirle el lote o la compra
  final String identificador;
  final String loteId;
  final String loteNombre;
  final double? peso; // null = entró sin peso y todavía no se ha pesado
  final DateTime fecha;

  /// Animal dado de alta sin peso: está en la lista para que se vea que
  /// entró, pero no tiene pesaje que corregir ni borrar.
  bool get sinPeso => peso == null;
  final double? ganancia; // total vs. el pesaje anterior; null = entrada
  final int? dias; // días entre el pesaje anterior y este; null = entrada
  final double? pesoCompra; // kilos de entrada; null = nació en la finca
  final double? precioKgCompra; // ₡/kg de compra; 0 = nació en la finca
  final DateTime? fechaCompra; // para no moverla al corregir el ₡/kg

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
    this.id = '',
    this.digitadoEl,
    this.digitadoPor,
  });
  final String id; // para corregirlo o borrarlo desde la hoja de vida
  final DateTime fecha;
  final double peso;
  final double? ganancia; // vs. el pesaje anterior; null = primero (entrada)
  final int? dias; // días desde el pesaje anterior

  /// Cuándo se digitó, si fue otro día que el del pesaje (se pesó el 5 y se
  /// pasó a la app el 8). null = se digitó el mismo día.
  final DateTime? digitadoEl;

  /// Nombre (o correo) de quien lo digitó, si se conoce.
  final String? digitadoPor;

  double? get gananciaDiaria {
    if (ganancia == null || dias == null || dias! < 1) return null;
    return ganancia! / dias!;
  }
}

/// Historial de pesos de un lote, jornada por jornada. Lo consume el módulo
/// Análisis para comparar lotes entre sí y ver cómo viene cada uno.
class ResumenPesosLote {
  const ResumenPesosLote({required this.lote, required this.periodos});

  final LoteRow lote;

  /// Jornadas de pesaje en orden cronológico (la más vieja primero).
  final List<PeriodoLote> periodos;

  PeriodoLote? get ultimaJornada => periodos.isEmpty ? null : periodos.last;

  /// La jornada más reciente que sí pudo compararse contra la anterior. Puede
  /// no ser la última: si en la última nadie tenía pesaje previo, no hay
  /// ganancia que mostrar.
  PeriodoLote? get ultimaConGanancia {
    for (var i = periodos.length - 1; i >= 0; i--) {
      if (periodos[i].gananciaPromedio != null) return periodos[i];
    }
    return null;
  }
}

/// Se lanza cuando se intenta registrar un animal con un identificador que ya
/// existe activo dentro de la misma finca.
class AnimalDuplicadoException implements Exception {
  const AnimalDuplicadoException(this.identificador);

  final String identificador;
}

/// Acceso a animales y pesajes (base local; el sync corre por separado).
class PesajesRepository {
  PesajesRepository(this.db) : _reglas = ReglasDeFechas(db);

  final AppDatabase db;
  final ReglasDeFechas _reglas;
  final _uuid = const Uuid();

  /// Días de CALENDARIO entre dos pesajes (ignora la hora del día). Así, de
  /// ayer a hoy = 1 día aunque hayan pasado menos de 24 horas reales. Usar
  /// `inDays` de la diferencia contaría bloques completos de 24 h (ayer 3pm →
  /// hoy 10am = 0), y el kg/día nunca aparecería.
  static int _diasCalendario(DateTime anterior, DateTime actual) =>
      diasCalendario(anterior, actual);

  /// Stream reactivo con los animales (no borrados) de un lote, cada uno con su
  /// peso actual (el pesaje más reciente). Se actualiza solo al cambiar datos.
  Stream<List<AnimalConPeso>> observarAnimalesDeLote(String loteId) {
    final consulta = db.select(db.animales)
      ..where(
        (t) =>
            t.loteId.equals(loteId) &
            t.deletedAt.isNull() &
            t.estado.equals(EstadoAnimal.activo),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.identificador)]);

    // Los pesajes vivos del lote entero, del más nuevo al más viejo. De acá
    // salen, en memoria, el peso actual y la ganancia de cada animal.
    final pesajesDelLote =
        db.select(db.pesajes).join([
            innerJoin(
              db.animales,
              db.animales.id.equalsExp(db.pesajes.animalId),
            ),
          ])
          ..where(
            db.animales.loteId.equals(loteId) & db.pesajes.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.desc(db.pesajes.fecha)]);

    // Se escuchan las DOS tablas: el peso sale de `pesajes`, así que mirando
    // solo `animales` la lista no se movía al entrar un pesaje nuevo — al
    // sincronizar, el inventario seguía con el peso viejo hasta salir y
    // volver a entrar.
    //
    // Y se resuelve en DOS consultas, no en una por animal. Con 91 animales
    // eran 92 consultas por refresco: tardaba tanto que los avisos de cambio
    // que llegaban mientras tanto se perdían, y la pantalla se quedaba
    // mostrando datos viejos aunque la base ya estuviera al día.
    return db
        .cambiosEn('animales_del_lote', {db.animales, db.pesajes})
        .asyncMap((_) async {
          final animales = await consulta.get();
          if (animales.isEmpty) return const <AnimalConPeso>[];

          final porAnimal = <String, List<PesajeRow>>{};
          for (final fila in await pesajesDelLote.get()) {
            final p = fila.readTable(db.pesajes);
            final suyos = porAnimal.putIfAbsent(p.animalId, () => []);
            // Solo hacen falta los dos más recientes de cada uno.
            if (suyos.length < 2) suyos.add(p);
          }

          return [
            for (final a in animales)
              _conPeso(a, porAnimal[a.id] ?? const <PesajeRow>[]),
          ];
        });
  }

  /// Peso actual y ganancia diaria de un animal a partir de sus dos pesajes
  /// más recientes (el primero de la lista es el más nuevo).
  static AnimalConPeso _conPeso(AnimalRow animal, List<PesajeRow> ultimos) {
    double? gananciaDiaria;
    if (ultimos.length == 2) {
      final dias = _diasCalendario(ultimos[1].fecha, ultimos[0].fecha);
      if (dias >= 1) {
        gananciaDiaria = (ultimos[0].peso - ultimos[1].peso) / dias;
      }
    }
    return AnimalConPeso(
      animal: animal,
      pesoActual: ultimos.isNotEmpty ? ultimos.first.peso : null,
      gananciaDiaria: gananciaDiaria,
    );
  }

  /// Stream de animales vendidos de la finca (historial de ventas).
  Stream<List<AnimalRow>> observarAnimalesVendidos(String fincaId) {
    return (db.select(db.animales)
          ..where(
            (t) =>
                t.fincaId.equals(fincaId) &
                t.deletedAt.isNull() &
                t.estado.equals(EstadoAnimal.vendido),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Busca un animal activo por arete dentro de una finca (corral / pesaje).
  Future<AnimalRow?> buscarAnimalActivo(String fincaId, String identificador) {
    return (db.select(db.animales)..where(
          (t) =>
              t.fincaId.equals(fincaId) &
              t.identificador.equals(identificador) &
              t.deletedAt.isNull() &
              t.estado.equals(EstadoAnimal.activo),
        ))
        .getSingleOrNull();
  }

  /// Busca un animal por su identificador (arete) dentro de una finca.
  /// Devuelve null si no existe.
  Future<AnimalRow?> buscarAnimal(String fincaId, String identificador) {
    return (db.select(db.animales)..where(
          (t) =>
              t.fincaId.equals(fincaId) &
              t.identificador.equals(identificador) &
              t.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// Crea un animal nuevo en un lote y registra su primer pesaje (peso de
  /// entrada), todo en una transacción. Todas las filas quedan pendientes de
  /// subir.
  ///
  /// [fecha] es el día en que el animal ENTRÓ (la fecha de la jornada en
  /// Trabajo; hoy si no se dice otra cosa). De esa fecha arrancan la compra,
  /// el primer movimiento de lote, el pesaje de entrada y con ellos la dieta
  /// y los gastos fijos. `createdAt` sí es el momento en que se digitó.
  ///
  /// [peso] null = entró sin pesar: no se crea pesaje, y el primero que se le
  /// haga después pasa a ser su peso de entrada.
  ///
  /// Compra, una de tres:
  /// - por kilo: [pesoCompra] × [precioKgCompra] = total;
  /// - monto total: [precioCompra] sin ₡/kg; el ₡/kg sale de dividir entre
  ///   el peso de entrada (ahora, o cuando se pese por primera vez);
  /// - nació en la finca: [precioKgCompra] = 0 → compra ₡0.
  Future<void> crearAnimalConPesaje({
    required String fincaId,
    required String loteId,
    required String identificador,
    required double? peso,
    required String registradoPor,
    double? pesoCompra,
    double? precioKgCompra,
    double? precioCompra,
    DateTime? fecha,
  }) async {
    final existente = await buscarAnimal(fincaId, identificador);
    if (existente != null) {
      throw AnimalDuplicadoException(identificador);
    }

    final ahora = DateTime.now();
    final dia = fecha ?? ahora;
    _reglas.noFutura(dia, hoy: ahora);
    final cuando = momentoDe(dia, ahora: ahora);
    final animalId = _uuid.v4();
    final nacioEnFinca = precioKgCompra == 0;
    final totalCompra = nacioEnFinca
        ? 0.0
        : precioCompra ??
              ((pesoCompra != null && precioKgCompra != null)
                  ? pesoCompra * precioKgCompra
                  : null);
    // Monto total sin ₡/kg: si ya se sabe el peso de compra, se divide.
    final precioKg = nacioEnFinca
        ? 0.0
        : precioKgCompra ??
              ((totalCompra != null && pesoCompra != null && pesoCompra > 0)
                  ? totalCompra / pesoCompra
                  : null);
    await db.transaction(() async {
      await db
          .into(db.animales)
          .insert(
            AnimalesCompanion.insert(
              id: animalId,
              fincaId: fincaId,
              loteId: loteId,
              identificador: identificador,
              pesoCompra: Value(nacioEnFinca ? null : pesoCompra),
              precioKgCompra: Value(precioKg),
              precioCompra: Value(totalCompra),
              fechaCompra: Value(
                nacioEnFinca || totalCompra == null ? null : cuando,
              ),
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
      if (peso != null) {
        await db
            .into(db.pesajes)
            .insert(
              PesajesCompanion.insert(
                id: _uuid.v4(),
                animalId: animalId,
                peso: peso,
                fecha: cuando,
                registradoPor: Value(registradoPor),
                createdAt: ahora,
                updatedAt: ahora,
                pendiente: const Value(true),
              ),
            );
      }
      await db
          .into(db.movimientosLote)
          .insert(
            MovimientosLoteCompanion.insert(
              id: _uuid.v4(),
              animalId: animalId,
              loteOrigen: const Value(null),
              loteDestino: loteId,
              fecha: cuando,
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
    });
  }

  /// Stream con los pesajes de la finca DIGITADOS desde [desde] (inicio del
  /// día), cada uno con el lote del animal y la ganancia respecto al pesaje
  /// inmediatamente anterior. Más reciente primero.
  ///
  /// Se filtra por cuándo se digitó y no por la fecha del pesaje: si el
  /// patrón pasa hoy lo que el peón pesó el 5, lo tiene que ver en la lista
  /// para poder corregirlo. Los animales dados de alta en ese lapso sin peso
  /// también salen (con `peso` null), para que se vea que entraron.
  Stream<List<PesajeHoy>> observarPesajesDelDia(
    String fincaId,
    DateTime desde,
  ) {
    final consulta =
        db.select(db.animales).join([
          leftOuterJoin(
            db.pesajes,
            db.pesajes.animalId.equalsExp(db.animales.id) &
                db.pesajes.deletedAt.isNull(),
          ),
          innerJoin(db.lotes, db.lotes.id.equalsExp(db.animales.loteId)),
        ])..where(
          db.animales.fincaId.equals(fincaId) &
              db.animales.deletedAt.isNull() &
              (db.pesajes.createdAt.isBiggerOrEqualValue(desde) |
                  (db.pesajes.id.isNull() &
                      db.animales.createdAt.isBiggerOrEqualValue(desde))),
        );

    return consulta.watch().asyncMap((filas) async {
      final resultado = <(DateTime, PesajeHoy)>[];
      for (final fila in filas) {
        final p = fila.readTableOrNull(db.pesajes);
        final a = fila.readTable(db.animales);
        final l = fila.readTable(db.lotes);
        if (p == null) {
          resultado.add((
            a.createdAt,
            PesajeHoy(
              id: '',
              animalId: a.id,
              identificador: a.identificador,
              loteId: l.id,
              loteNombre: l.nombre,
              peso: null,
              fecha: a.fechaCompra ?? a.createdAt,
              ganancia: null,
              dias: null,
              pesoCompra: a.pesoCompra,
              precioKgCompra: a.precioKgCompra,
              fechaCompra: a.fechaCompra,
            ),
          ));
          continue;
        }
        // Peso del pesaje inmediatamente anterior a este (de ese animal).
        final prev =
            await (db.select(db.pesajes)
                  ..where(
                    (t) =>
                        t.animalId.equals(a.id) &
                        t.deletedAt.isNull() &
                        t.fecha.isSmallerThanValue(p.fecha),
                  )
                  ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
                  ..limit(1))
                .getSingleOrNull();
        resultado.add((
          p.createdAt,
          PesajeHoy(
            id: p.id,
            animalId: a.id,
            identificador: a.identificador,
            loteId: l.id,
            loteNombre: l.nombre,
            peso: p.peso,
            fecha: p.fecha,
            ganancia: prev == null ? null : p.peso - prev.peso,
            dias: prev == null ? null : _diasCalendario(prev.fecha, p.fecha),
            pesoCompra: a.pesoCompra,
            precioKgCompra: a.precioKgCompra,
            fechaCompra: a.fechaCompra,
          ),
        ));
      }
      // Lo último digitado arriba.
      resultado.sort((x, y) => y.$1.compareTo(x.$1));
      return [for (final r in resultado) r.$2];
    });
  }

  /// Stream con el historial completo de pesajes de un animal, en orden
  /// cronológico (más antiguo primero), cada uno con su ganancia respecto al
  /// pesaje anterior y los días transcurridos.
  Stream<List<PesajeHistorial>> observarHistorial(String animalId) {
    final consulta = db.select(db.pesajes)
      ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.fecha)]);

    return consulta.watch().asyncMap((filas) async {
      // Quién digitó cada uno: solo hace falta cuando se digitó otro día.
      final quienes = {
        for (final p in filas)
          if (p.registradoPor != null && !mismoDia(p.createdAt, p.fecha))
            p.registradoPor!,
      };
      final nombres = <String, String>{};
      if (quienes.isNotEmpty) {
        final usuarios = await (db.select(
          db.usuarios,
        )..where((t) => t.id.isIn(quienes))).get();
        for (final u in usuarios) {
          // Sin nombre, la parte del correo antes de la @: el correo entero
          // no cabe en la columna de la fecha.
          final nombre = (u.nombre?.trim().isNotEmpty ?? false)
              ? u.nombre!.trim()
              : u.email?.split('@').first;
          if (nombre != null) nombres[u.id] = nombre;
        }
      }

      final resultado = <PesajeHistorial>[];
      for (var i = 0; i < filas.length; i++) {
        final p = filas[i];
        final prev = i == 0 ? null : filas[i - 1];
        final tarde = !mismoDia(p.createdAt, p.fecha);
        resultado.add(
          PesajeHistorial(
            id: p.id,
            fecha: p.fecha,
            peso: p.peso,
            ganancia: prev == null ? null : p.peso - prev.peso,
            dias: prev == null ? null : _diasCalendario(prev.fecha, p.fecha),
            digitadoEl: tarde ? p.createdAt : null,
            digitadoPor: tarde ? nombres[p.registradoPor] : null,
          ),
        );
      }
      return resultado;
    });
  }

  /// Stream con el resumen del lote por jornadas de pesaje (D-01: se agrupa
  /// por fecha de calendario). Cada período compara cada animal contra su
  /// propio pesaje anterior. Orden cronológico (más antiguo primero).
  ///
  /// Incluye los pesajes de los animales que están HOY en el lote (no
  /// borrados); ver D-05 para el historial de movimientos entre lotes.
  Stream<List<PeriodoLote>> observarResumenLote(String loteId) {
    final consulta =
        db.select(db.pesajes).join([
          innerJoin(db.animales, db.animales.id.equalsExp(db.pesajes.animalId)),
        ])..where(
          db.animales.loteId.equals(loteId) &
              db.animales.deletedAt.isNull() &
              db.pesajes.deletedAt.isNull(),
        );

    return consulta.watch().map((filas) {
      final pesajes = filas.map((fila) {
        final p = fila.readTable(db.pesajes);
        return (animalId: p.animalId, fecha: p.fecha, peso: p.peso);
      }).toList();
      return resumenPorPeriodos(pesajes);
    });
  }

  /// Stream con el historial de pesos de TODOS los lotes de la finca, para
  /// compararlos en Análisis. Una sola consulta para toda la finca y luego se
  /// agrupa en memoria: pedir el resumen lote por lote haría N consultas.
  ///
  /// Incluye los lotes sin pesajes (con la lista de períodos vacía) para que en
  /// pantalla se vea que existen y que les falta pesar.
  Stream<List<ResumenPesosLote>> observarResumenPesosFinca(String fincaId) {
    final consulta =
        db.select(db.pesajes).join([
          innerJoin(db.animales, db.animales.id.equalsExp(db.pesajes.animalId)),
        ])..where(
          db.animales.fincaId.equals(fincaId) &
              db.animales.deletedAt.isNull() &
              db.pesajes.deletedAt.isNull(),
        );

    return consulta.watch().asyncMap((filas) async {
      final porLote = <String, List<PesajeDeAnimal>>{};
      for (final fila in filas) {
        final p = fila.readTable(db.pesajes);
        final a = fila.readTable(db.animales);
        porLote.putIfAbsent(a.loteId, () => []).add((
          animalId: p.animalId,
          fecha: p.fecha,
          peso: p.peso,
        ));
      }

      final lotes =
          await (db.select(db.lotes)
                ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
                ..orderBy([
                  (t) => OrderingTerm.asc(t.numero),
                  (t) => OrderingTerm.asc(t.nombre),
                ]))
              .get();

      return [
        for (final l in lotes)
          ResumenPesosLote(
            lote: l,
            periodos: resumenPorPeriodos(porLote[l.id] ?? const []),
          ),
      ];
    });
  }

  /// Devuelve el peso del pesaje más reciente de un animal (o null si no tiene
  /// ninguno todavía). Sirve para calcular la ganancia respecto al anterior.
  /// Cuándo entró el animal a la finca. **No** es `createdAt`: la fila se crea
  /// cuando el ganadero lo registra, que puede ser meses después de comprarlo.
  /// Manda la fecha de compra; si no se digitó, el primer movimiento a un lote;
  /// y de último recurso sí, cuándo se creó la fila.
  ///
  /// Regla única compartida con el prorrateo de gastos fijos
  /// (`GastosFijosRepository.estanciaDe`), para que la ficha del animal y su
  /// economía no se contradigan.
  Future<DateTime> fechaIngreso(AnimalRow animal) async {
    if (animal.fechaCompra != null) return animal.fechaCompra!;
    final primerMovimiento =
        await (db.select(db.movimientosLote)
              ..where(
                (t) => t.animalId.equals(animal.id) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    return fechaIngresoCon(animal, primerMovimiento?.fecha);
  }

  /// La MISMA regla de [fechaIngreso], pero cuando el primer movimiento ya
  /// se tiene a mano. La usan los cálculos de finca entera (Análisis
  /// financiero, prorrateo de gastos fijos), que traen los movimientos de
  /// todos los animales de una sola vez en vez de uno por uno.
  ///
  /// Existe para que esos cálculos no copien la regla: si algún día cambia,
  /// cambia acá y cambia en todo lado.
  static DateTime fechaIngresoCon(
    AnimalRow animal,
    DateTime? primerMovimiento,
  ) => animal.fechaCompra ?? primerMovimiento ?? animal.createdAt;

  /// Peso del PRIMER pesaje del animal (el de entrada). Sirve como peso de
  /// compra cuando el ganadero le pone precio a un animal que se había
  /// registrado como nacido en la finca y nunca tuvo `pesoCompra`.
  Future<double?> primerPeso(String animalId) async {
    final fila =
        await (db.select(db.pesajes)
              ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    return fila?.peso;
  }

  Future<double?> ultimoPeso(String animalId) async {
    final fila =
        await (db.select(db.pesajes)
              ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    return fila?.peso;
  }

  /// Mueve un animal a otro lote y registra el movimiento (D-05). Queda
  /// pendiente para sincronizar.
  ///
  /// [fecha] es el día en que de verdad se movió (hoy si no se dice). Cuenta
  /// para la dieta: hasta ese día come la del lote viejo, desde ese día la
  /// del nuevo. No puede ser antes de que entrara ni antes de su último
  /// movimiento, porque partiría en dos un período que ya pasó.
  Future<void> moverAnimalDeLote({
    required String animalId,
    required String nuevoLoteId,
    DateTime? fecha,
  }) async {
    final ahora = DateTime.now();
    final dia = fecha ?? ahora;
    final animal = await _reglas.desdeElIngreso(animalId, dia, hoy: ahora);
    if (animal.loteId == nuevoLoteId) return;

    final ultimo = await _ultimoMovimiento(animalId);
    if (ultimo != null && soloDia(dia).isBefore(soloDia(ultimo.fecha))) {
      throw FechaInvalidaException(
        'El animal ${animal.identificador} cambió de lote el '
        '${fechaCorta(ultimo.fecha)}: el nuevo cambio no puede ser antes.',
      );
    }
    var cuando = momentoDe(dia, ahora: ahora);
    // Mismo día que el movimiento anterior: que quede después de ese.
    if (ultimo != null && !cuando.isAfter(ultimo.fecha)) {
      cuando = ultimo.fecha.add(const Duration(minutes: 1));
    }

    await db.transaction(() async {
      await (db.update(db.animales)..where((t) => t.id.equals(animalId))).write(
        AnimalesCompanion(
          loteId: Value(nuevoLoteId),
          updatedAt: Value(ahora),
          pendiente: const Value(true),
        ),
      );
      await db
          .into(db.movimientosLote)
          .insert(
            MovimientosLoteCompanion.insert(
              id: _uuid.v4(),
              animalId: animalId,
              loteOrigen: Value(animal.loteId),
              loteDestino: nuevoLoteId,
              fecha: cuando,
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
    });
  }

  Future<MovimientoLoteRow?> _ultimoMovimiento(String animalId) {
    return (db.select(db.movimientosLote)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Corrige el lote que se escogió mal al dar de alta el animal.
  ///
  /// Si el animal no se ha movido nunca, el error es del alta: se cambia el
  /// lote de entrada y no se inventa un movimiento (si no, la dieta del lote
  /// equivocado le quedaría cobrada desde el ingreso hasta hoy). Si ya tenía
  /// movimientos, es un cambio de lote normal, con la fecha [fecha].
  Future<void> corregirLote({
    required String animalId,
    required String nuevoLoteId,
    DateTime? fecha,
  }) async {
    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals(animalId))).getSingle();
    if (animal.loteId == nuevoLoteId) return;
    final movimientos = await (db.select(
      db.movimientosLote,
    )..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())).get();
    // Ya se había movido (o es un dato viejo sin movimiento de entrada): es
    // un cambio de lote normal.
    if (movimientos.length != 1) {
      await moverAnimalDeLote(
        animalId: animalId,
        nuevoLoteId: nuevoLoteId,
        fecha: fecha,
      );
      return;
    }

    final ahora = DateTime.now();
    await db.transaction(() async {
      await (db.update(db.animales)..where((t) => t.id.equals(animalId))).write(
        AnimalesCompanion(
          loteId: Value(nuevoLoteId),
          updatedAt: Value(ahora),
          pendiente: const Value(true),
        ),
      );
      if (movimientos.isNotEmpty) {
        await (db.update(
          db.movimientosLote,
        )..where((t) => t.id.equals(movimientos.single.id))).write(
          MovimientosLoteCompanion(
            loteDestino: Value(nuevoLoteId),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }
    });
  }

  /// Cambia el día en que el animal entró a la finca: mueve la fecha de
  /// compra y la de su primer movimiento de lote, que son las que mandan el
  /// arranque de la dieta y de los gastos fijos.
  ///
  /// No puede quedar después de su primer pesaje, de su primer cambio de
  /// lote, de su primera sanidad ni de su venta: el animal no puede haber
  /// sido pesado, movido o vacunado antes de llegar.
  Future<void> cambiarFechaIngreso({
    required String animalId,
    required DateTime fecha,
  }) async {
    final ahora = DateTime.now();
    _reglas.noFutura(fecha, hoy: ahora);
    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals(animalId))).getSingle();

    final movimientos =
        await (db.select(db.movimientosLote)
              ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
            .get();
    final primerPesaje =
        await (db.select(db.pesajes)
              ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    final primeraSanidad =
        await (db.select(db.eventosSanitarios)
              ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    final venta =
        await (db.select(db.ventas)
              ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();

    final topes = <(DateTime, String)>[
      if (primerPesaje != null) (primerPesaje.fecha, 'su primer pesaje'),
      if (movimientos.length > 1) (movimientos[1].fecha, 'un cambio de lote'),
      if (primeraSanidad != null) (primeraSanidad.fecha, 'sanidad aplicada'),
      if (venta != null) (venta.fecha, 'su venta'),
    ];
    for (final (tope, que) in topes) {
      if (soloDia(fecha).isAfter(soloDia(tope))) {
        throw FechaInvalidaException(
          'El animal ${animal.identificador} tiene $que el ${fechaCorta(tope)}: '
          'no pudo haber entrado después.',
        );
      }
    }

    var cuando = momentoDe(fecha, ahora: ahora);
    // Mismo día que su primer pesaje: la entrada no puede quedar después.
    if (primerPesaje != null &&
        mismoDia(cuando, primerPesaje.fecha) &&
        cuando.isAfter(primerPesaje.fecha)) {
      cuando = primerPesaje.fecha;
    }

    await db.transaction(() async {
      if (animal.fechaCompra != null) {
        await (db.update(
          db.animales,
        )..where((t) => t.id.equals(animalId))).write(
          AnimalesCompanion(
            fechaCompra: Value(cuando),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }
      if (movimientos.isNotEmpty) {
        await (db.update(
          db.movimientosLote,
        )..where((t) => t.id.equals(movimientos.first.id))).write(
          MovimientosLoteCompanion(
            fecha: Value(cuando),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }
    });
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

  /// Pesaje de hoy (día de calendario) del animal, si existe.
  Future<PesajeRow?> pesajeDeHoy(String animalId, {DateTime? dia}) async {
    final base = dia ?? DateTime.now();
    final inicio = DateTime(base.year, base.month, base.day);
    final fin = inicio.add(const Duration(days: 1));
    return (db.select(db.pesajes)
          ..where(
            (t) =>
                t.animalId.equals(animalId) &
                t.deletedAt.isNull() &
                t.fecha.isBiggerOrEqualValue(inicio) &
                t.fecha.isSmallerThanValue(fin),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Corrige el peso de un pesaje existente (mismo día / oro: no duplicar).
  Future<void> actualizarPesaje({
    required String pesajeId,
    required double peso,
  }) async {
    final ahora = DateTime.now();
    await (db.update(db.pesajes)..where((t) => t.id.equals(pesajeId))).write(
      PesajesCompanion(
        peso: Value(peso),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  /// Corrige un pesaje desde la hoja de vida: el peso y/o el día.
  ///
  /// El día nuevo respeta las mismas reglas que un pesaje nuevo (no futuro,
  /// no antes de que el animal entrara) y no puede caer en un día que ya
  /// tiene otro pesaje: un animal, un peso por día.
  Future<void> editarPesaje({
    required String pesajeId,
    required double peso,
    required DateTime fecha,
  }) async {
    final ahora = DateTime.now();
    final actual = await (db.select(
      db.pesajes,
    )..where((t) => t.id.equals(pesajeId))).getSingle();
    final animal = await _reglas.desdeElIngreso(
      actual.animalId,
      fecha,
      hoy: ahora,
    );
    final otro = await pesajeDeHoy(actual.animalId, dia: fecha);
    if (otro != null && otro.id != pesajeId) {
      throw FechaInvalidaException(
        '${animal.identificador} ya tiene un pesaje el ${fechaCorta(fecha)} '
        '(${_kg(otro.peso)} kg): corregí ese.',
      );
    }
    final cuando = mismoDia(fecha, actual.fecha)
        ? actual.fecha
        : momentoDe(fecha, ahora: ahora);
    await (db.update(db.pesajes)..where((t) => t.id.equals(pesajeId))).write(
      PesajesCompanion(
        peso: Value(peso),
        fecha: Value(cuando),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  static String _kg(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);

  /// Registra un pesaje en la FECHA que elija el usuario: sirve para pasar a
  /// la app los pesajes que trae anotados en el cuaderno.
  ///
  /// Si ese día ya tiene un pesaje, lo CORRIGE en vez de agregar otro (la
  /// misma regla del pesaje del día: un animal, un peso por día). Devuelve
  /// true cuando corrigió uno que ya existía, para poder avisarlo.
  ///
  /// Un día que no es hoy se guarda al mediodía (ver [momentoDe]).
  Future<bool> registrarPesajeEnFecha({
    required String animalId,
    required double peso,
    required DateTime fecha,
    required String registradoPor,
  }) async {
    final ahora = DateTime.now();
    await _reglas.desdeElIngreso(animalId, fecha, hoy: ahora);
    final existente = await pesajeDeHoy(animalId, dia: fecha);
    if (existente != null) {
      await actualizarPesaje(pesajeId: existente.id, peso: peso);
      return true;
    }

    await db
        .into(db.pesajes)
        .insert(
          PesajesCompanion.insert(
            id: _uuid.v4(),
            animalId: animalId,
            peso: peso,
            fecha: momentoDe(fecha, ahora: ahora),
            registradoPor: Value(registradoPor),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
    await _completarCompraConPrimerPeso(animalId);
    return false;
  }

  /// Registra un pesaje para un animal existente, el día [fecha] (hoy si no
  /// se dice otra cosa).
  Future<void> agregarPesaje({
    required String animalId,
    required double peso,
    required String registradoPor,
    DateTime? fecha,
  }) async {
    final ahora = DateTime.now();
    final dia = fecha ?? ahora;
    await _reglas.desdeElIngreso(animalId, dia, hoy: ahora);
    await db
        .into(db.pesajes)
        .insert(
          PesajesCompanion.insert(
            id: _uuid.v4(),
            animalId: animalId,
            peso: peso,
            fecha: momentoDe(dia, ahora: ahora),
            registradoPor: Value(registradoPor),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
    await _completarCompraConPrimerPeso(animalId);
  }

  /// Un animal que se compró por MONTO TOTAL y entró sin pesar: con su
  /// primer pesaje ya se sabe el peso de compra, y el ₡/kg sale de dividir
  /// el monto entre esos kilos.
  Future<void> _completarCompraConPrimerPeso(String animalId) async {
    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals(animalId))).getSingle();
    final total = animal.precioCompra;
    if (total == null || total <= 0 || animal.pesoCompra != null) return;
    final peso = await primerPeso(animalId);
    if (peso == null || peso <= 0) return;
    await (db.update(db.animales)..where((t) => t.id.equals(animalId))).write(
      AnimalesCompanion(
        pesoCompra: Value(peso),
        precioKgCompra: Value(total / peso),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }
}
