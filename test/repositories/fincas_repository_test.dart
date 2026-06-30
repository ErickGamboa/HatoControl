import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';

void main() {
  late AppDatabase db;
  late FincasRepository repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = FincasRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedCuenta({
    required String usuarioId,
    required String cuentaId,
    String plan = 'light',
    int limite = 1,
  }) async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.planes)
        .insert(
          PlanesCompanion.insert(
            codigo: plan,
            nombre: 'Plan $plan',
            limiteFincas: limite,
            updatedAt: now,
          ),
        );
    await db
        .into(db.cuentas)
        .insert(
          CuentasCompanion.insert(
            id: cuentaId,
            nombre: 'Cuenta test',
            duenoId: usuarioId,
            plan: plan,
            estado: 'activa',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: usuarioId,
            nombre: const Value('Usuario Test'),
            email: const Value('test@example.com'),
            cuentaId: Value(cuentaId),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test(
    'crearFinca crea finca y membresía admin en una transacción local',
    () async {
      await seedCuenta(usuarioId: 'user-1', cuentaId: 'account-1', limite: 2);

      await repo.crearFinca(
        nombre: 'El Porvenir',
        creadaPor: 'user-1',
        fotoLocalPath: '/tmp/foto.jpg',
      );

      final fincas = await db.select(db.fincas).get();
      final miembros = await db.select(db.fincaMiembros).get();

      expect(fincas, hasLength(1));
      expect(miembros, hasLength(1));

      final finca = fincas.single;
      expect(finca.nombre, 'El Porvenir');
      expect(finca.creadaPor, 'user-1');
      expect(finca.cuentaId, 'account-1');
      expect(finca.fotoLocalPath, '/tmp/foto.jpg');
      expect(finca.fotoPendiente, isTrue);
      expect(finca.pendiente, isTrue);
      expect(finca.deletedAt, isNull);

      final miembro = miembros.single;
      expect(miembro.fincaId, finca.id);
      expect(miembro.usuarioId, 'user-1');
      expect(miembro.rol, 'admin');
      expect(miembro.pendiente, isTrue);
    },
  );

  test(
    'crearFinca falla sin cuenta sincronizada y no deja filas parciales',
    () async {
      expect(
        () => repo.crearFinca(nombre: 'Sin cuenta', creadaPor: 'user-1'),
        throwsA(isA<LicenciaNoDisponibleException>()),
      );

      expect(await db.select(db.fincas).get(), isEmpty);
      expect(await db.select(db.fincaMiembros).get(), isEmpty);
    },
  );

  test('crearFinca respeta el límite del plan y no crea filas extra', () async {
    await seedCuenta(usuarioId: 'user-1', cuentaId: 'account-1', limite: 1);
    await repo.crearFinca(nombre: 'Primera', creadaPor: 'user-1');

    expect(
      () => repo.crearFinca(nombre: 'Segunda', creadaPor: 'user-1'),
      throwsA(isA<LimiteFincasException>()),
    );

    expect(await db.select(db.fincas).get(), hasLength(1));
    expect(await db.select(db.fincaMiembros).get(), hasLength(1));
  });

  test('observarFincas oculta fincas y membresías con borrado suave', () async {
    await seedCuenta(usuarioId: 'user-1', cuentaId: 'account-1', limite: 3);
    await repo.crearFinca(nombre: 'Visible', creadaPor: 'user-1');
    await repo.crearFinca(nombre: 'Oculta por finca', creadaPor: 'user-1');
    await repo.crearFinca(nombre: 'Oculta por miembro', creadaPor: 'user-1');

    final todas = await db.select(db.fincas).get();
    final porNombre = {for (final f in todas) f.nombre: f};
    final now = DateTime.now();
    await (db.update(db.fincas)
          ..where((t) => t.id.equals(porNombre['Oculta por finca']!.id)))
        .write(FincasCompanion(deletedAt: Value(now)));
    await (db.update(db.fincaMiembros)
          ..where((t) => t.fincaId.equals(porNombre['Oculta por miembro']!.id)))
        .write(FincaMiembrosCompanion(deletedAt: Value(now)));

    final visibles = await repo.observarFincas('user-1').first;

    expect(visibles.map((f) => f.nombre), ['Visible']);
  });
}
