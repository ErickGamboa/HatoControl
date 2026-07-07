import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Dieta vigente de un lote con su nombre y costo congelado al asignar.
class DietaVigenteLote {
  const DietaVigenteLote({required this.asignacion, required this.dieta});

  final LoteDietaRow asignacion;
  final DietaRow dieta;
}

/// Acceso local a dietas y asignaciones lote-dieta. Sync corre por separado.
class DietasRepository {
  DietasRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  Stream<List<DietaRow>> observarDietas(String fincaId) {
    return (db.select(db.dietas)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  Future<void> crearDieta({
    required String fincaId,
    required String nombre,
    String? descripcion,
    required double costoAnimalDia,
    String moneda = 'CRC',
  }) async {
    final ahora = DateTime.now();
    await db
        .into(db.dietas)
        .insert(
          DietasCompanion.insert(
            id: _uuid.v4(),
            fincaId: fincaId,
            nombre: nombre,
            descripcion: Value(descripcion),
            costoAnimalDia: costoAnimalDia,
            moneda: Value(moneda),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
  }

  Future<void> editarDieta({
    required String dietaId,
    required String nombre,
    String? descripcion,
    required double costoAnimalDia,
    String moneda = 'CRC',
  }) async {
    await (db.update(db.dietas)..where((t) => t.id.equals(dietaId))).write(
      DietasCompanion(
        nombre: Value(nombre),
        descripcion: Value(descripcion),
        costoAnimalDia: Value(costoAnimalDia),
        moneda: Value(moneda),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  /// Asigna una dieta a un lote: cierra la vigente anterior (si hay) y abre
  /// una nueva con el costo congelado (D-02). Todo en una transacción.
  Future<void> asignarDietaALote({
    required String loteId,
    required String dietaId,
  }) async {
    final dieta = await (db.select(
      db.dietas,
    )..where((t) => t.id.equals(dietaId) & t.deletedAt.isNull())).getSingle();
    final ahora = DateTime.now();

    await db.transaction(() async {
      final vigente =
          await (db.select(db.loteDietas)..where(
                (t) =>
                    t.loteId.equals(loteId) &
                    t.hasta.isNull() &
                    t.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (vigente != null) {
        if (vigente.dietaId == dietaId) return;
        await (db.update(
          db.loteDietas,
        )..where((t) => t.id.equals(vigente.id))).write(
          LoteDietasCompanion(
            hasta: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }

      await db
          .into(db.loteDietas)
          .insert(
            LoteDietasCompanion.insert(
              id: _uuid.v4(),
              loteId: loteId,
              dietaId: dietaId,
              desde: ahora,
              costoAnimalDiaSnapshot: dieta.costoAnimalDia,
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
    });
  }

  /// Stream con la dieta vigente del lote, o null si no tiene asignación.
  Stream<DietaVigenteLote?> observarDietaVigente(String loteId) {
    final consulta = db.select(db.loteDietas)
      ..where(
        (t) =>
            t.loteId.equals(loteId) & t.hasta.isNull() & t.deletedAt.isNull(),
      );

    return consulta.watch().asyncMap((filas) async {
      if (filas.isEmpty) return null;
      final asignacion = filas.first;
      final dieta = await (db.select(
        db.dietas,
      )..where((t) => t.id.equals(asignacion.dietaId))).getSingleOrNull();
      if (dieta == null || dieta.deletedAt != null) return null;
      return DietaVigenteLote(asignacion: asignacion, dieta: dieta);
    });
  }

  /// Historial de asignaciones de dieta de un lote (más reciente primero).
  Stream<List<LoteDietaRow>> observarHistorialDietaLote(String loteId) {
    return (db.select(db.loteDietas)
          ..where((t) => t.loteId.equals(loteId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.desde)]))
        .watch();
  }
}
