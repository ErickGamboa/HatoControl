import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../estadisticas/estadisticas_economicas.dart';
import '../estadisticas/estadisticas_sanidad.dart';
import '../local/database.dart';
import 'dietas_repository.dart';
import 'sanidad_repository.dart';

/// Estados del animal en inventario activo (D-08).
abstract final class EstadoAnimal {
  static const activo = 'activo';
  static const vendido = 'vendido';
  static const muerto = 'muerto';

  static const activosInventario = [activo];
}

class ResumenLoteVenta {
  const ResumenLoteVenta({
    required this.lote,
    required this.ventas,
    required this.utilidadTotal,
  });

  final LoteVentaRow lote;
  final List<VentaConAnimal> ventas;
  final double utilidadTotal;
}

class VentaConAnimal {
  const VentaConAnimal({
    required this.venta,
    required this.animal,
    required this.utilidad,
  });

  final VentaRow venta;
  final AnimalRow animal;
  final double? utilidad;
}

/// Ventas y utilidad oro (sin “otros costos” en la fórmula de producto).
class VentasRepository {
  VentasRepository(
    this.db, {
    DietasRepository? dietasRepository,
    SanidadRepository? sanidadRepository,
  }) : _dietasRepository = dietasRepository ?? DietasRepository(db),
       _sanidadRepository = sanidadRepository ?? SanidadRepository(db);

  final AppDatabase db;
  final DietasRepository _dietasRepository;
  final SanidadRepository _sanidadRepository;
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

  Stream<List<ResumenLoteVenta>> observarLotesVenta(String fincaId) {
    return (db.select(db.lotesVenta)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .watch()
        .asyncMap((lotes) async {
          final out = <ResumenLoteVenta>[];
          for (final lote in lotes) {
            final ventas =
                await (db.select(db.ventas)..where(
                      (t) =>
                          t.loteVentaId.equals(lote.id) & t.deletedAt.isNull(),
                    ))
                    .get();
            final items = <VentaConAnimal>[];
            var utilidadTotal = 0.0;
            for (final v in ventas) {
              final animal = await (db.select(
                db.animales,
              )..where((t) => t.id.equals(v.animalId))).getSingle();
              final resumen = await _resumenDesdeAnimal(animal);
              final u = resumen.utilidad ?? 0;
              utilidadTotal += u;
              items.add(
                VentaConAnimal(
                  venta: v,
                  animal: animal,
                  utilidad: resumen.utilidad,
                ),
              );
            }
            out.add(
              ResumenLoteVenta(
                lote: lote,
                ventas: items,
                utilidadTotal: utilidadTotal,
              ),
            );
          }
          return out;
        });
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

  /// Confirma un lote de venta (varios animales). Bloquea si alguno está en retiro.
  Future<String> confirmarLoteVenta({
    required String fincaId,
    required List<({String animalId, double precio, double peso})> items,
    DateTime? fecha,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('La venta no tiene animales');
    }
    for (final item in items) {
      final retiro = await _sanidadRepository.retiroHasta(item.animalId);
      if (retiro != null) {
        throw AnimalEnRetiroException(retiro);
      }
    }

    final ahora = fecha ?? DateTime.now();
    final loteId = _uuid.v4();
    await db.transaction(() async {
      await db
          .into(db.lotesVenta)
          .insert(
            LotesVentaCompanion.insert(
              id: loteId,
              fincaId: fincaId,
              fecha: ahora,
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
      for (final item in items) {
        await db
            .into(db.ventas)
            .insert(
              VentasCompanion.insert(
                id: _uuid.v4(),
                animalId: item.animalId,
                loteVentaId: Value(loteId),
                fecha: ahora,
                precio: item.precio,
                peso: Value(item.peso),
                createdAt: ahora,
                updatedAt: ahora,
                pendiente: const Value(true),
              ),
            );
        await db
            .into(db.pesajes)
            .insert(
              PesajesCompanion.insert(
                id: _uuid.v4(),
                animalId: item.animalId,
                peso: item.peso,
                fecha: ahora,
                createdAt: ahora,
                updatedAt: ahora,
                pendiente: const Value(true),
              ),
            );
        await (db.update(
          db.animales,
        )..where((t) => t.id.equals(item.animalId))).write(
          AnimalesCompanion(
            estado: const Value(EstadoAnimal.vendido),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }
    });
    return loteId;
  }

  /// Venta individual (compat). Prefiere [confirmarLoteVenta].
  Future<void> registrarVenta({
    required String animalId,
    required double precio,
    double? peso,
    DateTime? fecha,
    String? comprador,
    String? observaciones,
    String? loteVentaId,
  }) async {
    final retiro = await _sanidadRepository.retiroHasta(animalId);
    if (retiro != null) {
      throw AnimalEnRetiroException(retiro);
    }
    final ahora = fecha ?? DateTime.now();
    await db.transaction(() async {
      await db
          .into(db.ventas)
          .insert(
            VentasCompanion.insert(
              id: _uuid.v4(),
              animalId: animalId,
              loteVentaId: Value(loteVentaId),
              fecha: ahora,
              precio: precio,
              peso: Value(peso),
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
    final venta =
        await (db.select(db.ventas)
              ..where(
                (t) => t.animalId.equals(animal.id) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();

    // Oro: utilidad = venta − (compra + dietas + sanidad). Sin “otros”.
    final alimentacion = costoAlimentacionDesdePeriodos(periodos);
    final sanitario = costoSanitarioDesdeEventos(
      eventos.map((e) => e.costo).toList(),
    );
    final utilidad = utilidadOro(
      precioVenta: venta?.precio,
      precioCompra: animal.precioCompra,
      costoDietas: alimentacion,
      costoSanidad: sanitario,
    );
    final total = (animal.precioCompra ?? 0) + alimentacion + sanitario;

    return ResumenEconomicoAnimal(
      precioCompra: animal.precioCompra,
      costoAlimentacion: alimentacion,
      costoSanitario: sanitario,
      costoOtros: 0,
      precioVenta: venta?.precio,
      costoTotal: total,
      utilidad: utilidad,
      margenPorcentaje: null,
      rentabilidadPorcentaje: null,
    );
  }
}
