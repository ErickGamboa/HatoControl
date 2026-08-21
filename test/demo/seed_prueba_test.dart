import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/gastos_fijos_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/medicamentos_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';
import 'package:hato_control/demo/seed_prueba.dart';

/// Verifica los números redondos del set de prueba y cómo se entrelazan los
/// módulos, sin depender del emulador.
void main() {
  late AppDatabase db;
  late SeedPrueba seed;
  late FincasRepository fincas;
  late PesajesRepository pesajes;
  late VentasRepository ventas;

  const usuarioId = 'user-erick';

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    fincas = FincasRepository(db);
    pesajes = PesajesRepository(db);
    final medicamentos = MedicamentosRepository(db);
    final sanidad = SanidadRepository(db, medicamentosRepository: medicamentos);
    final gastosFijos = GastosFijosRepository(db);
    ventas = VentasRepository(
      db,
      gastosFijosRepository: gastosFijos,
      sanidadRepository: sanidad,
    );
    seed = SeedPrueba(
      database: db,
      fincas: fincas,
      lotes: LotesRepository(db),
      pesajes: pesajes,
      dietas: DietasRepository(db),
      sanidad: sanidad,
      ventas: ventas,
      medicamentos: medicamentos,
      gastosFijos: gastosFijos,
    );

    // La licencia se baja del servidor: sin ella crearFinca no procede.
    final now = DateTime(2026, 8, 21);
    await db
        .into(db.planes)
        .insert(
          PlanesCompanion.insert(
            codigo: 'light',
            nombre: 'Light',
            limiteFincas: 1,
            updatedAt: now,
          ),
        );
    await db
        .into(db.cuentas)
        .insert(
          CuentasCompanion.insert(
            id: 'cuenta-1',
            nombre: 'Mi cuenta',
            duenoId: usuarioId,
            plan: 'light',
            estado: 'activa',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: usuarioId,
            nombre: const Value('Erick'),
            email: const Value('erick.yosue@gmail.com'),
            cuentaId: const Value('cuenta-1'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await seed.sembrarSiFalta(usuarioId: usuarioId);
  });

  tearDown(() async {
    await db.close();
  });

  Future<AnimalRow> animal(String identificador) async {
    final finca = (await fincas.observarFincas(usuarioId).first).single;
    return (await pesajes.buscarAnimal(finca.id, identificador))!;
  }

  test('siembra una finca con un lote, una dieta y tres animales', () async {
    final f = (await fincas.observarFincas(usuarioId).first).single;
    expect(f.nombre, SeedPrueba.fincaNombre);
    expect(await db.select(db.lotes).get(), hasLength(1));
    expect(await db.select(db.dietas).get(), hasLength(1));
    expect(await db.select(db.animales).get(), hasLength(3));
    // Dos pesajes por animal (entrada + hoy) y uno extra: confirmar la venta
    // guarda los kilos de salida como pesaje del animal vendido.
    expect(await db.select(db.pesajes).get(), hasLength(7));
    expect(await db.select(db.medicamentos).get(), hasLength(1));
    expect(await db.select(db.eventosSanitarios).get(), hasLength(3));
    expect(await db.select(db.gastosFijos).get(), hasLength(1));
    expect(await db.select(db.ventas).get(), hasLength(1));
  });

  test('todo queda pendiente de sincronizar', () async {
    final pend = await db.select(db.pesajes).get();
    expect(pend.every((p) => p.pendiente), isTrue);
    final an = await db.select(db.animales).get();
    expect(an.every((a) => a.pendiente), isTrue);
  });

  test(
    'dieta: ₡100/kg × 10 kg = ₡1.000 por animal/día y ₡7.000/semana',
    () async {
      final dieta = (await db.select(db.dietas).get()).single;
      expect(dieta.costoKg, 100);
      expect(dieta.kgAnimalDia, 10);
      expect(dieta.costoAnimalDia, 1000);
      expect(dieta.costoAnimalSemana, 7000);
    },
  );

  test('pesajes: 200 → 210 kg en 10 días = 1,0 kg/día', () async {
    final a1 = await animal('A-1');
    final filas = await (db.select(
      db.pesajes,
    )..where((t) => t.animalId.equals(a1.id))).get();
    filas.sort((x, y) => x.fecha.compareTo(y.fecha));

    expect(filas.first.peso, 200);
    expect(filas.last.peso, 210);
    final dias = filas.last.fecha.difference(filas.first.fecha).inDays;
    expect(dias, SeedPrueba.diasEstadia);
    expect((filas.last.peso - filas.first.peso) / dias, 1.0);
  });

  test(
    'sanidad: envase ₡10.000 ÷ 100 aplicaciones = ₡100 por animal',
    () async {
      final eventos = await db.select(db.eventosSanitarios).get();
      expect(eventos, hasLength(3));
      expect(eventos.every((e) => e.costo == 100), isTrue);
    },
  );

  test('economía de un animal sin vender: compra + dieta + sanidad', () async {
    final a1 = await animal('A-1');
    final r = await ventas.resumenDe(a1.id);

    expect(r.precioCompra, 200000);
    expect(r.pesoCompra, 200);
    expect(r.precioKgCompra, 1000);
    // 10 días × ₡1.000 = ₡10.000 de dieta.
    expect(r.costoAlimentacion, 10000);
    expect(r.costoSanitario, 100);
    // Sin venta no hay utilidad, nunca ₡0.
    expect(r.precioVenta, isNull);
    expect(r.utilidad, isNull);
  });

  test(
    'venta de A-3: rendimiento derivado y utilidad contra el dinero recibido',
    () async {
      final a3 = await animal('A-3');
      final r = await ventas.resumenDe(a3.id);

      expect(a3.estado, EstadoAnimal.vendido);
      expect(r.pesoPie, 205);
      expect(r.pesoCanal, 105);
      // 105 / 205 × 100 = 51,22 % — derivado, no digitado.
      expect(r.rendimiento, closeTo(51.22, 0.01));
      expect(r.precioVenta, 300000);

      // La utilidad sale del dinero recibido menos todos los costos.
      final costos =
          r.precioCompra! +
          r.costoAlimentacion +
          r.costoSanitario +
          r.costoOtros +
          r.costoGastosFijos;
      expect(r.costoTotal, closeTo(costos, 0.01));
      expect(r.utilidad, closeTo(300000 - costos, 0.01));
    },
  );

  test('es idempotente: correrlo de nuevo no duplica nada', () async {
    await seed.sembrarSiFalta(usuarioId: usuarioId);

    expect(await db.select(db.fincas).get(), hasLength(1));
    expect(await db.select(db.animales).get(), hasLength(3));
    expect(await db.select(db.pesajes).get(), hasLength(7));
  });

  test('siembra dentro de una finca que ya existía y está vacía', () async {
    // Caso real: el usuario creó "Finca de Erick" desde la app antes de
    // sembrar. El plan light solo permite una finca, así que hay que reusarla
    // en vez de intentar crear otra.
    final db2 = AppDatabase.forExecutor(NativeDatabase.memory());
    addTearDown(db2.close);
    final fincas2 = FincasRepository(db2);
    final pesajes2 = PesajesRepository(db2);
    final medicamentos2 = MedicamentosRepository(db2);
    final sanidad2 = SanidadRepository(
      db2,
      medicamentosRepository: medicamentos2,
    );
    final gastos2 = GastosFijosRepository(db2);
    final seed2 = SeedPrueba(
      database: db2,
      fincas: fincas2,
      lotes: LotesRepository(db2),
      pesajes: pesajes2,
      dietas: DietasRepository(db2),
      sanidad: sanidad2,
      ventas: VentasRepository(
        db2,
        gastosFijosRepository: gastos2,
        sanidadRepository: sanidad2,
      ),
      medicamentos: medicamentos2,
      gastosFijos: gastos2,
    );

    final now = DateTime(2026, 8, 21);
    await db2
        .into(db2.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-existente',
            nombre: SeedPrueba.fincaNombre,
            creadaPor: usuarioId,
            cuentaId: const Value('cuenta-1'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db2
        .into(db2.fincaMiembros)
        .insert(
          FincaMiembrosCompanion.insert(
            id: 'miembro-existente',
            fincaId: 'finca-existente',
            usuarioId: usuarioId,
            rol: RolFinca.admin,
            createdAt: now,
            updatedAt: now,
          ),
        );

    await seed2.sembrarSiFalta(usuarioId: usuarioId);

    // No creó una segunda finca: sembró en la que ya estaba.
    expect(await db2.select(db2.fincas).get(), hasLength(1));
    expect(await db2.select(db2.animales).get(), hasLength(3));
    final lotes = await db2.select(db2.lotes).get();
    expect(lotes.single.fincaId, 'finca-existente');
  });
}
