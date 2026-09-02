import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';
import '../support/local_db_seed.dart';

/// Flujo offline de la ronda 1 (puntos 6, 11, 13, 14): dinero por kg/semana,
/// ingredientes solo nombres, lote sin dieta, sync de columnas nuevas.
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  late DietasRepository dietas;
  late VentasRepository ventas;
  late FakeSyncRemoteGateway remote;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
    dietas = DietasRepository(db);
    ventas = VentasRepository(db);
    remote = FakeSyncRemoteGateway();
    sync = SyncService(db, remote: remote, esperasReintento: const []);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedBase() async {
    await seedCuentaLocal(db, usuarioId: 'u1', cuentaId: 'cuenta-1');
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca R1',
            creadaPor: 'u1',
            cuentaId: const Value('cuenta-1'),
            createdAt: now,
            updatedAt: now,
            pendiente: const Value(true),
          ),
        );
    await db
        .into(db.fincaMiembros)
        .insert(
          FincaMiembrosCompanion.insert(
            id: 'm1',
            fincaId: 'f1',
            usuarioId: 'u1',
            rol: 'admin',
            createdAt: now,
            updatedAt: now,
            pendiente: const Value(true),
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'l1',
            fincaId: 'f1',
            nombre: 'Lote R1',
            createdAt: now,
            updatedAt: now,
            pendiente: const Value(true),
          ),
        );
  }

  test(
    'ronda1: compra/kg + dieta semanal/ingredientes + venta/kg + sync columnas',
    () async {
      await seedBase();

      await pesajes.crearAnimalConPesaje(
        fincaId: 'f1',
        loteId: 'l1',
        identificador: 'R1-100',
        peso: 100,
        registradoPor: 'u1',
        pesoCompra: 100,
        precioKgCompra: 1000,
        precioCompra: 100000,
      );
      final animal = await pesajes.buscarAnimal('f1', 'R1-100');
      expect(animal!.precioCompra, 100000);
      expect(animal.pesoCompra, 100);
      expect(animal.precioKgCompra, 1000);

      final entrada = DateTime(2025, 1, 1);
      await (db.update(
        db.animales,
      )..where((t) => t.id.equals(animal.id))).write(
        AnimalesCompanion(
          fechaCompra: Value(entrada),
          updatedAt: Value(entrada),
        ),
      );
      await (db.update(
        db.movimientosLote,
      )..where((t) => t.animalId.equals(animal.id))).write(
        MovimientosLoteCompanion(
          fecha: Value(entrada),
          updatedAt: Value(entrada),
        ),
      );

      await dietas.crearDieta(
        fincaId: 'f1',
        nombre: 'Engorde R1',
        costoKg: 500,
        kgAnimalDia: 2,
        ingredientes: ['Pasto', 'Concentrado', 'Melaza'],
      );
      final dieta = (await db.select(db.dietas).get()).single;
      expect(dieta.costoAnimalSemana, 7000);
      expect(dieta.costoAnimalDia, closeTo(1000, 0.0001));
      final ings = await dietas.listarIngredientes(dieta.id);
      expect(ings.map((i) => i.nombre).toSet(), {
        'Pasto',
        'Concentrado',
        'Melaza',
      });
      expect(ings.every((i) => i.costoAnimalDia == 0), isTrue);

      await dietas.asignarDietaALote(loteId: 'l1', dietaId: dieta.id);
      final asig = (await db.select(db.loteDietas).get()).single;
      await (db.update(
        db.loteDietas,
      )..where((t) => t.id.equals(asig.id))).write(
        LoteDietasCompanion(desde: Value(entrada), updatedAt: Value(entrada)),
      );

      final ventaFecha = entrada.add(const Duration(days: 215));
      await ventas.confirmarLoteVenta(
        fincaId: 'f1',
        fecha: ventaFecha,
        items: [(animalId: animal.id, peso: 400)],
      );
      final creada = (await db.select(db.ventas).get()).single;
      expect(creada.peso, 400, reason: 'kilos de salida de la finca');
      // El grupo se crea sin dinero: la utilidad todavía no existe (D-19).
      expect(creada.dineroRecibido, isNull);
      expect((await ventas.resumenDe(animal.id)).utilidad, isNull);

      await ventas.registrarDatosPlanta(
        ventaId: creada.id,
        pesoPie: 400,
        pesoCanal: 220,
        dineroRecibido: 600000,
      );
      final venta = (await db.select(db.ventas).get()).single;
      expect(venta.rendimiento, closeTo(55, 0.0001));
      expect(venta.dineroRecibido, 600000);
      expect(venta.precio, 600000, reason: 'espejo del dinero recibido');
      expect(venta.precioKg, closeTo(600000 / 220, 0.01), reason: '₡/kg canal');

      final r = await ventas.resumenDe(animal.id);
      expect(r.costoAlimentacion, closeTo(215000, 1));
      expect(r.precioVenta, 600000);
      expect(r.utilidad, closeTo(285000, 1));
      expect((await ventas.resumenDe(animal.id)).utilidad, r.utilidad);

      await sync.sincronizar();

      Map<String, dynamic> ultimaSubida(String tabla) {
        final writes = remote.subidas.where((w) => w.tabla == tabla).toList();
        expect(writes, isNotEmpty, reason: 'faltó subida de $tabla');
        return writes.last.datos;
      }

      final animalPush = ultimaSubida('animales');
      expect(animalPush['peso_compra'], 100);
      expect(animalPush['precio_kg_compra'], 1000);

      final dietaPush = ultimaSubida('dietas');
      expect(dietaPush['costo_animal_semana'], 7000);

      final ventaPush = ultimaSubida('ventas');
      expect(ventaPush['precio'], 600000);
      expect(ventaPush['peso'], 400);
      expect(ventaPush['peso_pie'], 400);
      expect(ventaPush['peso_canal'], 220);
      expect(ventaPush['rendimiento'], closeTo(55, 0.0001));
      expect(ventaPush['dinero_recibido'], 600000);

      final ingPush = remote.subidas
          .where((w) => w.tabla == 'dieta_ingredientes')
          .map((w) => w.datos['nombre'] as String)
          .toSet();
      expect(ingPush, containsAll(['Pasto', 'Concentrado', 'Melaza']));
    },
  );

  test(
    'ronda1 #13: lote sin dieta y quitar dieta conserva historial',
    () async {
      await seedBase();
      await dietas.crearDieta(
        fincaId: 'f1',
        nombre: 'Temp',
        costoKg: 500,
        kgAnimalDia: 2,
      );
      final dieta = (await db.select(db.dietas).get()).single;

      expect(await dietas.observarDietaVigente('l1').first, isNull);

      await dietas.asignarDietaALote(loteId: 'l1', dietaId: dieta.id);
      expect(await dietas.observarDietaVigente('l1').first, isNotNull);

      await dietas.quitarDietaDeLote('l1');
      expect(await dietas.observarDietaVigente('l1').first, isNull);

      final historial = await dietas.observarHistorialDietaLote('l1').first;
      expect(historial, hasLength(1));
      expect(historial.single.hasta, isNotNull);
    },
  );
}
