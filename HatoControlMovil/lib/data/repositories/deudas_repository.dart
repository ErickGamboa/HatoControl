import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Estados de una deuda.
abstract final class EstadoDeuda {
  /// Todavía se debe (aunque tenga abonos).
  static const pendiente = 'pendiente';

  /// Ya se pagó completa.
  static const pagada = 'pagada';

  /// Se dejó sin efecto (se registró mal, se perdonó, se cambió por otra).
  /// No suma en los totales.
  static const anulada = 'anulada';

  static const todos = [pendiente, pagada, anulada];
}

/// Qué deudas mostrar en la lista.
enum FiltroDeuda {
  todas,
  pendientes,
  pagadas,
  anuladas,

  /// Pendientes cuya fecha de vencimiento ya pasó.
  vencidas,
}

/// Una deuda con lo que lleva abonado y su saldo.
class DeudaConSaldo {
  const DeudaConSaldo({required this.deuda, required this.abonado});

  final DeudaRow deuda;

  /// Suma de los abonos (no borrados) de esta deuda.
  final double abonado;

  double get saldo {
    final resto = deuda.monto - abonado;
    return resto < 0 ? 0 : resto;
  }

  bool get pagada => deuda.estado == EstadoDeuda.pagada;
  bool get anulada => deuda.estado == EstadoDeuda.anulada;

  /// Pendiente y con fecha de vencimiento ya pasada.
  bool vencida({DateTime? hoy}) {
    if (deuda.estado != EstadoDeuda.pendiente) return false;
    final vence = deuda.vence;
    if (vence == null) return false;
    final referencia = hoy ?? DateTime.now();
    final diaVence = DateTime(vence.year, vence.month, vence.day);
    final diaHoy = DateTime(referencia.year, referencia.month, referencia.day);
    return diaVence.isBefore(diaHoy);
  }
}

/// Totales de lo que hay en pantalla después de filtrar. Es lo que se muestra
/// abajo de la lista y lo que sale en el PDF.
class TotalesDeudas {
  const TotalesDeudas({
    required this.cantidad,
    required this.total,
    required this.abonado,
    required this.saldo,
  });

  static const vacio = TotalesDeudas(
    cantidad: 0,
    total: 0,
    abonado: 0,
    saldo: 0,
  );

  final int cantidad;

  /// Monto sumado de las deudas listadas (sin las anuladas).
  final double total;
  final double abonado;
  final double saldo;

  factory TotalesDeudas.de(Iterable<DeudaConSaldo> deudas) {
    var total = 0.0;
    var abonado = 0.0;
    var saldo = 0.0;
    var cantidad = 0;
    for (final d in deudas) {
      cantidad++;
      if (d.anulada) continue; // no se debe: no suma en ningún total
      total += d.deuda.monto;
      abonado += d.abonado;
      saldo += d.saldo;
    }
    return TotalesDeudas(
      cantidad: cantidad,
      total: total,
      abonado: abonado,
      saldo: saldo,
    );
  }
}

/// Deudas de la finca: a quién se le debe, cuánto, y cómo se va pagando.
///
/// NO toca la contabilidad del animal. La utilidad se calcula con compra,
/// venta, dietas, sanidad y gastos fijos; las deudas son una lista aparte
/// para llevar el control, y por eso no aparecen en ningún análisis
/// financiero. Si algún día tienen que pesar en la utilidad, van como gasto
/// fijo, no por acá.
class DeudasRepository {
  DeudasRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  /// Deudas de la finca con su saldo, de la más reciente a la más vieja.
  Stream<List<DeudaConSaldo>> observarDeudas(String fincaId) {
    final consulta = db.select(db.deudas)
      ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.fecha),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);

    // Se escuchan las DOS tablas: la lista tiene que moverse sola tanto al
    // agregar o editar una deuda como al registrar un abono (ahí cambia el
    // saldo, aunque la fila de la deuda no se haya tocado).
    return db
        .customSelect(
          'SELECT 1',
          readsFrom: {db.deudas, db.deudaAbonos},
        )
        .watch()
        .asyncMap((_) => _conSaldo(consulta.get()));
  }

  Future<List<DeudaConSaldo>> deudasDe(String fincaId) {
    final consulta = db.select(db.deudas)
      ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.fecha),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return _conSaldo(consulta.get());
  }

  Future<List<DeudaConSaldo>> _conSaldo(Future<List<DeudaRow>> filas) async {
    final deudas = await filas;
    if (deudas.isEmpty) return const [];

    final ids = deudas.map((d) => d.id).toList();
    final suma = db.deudaAbonos.monto.sum();
    final consulta = db.selectOnly(db.deudaAbonos)
      ..addColumns([db.deudaAbonos.deudaId, suma])
      ..where(
        db.deudaAbonos.deudaId.isIn(ids) & db.deudaAbonos.deletedAt.isNull(),
      )
      ..groupBy([db.deudaAbonos.deudaId]);

    final abonos = <String, double>{};
    for (final fila in await consulta.get()) {
      abonos[fila.read(db.deudaAbonos.deudaId)!] = fila.read(suma) ?? 0;
    }

    return [
      for (final d in deudas)
        DeudaConSaldo(deuda: d, abonado: abonos[d.id] ?? 0),
    ];
  }

  /// Abonos de una deuda, del más reciente al más viejo.
  Stream<List<DeudaAbonoRow>> observarAbonos(String deudaId) {
    return (db.select(db.deudaAbonos)
          ..where((t) => t.deudaId.equals(deudaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)]))
        .watch();
  }

  Future<String> crearDeuda({
    required String fincaId,
    required String acreedor,
    required double monto,
    required DateTime fecha,
    DateTime? vence,
    String? nota,
    String moneda = 'CRC',
  }) async {
    final ahora = DateTime.now();
    final id = _uuid.v4();
    await db
        .into(db.deudas)
        .insert(
          DeudasCompanion.insert(
            id: id,
            fincaId: fincaId,
            acreedor: acreedor.trim(),
            monto: monto,
            fecha: fecha,
            vence: Value(vence),
            nota: Value(_limpiar(nota)),
            moneda: Value(moneda),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
    return id;
  }

  Future<void> editarDeuda({
    required String deudaId,
    required String acreedor,
    required double monto,
    required DateTime fecha,
    DateTime? vence,
    String? nota,
  }) async {
    await (db.update(db.deudas)..where((t) => t.id.equals(deudaId))).write(
      DeudasCompanion(
        acreedor: Value(acreedor.trim()),
        monto: Value(monto),
        fecha: Value(fecha),
        vence: Value(vence),
        nota: Value(_limpiar(nota)),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
    await _revisarSiQuedoPagada(deudaId);
  }

  /// Registra un abono. Si con este abono ya no queda saldo, la deuda pasa
  /// sola a pagada: nadie tiene que acordarse de cambiarle el estado.
  Future<void> registrarAbono({
    required String deudaId,
    required double monto,
    required DateTime fecha,
    String? nota,
  }) async {
    final ahora = DateTime.now();
    await db
        .into(db.deudaAbonos)
        .insert(
          DeudaAbonosCompanion.insert(
            id: _uuid.v4(),
            deudaId: deudaId,
            monto: monto,
            fecha: fecha,
            nota: Value(_limpiar(nota)),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
    await _revisarSiQuedoPagada(deudaId);
  }

  Future<void> eliminarAbono(String abonoId) async {
    final abono = await (db.select(
      db.deudaAbonos,
    )..where((t) => t.id.equals(abonoId))).getSingleOrNull();
    if (abono == null) return;
    final ahora = DateTime.now();
    await (db.update(db.deudaAbonos)..where((t) => t.id.equals(abonoId))).write(
      DeudaAbonosCompanion(
        deletedAt: Value(ahora),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
    await _revisarSiQuedoPagada(abono.deudaId);
  }

  /// "Marcar pagada" de un toque: registra el abono que falta para dejar el
  /// saldo en cero y deja la deuda pagada. Se registra el abono en vez de
  /// solo cambiar el estado para que los totales de abonado y saldo sigan
  /// cuadrando con el monto.
  Future<void> marcarPagada(String deudaId, {DateTime? fecha}) async {
    final actual = await _deudaConSaldo(deudaId);
    if (actual == null) return;
    if (actual.saldo > 0) {
      await registrarAbono(
        deudaId: deudaId,
        monto: actual.saldo,
        fecha: fecha ?? DateTime.now(),
        nota: 'Pago del saldo',
      );
      return;
    }
    await _cambiarEstado(deudaId, EstadoDeuda.pagada);
  }

  /// Vuelve a dejarla pendiente (se marcó pagada por error, o se anuló y hay
  /// que volver a deberla). Los abonos no se tocan.
  Future<void> reabrir(String deudaId) =>
      _cambiarEstado(deudaId, EstadoDeuda.pendiente);

  /// Deja la deuda sin efecto: queda en la lista para consultarla, pero no
  /// suma en ningún total.
  Future<void> anular(String deudaId) =>
      _cambiarEstado(deudaId, EstadoDeuda.anulada);

  /// Borrado suave. Desaparece de la lista y del PDF.
  Future<void> eliminarDeuda(String deudaId) async {
    final ahora = DateTime.now();
    await (db.update(db.deudas)..where((t) => t.id.equals(deudaId))).write(
      DeudasCompanion(
        deletedAt: Value(ahora),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  Future<DeudaConSaldo?> _deudaConSaldo(String deudaId) async {
    final lista = await _conSaldo(
      (db.select(db.deudas)..where((t) => t.id.equals(deudaId))).get(),
    );
    return lista.isEmpty ? null : lista.first;
  }

  /// Mantiene el estado de acuerdo con el saldo: sin saldo = pagada, con
  /// saldo = pendiente. No toca las anuladas, que son una decisión a mano.
  Future<void> _revisarSiQuedoPagada(String deudaId) async {
    final actual = await _deudaConSaldo(deudaId);
    if (actual == null) return;
    if (actual.anulada) return;

    final estado = actual.saldo <= 0
        ? EstadoDeuda.pagada
        : EstadoDeuda.pendiente;
    if (estado == actual.deuda.estado) return;
    await _cambiarEstado(deudaId, estado);
  }

  Future<void> _cambiarEstado(String deudaId, String estado) async {
    await (db.update(db.deudas)..where((t) => t.id.equals(deudaId))).write(
      DeudasCompanion(
        estado: Value(estado),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  static String? _limpiar(String? texto) {
    final t = texto?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

/// Filtra y busca sobre la lista ya cargada. Está aparte del repositorio (no
/// es SQL) porque la pantalla filtra mientras se escribe y el PDF tiene que
/// salir con EXACTAMENTE lo que se ve en pantalla.
List<DeudaConSaldo> filtrarDeudas(
  List<DeudaConSaldo> deudas, {
  FiltroDeuda filtro = FiltroDeuda.todas,
  String busqueda = '',
  DateTime? desde,
  DateTime? hasta,
  DateTime? hoy,
}) {
  final texto = busqueda.trim().toLowerCase();
  return deudas.where((d) {
    switch (filtro) {
      case FiltroDeuda.todas:
        break;
      case FiltroDeuda.pendientes:
        if (d.deuda.estado != EstadoDeuda.pendiente) return false;
      case FiltroDeuda.pagadas:
        if (!d.pagada) return false;
      case FiltroDeuda.anuladas:
        if (!d.anulada) return false;
      case FiltroDeuda.vencidas:
        if (!d.vencida(hoy: hoy)) return false;
    }

    if (desde != null && d.deuda.fecha.isBefore(desde)) return false;
    if (hasta != null) {
      // `hasta` es un día completo: cuenta hasta las 23:59 de ese día.
      final finDelDia = DateTime(
        hasta.year,
        hasta.month,
        hasta.day,
      ).add(const Duration(days: 1));
      if (!d.deuda.fecha.isBefore(finDelDia)) return false;
    }

    if (texto.isEmpty) return true;
    final acreedor = d.deuda.acreedor.toLowerCase();
    final nota = d.deuda.nota?.toLowerCase() ?? '';
    return acreedor.contains(texto) || nota.contains(texto);
  }).toList();
}
