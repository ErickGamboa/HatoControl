import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/deudas_repository.dart';

/// Deudas (módulo Gastos · pestaña Deudas): saldo con abonos, estados y los
/// filtros con los que se arma el PDF.
void main() {
  late AppDatabase db;
  late DeudasRepository deudas;
  final hoy = DateTime(2026, 9, 21);

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    deudas = DeudasRepository(db);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca',
            creadaPor: 'u1',
            createdAt: hoy,
            updatedAt: hoy,
          ),
        );
  });

  tearDown(() async => db.close());

  Future<String> crear({
    String acreedor = 'Cooperativa',
    double monto = 450000,
    DateTime? fecha,
    DateTime? vence,
    String? nota,
  }) {
    return deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: acreedor,
      monto: monto,
      fecha: fecha ?? hoy,
      vence: vence,
      nota: nota,
    );
  }

  Future<DeudaConSaldo> leer(String id) async {
    final todas = await deudas.deudasDe('f1');
    return todas.firstWhere((d) => d.deuda.id == id);
  }

  test('una deuda nueva nace pendiente, sin abonos y con todo el saldo', () async {
    final id = await crear();
    final d = await leer(id);

    expect(d.deuda.estado, EstadoDeuda.pendiente);
    expect(d.abonado, 0);
    expect(d.saldo, 450000);
    expect(d.deuda.pendiente, isTrue, reason: 'queda por sincronizar');
  });

  test('los abonos bajan el saldo y al cubrirlo la deja pagada sola', () async {
    final id = await crear();

    await deudas.registrarAbono(deudaId: id, monto: 200000, fecha: hoy);
    var d = await leer(id);
    expect(d.abonado, 200000);
    expect(d.saldo, 250000);
    expect(d.deuda.estado, EstadoDeuda.pendiente);

    await deudas.registrarAbono(deudaId: id, monto: 250000, fecha: hoy);
    d = await leer(id);
    expect(d.saldo, 0);
    expect(d.pagada, isTrue, reason: 'nadie tuvo que cambiarle el estado');
  });

  test('borrar un abono vuelve a dejarla pendiente', () async {
    final id = await crear(monto: 100000);
    await deudas.registrarAbono(deudaId: id, monto: 100000, fecha: hoy);
    expect((await leer(id)).pagada, isTrue);

    final abono = (await deudas.observarAbonos(id).first).single;
    await deudas.eliminarAbono(abono.id);

    final d = await leer(id);
    expect(d.deuda.estado, EstadoDeuda.pendiente);
    expect(d.saldo, 100000);
  });

  test('marcar pagada registra el abono que falta, no solo cambia el estado', () async {
    final id = await crear(monto: 300000);
    await deudas.registrarAbono(deudaId: id, monto: 100000, fecha: hoy);

    await deudas.marcarPagada(id, fecha: hoy);

    final d = await leer(id);
    expect(d.pagada, isTrue);
    expect(d.saldo, 0);
    // Los números siguen cuadrando: abonado == monto.
    expect(d.abonado, 300000);
    expect(await deudas.observarAbonos(id).first, hasLength(2));
  });

  test('anular la saca de los totales y reabrir la devuelve', () async {
    final id = await crear(monto: 80000);
    await deudas.anular(id);

    var d = await leer(id);
    expect(d.anulada, isTrue);
    expect(TotalesDeudas.de([d]).total, 0, reason: 'anulada no suma');
    expect(TotalesDeudas.de([d]).cantidad, 1, reason: 'pero sí se lista');

    await deudas.reabrir(id);
    d = await leer(id);
    expect(d.deuda.estado, EstadoDeuda.pendiente);
    expect(TotalesDeudas.de([d]).saldo, 80000);
  });

  test('una anulada no se vuelve pagada sola al abonarle', () async {
    final id = await crear(monto: 50000);
    await deudas.anular(id);
    await deudas.registrarAbono(deudaId: id, monto: 50000, fecha: hoy);

    expect((await leer(id)).anulada, isTrue);
  });

  test('vencida = pendiente con fecha de pago ya pasada', () async {
    final id = await crear(vence: DateTime(2026, 9, 1));
    final vencida = await leer(id);
    expect(vencida.vencida(hoy: hoy), isTrue);

    final id2 = await crear(vence: DateTime(2026, 12, 1));
    expect((await leer(id2)).vencida(hoy: hoy), isFalse);

    await deudas.marcarPagada(id, fecha: hoy);
    expect(
      (await leer(id)).vencida(hoy: hoy),
      isFalse,
      reason: 'ya pagada no está vencida',
    );
  });

  test('borrar una deuda la saca de la lista (borrado suave)', () async {
    final id = await crear();
    await deudas.eliminarDeuda(id);
    expect(await deudas.deudasDe('f1'), isEmpty);
  });

  group('filtros (lo que se ve en pantalla es lo que sale en el PDF)', () {
    late List<DeudaConSaldo> todas;

    setUp(() async {
      await crear(acreedor: 'Cooperativa', monto: 100000, fecha: hoy);
      final vieja = await crear(
        acreedor: 'Veterinario',
        monto: 50000,
        fecha: DateTime(2026, 5, 10),
        nota: 'Medicamentos del hato',
      );
      await deudas.marcarPagada(vieja, fecha: hoy);
      await crear(
        acreedor: 'Banco',
        monto: 900000,
        fecha: DateTime(2026, 8, 1),
        vence: DateTime(2026, 9, 1),
      );
      todas = await deudas.deudasDe('f1');
    });

    test('por estado', () {
      final pendientes = filtrarDeudas(
        todas,
        filtro: FiltroDeuda.pendientes,
      );
      expect(pendientes.map((d) => d.deuda.acreedor), ['Cooperativa', 'Banco']);

      final pagadas = filtrarDeudas(todas, filtro: FiltroDeuda.pagadas);
      expect(pagadas.single.deuda.acreedor, 'Veterinario');

      final vencidas = filtrarDeudas(
        todas,
        filtro: FiltroDeuda.vencidas,
        hoy: hoy,
      );
      expect(vencidas.single.deuda.acreedor, 'Banco');
    });

    test('por rango de fechas, incluyendo el día del tope', () {
      final agosto = filtrarDeudas(
        todas,
        desde: DateTime(2026, 8, 1),
        hasta: DateTime(2026, 8, 1),
      );
      expect(agosto.single.deuda.acreedor, 'Banco');
    });

    test('el buscador mira el acreedor y la nota', () {
      expect(
        filtrarDeudas(todas, busqueda: 'banc').single.deuda.acreedor,
        'Banco',
      );
      expect(
        filtrarDeudas(todas, busqueda: 'medicamentos').single.deuda.acreedor,
        'Veterinario',
      );
      expect(filtrarDeudas(todas, busqueda: 'nada de nada'), isEmpty);
    });

    test('los totales son los de lo filtrado, no los de todo', () {
      final pendientes = filtrarDeudas(todas, filtro: FiltroDeuda.pendientes);
      final totales = TotalesDeudas.de(pendientes);

      expect(totales.cantidad, 2);
      expect(totales.total, 1000000);
      expect(totales.abonado, 0);
      expect(totales.saldo, 1000000);
    });
  });
}
