import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

/// Módulo 7 en el sync: ningún módulo queda afuera (`docs/CORRECCIONES.md`).
void main() {
  late AppDatabase db;
  late FakeSyncRemoteGateway remote;
  late SyncService sync;

  final now = DateTime(2026, 8, 1);
  final julio = DateTime(2026, 7, 1);

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    remote = FakeSyncRemoteGateway();
    sync = SyncService(db, remote: remote, esperasReintento: const []);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedGasto({bool pendiente = true, DateTime? hasta}) async {
    await db
        .into(db.gastosFijos)
        .insert(
          GastosFijosCompanion.insert(
            id: 'gasto-1',
            fincaId: 'finca-1',
            concepto: 'Salario peón',
            monto: 300000,
            periodicidad: 'mensual',
            desde: julio,
            hasta: Value(hasta),
            createdAt: now,
            updatedAt: now,
            pendiente: Value(pendiente),
          ),
        );
  }

  Future<void> seedCargo({bool pendiente = true}) async {
    await db
        .into(db.gastoFijoCargos)
        .insert(
          GastoFijoCargosCompanion.insert(
            id: 'cargo-1',
            gastoFijoId: 'gasto-1',
            animalId: 'animal-1',
            mes: julio,
            dias: 31,
            monto: 150000,
            createdAt: now,
            updatedAt: now,
            pendiente: Value(pendiente),
          ),
        );
  }

  test('sube gastos fijos pendientes y limpia la bandera', () async {
    await seedGasto();

    await sync.sincronizar();

    final subida = remote.subidas.singleWhere((s) => s.tabla == 'gastos_fijos');
    expect(subida.id, 'gasto-1');
    expect(subida.datos['concepto'], 'Salario peón');
    expect(subida.datos['monto'], 300000);
    expect(subida.datos['periodicidad'], 'mensual');
    expect(subida.datos['desde'], julio.toIso8601String());
    expect(subida.datos['hasta'], isNull);
    // `updated_at` lo pone el trigger del servidor, no viaja en el push.
    expect(subida.datos.containsKey('updated_at'), isFalse);

    final fila = await (db.select(
      db.gastosFijos,
    )..where((t) => t.id.equals('gasto-1'))).getSingle();
    expect(fila.pendiente, isFalse);
  });

  test('sube cargos congelados pendientes', () async {
    await seedCargo();

    await sync.sincronizar();

    final subida = remote.subidas.singleWhere(
      (s) => s.tabla == 'gasto_fijo_cargos',
    );
    expect(subida.id, 'cargo-1');
    expect(subida.datos['gasto_fijo_id'], 'gasto-1');
    expect(subida.datos['animal_id'], 'animal-1');
    expect(subida.datos['dias'], 31);
    expect(subida.datos['monto'], 150000);

    final fila = await (db.select(
      db.gastoFijoCargos,
    )..where((t) => t.id.equals('cargo-1'))).getSingle();
    expect(fila.pendiente, isFalse);
  });

  test('baja un gasto fijo nuevo y avanza el cursor', () async {
    final updatedAt = DateTime(2026, 8, 4);
    remote.descargas['gastos_fijos'] = [
      {
        'id': 'gasto-remoto',
        'finca_id': 'finca-1',
        'concepto': 'Luz',
        'monto': 25000,
        'periodicidad': 'mensual',
        'desde': julio.toIso8601String(),
        'hasta': null,
        'moneda': 'CRC',
        'created_at': now.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': null,
      },
    ];

    await sync.sincronizar();

    final fila = await (db.select(
      db.gastosFijos,
    )..where((t) => t.id.equals('gasto-remoto'))).getSingle();
    expect(fila.concepto, 'Luz');
    expect(fila.monto, 25000);
    expect(fila.moneda, 'CRC');
    expect(fila.pendiente, isFalse);

    final cursor = await (db.select(
      db.syncCursores,
    )..where((t) => t.tabla.equals('gastos_fijos'))).getSingle();
    expect(cursor.ultimaBajada, updatedAt);
  });

  test('la bajada no pisa un gasto con cambios locales pendientes', () async {
    await seedGasto();
    remote.fallarSubidas.add('gastos_fijos:gasto-1');
    remote.descargas['gastos_fijos'] = [
      {
        'id': 'gasto-1',
        'finca_id': 'finca-1',
        'concepto': 'SERVIDOR',
        'monto': 1,
        'periodicidad': 'mensual',
        'desde': julio.toIso8601String(),
        'hasta': null,
        'moneda': 'CRC',
        'created_at': now.toIso8601String(),
        'updated_at': DateTime(2026, 8, 5).toIso8601String(),
        'deleted_at': null,
      },
    ];

    await sync.sincronizar();

    final fila = await (db.select(
      db.gastosFijos,
    )..where((t) => t.id.equals('gasto-1'))).getSingle();
    expect(fila.concepto, 'Salario peón');
    expect(fila.pendiente, isTrue);

    final cursor = await (db.select(
      db.syncCursores,
    )..where((t) => t.tabla.equals('gastos_fijos'))).getSingleOrNull();
    expect(cursor, isNull);
  });

  test('el borrado suave viaja como deleted_at', () async {
    await db
        .into(db.gastosFijos)
        .insert(
          GastosFijosCompanion.insert(
            id: 'gasto-borrado',
            fincaId: 'finca-1',
            concepto: 'Viejo',
            monto: 1000,
            periodicidad: 'unico',
            desde: julio,
            createdAt: now,
            updatedAt: now,
            deletedAt: Value(DateTime(2026, 8, 2)),
            pendiente: const Value(true),
          ),
        );

    await sync.sincronizar();

    final subida = remote.subidas.singleWhere((s) => s.tabla == 'gastos_fijos');
    expect(subida.datos['deleted_at'], DateTime(2026, 8, 2).toIso8601String());
  });
}
