import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Dieta vigente de un lote con su nombre y costo congelado al asignar.
class DietaVigenteLote {
  const DietaVigenteLote({required this.asignacion, required this.dieta});

  final LoteDietaRow asignacion;
  final DietaRow dieta;
}

/// Dieta recibida por un animal vía los lotes donde estuvo (D-05).
class DietaRecibidaAnimal {
  const DietaRecibidaAnimal({
    required this.loteNombre,
    required this.dietaNombre,
    required this.desde,
    required this.hasta,
    required this.costoAnimalDia,
  });

  final String loteNombre;
  final String dietaNombre;
  final DateTime desde;
  final DateTime? hasta;
  final double costoAnimalDia;
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

  /// El ganadero digita [costoKg] (₡ por kilo de alimento) y [kgAnimalDia]
  /// (kilos que recibe cada animal por día). De ahí sale el costo por animal:
  /// día = ₡/kg × kg/día, semana = día × 7.
  /// [ingredientes] son solo nombres informativos (costo de ingrediente = 0).
  Future<void> crearDieta({
    required String fincaId,
    required String nombre,
    String? descripcion,
    required double costoKg,
    required double kgAnimalDia,
    String moneda = 'CRC',
    List<String> ingredientes = const [],
  }) async {
    final ahora = DateTime.now();
    final costoDia = costoKg * kgAnimalDia;
    final costoSemana = costoDia * 7;
    final dietaId = _uuid.v4();
    await db.transaction(() async {
      await db
          .into(db.dietas)
          .insert(
            DietasCompanion.insert(
              id: dietaId,
              fincaId: fincaId,
              nombre: nombre,
              descripcion: Value(descripcion),
              costoKg: Value(costoKg),
              kgAnimalDia: Value(kgAnimalDia),
              costoAnimalSemana: Value(costoSemana),
              costoAnimalDia: costoDia,
              moneda: Value(moneda),
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
      for (final nombreIng in ingredientes) {
        final n = nombreIng.trim();
        if (n.isEmpty) continue;
        await db
            .into(db.dietaIngredientes)
            .insert(
              DietaIngredientesCompanion.insert(
                id: _uuid.v4(),
                dietaId: dietaId,
                nombre: n,
                costoAnimalDia: const Value(0),
                createdAt: ahora,
                updatedAt: ahora,
                pendiente: const Value(true),
              ),
            );
      }
    });
  }

  Stream<List<DietaIngredienteRow>> observarIngredientes(String dietaId) {
    return (db.select(db.dietaIngredientes)
          ..where((t) => t.dietaId.equals(dietaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  Future<List<DietaIngredienteRow>> listarIngredientes(String dietaId) {
    return (db.select(db.dietaIngredientes)
          ..where((t) => t.dietaId.equals(dietaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .get();
  }

  /// Reemplaza ingredientes (solo nombres). No toca el costo de la dieta.
  Future<void> reemplazarIngredientes({
    required String dietaId,
    required List<String> ingredientes,
  }) async {
    final ahora = DateTime.now();
    await db.transaction(() async {
      final viejos = await (db.select(
        db.dietaIngredientes,
      )..where((t) => t.dietaId.equals(dietaId) & t.deletedAt.isNull())).get();
      for (final v in viejos) {
        await (db.update(
          db.dietaIngredientes,
        )..where((t) => t.id.equals(v.id))).write(
          DietaIngredientesCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }
      for (final nombreIng in ingredientes) {
        final n = nombreIng.trim();
        if (n.isEmpty) continue;
        await db
            .into(db.dietaIngredientes)
            .insert(
              DietaIngredientesCompanion.insert(
                id: _uuid.v4(),
                dietaId: dietaId,
                nombre: n,
                costoAnimalDia: const Value(0),
                createdAt: ahora,
                updatedAt: ahora,
                pendiente: const Value(true),
              ),
            );
      }
    });
  }

  Future<void> editarDieta({
    required String dietaId,
    required String nombre,
    String? descripcion,
    required double costoKg,
    required double kgAnimalDia,
    String moneda = 'CRC',
  }) async {
    final costoDia = costoKg * kgAnimalDia;
    await (db.update(db.dietas)..where((t) => t.id.equals(dietaId))).write(
      DietasCompanion(
        nombre: Value(nombre),
        descripcion: Value(descripcion),
        costoKg: Value(costoKg),
        kgAnimalDia: Value(kgAnimalDia),
        costoAnimalSemana: Value(costoDia * 7),
        costoAnimalDia: Value(costoDia),
        moneda: Value(moneda),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  /// Cierra la dieta vigente del lote (queda sin dieta). El historial se conserva.
  Future<void> quitarDietaDeLote(String loteId) async {
    final ahora = DateTime.now();
    final vigente =
        await (db.select(db.loteDietas)..where(
              (t) =>
                  t.loteId.equals(loteId) &
                  t.hasta.isNull() &
                  t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (vigente == null) return;
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

  /// Dietas que recibió un animal según los lotes por los que pasó y las
  /// asignaciones vigentes en cada periodo.
  Stream<List<DietaRecibidaAnimal>> observarDietasRecibidas(String animalId) {
    final movimientos = db.select(db.movimientosLote)
      ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.fecha)]);

    return movimientos.watch().asyncMap((movs) async {
      if (movs.isEmpty) return const <DietaRecibidaAnimal>[];

      final resultado = <DietaRecibidaAnimal>[];
      for (var i = 0; i < movs.length; i++) {
        final mov = movs[i];
        final periodoFin = i + 1 < movs.length ? movs[i + 1].fecha : null;
        final asignaciones =
            await (db.select(db.loteDietas)..where(
                  (t) =>
                      t.loteId.equals(mov.loteDestino) &
                      t.deletedAt.isNull() &
                      t.desde.isSmallerOrEqualValue(
                        periodoFin ?? DateTime.now(),
                      ),
                ))
                .get();

        for (final asig in asignaciones) {
          final finAsig = asig.hasta;
          if (finAsig != null && finAsig.isBefore(mov.fecha)) continue;
          if (periodoFin != null &&
              finAsig != null &&
              finAsig.isBefore(periodoFin) &&
              finAsig.isBefore(mov.fecha)) {
            continue;
          }
          final dieta = await (db.select(
            db.dietas,
          )..where((t) => t.id.equals(asig.dietaId))).getSingleOrNull();
          if (dieta == null || dieta.deletedAt != null) continue;

          final lote = await (db.select(
            db.lotes,
          )..where((t) => t.id.equals(mov.loteDestino))).getSingleOrNull();

          resultado.add(
            DietaRecibidaAnimal(
              loteNombre: lote?.nombre ?? 'Lote',
              dietaNombre: dieta.nombre,
              desde: mov.fecha.isAfter(asig.desde) ? mov.fecha : asig.desde,
              hasta: _finPeriodo(periodoFin, asig.hasta),
              costoAnimalDia: asig.costoAnimalDiaSnapshot,
            ),
          );
        }
      }
      return resultado;
    });
  }

  DateTime? _finPeriodo(DateTime? finMovimiento, DateTime? finAsignacion) {
    if (finMovimiento == null && finAsignacion == null) return null;
    if (finMovimiento == null) return finAsignacion;
    if (finAsignacion == null) return finMovimiento;
    return finMovimiento.isBefore(finAsignacion)
        ? finMovimiento
        : finAsignacion;
  }
}
