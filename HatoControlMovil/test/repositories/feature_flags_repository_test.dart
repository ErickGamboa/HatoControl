import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/feature_flags_repository.dart';

void main() {
  late AppDatabase db;
  late FeatureFlagsRepository repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = FeatureFlagsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertarFlag({
    required String id,
    required String scope,
    String? scopeId,
    required String clave,
    required bool habilitado,
    DateTime? deletedAt,
  }) {
    final ahora = DateTime(2026, 1, 1);
    return db
        .into(db.featureFlags)
        .insert(
          FeatureFlagRow(
            id: id,
            scope: scope,
            scopeId: scopeId,
            clave: clave,
            habilitado: habilitado,
            nota: null,
            createdAt: ahora,
            updatedAt: ahora,
            deletedAt: deletedAt,
          ),
        );
  }

  test('sin ninguna fila, usa defaultValue (fail-open)', () async {
    expect(
      await repo.isEnabled('sanidad', fincaId: 'finca-1', cuentaId: 'cta-1'),
      isTrue,
    );
    expect(
      await repo.isEnabled(
        'sanidad',
        fincaId: 'finca-1',
        cuentaId: 'cta-1',
        defaultValue: false,
      ),
      isFalse,
    );
  });

  test('cae a global cuando no hay override de finca/cuenta', () async {
    await insertarFlag(
      id: 'f1',
      scope: 'global',
      clave: 'dietas',
      habilitado: false,
    );

    expect(
      await repo.isEnabled('dietas', fincaId: 'finca-1', cuentaId: 'cta-1'),
      isFalse,
    );
  });

  test('override de cuenta gana sobre global', () async {
    await insertarFlag(
      id: 'f1',
      scope: 'global',
      clave: 'dietas',
      habilitado: false,
    );
    await insertarFlag(
      id: 'f2',
      scope: 'cuenta',
      scopeId: 'cta-1',
      clave: 'dietas',
      habilitado: true,
    );

    expect(
      await repo.isEnabled('dietas', fincaId: 'finca-1', cuentaId: 'cta-1'),
      isTrue,
    );
  });

  test('override de finca gana sobre cuenta y global', () async {
    await insertarFlag(
      id: 'f1',
      scope: 'global',
      clave: 'dietas',
      habilitado: true,
    );
    await insertarFlag(
      id: 'f2',
      scope: 'cuenta',
      scopeId: 'cta-1',
      clave: 'dietas',
      habilitado: true,
    );
    await insertarFlag(
      id: 'f3',
      scope: 'finca',
      scopeId: 'finca-1',
      clave: 'dietas',
      habilitado: false,
    );

    expect(
      await repo.isEnabled('dietas', fincaId: 'finca-1', cuentaId: 'cta-1'),
      isFalse,
    );
  });

  test('override de finca de otra finca no aplica', () async {
    await insertarFlag(
      id: 'f1',
      scope: 'finca',
      scopeId: 'finca-2',
      clave: 'dietas',
      habilitado: false,
    );

    expect(
      await repo.isEnabled('dietas', fincaId: 'finca-1', cuentaId: 'cta-1'),
      isTrue,
    );
  });

  test(
    'fila borrada (soft delete) se ignora, cae al siguiente scope',
    () async {
      await insertarFlag(
        id: 'f1',
        scope: 'global',
        clave: 'dietas',
        habilitado: true,
      );
      await insertarFlag(
        id: 'f2',
        scope: 'finca',
        scopeId: 'finca-1',
        clave: 'dietas',
        habilitado: false,
        deletedAt: DateTime(2026, 1, 2),
      );

      expect(
        await repo.isEnabled('dietas', fincaId: 'finca-1', cuentaId: 'cta-1'),
        isTrue,
      );
    },
  );

  test('sin fincaId/cuentaId solo mira global', () async {
    await insertarFlag(
      id: 'f1',
      scope: 'finca',
      scopeId: 'finca-1',
      clave: 'dietas',
      habilitado: false,
    );
    await insertarFlag(
      id: 'f2',
      scope: 'global',
      clave: 'dietas',
      habilitado: true,
    );

    expect(await repo.isEnabled('dietas'), isTrue);
  });

  test('observarFlags excluye filas borradas', () async {
    await insertarFlag(
      id: 'f1',
      scope: 'global',
      clave: 'dietas',
      habilitado: true,
    );
    await insertarFlag(
      id: 'f2',
      scope: 'global',
      clave: 'ventas',
      habilitado: true,
      deletedAt: DateTime(2026, 1, 2),
    );

    final filas = await repo.observarFlags().first;
    expect(filas, hasLength(1));
    expect(filas.single.clave, 'dietas');
  });

  test(
    'observarHabilitado emite fail-open y se actualiza cuando el sync baja un flag',
    () async {
      final valores = <bool>[];
      final sub = repo
          .observarHabilitado('sanidad', fincaId: 'finca-1')
          .listen(valores.add);
      addTearDown(sub.cancel);

      await pumpEventQueue();
      expect(valores, [true]); // sin filas todavía: fail-open

      await insertarFlag(
        id: 'f1',
        scope: 'finca',
        scopeId: 'finca-1',
        clave: 'sanidad',
        habilitado: false,
      );
      await pumpEventQueue();

      expect(valores, [true, false]);
    },
  );
}
