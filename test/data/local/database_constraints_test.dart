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
}
