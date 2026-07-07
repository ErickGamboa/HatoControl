import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Tipos de evento sanitario (D-04).
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

/// Acceso local a eventos sanitarios por animal. Sync corre por separado.
class SanidadRepository {
  SanidadRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  /// Historial sanitario de un animal, más reciente primero.
  Stream<List<EventoSanitarioRow>> observarHistorial(String animalId) {
    return (db.select(db.eventosSanitarios)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .watch();
  }

  /// Eventos de los animales de un lote en una fecha (día de calendario).
  Stream<List<EventoSanitarioRow>> observarEventosDelDia({
    required String loteId,
    required DateTime dia,
  }) {
    final inicio = DateTime(dia.year, dia.month, dia.day);
    final fin = inicio.add(const Duration(days: 1));
    final consulta =
        db.select(db.eventosSanitarios).join([
            innerJoin(
              db.animales,
              db.animales.id.equalsExp(db.eventosSanitarios.animalId),
            ),
          ])
          ..where(
            db.animales.loteId.equals(loteId) &
                db.animales.deletedAt.isNull() &
                db.eventosSanitarios.deletedAt.isNull() &
                db.eventosSanitarios.fecha.isBiggerOrEqualValue(inicio) &
                db.eventosSanitarios.fecha.isSmallerThanValue(fin),
          )
          ..orderBy([OrderingTerm.desc(db.eventosSanitarios.fecha)]);

    return consulta.watch().map(
      (filas) => filas.map((f) => f.readTable(db.eventosSanitarios)).toList(),
    );
  }

  /// Productos usados antes en la finca (para sugerencias al registrar).
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

  /// Registra un evento sanitario para un animal.
  Future<void> registrarEvento({
    required String animalId,
    required String tipo,
    required String producto,
    String? dosis,
    DateTime? fecha,
    String? responsableId,
    String? observaciones,
    double? costo,
  }) async {
    final ahora = fecha ?? DateTime.now();
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
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
  }

  /// Aplica el mismo evento a todos los animales activos del lote en una
  /// transacción (modo corral / lote).
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
    final animales = await (db.select(
      db.animales,
    )..where((t) => t.loteId.equals(loteId) & t.deletedAt.isNull())).get();
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

  /// Borrado suave de un evento.
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
