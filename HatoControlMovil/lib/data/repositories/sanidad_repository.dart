import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../estadisticas/estadisticas_sanidad.dart';
import '../local/database.dart';
import 'medicamentos_repository.dart';
import 'reglas_de_fechas.dart';

/// Tipos de evento sanitario (legado + oro).
abstract final class TipoEventoSanitario {
  static const vacuna = 'vacuna';
  static const medicamento = 'medicamento';
  static const desparasitacion = 'desparasitacion';
  static const otro = 'otro';

  static const todos = [vacuna, medicamento, desparasitacion, otro];

  static String etiqueta(String tipo) => switch (tipo) {
    vacuna => 'Vacuna',
    medicamento => 'Medicamento',
    desparasitacion => 'Desparasitación',
    otro => 'Otro',
    _ => tipo,
  };
}

/// Lo que pasó al aplicar medicamentos a un lote entero (ver
/// [SanidadRepository.aplicarMedicamentoALote]).
class ResultadoAplicacionLote {
  const ResultadoAplicacionLote({
    required this.animales,
    required this.aplicadas,
    required this.yaLoTenian,
    required this.entraronDespues,
    required this.sinPeso,
  });

  /// Animales activos del lote.
  final int animales;

  /// Aplicaciones nuevas (animal × medicamento).
  final int aplicadas;

  /// Aplicaciones que se saltaron porque ese día ya estaban.
  final int yaLoTenian;

  /// Aretes de los que entraron a la finca después de la fecha.
  final List<String> entraronDespues;

  /// Aretes sin ningún peso, a los que no se les pudo calcular la dosis.
  final List<String> sinPeso;
}

class AnimalEnRetiroException implements Exception {
  const AnimalEnRetiroException(this.retiroHasta);
  final DateTime retiroHasta;
}

/// Acceso local a eventos sanitarios y retiro. Sync corre por separado.
class SanidadRepository {
  SanidadRepository(this.db, {MedicamentosRepository? medicamentosRepository})
    : _medicamentos = medicamentosRepository ?? MedicamentosRepository(db),
      _reglas = ReglasDeFechas(db);

  final AppDatabase db;
  final MedicamentosRepository _medicamentos;
  final ReglasDeFechas _reglas;
  final _uuid = const Uuid();

  Stream<List<EventoSanitarioRow>> observarHistorial(String animalId) {
    return (db.select(db.eventosSanitarios)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .watch();
  }

  /// Fecha fin de retiro vigente del animal (null si no está en retiro).
  ///
  /// [hoy] es el día contra el que se mira: la fecha de la venta cuando se
  /// vende con fecha atrás. Solo cuentan los medicamentos aplicados hasta ese
  /// día; lo que se aplicó después no podía bloquear una venta anterior.
  Future<DateTime?> retiroHasta(String animalId, {DateTime? hoy}) async {
    final ahora = hoy ?? DateTime.now();
    final dia = DateTime(ahora.year, ahora.month, ahora.day);
    final finDelDia = diaSiguiente(dia);
    final eventos =
        await (db.select(db.eventosSanitarios)..where(
              (t) =>
                  t.animalId.equals(animalId) &
                  t.deletedAt.isNull() &
                  t.retiroHasta.isNotNull() &
                  t.fecha.isSmallerThanValue(finDelDia),
            ))
            .get();
    DateTime? maxFin;
    for (final e in eventos) {
      final fin = e.retiroHasta;
      if (fin == null) continue;
      if (!estaEnRetiro(fin, hoy: dia)) continue;
      if (maxFin == null || fin.isAfter(maxFin)) maxFin = fin;
    }
    return maxFin;
  }

  Stream<DateTime?> observarRetiroHasta(String animalId) {
    return observarHistorial(animalId).asyncMap((_) => retiroHasta(animalId));
  }

  Future<List<String>> sugerenciasProducto(String fincaId) async {
    final filas =
        await (db.select(db.eventosSanitarios).join([
              innerJoin(
                db.animales,
                db.animales.id.equalsExp(db.eventosSanitarios.animalId),
              ),
            ])..where(
              db.animales.fincaId.equals(fincaId) &
                  db.eventosSanitarios.deletedAt.isNull(),
            ))
            .get();
    final productos = filas
        .map((f) => f.readTable(db.eventosSanitarios).producto)
        .toSet()
        .toList();
    productos.sort();
    return productos;
  }

  /// Aplica un medicamento del catálogo con dosis/costo/retiro calculados.
  ///
  /// [fecha] es el día en que se aplicó (hoy si no se dice): el retiro se
  /// cuenta desde ese día, aunque se digite después.
  Future<void> aplicarMedicamento({
    required String animalId,
    required String medicamentoId,
    required double pesoKg,
    DateTime? fecha,
    String? responsableId,
  }) async {
    final med = await _medicamentos.porId(medicamentoId);
    if (med == null) {
      throw StateError('Medicamento no encontrado: $medicamentoId');
    }
    final digitado = DateTime.now();
    final dia = fecha ?? digitado;
    await _reglas.desdeElIngreso(animalId, dia, hoy: digitado);
    await _insertarAplicacion(
      animalId: animalId,
      med: med,
      pesoKg: pesoKg,
      dia: dia,
      digitado: digitado,
      responsableId: responsableId,
    );
  }

  /// Aplica uno o varios medicamentos del catálogo a todos los animales
  /// activos del lote, de un solo tiro, el día [fecha] (hoy si no se dice).
  ///
  /// La dosis de cada animal sale de su último peso hasta ese día. Se salta:
  /// - el animal que ese mismo día ya tiene ese mismo medicamento (así se
  ///   puede terminar un lote que quedó a medias sin duplicar a nadie);
  /// - el que entró a la finca después de esa fecha;
  /// - el que no tiene ningún peso, si la dosis va por peso.
  Future<ResultadoAplicacionLote> aplicarMedicamentoALote({
    required String loteId,
    required List<String> medicamentoIds,
    DateTime? fecha,
    String? responsableId,
  }) async {
    final digitado = DateTime.now();
    final dia = fecha ?? digitado;
    _reglas.noFutura(dia, hoy: digitado);
    final inicio = soloDia(dia);
    final finDelDia = diaSiguiente(inicio);

    final meds = <MedicamentoRow>[];
    for (final id in medicamentoIds) {
      final med = await _medicamentos.porId(id);
      if (med == null) throw StateError('Medicamento no encontrado: $id');
      meds.add(med);
    }
    final animales =
        await (db.select(db.animales)..where(
              (t) =>
                  t.loteId.equals(loteId) &
                  t.deletedAt.isNull() &
                  t.estado.equals('activo'),
            ))
            .get();

    var aplicadas = 0;
    var yaLoTenian = 0;
    final entraronDespues = <String>[];
    final sinPeso = <String>[];
    await db.transaction(() async {
      for (final a in animales) {
        if (soloDia(dia).isBefore(soloDia(await _reglas.primerDia(a)))) {
          entraronDespues.add(a.identificador);
          continue;
        }
        final peso = await _pesoAl(a, finDelDia);
        for (final med in meds) {
          final yaTiene =
              await (db.select(db.eventosSanitarios)
                    ..where(
                      (t) =>
                          t.animalId.equals(a.id) &
                          t.medicamentoId.equals(med.id) &
                          t.deletedAt.isNull() &
                          t.fecha.isBiggerOrEqualValue(inicio) &
                          t.fecha.isSmallerThanValue(finDelDia),
                    )
                    ..limit(1))
                  .getSingleOrNull();
          if (yaTiene != null) {
            yaLoTenian++;
            continue;
          }
          if (peso == null &&
              med.tipoAplicacion == TipoAplicacionMedicamento.porPeso) {
            if (!sinPeso.contains(a.identificador)) {
              sinPeso.add(a.identificador);
            }
            continue;
          }
          await _insertarAplicacion(
            animalId: a.id,
            med: med,
            pesoKg: peso ?? 0,
            dia: dia,
            digitado: digitado,
            responsableId: responsableId,
          );
          aplicadas++;
        }
      }
    });
    return ResultadoAplicacionLote(
      animales: animales.length,
      aplicadas: aplicadas,
      yaLoTenian: yaLoTenian,
      entraronDespues: entraronDespues,
      sinPeso: sinPeso,
    );
  }

  /// Último peso del animal antes de [hasta]; si no tiene pesajes hasta ese
  /// día, el primero que tenga, y si no, el de compra.
  Future<double?> _pesoAl(AnimalRow animal, DateTime hasta) async {
    final antes =
        await (db.select(db.pesajes)
              ..where(
                (t) =>
                    t.animalId.equals(animal.id) &
                    t.deletedAt.isNull() &
                    t.fecha.isSmallerThanValue(hasta),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    if (antes != null) return antes.peso;
    final despues =
        await (db.select(db.pesajes)
              ..where(
                (t) => t.animalId.equals(animal.id) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    return despues?.peso ?? animal.pesoCompra;
  }

  Future<void> _insertarAplicacion({
    required String animalId,
    required MedicamentoRow med,
    required double pesoKg,
    required DateTime dia,
    required DateTime digitado,
    String? responsableId,
  }) async {
    final dosis = _medicamentos.dosisParaPeso(med, pesoKg);
    final ahora = momentoDe(dia, ahora: digitado);
    final retiro = fechaFinRetiro(ahora, med.diasRetiro);

    await db
        .into(db.eventosSanitarios)
        .insert(
          EventosSanitariosCompanion.insert(
            id: _uuid.v4(),
            animalId: animalId,
            tipo: TipoEventoSanitario.medicamento,
            producto: med.nombre,
            dosis: Value(dosis.etiquetaDosis),
            fecha: ahora,
            responsableId: Value(responsableId),
            costo: Value(dosis.costoUso),
            medicamentoId: Value(med.id),
            mlAplicados: Value(dosis.mlAplicados),
            aplicaciones: Value(dosis.aplicaciones),
            diasRetiro: Value(med.diasRetiro > 0 ? med.diasRetiro : null),
            retiroHasta: Value(retiro),
            createdAt: digitado,
            updatedAt: digitado,
            pendiente: const Value(true),
          ),
        );
  }

  Future<void> registrarEvento({
    required String animalId,
    required String tipo,
    required String producto,
    String? dosis,
    DateTime? fecha,
    String? responsableId,
    String? observaciones,
    double? costo,
    int? diasRetiro,
  }) async {
    final ahora = fecha ?? DateTime.now();
    final retiro = diasRetiro == null
        ? null
        : fechaFinRetiro(ahora, diasRetiro);
    await db
        .into(db.eventosSanitarios)
        .insert(
          EventosSanitariosCompanion.insert(
            id: _uuid.v4(),
            animalId: animalId,
            tipo: tipo,
            producto: producto,
            dosis: Value(dosis),
            fecha: ahora,
            responsableId: Value(responsableId),
            observaciones: Value(observaciones),
            costo: Value(costo),
            diasRetiro: Value(diasRetiro),
            retiroHasta: Value(retiro),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
  }

  Future<int> registrarEventoEnLote({
    required String loteId,
    required String tipo,
    required String producto,
    String? dosis,
    DateTime? fecha,
    String? responsableId,
    String? observaciones,
    double? costo,
  }) async {
    final animales =
        await (db.select(db.animales)..where(
              (t) =>
                  t.loteId.equals(loteId) &
                  t.deletedAt.isNull() &
                  t.estado.equals('activo'),
            ))
            .get();
    if (animales.isEmpty) return 0;

    final ahora = fecha ?? DateTime.now();
    await db.transaction(() async {
      for (final a in animales) {
        await db
            .into(db.eventosSanitarios)
            .insert(
              EventosSanitariosCompanion.insert(
                id: _uuid.v4(),
                animalId: a.id,
                tipo: tipo,
                producto: producto,
                dosis: Value(dosis),
                fecha: ahora,
                responsableId: Value(responsableId),
                observaciones: Value(observaciones),
                costo: Value(costo),
                createdAt: ahora,
                updatedAt: ahora,
                pendiente: const Value(true),
              ),
            );
      }
    });
    return animales.length;
  }

  Future<EventoSanitarioRow?> ultimoEvento(String animalId) async {
    return (db.select(db.eventosSanitarios)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> eliminarEvento(String eventoId) async {
    await (db.update(
      db.eventosSanitarios,
    )..where((t) => t.id.equals(eventoId))).write(
      EventosSanitariosCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }
}
