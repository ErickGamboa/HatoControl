import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

void main() {
  late AppDatabase db;
  late VentasRepository ventasRepo;
  late SanidadRepository sanidadRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    ventasRepo = VentasRepository(db);
    sanidadRepo = SanidadRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedAnimal() async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
            nombre: 'Finca',
            creadaPor: 'u1',
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
            nombre: 'Lote',
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
            identificador: 'A-1',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('registrarVenta marca animal vendido y pendiente', () async {
    await seedAnimal();
    await ventasRepo.registrarVenta(animalId: 'animal-1', precio: 780000);

    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals('animal-1'))).getSingle();
    expect(animal.estado, EstadoAnimal.vendido);
    expect(animal.pendiente, isTrue);
    expect(await db.select(db.ventas).get(), hasLength(1));
  });

  test('resumen incluye costos sanitarios de eventos', () async {
    await seedAnimal();
    await sanidadRepo.registrarEvento(
      animalId: 'animal-1',
      tipo: TipoEventoSanitario.medicamento,
      producto: 'Ivermectina',
      costo: 18000,
    );
    await ventasRepo.actualizarCompra(
      animalId: 'animal-1',
      precioCompra: 520000,
    );

    final r = await ventasRepo.resumenDe('animal-1');
    expect(r.precioCompra, 520000);
    expect(r.costoSanitario, 18000);
  });

  test('repetirUltimoEvento duplica ficha del último evento', () async {
    await seedAnimal();
    await sanidadRepo.registrarEvento(
      animalId: 'animal-1',
      tipo: TipoEventoSanitario.vacuna,
      producto: 'Clostridial',
      dosis: '5 ml',
      costo: 3500,
    );
    final ok = await sanidadRepo.repetirUltimoEvento(animalId: 'animal-1');
    expect(ok, isTrue);
    expect(await db.select(db.eventosSanitarios).get(), hasLength(2));
  });
}
