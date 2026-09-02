import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/sesion_local_repository.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

/// DOS CUENTAS EN EL MISMO APARATO (o el mismo navegador).
///
/// Los cursores de bajada son del aparato, no del usuario. Si el segundo que
/// entra tiene filas MÁS VIEJAS que el cursor que dejó el primero, esas filas
/// no bajan nunca: la cuenta se ve vacía teniendo su finca sana en la nube.
///
/// Pasó en producción el 2026-09-02 con `erick.yosue@gmail.com` en la web:
/// antes había entrado otra cuenta, cuyo cursor de `usuarios` quedó en el 22
/// de agosto y el de `finca_miembros` también. La fila de `usuarios` y la
/// membresía de erick son del 21 de agosto, así que el servidor las devolvía
/// pero el filtro del cursor las descartaba. Su finca sí bajó (24 de agosto),
/// pero sin membresía no hay fincas que mostrar, y sin la fila de `usuarios`
/// no hay `cuenta_id` que leer: crear una finca contestaba "Conectate a
/// internet una vez para activar tu cuenta".
///
/// El fake replica el filtro `(updated_at, id) > cursor` del gateway real, y
/// `descargas` se cambia entre fases para imitar lo que la RLS deja ver a cada
/// usuario.
void main() {
  late AppDatabase db;
  late FakeSyncRemoteGateway remote;
  late SyncService sync;
  late SesionLocalRepository sesiones;
  late FincasRepository fincas;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    remote = FakeSyncRemoteGateway();
    sync = SyncService(db, remote: remote, esperasReintento: const []);
    sesiones = SesionLocalRepository(db);
    fincas = FincasRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  final plan = {
    'codigo': 'pro',
    'nombre': 'Pro',
    'limite_fincas': 999,
    'updated_at': DateTime.utc(2026, 8, 21).toIso8601String(),
  };

  Map<String, dynamic> cuenta(String id, DateTime updatedAt) => {
    'id': id,
    'nombre': 'Mi cuenta',
    'dueno_id': 'dueno-$id',
    'plan': 'pro',
    'estado': 'activa',
    'prueba_termina': null,
    'created_at': DateTime.utc(2026, 8, 21).toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': null,
  };

  Map<String, dynamic> usuario(String id, String cuentaId, DateTime updatedAt) =>
      {
        'id': id,
        'nombre': null,
        'email': '$id@example.com',
        'cuenta_id': cuentaId,
        'created_at': DateTime.utc(2026, 8, 21).toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> finca(
    String id,
    String cuentaId,
    String creadaPor,
    DateTime updatedAt,
  ) => {
    'id': id,
    'nombre': 'Finca de $creadaPor',
    'foto_url': null,
    'creada_por': creadaPor,
    'cuenta_id': cuentaId,
    'created_at': DateTime.utc(2026, 8, 21).toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': null,
  };

  Map<String, dynamic> miembro(
    String id,
    String fincaId,
    String usuarioId,
    DateTime updatedAt,
  ) => {
    'id': id,
    'finca_id': fincaId,
    'usuario_id': usuarioId,
    'rol': 'admin',
    'created_at': DateTime.utc(2026, 8, 21).toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': null,
  };

  /// Lo que la RLS le muestra al primero que entró: todo suyo, del 22 de
  /// agosto, así que deja los cursores en esa fecha.
  void datosDeLaPrimeraCuenta() {
    final el22 = DateTime.utc(2026, 8, 22, 1, 43);
    remote.descargas
      ..['planes'] = [plan]
      ..['cuentas'] = [cuenta('cuenta-a', DateTime.utc(2026, 9, 2))]
      ..['usuarios'] = [usuario('user-a', 'cuenta-a', el22)]
      ..['fincas'] = [finca('finca-a', 'cuenta-a', 'user-a', el22)]
      ..['finca_miembros'] = [miembro('miembro-a', 'finca-a', 'user-a', el22)];
  }

  /// Lo que ve la segunda cuenta: sus filas son del 21 —MÁS VIEJAS que el
  /// cursor heredado— salvo la finca (24) y la cuenta (2 de setiembre).
  void datosDeLaSegundaCuenta() {
    final el21 = DateTime.utc(2026, 8, 21, 17, 27);
    remote.descargas
      ..['planes'] = [plan]
      ..['cuentas'] = [cuenta('cuenta-b', DateTime.utc(2026, 9, 2, 3, 41))]
      ..['usuarios'] = [usuario('user-b', 'cuenta-b', el21)]
      ..['fincas'] = [
        finca('finca-b', 'cuenta-b', 'user-b', DateTime.utc(2026, 8, 24)),
      ]
      ..['finca_miembros'] = [miembro('miembro-b', 'finca-b', 'user-b', el21)];
  }

  test(
    'sin limpiar la caché, las filas viejas de la segunda cuenta no bajan '
    '(el bug que se arregló)',
    () async {
      datosDeLaPrimeraCuenta();
      await sync.sincronizar();

      // La segunda cuenta entra SIN pasar por guardarUsuarioVerificado, que
      // es lo que hacía la app antes del arreglo.
      datosDeLaSegundaCuenta();
      await sync.sincronizar();

      // La finca sí baja (24 de agosto > cursor del 22)...
      final fincaBajada = await (db.select(
        db.fincas,
      )..where((t) => t.id.equals('finca-b'))).getSingleOrNull();
      expect(fincaBajada, isNotNull);

      // ...pero la membresía y la fila de usuarios, no: quedan detrás del
      // cursor para siempre.
      expect(await fincas.observarFincas('user-b').first, isEmpty);
      expect(await fincas.estadoLicencia('user-b'), isNull);
    },
  );

  test(
    'al entrar una cuenta distinta se limpia la caché y sus filas viejas sí '
    'bajan',
    () async {
      datosDeLaPrimeraCuenta();
      await sesiones.guardarUsuarioVerificado(
        usuarioId: 'user-a',
        email: 'user-a@example.com',
      );
      await sync.sincronizar();
      expect(await fincas.observarFincas('user-a').first, hasLength(1));

      datosDeLaSegundaCuenta();
      await sesiones.guardarUsuarioVerificado(
        usuarioId: 'user-b',
        email: 'user-b@example.com',
      );

      // La caché del primero se fue completa, cursores incluidos.
      expect(await db.select(db.fincas).get(), isEmpty);
      expect(await db.select(db.syncCursores).get(), isEmpty);
      // Y la identidad nueva quedó guardada.
      expect(sesiones.usuarioId, 'user-b');

      await sync.sincronizar();

      final misFincas = await fincas.observarFincas('user-b').first;
      expect(misFincas, hasLength(1));
      expect(misFincas.single.id, 'finca-b');
      // Con la fila de `usuarios` abajo, ya hay licencia que leer: crear una
      // finca deja de contestar "Conectate a internet".
      final estado = await fincas.estadoLicencia('user-b');
      expect(estado, isNotNull);
      expect(estado!.planNombre, 'Pro');
      expect(estado.usadas, 1);
      // Y nada del primero quedó mezclado.
      expect(await fincas.observarFincas('user-a').first, isEmpty);
    },
  );

  test('volver a entrar la MISMA cuenta no borra su caché offline', () async {
    datosDeLaPrimeraCuenta();
    await sesiones.guardarUsuarioVerificado(
      usuarioId: 'user-a',
      email: 'user-a@example.com',
    );
    await sync.sincronizar();

    await sesiones.guardarUsuarioVerificado(
      usuarioId: 'user-a',
      email: 'user-a@example.com',
    );

    expect(await fincas.observarFincas('user-a').first, hasLength(1));
    expect(await db.select(db.syncCursores).get(), isNotEmpty);
  });
}
