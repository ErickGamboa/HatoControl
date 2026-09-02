import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

void main() {
  late AppDatabase db;
  late VentasRepository ventasRepo;
  late SanidadRepository sanidadRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    ventasRepo = VentasRepository(db);
    sanidadRepo = SanidadRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedAnimal() async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
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
            id: 'lote-1',
            fincaId: 'finca-1',
            nombre: 'Lote',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: 'animal-1',
            fincaId: 'finca-1',
            loteId: 'lote-1',
            identificador: 'A-1',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('registrarVenta marca animal vendido y pendiente', () async {
    await seedAnimal();
    await ventasRepo.registrarVenta(animalId: 'animal-1', precio: 780000);

    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals('animal-1'))).getSingle();
    expect(animal.estado, EstadoAnimal.vendido);
    expect(animal.pendiente, isTrue);
    expect(await db.select(db.ventas).get(), hasLength(1));
  });

  test('resumen incluye costos sanitarios de eventos', () async {
    await seedAnimal();
    await sanidadRepo.registrarEvento(
      animalId: 'animal-1',
      tipo: TipoEventoSanitario.medicamento,
      producto: 'Ivermectina',
      costo: 18000,
    );
    await ventasRepo.actualizarCompra(
      animalId: 'animal-1',
      pesoCompra: 200,
      precioKgCompra: 2600,
      precioCompra: 520000,
    );

    final r = await ventasRepo.resumenDe('animal-1');
    expect(r.precioCompra, 520000);
    expect(r.costoSanitario, 18000);
  });

  group('datos de planta (D-19)', () {
    /// Segundo animal para poder probar grupos de dos.
    Future<void> seedAnimal2() async {
      final now = DateTime(2026, 1, 1);
      await db
          .into(db.animales)
          .insert(
            AnimalesCompanion.insert(
              id: 'animal-2',
              fincaId: 'finca-1',
              loteId: 'lote-1',
              identificador: 'A-2',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    test('el grupo se crea solo con kilos de salida, sin dinero', () async {
      await seedAnimal();
      await ventasRepo.confirmarLoteVenta(
        fincaId: 'finca-1',
        items: [(animalId: 'animal-1', peso: 450)],
      );

      final venta = (await db.select(db.ventas).get()).single;
      expect(venta.peso, 450);
      expect(venta.pesoPie, isNull);
      expect(venta.pesoCanal, isNull);
      expect(venta.rendimiento, isNull);
      expect(venta.dineroRecibido, isNull);
      expect(venta.precio, 0);

      // Sin dinero no hay utilidad: “—”, nunca ₡0.
      expect((await ventasRepo.resumenDe('animal-1')).utilidad, isNull);
    });

    test('registrarDatosPlanta calcula el rendimiento y la utilidad', () async {
      await seedAnimal();
      await ventasRepo.actualizarCompra(
        animalId: 'animal-1',
        pesoCompra: 200,
        precioKgCompra: 1000,
        precioCompra: 200000,
      );
      await ventasRepo.confirmarLoteVenta(
        fincaId: 'finca-1',
        items: [(animalId: 'animal-1', peso: 450)],
      );
      final ventaId = (await db.select(db.ventas).get()).single.id;

      await ventasRepo.registrarDatosPlanta(
        ventaId: ventaId,
        pesoPie: 450,
        pesoCanal: 252,
        dineroRecibido: 1260000,
      );

      final venta = (await db.select(db.ventas).get()).single;
      expect(venta.pesoPie, 450);
      expect(venta.pesoCanal, 252);
      expect(venta.rendimiento, closeTo(56, 0.0001));
      expect(venta.dineroRecibido, 1260000);
      expect(venta.precio, 1260000, reason: 'espejo del dinero recibido');
      expect(venta.precioKg, closeTo(5000, 0.01), reason: '₡/kg de canal');
      expect(venta.pendiente, isTrue);
      // Los kilos de salida de finca no se tocan.
      expect(venta.peso, 450);

      final r = await ventasRepo.resumenDe('animal-1');
      expect(r.precioVenta, 1260000);
      expect(r.rendimiento, closeTo(56, 0.0001));
      expect(r.utilidad, closeTo(1060000, 0.5));
    });

    test('acepta datos parciales: pesos sin dinero todavía', () async {
      await seedAnimal();
      await ventasRepo.confirmarLoteVenta(
        fincaId: 'finca-1',
        items: [(animalId: 'animal-1', peso: 450)],
      );
      final ventaId = (await db.select(db.ventas).get()).single.id;

      await ventasRepo.registrarDatosPlanta(
        ventaId: ventaId,
        pesoPie: 440,
        pesoCanal: 220,
      );

      final venta = (await db.select(db.ventas).get()).single;
      expect(venta.rendimiento, closeTo(50, 0.0001));
      expect(venta.dineroRecibido, isNull);
      expect((await ventasRepo.resumenDe('animal-1')).utilidad, isNull);
    });

    test('canal mayor que pie no deja rendimiento inventado', () async {
      await seedAnimal();
      await ventasRepo.confirmarLoteVenta(
        fincaId: 'finca-1',
        items: [(animalId: 'animal-1', peso: 450)],
      );
      final ventaId = (await db.select(db.ventas).get()).single.id;

      await ventasRepo.registrarDatosPlanta(
        ventaId: ventaId,
        pesoPie: 200,
        pesoCanal: 300,
        dineroRecibido: 500000,
      );

      final venta = (await db.select(db.ventas).get()).single;
      expect(venta.rendimiento, isNull);
      expect(venta.dineroRecibido, 500000);
    });

    test('análisis del grupo: utilidad total y rendimiento promedio', () async {
      await seedAnimal();
      await seedAnimal2();
      for (final id in ['animal-1', 'animal-2']) {
        await ventasRepo.actualizarCompra(
          animalId: id,
          pesoCompra: 200,
          precioKgCompra: 1000,
          precioCompra: 200000,
        );
      }
      await ventasRepo.confirmarLoteVenta(
        fincaId: 'finca-1',
        items: [
          (animalId: 'animal-1', peso: 450),
          (animalId: 'animal-2', peso: 400),
        ],
      );

      final ventas = await db.select(db.ventas).get();
      final v1 = ventas.firstWhere((v) => v.animalId == 'animal-1');
      final v2 = ventas.firstWhere((v) => v.animalId == 'animal-2');

      // Solo uno liquidado: el promedio usa únicamente los que tienen datos.
      await ventasRepo.registrarDatosPlanta(
        ventaId: v1.id,
        pesoPie: 450,
        pesoCanal: 252,
        dineroRecibido: 1260000,
      );

      var grupo = (await ventasRepo.observarLotesVenta('finca-1').first).single;
      expect(grupo.total, 2);
      expect(grupo.conDatosPlanta, 1);
      expect(grupo.pendientesDeDatos, 1);
      expect(grupo.completo, isFalse);
      expect(grupo.rendimientoPromedio, closeTo(56, 0.0001));
      expect(grupo.dineroRecibidoTotal, 1260000);
      expect(grupo.pesoFincaTotal, 850, reason: 'kilos de salida de los dos');
      expect(grupo.utilidadTotal, closeTo(1060000, 0.5));

      // Al liquidar el segundo, el promedio y los totales se completan.
      await ventasRepo.registrarDatosPlanta(
        ventaId: v2.id,
        pesoPie: 400,
        pesoCanal: 216,
        dineroRecibido: 1080000,
      );

      grupo = (await ventasRepo.observarLotesVenta('finca-1').first).single;
      expect(grupo.conDatosPlanta, 2);
      expect(grupo.completo, isTrue);
      // (56 + 54) ÷ 2
      expect(grupo.rendimientoPromedio, closeTo(55, 0.0001));
      expect(grupo.dineroRecibidoTotal, 2340000);
      expect(grupo.pesoPieTotal, 850);
      expect(grupo.pesoCanalTotal, 468);
      expect(grupo.precioKgCanal, closeTo(2340000 / 468, 0.01));
      expect(grupo.utilidadTotal, closeTo(1940000, 0.5));
    });
  });
}
