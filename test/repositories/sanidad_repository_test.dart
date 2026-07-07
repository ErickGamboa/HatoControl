import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';

void main() {
  late AppDatabase db;
  late SanidadRepository repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = SanidadRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seed() async {
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
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: 'animal-1',
            fincaId: 'finca-1',
            loteId: 'lote-1',
            identificador: 'A-001',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: 'animal-2',
            fincaId: 'finca-1',
            loteId: 'lote-1',
            identificador: 'A-002',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('registrarEvento crea fila pendiente ordenada por fecha desc', () async {
    await seed();
    await repo.registrarEvento(
      animalId: 'animal-1',
      tipo: TipoEventoSanitario.vacuna,
      producto: 'Clostridial',
      dosis: '5 ml',
      fecha: DateTime(2026, 2, 1),
      responsableId: 'user-1',
      costo: 3500,
    );
    await repo.registrarEvento(
      animalId: 'animal-1',
      tipo: TipoEventoSanitario.medicamento,
      producto: 'Ivermectina',
      fecha: DateTime(2026, 3, 1),
    );

    final historial = await repo.observarHistorial('animal-1').first;
    expect(historial, hasLength(2));
    expect(historial.first.producto, 'Ivermectina');
    expect(historial.first.pendiente, isTrue);
    expect(historial.last.producto, 'Clostridial');
    expect(historial.last.costo, 3500);
  });

  test('registrarEventoEnLote aplica a todos los animales activos', () async {
    await seed();
    final count = await repo.registrarEventoEnLote(
      loteId: 'lote-1',
      tipo: TipoEventoSanitario.desparasitacion,
      producto: 'Albendazol',
      dosis: '10 ml',
      responsableId: 'user-1',
    );
    expect(count, 2);
    final filas = await db.select(db.eventosSanitarios).get();
    expect(filas, hasLength(2));
    expect(filas.every((e) => e.producto == 'Albendazol'), isTrue);
    expect(filas.every((e) => e.pendiente), isTrue);
  });

  test('eliminarEvento aplica borrado suave', () async {
    await seed();
    await repo.registrarEvento(
      animalId: 'animal-1',
      tipo: TipoEventoSanitario.otro,
      producto: 'Vitamina',
    );
    final id = (await db.select(db.eventosSanitarios).getSingle()).id;
    await repo.eliminarEvento(id);

    final historial = await repo.observarHistorial('animal-1').first;
    expect(historial, isEmpty);
    final fila = await (db.select(
      db.eventosSanitarios,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(fila.deletedAt, isNotNull);
    expect(fila.pendiente, isTrue);
  });

  test('sugerenciasProducto devuelve productos únicos de la finca', () async {
    await seed();
    await repo.registrarEvento(
      animalId: 'animal-1',
      tipo: TipoEventoSanitario.medicamento,
      producto: 'Ivermectina',
    );
    await repo.registrarEvento(
      animalId: 'animal-2',
      tipo: TipoEventoSanitario.medicamento,
      producto: 'Ivermectina',
    );
    await repo.registrarEvento(
      animalId: 'animal-1',
      tipo: TipoEventoSanitario.vacuna,
      producto: 'Clostridial',
    );

    final sugerencias = await repo.sugerenciasProducto('finca-1');
    expect(sugerencias, ['Clostridial', 'Ivermectina']);
  });
}
