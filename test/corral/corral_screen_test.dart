import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/corral/corral_screen.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';

void main() {
  late AppDatabase db;
  late PesajesRepository pesajesRepo;
  late SanidadRepository sanidadRepo;
  late LotesRepository lotesRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajesRepo = PesajesRepository(db);
    sanidadRepo = SanidadRepository(db);
    lotesRepo = LotesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<FincaRow> seedFinca() async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
            nombre: 'Test',
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
            nombre: 'Destete',
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (await db.select(db.fincas).get()).single;
  }

  testWidgets('scan → peso → guardar en 3 interacciones', (tester) async {
    final finca = await seedFinca();
    await tester.pumpWidget(
      MaterialApp(
        home: CorralScreen(
          finca: finca,
          usuarioId: 'u1',
          pesajesRepository: pesajesRepo,
          sanidadRepository: sanidadRepo,
          lotesRepository: lotesRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('corral.animalId')),
      'COR-99',
    );
    await tester.enterText(find.byKey(const ValueKey('corral.weight')), '210');
    await tester.tap(find.byKey(const ValueKey('corral.submitPeso')));
    await tester.pumpAndSettle();

    expect(find.text('Destete'), findsOneWidget);
    await tester.tap(find.text('Destete'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('corral.animalCard')), findsOneWidget);
    expect(await db.select(db.pesajes).get(), hasLength(1));
  });
}
