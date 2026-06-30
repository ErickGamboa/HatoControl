import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';

void main() {
  late AppDatabase db;
  late PesajesRepository repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = PesajesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedFincaYLote() async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
            nombre: 'Finca test',
            creadaPor: 'user-1',
            cuentaId: const Value('account-1'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'lote-1',
            fincaId: 'finca-1',
            nombre: 'Levante',
            numero: const Value(1),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> insertAnimal({
    String id = 'animal-1',
    String loteId = 'lote-1',
    String identificador = 'A-001',
  }) async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: id,
            fincaId: 'finca-1',
            loteId: loteId,
            identificador: identificador,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> insertPesaje({
    required String id,
    required double peso,
    required DateTime fecha,
    String animalId = 'animal-1',
  }) async {
    await db
        .into(db.pesajes)
        .insert(
          PesajesCompanion.insert(
            id: id,
            animalId: animalId,
            peso: peso,
            fecha: fecha,
            registradoPor: const Value('user-1'),
            createdAt: fecha,
            updatedAt: fecha,
          ),
        );
  }

  test('crearAnimalConPesaje crea animal y primer pesaje pendientes', () async {
    await seedFincaYLote();

    await repo.crearAnimalConPesaje(
      fincaId: 'finca-1',
      loteId: 'lote-1',
      identificador: 'A-100',
      peso: 235.5,
      registradoPor: 'user-1',
    );

    final animales = await db.select(db.animales).get();
    final pesajes = await db.select(db.pesajes).get();

    expect(animales, hasLength(1));
    expect(pesajes, hasLength(1));
    expect(animales.single.identificador, 'A-100');
    expect(animales.single.fincaId, 'finca-1');
    expect(animales.single.loteId, 'lote-1');
    expect(animales.single.pendiente, isTrue);
    expect(pesajes.single.animalId, animales.single.id);
    expect(pesajes.single.peso, 235.5);
    expect(pesajes.single.registradoPor, 'user-1');
    expect(pesajes.single.pendiente, isTrue);
  });

  test(
    'observarAnimalesDeLote calcula peso actual y ganancia diaria calendario',
    () async {
      await seedFincaYLote();
      await insertAnimal();
      await insertPesaje(
        id: 'p-1',
        peso: 200,
        fecha: DateTime(2026, 1, 10, 18),
      );
      await insertPesaje(id: 'p-2', peso: 221, fecha: DateTime(2026, 1, 17, 8));

      final animales = await repo.observarAnimalesDeLote('lote-1').first;

      expect(animales, hasLength(1));
      expect(animales.single.pesoActual, 221);
      expect(animales.single.gananciaDiaria, closeTo(3, 0.001));
    },
  );

  test(
    'observarPesajesDelDia incluye ganancia contra pesaje anterior',
    () async {
      await seedFincaYLote();
      await insertAnimal();
      await insertPesaje(
        id: 'ayer',
        peso: 310,
        fecha: DateTime(2026, 2, 1, 23),
      );
      await insertPesaje(id: 'hoy', peso: 316, fecha: DateTime(2026, 2, 2, 7));

      final pesajes = await repo
          .observarPesajesDelDia('finca-1', DateTime(2026, 2, 2))
          .first;

      expect(pesajes, hasLength(1));
      expect(pesajes.single.id, 'hoy');
      expect(pesajes.single.identificador, 'A-001');
      expect(pesajes.single.loteNombre, 'Levante');
      expect(pesajes.single.ganancia, 6);
      expect(pesajes.single.dias, 1);
      expect(pesajes.single.gananciaDiaria, 6);
    },
  );

  test(
    'eliminarPesaje aplica borrado suave y actualiza peso más reciente',
    () async {
      await seedFincaYLote();
      await insertAnimal();
      await insertPesaje(id: 'p-1', peso: 180, fecha: DateTime(2026, 3, 1));
      await insertPesaje(id: 'p-2', peso: 190, fecha: DateTime(2026, 3, 5));

      await repo.eliminarPesaje('p-2');

      final eliminado = await (db.select(
        db.pesajes,
      )..where((t) => t.id.equals('p-2'))).getSingle();
      expect(eliminado.deletedAt, isNotNull);
      expect(eliminado.pendiente, isTrue);
      expect(await repo.ultimoPeso('animal-1'), 180);
    },
  );
}
