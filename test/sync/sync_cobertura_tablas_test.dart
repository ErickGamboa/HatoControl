import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

/// Invariante de `docs/CORRECCIONES.md`: **ningún módulo queda afuera** del
/// sync, "y lo que se agregue después". Este test falla si alguien agrega una
/// tabla de dominio a Drift y se olvida de registrarla en `SyncService`.
void main() {
  late AppDatabase db;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    sync = SyncService(
      db,
      remote: FakeSyncRemoteGateway(),
      esperasReintento: const [],
    );
  });

  tearDown(() async {
    await db.close();
  });

  /// Tablas solo locales: infraestructura de sync y sesión del dispositivo.
  /// No son datos de dominio, así que no se sincronizan.
  const soloLocales = {'sync_cursores', 'sync_estados', 'sesiones_locales'};

  test('toda tabla de dominio está registrada en el sync', () {
    final deDominio = db.allTables
        .map((t) => t.actualTableName)
        .where((n) => !soloLocales.contains(n))
        .toSet();

    final registradas = sync.tablasRegistradas.toSet();
    expect(
      deDominio.difference(registradas),
      isEmpty,
      reason:
          'Hay tablas de dominio sin TableSyncSpec en SyncService. '
          'Agregale su spec y metela en _specs, en orden de llaves foráneas.',
    );
  });

  test('no hay specs de tablas que ya no existen', () {
    final locales = db.allTables.map((t) => t.actualTableName).toSet();
    expect(sync.tablasRegistradas.toSet().difference(locales), isEmpty);
  });

  test('gastos fijos y sus cargos van después de sus dependencias', () {
    final orden = sync.tablasRegistradas;
    expect(orden, contains('gastos_fijos'));
    expect(orden, contains('gasto_fijo_cargos'));
    // gastos_fijos referencia fincas; los cargos referencian gastos_fijos y
    // animales. El pull aplica en este orden, así que las FK deben respetarse.
    expect(orden.indexOf('gastos_fijos'), greaterThan(orden.indexOf('fincas')));
    expect(
      orden.indexOf('gasto_fijo_cargos'),
      greaterThan(orden.indexOf('gastos_fijos')),
    );
    expect(
      orden.indexOf('gasto_fijo_cargos'),
      greaterThan(orden.indexOf('animales')),
    );
  });
}
