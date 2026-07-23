import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../estadisticas/estadisticas_sanidad.dart';
import '../local/database.dart';
import 'medicamentos_repository.dart';

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

class AnimalEnRetiroException implements Exception {
  const AnimalEnRetiroException(this.retiroHasta);
  final DateTime retiroHasta;
}

/// Acceso local a eventos sanitarios y retiro. Sync corre por separado.
class SanidadRepository {
  SanidadRepository(this.db, {MedicamentosRepository? medicamentosRepository})
    : _medicamentos = medicamentosRepository ?? MedicamentosRepository(db);

  final AppDatabase db;
  final MedicamentosRepository _medicamentos;
  final _uuid = const Uuid();

  Stream<List<EventoSanitarioRow>> observarHistorial(String animalId) {
    return (db.select(db.eventosSanitarios)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .watch();
  }

  /// Fecha fin de retiro vigente del animal (null si no está en retiro).
  Future<DateTime?> retiroHasta(String animalId, {DateTime? hoy}) async {
    final ahora = hoy ?? DateTime.now();
    final dia = DateTime(ahora.year, ahora.month, ahora.day);
    final eventos =
        await (db.select(db.eventosSanitarios)..where(
              (t) =>
                  t.animalId.equals(animalId) &
                  t.deletedAt.isNull() &
                  t.retiroHasta.isNotNull(),
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
    final dosis = _medicamentos.dosisParaPeso(med, pesoKg);
    final ahora = fecha ?? DateTime.now();
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
            medicamentoId: Value(medicamentoId),
            mlAplicados: Value(dosis.mlAplicados),
            aplicaciones: Value(dosis.aplicaciones),
            diasRetiro: Value(med.diasRetiro > 0 ? med.diasRetiro : null),
            retiroHasta: Value(retiro),
            createdAt: ahora,
            updatedAt: ahora,
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

  Future<bool> repetirUltimoEvento({
    required String animalId,
    String? responsableId,
    double? pesoKg,
  }) async {
    final ultimo = await ultimoEvento(animalId);
    if (ultimo == null) return false;
    if (ultimo.medicamentoId != null && pesoKg != null) {
      await aplicarMedicamento(
        animalId: animalId,
        medicamentoId: ultimo.medicamentoId!,
        pesoKg: pesoKg,
        responsableId: responsableId,
      );
      return true;
    }
    await registrarEvento(
      animalId: animalId,
      tipo: ultimo.tipo,
      producto: ultimo.producto,
      dosis: ultimo.dosis,
      observaciones: ultimo.observaciones,
      costo: ultimo.costo,
      diasRetiro: ultimo.diasRetiro,
      responsableId: responsableId,
    );
    return true;
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
