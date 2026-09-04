import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

/// Un valor que en el servidor pasa a NULL tiene que quedar NULL también en la
/// copia local. El caso que lo destapó: cuando había prueba gratis de 7 días,
/// al pagar se borraba la fecha de vencimiento en la nube y, si la bajada no
/// limpiaba la vieja, el cliente quedaba bloqueado para siempre. Esa prueba ya
/// no existe, pero la regla del **companion completo** (ver `SyncService`) sí,
/// y se sigue cuidando acá con otra columna que se puede vaciar.
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

  Future<void> sembrarUsuarioLocal({String? nombre}) {
    return db
        .into(db.usuarios)
        .insert(
          UsuarioRow(
            id: 'user-1',
            nombre: nombre,
            email: 'quien@ejemplo.com',
            cuentaId: 'cuenta-1',
            createdAt: DateTime(2026, 8, 22),
            updatedAt: DateTime(2026, 8, 22),
            pendiente: false,
          ),
        );
  }

  void responderConNombre(String? nombre) {
    remote.descargas['usuarios'] = [
      {
        'id': 'user-1',
        'nombre': nombre,
        'email': 'quien@ejemplo.com',
        'cuenta_id': 'cuenta-1',
        'created_at': DateTime(2026, 8, 22).toIso8601String(),
        'updated_at': DateTime(2026, 9, 1).toIso8601String(),
      },
    ];
  }

  Future<UsuarioRow> leerUsuario() {
    return (db.select(
      db.usuarios,
    )..where((t) => t.id.equals('user-1'))).getSingle();
  }

  test('la bajada limpia un valor que el servidor mandó en null', () async {
    await sembrarUsuarioLocal(nombre: 'Nombre viejo');
    responderConNombre(null);

    await sync.sincronizar();

    final usuario = await leerUsuario();
    expect(
      usuario.nombre,
      isNull,
      reason: 'el dato borrado en el servidor tiene que borrarse acá también',
    );
    expect(usuario.email, 'quien@ejemplo.com', reason: 'lo demás no se toca');
  });

  test('un valor no nulo también pisa el viejo', () async {
    await sembrarUsuarioLocal(nombre: 'Nombre viejo');
    responderConNombre('Nombre nuevo');

    await sync.sincronizar();

    expect((await leerUsuario()).nombre, 'Nombre nuevo');
  });
}
