import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../estadisticas/estadisticas_gastos_fijos.dart';
import '../local/database.dart';
import 'pesajes_repository.dart';

/// Periodicidad de un gasto fijo (Módulo 7).
abstract final class PeriodicidadGasto {
  static const mensual = 'mensual';
  static const unico = 'unico';

  static const todas = [mensual, unico];
}

/// Resumen del mes en curso para el encabezado de la pantalla.
class ResumenGastosMes {
  const ResumenGastosMes({
    required this.mes,
    required this.totalDevengado,
    required this.diasAnimal,
    required this.animalesActivos,
  });

  final DateTime mes;

  /// ₡ que llevan devengados los gastos de la finca en el mes en curso.
  final double totalDevengado;

  /// Días-animal acumulados en el mes (denominador del prorrateo).
  final int diasAnimal;
  final int animalesActivos;

  /// ₡ por animal por día. null si todavía no hay días-animal que repartir.
  double? get costoPorAnimalDia =>
      diasAnimal == 0 ? null : totalDevengado / diasAnimal;
}

/// Gastos fijos de la finca y su prorrateo por días-animal (Módulo 7, D-17).
///
/// Mientras el animal está en la finca su parte se calcula **en vivo**; al
/// vender se **congela** en `gasto_fijo_cargos` para que su utilidad no cambie
/// después. Un gasto digitado atrasado se reparte solo entre los animales que
/// siguen activos, porque el prorrateo descuenta lo ya congelado.
class GastosFijosRepository {
  GastosFijosRepository(this.db, {PesajesRepository? pesajesRepository})
    : _pesajes = pesajesRepository ?? PesajesRepository(db);

  final AppDatabase db;

  /// Dueño de la regla de "cuándo entró el animal a la finca".
  final PesajesRepository _pesajes;
  final _uuid = const Uuid();

  Stream<List<GastoFijoRow>> observarGastos(String fincaId) {
    return (db.select(db.gastosFijos)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.concepto)]))
        .watch();
  }

  Future<List<GastoFijoRow>> gastosDe(String fincaId) {
    return (db.select(
      db.gastosFijos,
    )..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())).get();
  }

  /// [desde] se normaliza al primer día del mes cuando el gasto es mensual:
  /// el ganadero elige un mes, no un día.
  Future<String> crearGasto({
    required String fincaId,
    required String concepto,
    required double monto,
    required String periodicidad,
    required DateTime desde,
    DateTime? hasta,
    String moneda = 'CRC',
  }) async {
    final ahora = DateTime.now();
    final id = _uuid.v4();
    await db
        .into(db.gastosFijos)
        .insert(
          GastosFijosCompanion.insert(
            id: id,
            fincaId: fincaId,
            concepto: concepto.trim(),
            monto: monto,
            periodicidad: periodicidad,
            desde: _normalizarDesde(desde, periodicidad),
            hasta: Value(hasta),
            moneda: Value(moneda),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
    return id;
  }

  Future<void> editarGasto({
    required String gastoId,
    required String concepto,
    required double monto,
    required String periodicidad,
    required DateTime desde,
    DateTime? hasta,
  }) async {
    await (db.update(db.gastosFijos)..where((t) => t.id.equals(gastoId))).write(
      GastosFijosCompanion(
        concepto: Value(concepto.trim()),
        monto: Value(monto),
        periodicidad: Value(periodicidad),
        desde: Value(_normalizarDesde(desde, periodicidad)),
        hasta: Value(hasta),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  /// Da de baja el gasto sin borrarlo: deja de devengar a partir de [hasta].
  Future<void> darDeBaja(String gastoId, {DateTime? hasta}) async {
    final ahora = DateTime.now();
    await (db.update(db.gastosFijos)..where((t) => t.id.equals(gastoId))).write(
      GastosFijosCompanion(
        hasta: Value(hasta ?? ahora),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  Future<void> eliminarGasto(String gastoId) async {
    final ahora = DateTime.now();
    await (db.update(db.gastosFijos)..where((t) => t.id.equals(gastoId))).write(
      GastosFijosCompanion(
        deletedAt: Value(ahora),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  DateTime _normalizarDesde(DateTime desde, String periodicidad) {
    if (periodicidad != PeriodicidadGasto.mensual) return desde;
    return primerDiaDelMes(desde);
  }

  /// Estancia del animal en la finca.
  ///
  /// No hay columnas de ingreso/salida: el ingreso se deriva de la fecha de
  /// compra o del primer movimiento de lote (que se escribe al crear el
  /// animal), y la salida de la última venta. Para un animal muerto sin venta
  /// se usa `updatedAt`, que es cuando se marcó el estado.
  Future<EstanciaAnimal> estanciaDe(AnimalRow animal) async {
    final venta = await _ultimaVenta(animal.id);

    final ingreso = await _pesajes.fechaIngreso(animal);
    final salida =
        venta?.fecha ?? (animal.estado == 'activo' ? null : animal.updatedAt);
    return EstanciaAnimal(
      animalId: animal.id,
      ingreso: ingreso,
      salida: salida,
    );
  }

  Future<VentaRow?> _ultimaVenta(String animalId) {
    return (db.select(db.ventas)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<AnimalRow>> _animalesActivos(String fincaId) {
    return (db.select(db.animales)..where(
          (t) =>
              t.fincaId.equals(fincaId) &
              t.deletedAt.isNull() &
              t.estado.equals('activo'),
        ))
        .get();
  }

  Future<List<GastoFijoCargoRow>> cargosDe(String animalId) {
    return (db.select(
      db.gastoFijoCargos,
    )..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())).get();
  }

  /// Cargos congelados de todos los animales de la finca.
  Future<List<GastoFijoCargoRow>> _cargosDeFinca(String fincaId) async {
    final query =
        db.select(db.gastoFijoCargos).join([
          innerJoin(
            db.animales,
            db.animales.id.equalsExp(db.gastoFijoCargos.animalId),
          ),
        ])..where(
          db.animales.fincaId.equals(fincaId) &
              db.gastoFijoCargos.deletedAt.isNull(),
        );
    final filas = await query.get();
    return filas.map((f) => f.readTable(db.gastoFijoCargos)).toList();
  }

  List<GastoFijoVigencia> _vigencias(List<GastoFijoRow> gastos) {
    return [
      for (final g in gastos)
        GastoFijoVigencia(
          gastoFijoId: g.id,
          monto: g.monto,
          mensual: g.periodicidad == PeriodicidadGasto.mensual,
          desde: g.desde,
          hasta: g.hasta,
        ),
    ];
  }

  List<CargoCongelado> _congelados(List<GastoFijoCargoRow> cargos) {
    return [
      for (final c in cargos)
        CargoCongelado(gastoFijoId: c.gastoFijoId, mes: c.mes, monto: c.monto),
    ];
  }

  /// ₡ de gasto fijo que absorbió el animal.
  ///
  /// Si ya tiene cargos congelados (salió de la finca) devuelve su suma tal
  /// cual: la utilidad de un animal vendido no vuelve a cambiar. Si está activo
  /// se calcula en vivo con los gastos y los animales de la finca.
  Future<double> gastoFijoDeAnimal(AnimalRow animal, {DateTime? hoy}) async {
    final congeladosPropios = await cargosDe(animal.id);
    if (congeladosPropios.isNotEmpty) {
      return congeladosPropios.fold<double>(0, (s, c) => s + c.monto);
    }
    if (animal.estado != 'activo') {
      // Salió de la finca antes de que existiera el módulo: sin cargos que
      // reclamarle. Su utilidad queda como estaba.
      return 0;
    }

    final partes = await _prorratearFinca(animal.fincaId, hoy: hoy);
    return totalDeAnimal(partes, animal.id);
  }

  /// Reparte los gastos de la finca entre sus animales activos.
  /// [salidas] permite cortar la estancia de los animales que se están
  /// vendiendo en este momento (aún tienen estado `activo`).
  Future<List<ParteGastoMes>> _prorratearFinca(
    String fincaId, {
    DateTime? hoy,
    Map<String, DateTime> salidas = const {},
  }) async {
    final gastos = await gastosDe(fincaId);
    if (gastos.isEmpty) return const [];

    final activos = await _animalesActivos(fincaId);
    final estancias = <EstanciaAnimal>[];
    for (final a in activos) {
      final base = await estanciaDe(a);
      final salida = salidas[a.id];
      estancias.add(
        salida == null
            ? base
            : EstanciaAnimal(
                animalId: base.animalId,
                ingreso: base.ingreso,
                salida: salida,
              ),
      );
    }

    return prorratearGastos(
      gastos: _vigencias(gastos),
      activos: estancias,
      congelados: _congelados(await _cargosDeFinca(fincaId)),
      hoy: hoy ?? DateTime.now(),
    );
  }

  /// Congela la parte de gasto fijo de los animales que salen de la finca.
  ///
  /// Se calcula ANTES de marcarlos como vendidos (así los que salen juntos se
  /// reparten entre sí) y se escribe dentro de la transacción de la venta.
  /// Idempotente: si un animal ya tiene cargos, se deja como está.
  Future<void> congelarGastosFijos({
    required String fincaId,
    required List<String> animalIds,
    required DateTime fecha,
    DateTime? hoy,
  }) async {
    if (animalIds.isEmpty) return;

    final aCongelar = <String>[];
    for (final id in animalIds) {
      if ((await cargosDe(id)).isEmpty) aCongelar.add(id);
    }
    if (aCongelar.isEmpty) return;

    final partes = await _prorratearFinca(
      fincaId,
      hoy: hoy,
      salidas: {for (final id in aCongelar) id: fecha},
    );
    final propias = partes.where((p) => aCongelar.contains(p.animalId));
    if (propias.isEmpty) return;

    final ahora = DateTime.now();
    await db.batch((b) {
      for (final p in propias) {
        b.insert(
          db.gastoFijoCargos,
          GastoFijoCargosCompanion.insert(
            id: _uuid.v4(),
            gastoFijoId: p.gastoFijoId,
            animalId: p.animalId,
            mes: p.mes,
            dias: p.dias,
            monto: p.monto,
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
      }
    });
  }

  /// Total devengado del mes en curso y ₡ por animal-día, para el encabezado.
  Future<ResumenGastosMes> resumenMesActual(
    String fincaId, {
    DateTime? hoy,
  }) async {
    final ahora = hoy ?? DateTime.now();
    final mes = primerDiaDelMes(ahora);
    final gastos = await gastosDe(fincaId);

    var total = 0.0;
    for (final g in _vigencias(gastos)) {
      for (final m in mesesDeGasto(g, hoy: ahora)) {
        if (m.mes.isAtSameMomentAs(mes)) total += m.montoDevengado;
      }
    }

    final activos = await _animalesActivos(fincaId);
    var diasAnimal = 0;
    for (final a in activos) {
      diasAnimal += diasEnMes(await estanciaDe(a), mes, hoy: ahora);
    }

    return ResumenGastosMes(
      mes: mes,
      totalDevengado: total,
      diasAnimal: diasAnimal,
      animalesActivos: activos.length,
    );
  }
}
