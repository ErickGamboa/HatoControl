import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Acceso a los lotes de una finca. Lee y escribe en la base local; la
/// sincronización con Supabase corre por separado (SyncService).
class LotesRepository {
  LotesRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  /// Stream reactivo con los lotes (no borrados) de una finca, ordenados por
  /// número y luego por nombre.
  Stream<List<LoteRow>> observarLotes(String fincaId) {
    return (db.select(db.lotes)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.numero),
            (t) => OrderingTerm.asc(t.nombre),
          ]))
        .watch();
  }

  /// Lista (una sola vez) los lotes activos de una finca, ordenados.
  Future<List<LoteRow>> lotesActivos(String fincaId) {
    return (db.select(db.lotes)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.numero),
            (t) => OrderingTerm.asc(t.nombre),
          ]))
        .get();
  }

  Future<void> crearLote({
    required String fincaId,
    required String nombre,
    int? numero,
  }) async {
    final ahora = DateTime.now();
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: _uuid.v4(),
            fincaId: fincaId,
            nombre: nombre,
            numero: Value(numero),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
  }

  /// Edita el nombre y/o número de un lote. Queda pendiente de sincronizar.
  Future<void> editarLote({
    required String loteId,
    required String nombre,
    int? numero,
  }) async {
    await (db.update(db.lotes)..where((t) => t.id.equals(loteId))).write(
      LotesCompanion(
        nombre: Value(nombre),
        numero: Value(numero),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }
}
