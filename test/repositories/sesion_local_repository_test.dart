import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/sesion_local_repository.dart';

void main() {
  late AppDatabase db;
  late SesionLocalRepository repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = SesionLocalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('guarda una identidad verificada y activa el acceso offline', () async {
    await repo.guardarUsuarioVerificado(
      usuarioId: 'user-1',
      email: 'offline@example.com',
      nombre: 'Usuario Offline',
    );

    expect(repo.usuarioId, 'user-1');
    expect(repo.offlineActiva, isFalse);

    await repo.activarOffline();

    final sesion = await repo.obtener();
    expect(sesion, isNotNull);
    expect(sesion!.usuarioId, 'user-1');
    expect(sesion.email, 'offline@example.com');
    expect(sesion.nombre, 'Usuario Offline');
    expect(sesion.offlineActiva, isTrue);
    expect(repo.offlineActiva, isTrue);
  });

  test(
    'activa offline solo si el correo coincide con el usuario cacheado',
    () async {
      await repo.guardarUsuarioVerificado(
        usuarioId: 'user-1',
        email: 'offline@example.com',
      );

      expect(await repo.activarOfflineParaEmail('otra@example.com'), isFalse);
      expect((await repo.obtener())!.offlineActiva, isFalse);

      expect(await repo.activarOfflineParaEmail('OFFLINE@example.com'), isTrue);
      expect((await repo.obtener())!.offlineActiva, isTrue);
    },
  );

  test('desactiva y borra la identidad local al cerrar sesión', () async {
    await repo.guardarUsuarioVerificado(
      usuarioId: 'user-1',
      email: 'offline@example.com',
    );
    await repo.activarOffline();

    await repo.desactivarOffline();
    expect((await repo.obtener())!.offlineActiva, isFalse);

    await repo.borrar();
    expect(await repo.obtener(), isNull);
    expect(repo.usuarioId, isNull);
    expect(repo.offlineActiva, isFalse);
  });
}
