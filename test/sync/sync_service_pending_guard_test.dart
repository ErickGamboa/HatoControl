import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/sync/sync_remote_gateway.dart';
import 'package:hato_control/data/sync/sync_service.dart';

class RemoteWrite {
  const RemoteWrite({
    required this.tabla,
    required this.id,
    required this.datos,
  });

  final String tabla;
  final String id;
  final Map<String, dynamic> datos;
}

class FakeSyncRemoteGateway implements SyncRemoteGateway {
  FakeSyncRemoteGateway({this.tieneUsuario = true, this.tieneSesion = false});

  @override
  final bool tieneUsuario;

  @override
  final bool tieneSesion;

  final descargas = <String, List<Map<String, dynamic>>>{};
  final subidas = <RemoteWrite>[];
  final fallarSubidas = <String>{};

  @override
  Future<void> insertarOActualizar(
    String tabla,
    String id,
    Map<String, dynamic> datos,
  ) async {
    if (fallarSubidas.contains('$tabla:$id')) {
      throw StateError('fallo remoto simulado');
    }
    subidas.add(RemoteWrite(tabla: tabla, id: id, datos: Map.of(datos)));
  }

  @override
  Future<List<Map<String, dynamic>>> consultar(
    String tabla,
    DateTime? cursor,
  ) async {
    final filas = descargas[tabla] ?? const <Map<String, dynamic>>[];
    return filas
        .where((fila) {
          if (cursor == null) return true;
          return DateTime.parse(fila['updated_at'] as String).isAfter(cursor);
        })
        .map(Map<String, dynamic>.of)
        .toList()
      ..sort((a, b) {
        final fechaA = DateTime.parse(a['updated_at'] as String);
        final fechaB = DateTime.parse(b['updated_at'] as String);
        return fechaA.compareTo(fechaB);
      });
  }

  @override
  Future<String?> subirFotoFinca({
    required String fincaId,
    required String imagenBase64,
  }) async {
    return null;
  }
}

void main() {
  late AppDatabase db;
  late FakeSyncRemoteGateway remote;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    remote = FakeSyncRemoteGateway();
    sync = SyncService(db, remote: remote);
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
