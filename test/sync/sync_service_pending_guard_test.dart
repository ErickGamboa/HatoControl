import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

void main() {
  late AppDatabase db;
  late FakeSyncRemoteGateway remote;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    remote = FakeSyncRemoteGateway();
    sync = SyncService(db, remote: remote, esperasReintento: const []);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedAnimal({required bool pendiente}) async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: 'animal-1',
            fincaId: 'finca-1',
            loteId: 'lote-1',
            identificador: 'A-001',
            createdAt: now,
            updatedAt: now,
            pendiente: Value(pendiente),
          ),
        );
  }

  Map<String, dynamic> animalRemoto({
    String id = 'animal-1',
    String identificador = 'A-001',
    DateTime? updatedAt,
  }) {
    final fecha = updatedAt ?? DateTime(2026, 1, 2);
    return {
      'id': id,
      'finca_id': 'finca-1',
      'lote_id': 'lote-1',
      'identificador': identificador,
      'created_at': DateTime(2026, 1, 1).toIso8601String(),
      'updated_at': fecha.toIso8601String(),
      'deleted_at': null,
    };
  }

  test('detecta filas locales pendientes que no debe pisar al bajar', () async {
    await seedAnimal(pendiente: true);

    final tienePendiente = await sync.tieneCambiosLocalesPendientes(
      'animales',
      'animal-1',
    );

    expect(tienePendiente, isTrue);
  });

  test(
    'permite aplicar bajadas sobre filas ya sincronizadas o nuevas',
    () async {
      await seedAnimal(pendiente: false);

      expect(
        await sync.tieneCambiosLocalesPendientes('animales', 'animal-1'),
        isFalse,
      );
      expect(
        await sync.tieneCambiosLocalesPendientes('animales', 'animal-nuevo'),
        isFalse,
      );
    },
  );

  test('sube animales pendientes y limpia la bandera local', () async {
    await seedAnimal(pendiente: true);

    await sync.sincronizar();

    final subidaAnimal = remote.subidas.singleWhere(
      (subida) => subida.tabla == 'animales',
    );
    expect(subidaAnimal.id, 'animal-1');
    expect(subidaAnimal.datos['identificador'], 'A-001');

    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals('animal-1'))).getSingle();
    expect(animal.pendiente, isFalse);
  });

  test(
    'si falla la subida, la bajada no pisa cambios locales ni avanza cursor',
    () async {
      await seedAnimal(pendiente: true);
      remote.fallarSubidas.add('animales:animal-1');
      remote.descargas['animales'] = [
        animalRemoto(
          identificador: 'SERVIDOR',
          updatedAt: DateTime(2026, 1, 3),
        ),
      ];

      await sync.sincronizar();

      final animal = await (db.select(
        db.animales,
      )..where((t) => t.id.equals('animal-1'))).getSingle();
      expect(animal.identificador, 'A-001');
      expect(animal.pendiente, isTrue);

      final cursor = await (db.select(
        db.syncCursores,
      )..where((t) => t.tabla.equals('animales'))).getSingleOrNull();
      expect(cursor, isNull);
    },
  );

  test('baja animales nuevos y avanza el cursor de la tabla', () async {
    final updatedAt = DateTime(2026, 1, 4);
    remote.descargas['animales'] = [
      animalRemoto(
        id: 'animal-remoto',
        identificador: 'R-001',
        updatedAt: updatedAt,
      ),
    ];

    await sync.sincronizar();

    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals('animal-remoto'))).getSingle();
    expect(animal.identificador, 'R-001');
    expect(animal.pendiente, isFalse);

    final cursor = await (db.select(
      db.syncCursores,
    )..where((t) => t.tabla.equals('animales'))).getSingle();
    expect(cursor.ultimaBajada, updatedAt);
  });
}
