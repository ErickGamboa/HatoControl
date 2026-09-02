import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

/// Un valor que en el servidor pasa a NULL tiene que quedar NULL también en la
/// copia local. El caso real: al pagar la licencia, el admin pone
/// `cuentas.prueba_termina = null`; si la bajada no borra la fecha vieja, el
/// `CuentaGate` sigue mostrando "Tu prueba gratis terminó" para siempre.
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

  test('la bajada limpia prueba_termina cuando el servidor la manda en null', () async {
    // Caché vieja: prueba vencida, plan light (lo que tiene el cliente hoy).
    await db.into(db.cuentas).insert(
          CuentaRow(
            id: 'cuenta-1',
            nombre: 'Mi cuenta',
            duenoId: 'user-1',
            plan: 'light',
            estado: 'activa',
            pruebaTermina: DateTime(2026, 8, 29),
            createdAt: DateTime(2026, 8, 22),
            updatedAt: DateTime(2026, 8, 22),
            pendiente: false,
          ),
        );

    // El admin le vendió la licencia: pro y sin prueba.
    remote.descargas['cuentas'] = [
      {
        'id': 'cuenta-1',
        'nombre': 'Mi cuenta',
        'dueno_id': 'user-1',
        'plan': 'pro',
        'estado': 'activa',
        'prueba_termina': null,
        'created_at': DateTime(2026, 8, 22).toIso8601String(),
        'updated_at': DateTime(2026, 9, 1).toIso8601String(),
        'deleted_at': null,
      },
    ];

    await sync.sincronizar();

    final cuenta = await (db.select(
      db.cuentas,
    )..where((t) => t.id.equals('cuenta-1'))).getSingle();

    expect(cuenta.plan, 'pro', reason: 'el plan sí se actualiza');
    expect(
      cuenta.pruebaTermina,
      isNull,
      reason: 'la fecha de prueba tiene que quedar en null, como en el servidor',
    );
  });

  test('una fecha futura NO nula sí pisa la vieja (rodeo sin app nueva)', () async {
    await db.into(db.cuentas).insert(
          CuentaRow(
            id: 'cuenta-1',
            nombre: 'Mi cuenta',
            duenoId: 'user-1',
            plan: 'light',
            estado: 'activa',
            pruebaTermina: DateTime(2026, 8, 29),
            createdAt: DateTime(2026, 8, 22),
            updatedAt: DateTime(2026, 8, 22),
            pendiente: false,
          ),
        );

    remote.descargas['cuentas'] = [
      {
        'id': 'cuenta-1',
        'nombre': 'Mi cuenta',
        'dueno_id': 'user-1',
        'plan': 'pro',
        'estado': 'activa',
        'prueba_termina': DateTime(2126, 1, 1).toIso8601String(),
        'created_at': DateTime(2026, 8, 22).toIso8601String(),
        'updated_at': DateTime(2026, 9, 1).toIso8601String(),
        'deleted_at': null,
      },
    ];

    await sync.sincronizar();

    final cuenta = await (db.select(
      db.cuentas,
    )..where((t) => t.id.equals('cuenta-1'))).getSingle();

    expect(cuenta.plan, 'pro');
    expect(cuenta.pruebaTermina, DateTime(2126, 1, 1));
    expect(
      cuenta.pruebaTermina!.isBefore(DateTime.now()),
      isFalse,
      reason: 'el CuentaGate ya no bloquea',
    );
  });
}
