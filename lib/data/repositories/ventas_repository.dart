import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../estadisticas/estadisticas_economicas.dart';
import '../estadisticas/estadisticas_financieras.dart';
import '../estadisticas/estadisticas_sanidad.dart';
import '../local/database.dart';
import 'dietas_repository.dart';
import 'gastos_fijos_repository.dart';
import 'sanidad_repository.dart';

/// Estados del animal en inventario activo (D-08).
abstract final class EstadoAnimal {
  static const activo = 'activo';
  static const vendido = 'vendido';
  static const muerto = 'muerto';

  static const activosInventario = [activo];
}

/// Un animal con su economía y los kilos que ganó, para el módulo Análisis.
class AnimalFinanciero {
  const AnimalFinanciero({
    required this.animal,
    required this.resumen,
    required this.kilosGanados,
  });

  final AnimalRow animal;
  final ResumenEconomicoAnimal resumen;

  /// Último peso menos el primero. 0 si tiene un solo pesaje o ninguno.
  final double kilosGanados;

  AporteFinanciero get aporte => (
    compra: resumen.precioCompra ?? 0,
    alimentacion: resumen.costoAlimentacion,
    sanidad: resumen.costoSanitario,
    gastosFijos: resumen.costoGastosFijos,
    dineroRecibido: resumen.precioVenta,
    utilidad: resumen.utilidad,
    kilosGanados: kilosGanados,
  );
}

/// Análisis de un grupo de venta: totales y promedios sobre los animales que
/// ya tienen datos de planta registrados (D-19).
class ResumenLoteVenta {
  const ResumenLoteVenta({
    required this.lote,
    required this.ventas,
    required this.utilidadTotal,
    required this.dineroRecibidoTotal,
    required this.pesoFincaTotal,
    required this.pesoPieTotal,
    required this.pesoCanalTotal,
    required this.rendimientoPromedio,
    required this.conDatosPlanta,
  });

  final LoteVentaRow lote;
  final List<VentaConAnimal> ventas;

  /// Σ utilidad de los animales con dinero recibido registrado.
  final double utilidadTotal;
  final double dineroRecibidoTotal;
  final double pesoFincaTotal;
  final double pesoPieTotal;
  final double pesoCanalTotal;

  /// Promedio simple del rendimiento de los animales que lo tienen; null si
  /// ninguno tiene los dos pesos todavía.
  final double? rendimientoPromedio;

  /// Cuántos animales del grupo ya tienen dinero recibido registrado.
  final int conDatosPlanta;

  int get total => ventas.length;
  int get pendientesDeDatos => total - conDatosPlanta;
  bool get completo => total > 0 && pendientesDeDatos == 0;

  /// ₡ por kilo de canal del grupo, derivado. Null si falta información.
  double? get precioKgCanal =>
      pesoCanalTotal > 0 ? dineroRecibidoTotal / pesoCanalTotal : null;
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

  /// Los datos de planta ya se registraron (el dinero es lo que manda).
  bool get tieneDatosPlanta => venta.dineroRecibido != null;
}

/// Ventas y utilidad oro: venta − (compra + dietas + sanidad + gastos fijos).
/// Los “otros costos” por animal (`costos_otros`) siguen fuera de la fórmula.
class VentasRepository {
  VentasRepository(
    this.db, {
    DietasRepository? dietasRepository,
    SanidadRepository? sanidadRepository,
    GastosFijosRepository? gastosFijosRepository,
  }) : _dietasRepository = dietasRepository ?? DietasRepository(db),
       _sanidadRepository = sanidadRepository ?? SanidadRepository(db),
       _gastosFijosRepository =
           gastosFijosRepository ?? GastosFijosRepository(db);

  final AppDatabase db;
  final DietasRepository _dietasRepository;
  final SanidadRepository _sanidadRepository;
  final GastosFijosRepository _gastosFijosRepository;
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

  /// Economía de cada animal de la finca (en pie y ya vendidos), con los kilos
  /// que ganó. El módulo Análisis agrupa esto por lote y lo suma.
  ///
  /// Reusa `_resumenDesdeAnimal`, el mismo cálculo que muestra la ficha del
  /// animal: así Análisis y ficha nunca dicen números distintos. Cuesta varias
  /// consultas por animal, por eso es un Future con indicador de carga y no un
  /// stream que se recalcula solo.
  Future<List<AnimalFinanciero>> financieroDeFinca(String fincaId) async {
    final animales =
        await (db.select(db.animales)
              ..where(
                (t) =>
                    t.fincaId.equals(fincaId) &
                    t.deletedAt.isNull() &
                    t.estado.equals(EstadoAnimal.muerto).not(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.identificador)]))
            .get();

    // Primer y último peso de cada animal, en una sola pasada.
    final pesajes =
        await (db.select(db.pesajes)
              ..where((t) => t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
            .get();
    final primero = <String, double>{};
    final ultimo = <String, double>{};
    for (final p in pesajes) {
      primero.putIfAbsent(p.animalId, () => p.peso);
      ultimo[p.animalId] = p.peso;
    }

    final resultado = <AnimalFinanciero>[];
    for (final a in animales) {
      final desde = primero[a.id];
      final hasta = ultimo[a.id];
      resultado.add(
        AnimalFinanciero(
          animal: a,
          resumen: await _resumenDesdeAnimal(a),
          kilosGanados: (desde == null || hasta == null) ? 0 : hasta - desde,
        ),
      );
    }
    return resultado;
  }

  Stream<List<ResumenLoteVenta>> observarLotesVenta(String fincaId) {
    // El análisis del grupo depende de `ventas` (los datos de planta se
    // registran ahí después de crear el grupo), así que hay que re-emitir
    // cuando cambie cualquiera de las tablas, no solo `lotes_venta`.
    return db
        .customSelect(
          'SELECT 1',
          readsFrom: {db.lotesVenta, db.ventas, db.animales},
        )
        .watch()
        .asyncMap((_) => _lotesVentaDe(fincaId));
  }

  Future<List<ResumenLoteVenta>> _lotesVentaDe(String fincaId) async {
    final lotes =
        await (db.select(db.lotesVenta)
              ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
            .get();
    final out = <ResumenLoteVenta>[];
    for (final lote in lotes) {
      final ventas =
          await (db.select(db.ventas)..where(
                (t) => t.loteVentaId.equals(lote.id) & t.deletedAt.isNull(),
              ))
              .get();
      final items = <VentaConAnimal>[];
      var utilidadTotal = 0.0;
      var dineroTotal = 0.0;
      var pesoFincaTotal = 0.0;
      var pesoPieTotal = 0.0;
      var pesoCanalTotal = 0.0;
      var sumaRendimiento = 0.0;
      var conRendimiento = 0;
      var conDatosPlanta = 0;
      for (final v in ventas) {
        final animal = await (db.select(
          db.animales,
        )..where((t) => t.id.equals(v.animalId))).getSingle();
        final resumen = await _resumenDesdeAnimal(animal);
        utilidadTotal += resumen.utilidad ?? 0;
        dineroTotal += v.dineroRecibido ?? 0;
        pesoFincaTotal += v.peso ?? 0;
        pesoPieTotal += v.pesoPie ?? 0;
        pesoCanalTotal += v.pesoCanal ?? 0;
        if (v.rendimiento != null) {
          sumaRendimiento += v.rendimiento!;
          conRendimiento++;
        }
        if (v.dineroRecibido != null) conDatosPlanta++;
        items.add(
          VentaConAnimal(venta: v, animal: animal, utilidad: resumen.utilidad),
        );
      }
      out.add(
        ResumenLoteVenta(
          lote: lote,
          ventas: items,
          utilidadTotal: utilidadTotal,
          dineroRecibidoTotal: dineroTotal,
          pesoFincaTotal: pesoFincaTotal,
          pesoPieTotal: pesoPieTotal,
          pesoCanalTotal: pesoCanalTotal,
          rendimientoPromedio: conRendimiento == 0
              ? null
              : sumaRendimiento / conRendimiento,
          conDatosPlanta: conDatosPlanta,
        ),
      );
    }
    return out;
  }

  Future<void> actualizarCompra({
    required String animalId,
    double? pesoCompra,
    double? precioKgCompra,
    double? precioCompra,
    DateTime? fechaCompra,
  }) async {
    final ahora = DateTime.now();
    final nacio = precioKgCompra == 0;
    final total = nacio
        ? 0.0
        : precioCompra ??
              ((pesoCompra != null && precioKgCompra != null)
                  ? pesoCompra * precioKgCompra
                  : precioCompra);
    await (db.update(db.animales)..where((t) => t.id.equals(animalId))).write(
      AnimalesCompanion(
        pesoCompra: Value(nacio ? null : pesoCompra),
        precioKgCompra: Value(precioKgCompra),
        precioCompra: Value(total),
        fechaCompra: Value(
          fechaCompra ?? (nacio || total == null ? null : ahora),
        ),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  /// Confirma un grupo de venta (varios animales). Bloquea si alguno está en
  /// retiro. [items] llevan solo los **kilos de salida de la finca** (D-19): el
  /// dinero y los datos de planta se registran después, animal por animal, con
  /// [registrarDatosPlanta]. Mientras eso no pase, la utilidad queda en “—”.
  Future<String> confirmarLoteVenta({
    required String fincaId,
    required List<({String animalId, double peso})> items,
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
      // Antes de marcarlos vendidos: los que salen juntos se reparten entre sí
      // el gasto fijo y su parte queda congelada (Módulo 7, D-17).
      await _gastosFijosRepository.congelarGastosFijos(
        fincaId: fincaId,
        animalIds: [for (final item in items) item.animalId],
        fecha: ahora,
        hoy: ahora,
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
                // Todavía no se sabe cuánto pagaron: el dinero llega con los
                // datos de planta. `precio` queda espejo de dineroRecibido.
                precio: 0,
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

  /// Registra los datos que devuelve la planta para un animal ya vendido
  /// (D-19). El rendimiento **no se digita**: sale de canal ÷ pie. El dinero
  /// recibido es lo que alimenta la utilidad, y se refleja en `precio` para
  /// que nada que lea el total quede desalineado.
  ///
  /// Se pueden guardar datos parciales (por ejemplo solo los pesos): lo que
  /// venga null se borra, así corregir un dato es simétrico a digitarlo.
  Future<void> registrarDatosPlanta({
    required String ventaId,
    double? pesoPie,
    double? pesoCanal,
    double? dineroRecibido,
  }) async {
    final ahora = DateTime.now();
    final rendimiento = rendimientoCanal(
      pesoPie: pesoPie,
      pesoCanal: pesoCanal,
    );
    await (db.update(db.ventas)..where((t) => t.id.equals(ventaId))).write(
      VentasCompanion(
        pesoPie: Value(pesoPie),
        pesoCanal: Value(pesoCanal),
        rendimiento: Value(rendimiento),
        dineroRecibido: Value(dineroRecibido),
        precio: Value(dineroRecibido ?? 0),
        // ₡/kg derivado del canal, para no perder la lectura por kilo.
        precioKg: Value(
          (dineroRecibido != null && pesoCanal != null && pesoCanal > 0)
              ? dineroRecibido / pesoCanal
              : null,
        ),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  /// Venta individual (compat). Prefiere [confirmarLoteVenta] +
  /// [registrarDatosPlanta]. Acá el dinero **sí** se conoce al registrar, así
  /// que [precio] queda también como dinero recibido y la utilidad sale de una.
  Future<void> registrarVenta({
    required String animalId,
    required double precio,
    double? peso,
    double? precioKg,
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
    final total = (peso != null && precioKg != null) ? peso * precioKg : precio;
    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals(animalId))).getSingle();
    await db.transaction(() async {
      // Congelar el gasto fijo antes de marcarlo vendido (Módulo 7, D-17).
      await _gastosFijosRepository.congelarGastosFijos(
        fincaId: animal.fincaId,
        animalIds: [animalId],
        fecha: ahora,
        hoy: ahora,
      );
      await db
          .into(db.ventas)
          .insert(
            VentasCompanion.insert(
              id: _uuid.v4(),
              animalId: animalId,
              loteVentaId: Value(loteVentaId),
              fecha: ahora,
              precio: total,
              dineroRecibido: Value(total),
              peso: Value(peso),
              precioKg: Value(precioKg),
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

    // Dieta se corta en la fecha de venta (o muerte); no sigue corriendo.
    final corte = venta?.fecha;
    final alimentacion = costoAlimentacionDesdePeriodos(periodos, hasta: corte);
    final sanitario = costoSanitarioDesdeEventos(
      eventos.map((e) => e.costo).toList(),
    );
    // Gasto fijo prorrateado: congelado si ya salió, en vivo si está activo.
    final gastosFijos = await _gastosFijosRepository.gastoFijoDeAnimal(animal);
    // La utilidad sale del **dinero recibido** (D-19). Mientras la planta no
    // haya liquidado, queda null → la pantalla muestra “—”, nunca ₡0.
    final utilidad = utilidadOro(
      precioVenta: venta?.dineroRecibido,
      precioCompra: animal.precioCompra,
      costoDietas: alimentacion,
      costoSanidad: sanitario,
      costoGastosFijos: gastosFijos,
    );
    final total =
        (animal.precioCompra ?? 0) + alimentacion + sanitario + gastosFijos;

    // Compra confiable si hay ₡/kg explícito (0 = nació) o no hay rastro de compra.
    final compraConfiable =
        animal.precioKgCompra != null ||
        (animal.precioCompra == null && animal.fechaCompra == null);

    return ResumenEconomicoAnimal(
      precioCompra: animal.precioCompra,
      pesoCompra: animal.pesoCompra,
      precioKgCompra: animal.precioKgCompra,
      costoAlimentacion: alimentacion,
      costoSanitario: sanitario,
      costoOtros: 0,
      costoGastosFijos: gastosFijos,
      precioVenta: venta?.dineroRecibido,
      pesoVenta: venta?.peso,
      precioKgVenta: venta?.precioKg,
      pesoPie: venta?.pesoPie,
      pesoCanal: venta?.pesoCanal,
      rendimiento: venta?.rendimiento,
      costoTotal: total,
      utilidad: utilidad,
      margenPorcentaje: null,
      rentabilidadPorcentaje: null,
      compraConfiable: compraConfiable,
    );
  }
}
