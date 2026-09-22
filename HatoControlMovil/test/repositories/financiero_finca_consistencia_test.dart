import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/estadisticas/estadisticas_economicas.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/gastos_fijos_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

/// EL INVARIANTE DEL MÓDULO ANÁLISIS: la pantalla de Análisis financiero y la
/// ficha del animal tienen que decir EXACTAMENTE los mismos números.
///
/// `financieroDeFinca` calcula la finca entera de una sola pasada (por
/// velocidad) y `resumenDe` calcula un animal como lo muestra su ficha. Este
/// test compara los dos, animal por animal y campo por campo, sobre una finca
/// con de todo: animales en pie, vendidos con y sin liquidar, con dietas,
/// cambios de lote, sanidad, gastos fijos prorrateados y cargos congelados.
///
/// Si alguien toca cualquiera de los dos caminos y los números se separan,
/// este test se cae.
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  late VentasRepository ventas;
  late DietasRepository dietas;
  late SanidadRepository sanidad;
  late GastosFijosRepository gastos;

  final haceTresMeses = DateTime(2026, 6, 15);

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
    ventas = VentasRepository(db);
    dietas = DietasRepository(db);
    sanidad = SanidadRepository(db);
    gastos = GastosFijosRepository(db);

    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca',
            creadaPor: 'u1',
            createdAt: haceTresMeses,
            updatedAt: haceTresMeses,
          ),
        );
    for (final (id, nombre) in [('l1', 'Engorde'), ('l2', 'Terminación')]) {
      await db
          .into(db.lotes)
          .insert(
            LotesCompanion.insert(
              id: id,
              fincaId: 'f1',
              nombre: nombre,
              createdAt: haceTresMeses,
              updatedAt: haceTresMeses,
            ),
          );
    }
  });

  tearDown(() async => db.close());

  /// Crea el animal y le atrasa el pesaje de entrada, porque `crearAnimal…`
  /// lo fecha hoy y una finca de verdad tiene animales que entraron antes.
  Future<AnimalRow> crearAnimal(
    String ident, {
    String loteId = 'l1',
    double peso = 200,
    double precioKg = 1000,
    DateTime? fechaCompra,
    DateTime? entradaEl,
  }) async {
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: loteId,
      identificador: ident,
      peso: peso,
      registradoPor: 'u1',
      pesoCompra: peso,
      precioKgCompra: precioKg,
    );
    final a = (await pesajes.buscarAnimal('f1', ident))!;

    final entrada = entradaEl ?? haceTresMeses;
    await (db.update(db.pesajes)..where((t) => t.animalId.equals(a.id))).write(
      PesajesCompanion(fecha: Value(entrada)),
    );
    await (db.update(db.movimientosLote)
          ..where((t) => t.animalId.equals(a.id)))
        .write(MovimientosLoteCompanion(fecha: Value(entrada)));

    if (fechaCompra != null) {
      await (db.update(db.animales)..where((t) => t.id.equals(a.id))).write(
        AnimalesCompanion(fechaCompra: Value(fechaCompra)),
      );
    }
    return (await pesajes.buscarAnimal('f1', ident))!;
  }

  /// Una finca con de todo, para que la comparación no sea de juguete.
  Future<void> sembrarFincaCompleta() async {
    await dietas.crearDieta(
      fincaId: 'f1',
      nombre: 'Engorde',
      costoKg: 500,
      kgAnimalDia: 2,
    );
    final dieta = (await dietas.observarDietas('f1').first).single;
    await dietas.asignarDietaALote(loteId: 'l1', dietaId: dieta.id);
    await dietas.asignarDietaALote(loteId: 'l2', dietaId: dieta.id);

    await gastos.crearGasto(
      fincaId: 'f1',
      concepto: 'Peón',
      monto: 173333,
      periodicidad: PeriodicidadGasto.mensual,
      desde: DateTime(2026, 7, 1),
    );
    await gastos.crearGasto(
      fincaId: 'f1',
      concepto: 'Agua',
      monto: 5000,
      periodicidad: PeriodicidadGasto.unico,
      desde: DateTime(2026, 8, 10),
    );

    // 1) En pie, con dieta, sanidad y fecha de compra digitada.
    final enPie = await crearAnimal('0001', fechaCompra: DateTime(2026, 6, 20));
    await sanidad.registrarEvento(
      animalId: enPie.id,
      tipo: 'medicamento',
      producto: 'Ivermectina',
      fecha: DateTime(2026, 7, 5),
      costo: 3500,
    );

    // 2) En pie, sin nada más que su pesaje de entrada.
    await crearAnimal('0002', peso: 180);

    // 3) En pie y movido de lote (dos periodos de dieta).
    final movido = await crearAnimal('0003', peso: 210);
    await pesajes.moverAnimalDeLote(animalId: movido.id, nuevoLoteId: 'l2');

    // 4) Nacido en la finca (₡/kg 0: no tiene costo de compra).
    await crearAnimal('0004', peso: 40, precioKg: 0);

    // 5) Vendido y liquidado (tiene cargos congelados de gasto fijo).
    final vendido = await crearAnimal('0005', peso: 300);
    await sanidad.registrarEvento(
      animalId: vendido.id,
      tipo: 'vacuna',
      producto: 'Triple',
      fecha: DateTime(2026, 8, 1),
      costo: 1200,
    );
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      items: [(animalId: vendido.id, peso: 430)],
    );
    final ventaFila = (await (db.select(
      db.ventas,
    )..where((t) => t.animalId.equals(vendido.id))).get()).single;
    await ventas.registrarDatosPlanta(
      ventaId: ventaFila.id,
      pesoPie: 430,
      pesoCanal: 240,
      dineroRecibido: 900000,
    );

    // 6) Vendido pero SIN liquidar: utilidad null, nunca ₡0.
    final sinLiquidar = await crearAnimal('0006', peso: 280);
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      items: [(animalId: sinLiquidar.id, peso: 400)],
    );

    // Un segundo pesaje para varios, para que kilosGanados no sea 0.
    for (final ident in ['0001', '0002', '0003']) {
      final a = (await pesajes.buscarAnimal('f1', ident))!;
      await pesajes.registrarPesajeEnFecha(
        animalId: a.id,
        peso: 260,
        fecha: DateTime(2026, 9, 1),
        registradoPor: 'u1',
      );
    }
  }

  void compararResumen(
    String ident,
    ResumenEconomicoAnimal enAnalisis,
    ResumenEconomicoAnimal enFicha,
  ) {
    String porque(String campo) => '$campo del animal $ident';

    expect(
      enAnalisis.precioCompra,
      enFicha.precioCompra,
      reason: porque('precioCompra'),
    );
    expect(
      enAnalisis.pesoCompra,
      enFicha.pesoCompra,
      reason: porque('pesoCompra'),
    );
    expect(
      enAnalisis.precioKgCompra,
      enFicha.precioKgCompra,
      reason: porque('precioKgCompra'),
    );
    expect(
      enAnalisis.costoAlimentacion,
      enFicha.costoAlimentacion,
      reason: porque('costoAlimentacion'),
    );
    expect(
      enAnalisis.costoSanitario,
      enFicha.costoSanitario,
      reason: porque('costoSanitario'),
    );
    expect(
      enAnalisis.costoGastosFijos,
      enFicha.costoGastosFijos,
      reason: porque('costoGastosFijos'),
    );
    expect(
      enAnalisis.precioVenta,
      enFicha.precioVenta,
      reason: porque('precioVenta'),
    );
    expect(enAnalisis.pesoVenta, enFicha.pesoVenta, reason: porque('pesoVenta'));
    expect(
      enAnalisis.precioKgVenta,
      enFicha.precioKgVenta,
      reason: porque('precioKgVenta'),
    );
    expect(enAnalisis.pesoPie, enFicha.pesoPie, reason: porque('pesoPie'));
    expect(
      enAnalisis.pesoCanal,
      enFicha.pesoCanal,
      reason: porque('pesoCanal'),
    );
    expect(
      enAnalisis.rendimiento,
      enFicha.rendimiento,
      reason: porque('rendimiento'),
    );
    expect(
      enAnalisis.costoTotal,
      enFicha.costoTotal,
      reason: porque('costoTotal'),
    );
    expect(enAnalisis.utilidad, enFicha.utilidad, reason: porque('utilidad'));
    expect(
      enAnalisis.compraConfiable,
      enFicha.compraConfiable,
      reason: porque('compraConfiable'),
    );
  }

  test('Análisis financiero dice lo mismo que la ficha, animal por animal', () async {
    await sembrarFincaCompleta();

    final delAnalisis = await ventas.financieroDeFinca('f1');
    expect(delAnalisis, hasLength(6));

    for (final fila in delAnalisis) {
      final deLaFicha = await ventas.resumenDe(fila.animal.id);
      compararResumen(fila.animal.identificador, fila.resumen, deLaFicha);
    }
  });

  test('los kilos ganados son el último peso menos el primero', () async {
    await sembrarFincaCompleta();

    final porIdent = {
      for (final f in await ventas.financieroDeFinca('f1'))
        f.animal.identificador: f,
    };

    // 0001: entró con 200 y el 1/9 quedó en 260.
    expect(porIdent['0001']!.kilosGanados, 60);
    // 0004 tiene un solo pesaje: no ganó nada todavía.
    expect(porIdent['0004']!.kilosGanados, 0);
  });

  test('el animal muerto no entra en el análisis', () async {
    await sembrarFincaCompleta();
    final a = (await pesajes.buscarAnimal('f1', '0002'))!;
    await (db.update(db.animales)..where((t) => t.id.equals(a.id))).write(
      const AnimalesCompanion(estado: Value('muerto')),
    );

    final delAnalisis = await ventas.financieroDeFinca('f1');
    expect(delAnalisis.map((f) => f.animal.identificador), isNot(contains('0002')));
    expect(delAnalisis, hasLength(5));
  });

  test('los pesajes de OTRA finca no se meten en los kilos de esta', () async {
    await sembrarFincaCompleta();

    // Otra finca en el mismo aparato, con un animal que ganó muchísimo.
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f2',
            nombre: 'Otra',
            creadaPor: 'u1',
            createdAt: haceTresMeses,
            updatedAt: haceTresMeses,
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'l9',
            fincaId: 'f2',
            nombre: 'Lote',
            createdAt: haceTresMeses,
            updatedAt: haceTresMeses,
          ),
        );
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f2',
      loteId: 'l9',
      identificador: '9999',
      peso: 500,
      registradoPor: 'u1',
      pesoCompra: 500,
      precioKgCompra: 1000,
    );

    final delAnalisis = await ventas.financieroDeFinca('f1');
    expect(delAnalisis, hasLength(6));
    expect(
      delAnalisis.map((f) => f.animal.fincaId).toSet(),
      {'f1'},
      reason: 'solo los animales de la finca que se está viendo',
    );
  });
}
