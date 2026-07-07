import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';
import 'package:hato_control/lotes/animal_ficha_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<AnimalRow> seedAnimal() async {
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
            identificador: 'TAB-1',
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await db.select(db.animales).get()).single;
  }

  testWidgets('muestra pestañas incluyendo Economía', (tester) async {
    final animal = await seedAnimal();
    await tester.pumpWidget(
      MaterialApp(
        home: AnimalFichaScreen(
          animal: animal,
          usuarioId: 'u1',
          pesajesRepository: PesajesRepository(db),
          sanidadRepository: SanidadRepository(db),
          dietasRepository: DietasRepository(db),
          ventasRepository: VentasRepository(db),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('General'), findsOneWidget);
    expect(find.text('Pesajes'), findsOneWidget);
    expect(find.text('Sanidad'), findsOneWidget);
    expect(find.text('Dietas'), findsOneWidget);
    expect(find.text('Economía'), findsOneWidget);

    await tester.tap(find.text('Economía'));
    await tester.pumpAndSettle();
    expect(find.text('Resumen económico'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
