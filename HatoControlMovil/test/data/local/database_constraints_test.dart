import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  FincaMiembrosCompanion miembro({required String id, DateTime? deletedAt}) {
    final now = DateTime(2026, 1, 1);
    return FincaMiembrosCompanion.insert(
      id: id,
      fincaId: 'finca-1',
      usuarioId: 'user-1',
      rol: 'admin',
      createdAt: now,
      updatedAt: now,
      deletedAt: Value(deletedAt),
    );
  }

  AnimalesCompanion animal({required String id, DateTime? deletedAt}) {
    final now = DateTime(2026, 1, 1);
    return AnimalesCompanion.insert(
      id: id,
      fincaId: 'finca-1',
      loteId: 'lote-1',
      identificador: 'A-001',
      createdAt: now,
      updatedAt: now,
      deletedAt: Value(deletedAt),
    );
  }

  test('rechaza membresías activas duplicadas por finca y usuario', () async {
    await db.into(db.fincaMiembros).insert(miembro(id: 'm-1'));

    expect(
      () => db.into(db.fincaMiembros).insert(miembro(id: 'm-2')),
      throwsA(anything),
    );
  });

  test(
    'rechaza animales activos duplicados por finca e identificador',
    () async {
      await db.into(db.animales).insert(animal(id: 'a-1'));

      expect(
        () => db.into(db.animales).insert(animal(id: 'a-2')),
        throwsA(anything),
      );
    },
  );

  test(
    'permite reutilizar claves cuando la fila previa está borrada',
    () async {
      final deletedAt = DateTime(2026, 1, 2);

      await db
          .into(db.fincaMiembros)
          .insert(miembro(id: 'm-borrado', deletedAt: deletedAt));
      await db.into(db.fincaMiembros).insert(miembro(id: 'm-activo'));

      await db
          .into(db.animales)
          .insert(animal(id: 'a-borrado', deletedAt: deletedAt));
      await db.into(db.animales).insert(animal(id: 'a-activo'));

      expect(await db.select(db.fincaMiembros).get(), hasLength(2));
      expect(await db.select(db.animales).get(), hasLength(2));
    },
  );

  group('CHECK constraints (Fase 3)', () {
    final now = DateTime(2026, 1, 1);

    test('rechaza un rol de finca_miembros fuera de admin/operario', () {
      expect(
        () => db
            .into(db.fincaMiembros)
            .insert(miembro(id: 'm-1').copyWith(rol: const Value('dueno'))),
        throwsA(anything),
      );
    });

    test('rechaza un plan o estado de cuenta fuera del catálogo', () async {
      CuentasCompanion cuenta({
        String plan = 'light',
        String estado = 'activa',
      }) => CuentasCompanion.insert(
        id: 'c-1',
        nombre: 'Cuenta',
        duenoId: 'user-1',
        plan: plan,
        estado: estado,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => db.into(db.cuentas).insert(cuenta(plan: 'ilimitado')),
        throwsA(anything),
      );
      expect(
        () => db.into(db.cuentas).insert(cuenta(estado: 'cancelada')),
        throwsA(anything),
      );
      await db.into(db.cuentas).insert(cuenta());
    });

    test('rechaza estado o precio_compra inválidos en animales', () async {
      expect(
        () => db
            .into(db.animales)
            .insert(animal(id: 'a-1').copyWith(estado: const Value('robado'))),
        throwsA(anything),
      );
      expect(
        () => db
            .into(db.animales)
            .insert(animal(id: 'a-2').copyWith(precioCompra: const Value(-10))),
        throwsA(anything),
      );
    });

    test('rechaza pesajes con peso cero o negativo', () async {
      PesajesCompanion pesaje(double peso) => PesajesCompanion.insert(
        id: 'p-1',
        animalId: 'animal-1',
        peso: peso,
        fecha: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(() => db.into(db.pesajes).insert(pesaje(0)), throwsA(anything));
      expect(() => db.into(db.pesajes).insert(pesaje(-5)), throwsA(anything));
      await db.into(db.pesajes).insert(pesaje(210));
    });

    test('rechaza montos negativos en dietas, ventas y costos_otros', () async {
      expect(
        () => db
            .into(db.dietas)
            .insert(
              DietasCompanion.insert(
                id: 'd-1',
                fincaId: 'finca-1',
                nombre: 'Dieta',
                costoAnimalDia: -1,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(anything),
      );
      expect(
        () => db
            .into(db.dietas)
            .insert(
              DietasCompanion.insert(
                id: 'd-2',
                fincaId: 'finca-1',
                nombre: 'Dieta ₡/kg negativo',
                costoKg: const Value(-1),
                costoAnimalDia: 0,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(anything),
      );
      expect(
        () => db
            .into(db.dietas)
            .insert(
              DietasCompanion.insert(
                id: 'd-3',
                fincaId: 'finca-1',
                nombre: 'Dieta kg negativos',
                kgAnimalDia: const Value(-2),
                costoAnimalDia: 0,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(anything),
      );
      expect(
        () => db
            .into(db.ventas)
            .insert(
              VentasCompanion.insert(
                id: 'v-1',
                animalId: 'animal-1',
                fecha: now,
                precio: -1,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(anything),
      );
      expect(
        () => db
            .into(db.costosOtros)
            .insert(
              CostosOtrosCompanion.insert(
                id: 'co-1',
                animalId: 'animal-1',
                concepto: 'Sal',
                monto: -1,
                fecha: now,
                createdAt: now,
                updatedAt: now,
              ),
            ),
        throwsA(anything),
      );
    });

    test(
      'rechaza feature_flags con scope inválido o scope_id inconsistente',
      () async {
        FeatureFlagsCompanion flag({
          String scope = 'global',
          Value<String?> scopeId = const Value.absent(),
        }) => FeatureFlagsCompanion.insert(
          id: 'f-1',
          scope: scope,
          scopeId: scopeId,
          clave: 'dietas',
          createdAt: now,
          updatedAt: now,
        );

        expect(
          () => db.into(db.featureFlags).insert(flag(scope: 'cuenta_todas')),
          throwsA(anything),
        );
        // scope='global' pero con scope_id no nulo: viola la constraint cruzada.
        expect(
          () => db
              .into(db.featureFlags)
              .insert(flag(scopeId: const Value('finca-1'))),
          throwsA(anything),
        );
        // scope='finca' pero sin scope_id: misma constraint, otro sentido.
        expect(
          () => db.into(db.featureFlags).insert(flag(scope: 'finca')),
          throwsA(anything),
        );
        await db.into(db.featureFlags).insert(flag());
      },
    );
  });
}
