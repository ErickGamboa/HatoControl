import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../estadisticas/estadisticas_economicas.dart';
import '../local/database.dart';
import 'dietas_repository.dart';

/// Estados del animal en inventario activo (D-08).
abstract final class EstadoAnimal {
  static const activo = 'activo';
  static const vendido = 'vendido';
  static const muerto = 'muerto';

  static const activosInventario = [activo];
}

/// Ventas, compra, otros costos y rentabilidad derivada (Module 4).
class VentasRepository {
  VentasRepository(this.db, {DietasRepository? dietasRepository})
    : _dietasRepository = dietasRepository ?? DietasRepository(db);

  final AppDatabase db;
  final DietasRepository _dietasRepository;
  final _uuid = const Uuid();

  Stream<VentaRow?> observarVenta(String animalId) {
    return (db.select(db.ventas)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<CostoOtroRow>> observarOtrosCostos(String animalId) {
    return (db.select(db.costosOtros)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .watch();
  }

  Stream<ResumenEconomicoAnimal> observarResumen(String animalId) {
    final query = db.select(db.animales)
      ..where((t) => t.id.equals(animalId) & t.deletedAt.isNull());
    return query.watchSingle().asyncMap(_resumenDesdeAnimal);
  }

  Future<ResumenEconomicoAnimal> resumenDe(String animalId) async {
    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals(animalId))).getSingle();
    return _resumenDesdeAnimal(animal);
  }

  Future<void> actualizarCompra({
    required String animalId,
    double? precioCompra,
    DateTime? fechaCompra,
  }) async {
    final ahora = DateTime.now();
    await (db.update(db.animales)..where((t) => t.id.equals(animalId))).write(
      AnimalesCompanion(
        precioCompra: Value(precioCompra),
        fechaCompra: Value(fechaCompra),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  Future<void> registrarVenta({
    required String animalId,
    required double precio,
    DateTime? fecha,
    String? comprador,
    String? observaciones,
  }) async {
    final ahora = fecha ?? DateTime.now();
    await db.transaction(() async {
      await db
          .into(db.ventas)
          .insert(
            VentasCompanion.insert(
              id: _uuid.v4(),
              animalId: animalId,
              fecha: ahora,
              precio: precio,
              comprador: Value(comprador),
              observaciones: Value(observaciones),
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
      await (db.update(db.animales)..where((t) => t.id.equals(animalId))).write(
        AnimalesCompanion(
          estado: const Value(EstadoAnimal.vendido),
          updatedAt: Value(ahora),
          pendiente: const Value(true),
        ),
      );
    });
  }

  Future<void> registrarCostoOtro({
    required String animalId,
    required String concepto,
    required double monto,
    DateTime? fecha,
  }) async {
    final ahora = fecha ?? DateTime.now();
    await db
        .into(db.costosOtros)
        .insert(
          CostosOtrosCompanion.insert(
            id: _uuid.v4(),
            animalId: animalId,
            concepto: concepto,
            monto: monto,
            fecha: ahora,
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
  }

  Future<ResumenEconomicoAnimal> _resumenDesdeAnimal(AnimalRow animal) async {
    final dietas = await _dietasRepository
        .observarDietasRecibidas(animal.id)
        .first;
    final periodos = dietas
        .map(
          (d) => PeriodoAlimentacion(
            desde: d.desde,
            hasta: d.hasta,
            costoAnimalDia: d.costoAnimalDia,
          ),
        )
        .toList();

    final eventos = await (db.select(
      db.eventosSanitarios,
    )..where((t) => t.animalId.equals(animal.id) & t.deletedAt.isNull())).get();
    final otros = await (db.select(
      db.costosOtros,
    )..where((t) => t.animalId.equals(animal.id) & t.deletedAt.isNull())).get();
    final venta =
        await (db.select(db.ventas)
              ..where(
                (t) => t.animalId.equals(animal.id) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();

    return calcularResumenEconomico(
      precioCompra: animal.precioCompra,
      periodosAlimentacion: periodos,
      costosSanitarios: eventos.map((e) => e.costo).toList(),
      costosOtros: otros.map((o) => o.monto).toList(),
      precioVenta: venta?.precio,
    );
  }
}
