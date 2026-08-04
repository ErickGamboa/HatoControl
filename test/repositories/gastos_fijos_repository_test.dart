import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/gastos_fijos_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

/// Módulo 7 (D-17): prorrateo por días-animal, congelado al vender y reparto
/// del gasto atrasado solo entre los animales no vendidos.
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  late GastosFijosRepository gastos;
  late VentasRepository ventas;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
    gastos = GastosFijosRepository(db);
    ventas = VentasRepository(db, gastosFijosRepository: gastos);
  });

  tearDown(() async {
    await db.close();
  });

  final entrada = DateTime(2026, 7, 1);
  final julio = DateTime(2026, 7, 1);

  Future<void> seed() async {
    final now = DateTime(2026, 7, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca',
            creadaPor: 'u1',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'l1',
            fincaId: 'f1',
            nombre: 'Lote',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  /// Crea un animal cuya estancia arranca en [ingreso].
  Future<AnimalRow> animal(String id, {DateTime? ingreso}) async {
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: 'l1',
      identificador: id,
      peso: 100,
      registradoPor: 'u1',
      pesoCompra: 100,
      precioKgCompra: 1000,
      precioCompra: 100000,
    );
    final a = (await pesajes.buscarAnimal('f1', id))!;
    final desde = ingreso ?? entrada;
    await (db.update(db.animales)..where((t) => t.id.equals(a.id))).write(
      AnimalesCompanion(fechaCompra: Value(desde), updatedAt: Value(desde)),
    );
    await (db.update(
      db.movimientosLote,
    )..where((t) => t.animalId.equals(a.id))).write(
      MovimientosLoteCompanion(fecha: Value(desde), updatedAt: Value(desde)),
    );
    return (await pesajes.buscarAnimal('f1', id))!;
  }

  Future<String> peon({double monto = 300000}) => gastos.crearGasto(
    fincaId: 'f1',
    concepto: 'Salario peón',
    monto: monto,
    periodicidad: PeriodicidadGasto.mensual,
    desde: julio,
  );

  test('crear normaliza `desde` al primer día del mes', () async {
    await seed();
    await gastos.crearGasto(
      fincaId: 'f1',
      concepto: 'Luz',
      monto: 25000,
      periodicidad: PeriodicidadGasto.mensual,
      desde: DateTime(2026, 7, 18),
    );
    final fila = (await gastos.gastosDe('f1')).single;
    expect(fila.desde, DateTime(2026, 7, 1));
  });

  test('gasto único conserva su fecha', () async {
    await seed();
    await gastos.crearGasto(
      fincaId: 'f1',
      concepto: 'Cerca',
      monto: 85000,
      periodicidad: PeriodicidadGasto.unico,
      desde: DateTime(2026, 7, 18),
    );
    expect((await gastos.gastosDe('f1')).single.desde, DateTime(2026, 7, 18));
  });

  test('eliminar es borrado suave y deja de contar', () async {
    await seed();
    final id = await peon();
    await gastos.eliminarGasto(id);
    expect(await gastos.gastosDe('f1'), isEmpty);
    final fila = await (db.select(
      db.gastosFijos,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(fila.deletedAt, isNotNull);
    expect(fila.pendiente, isTrue);
  });

  test('la estancia se deriva de la compra y de la venta', () async {
    await seed();
    final a = await animal('A-1');
    final e1 = await gastos.estanciaDe(a);
    expect(e1.ingreso, entrada);
    expect(e1.salida, isNull);

    final ventaFecha = DateTime(2026, 7, 20);
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      fecha: ventaFecha,
      items: [(animalId: a.id, peso: 400, precioKg: 1500)],
    );
    final vendido = (await pesajes.buscarAnimal('f1', 'A-1'))!;
    final e2 = await gastos.estanciaDe(vendido);
    expect(e2.salida, ventaFecha);
  });

  test('un solo animal absorbe el gasto completo del mes', () async {
    await seed();
    final a = await animal('A-1');
    await peon();

    // Al 31 de julio el mes está completo: los ₡300.000 son todos suyos.
    final total = await gastos.gastoFijoDeAnimal(a, hoy: DateTime(2026, 7, 31));
    expect(total, closeTo(300000, 0.01));
  });

  test(
    'dos animales con los mismos días parten el gasto por mitades',
    () async {
      await seed();
      final a = await animal('A-1');
      await animal('B-1');
      await peon();

      final total = await gastos.gastoFijoDeAnimal(
        a,
        hoy: DateTime(2026, 7, 31),
      );
      expect(total, closeTo(150000, 0.01));
    },
  );

  test('el que entró el día 20 paga solo sus 12 días', () async {
    await seed();
    // 10 animales el mes completo + 1 que entró el 20 → 322 días-animal.
    for (var i = 0; i < 10; i++) {
      await animal('A-$i');
    }
    final k = await animal('K-1', ingreso: DateTime(2026, 7, 20));
    await peon();

    final hoy = DateTime(2026, 7, 31);
    final deK = await gastos.gastoFijoDeAnimal(k, hoy: hoy);
    final deA = await gastos.gastoFijoDeAnimal(
      (await pesajes.buscarAnimal('f1', 'A-0'))!,
      hoy: hoy,
    );
    expect(deK, closeTo(11180.12, 0.1));
    expect(deA, closeTo(28881.99, 0.1));
  });

  test('el resumen del mes reporta total y ₡ por animal-día', () async {
    await seed();
    await animal('A-1');
    await animal('B-1');
    await peon(monto: 31000);

    final r = await gastos.resumenMesActual('f1', hoy: DateTime(2026, 7, 31));
    expect(r.mes, julio);
    expect(r.totalDevengado, closeTo(31000, 0.01));
    expect(r.diasAnimal, 62);
    expect(r.animalesActivos, 2);
    expect(r.costoPorAnimalDia, closeTo(500, 0.01));
  });

  test('sin animales el resumen no divide por cero', () async {
    await seed();
    await peon();
    final r = await gastos.resumenMesActual('f1', hoy: DateTime(2026, 7, 31));
    expect(r.diasAnimal, 0);
    expect(r.costoPorAnimalDia, isNull);
  });

  group('congelado al vender', () {
    test('la venta congela la parte del animal en gasto_fijo_cargos', () async {
      await seed();
      final a = await animal('A-1');
      await animal('B-1');
      await peon();

      await ventas.confirmarLoteVenta(
        fincaId: 'f1',
        fecha: DateTime(2026, 7, 31),
        items: [(animalId: a.id, peso: 400, precioKg: 1500)],
      );

      final cargos = await gastos.cargosDe(a.id);
      expect(cargos, hasLength(1));
      expect(cargos.single.mes, julio);
      expect(cargos.single.dias, 31);
      expect(cargos.single.monto, closeTo(150000, 0.01));
      expect(cargos.single.pendiente, isTrue);
    });

    test('la utilidad del vendido resta el gasto fijo congelado', () async {
      await seed();
      final a = await animal('A-1');
      await animal('B-1');
      await peon();

      await ventas.confirmarLoteVenta(
        fincaId: 'f1',
        fecha: DateTime(2026, 7, 31),
        items: [(animalId: a.id, peso: 400, precioKg: 1500)],
      );

      final r = await ventas.resumenDe(a.id);
      expect(r.costoGastosFijos, closeTo(150000, 0.01));
      // 600.000 − (100.000 compra + 0 dietas + 0 sanidad + 150.000 fijos)
      expect(r.utilidad, closeTo(350000, 0.5));
      expect(r.costoTotal, closeTo(250000, 0.5));
    });

    test('un gasto atrasado no cambia la utilidad del ya vendido', () async {
      await seed();
      final a = await animal('A-1');
      await animal('B-1');

      await ventas.confirmarLoteVenta(
        fincaId: 'f1',
        fecha: DateTime(2026, 7, 31),
        items: [(animalId: a.id, peso: 400, precioKg: 1500)],
      );
      final antes = await ventas.resumenDe(a.id);
      expect(antes.costoGastosFijos, 0);

      // Se digita la luz de julio DESPUÉS de vender a A.
      await gastos.crearGasto(
        fincaId: 'f1',
        concepto: 'Luz',
        monto: 60000,
        periodicidad: PeriodicidadGasto.mensual,
        desde: julio,
      );

      final despues = await ventas.resumenDe(a.id);
      expect(despues.costoGastosFijos, 0);
      expect(despues.utilidad, antes.utilidad);

      // Y lo absorbe completo el que sigue en la finca.
      final b = (await pesajes.buscarAnimal('f1', 'B-1'))!;
      final deB = await gastos.gastoFijoDeAnimal(b, hoy: DateTime(2026, 7, 31));
      expect(deB, closeTo(60000, 0.01));
    });

    test(
      'lo congelado se descuenta: B no paga dos veces la parte de A',
      () async {
        await seed();
        final a = await animal('A-1');
        await animal('B-1');
        await peon();

        await ventas.confirmarLoteVenta(
          fincaId: 'f1',
          fecha: DateTime(2026, 7, 31),
          items: [(animalId: a.id, peso: 400, precioKg: 1500)],
        );

        final b = (await pesajes.buscarAnimal('f1', 'B-1'))!;
        final deB = await gastos.gastoFijoDeAnimal(
          b,
          hoy: DateTime(2026, 7, 31),
        );
        final congeladoDeA = (await gastos.cargosDe(a.id)).single.monto;

        expect(deB, closeTo(150000, 0.01));
        expect(congeladoDeA + deB, closeTo(300000, 0.5));
      },
    );

    test('vendidos juntos se reparten entre sí y suman el gasto', () async {
      await seed();
      final a = await animal('A-1');
      final b = await animal('B-1');
      await peon();

      await ventas.confirmarLoteVenta(
        fincaId: 'f1',
        fecha: DateTime(2026, 7, 31),
        items: [
          (animalId: a.id, peso: 400, precioKg: 1500),
          (animalId: b.id, peso: 400, precioKg: 1500),
        ],
      );

      final deA = (await gastos.cargosDe(a.id)).single.monto;
      final deB = (await gastos.cargosDe(b.id)).single.monto;
      expect(deA, closeTo(150000, 0.01));
      expect(deB, closeTo(150000, 0.01));
      expect(deA + deB, closeTo(300000, 0.5));
    });

    test('congelar dos veces no duplica cargos', () async {
      await seed();
      final a = await animal('A-1');
      await peon();

      await gastos.congelarGastosFijos(
        fincaId: 'f1',
        animalIds: [a.id],
        fecha: DateTime(2026, 7, 31),
        hoy: DateTime(2026, 7, 31),
      );
      await gastos.congelarGastosFijos(
        fincaId: 'f1',
        animalIds: [a.id],
        fecha: DateTime(2026, 7, 31),
        hoy: DateTime(2026, 7, 31),
      );
      expect(await gastos.cargosDe(a.id), hasLength(1));
    });
  });

  test('sin gastos fijos la utilidad no cambia (Módulo 7 opcional)', () async {
    await seed();
    final a = await animal('A-1');
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      fecha: DateTime(2026, 7, 31),
      items: [(animalId: a.id, peso: 400, precioKg: 1500)],
    );
    final r = await ventas.resumenDe(a.id);
    expect(r.costoGastosFijos, 0);
    expect(r.utilidad, closeTo(500000, 0.5));
    expect(await gastos.cargosDe(a.id), isEmpty);
  });
}
