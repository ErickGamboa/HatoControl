import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/corral/corral_screen.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/feature_flags_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';

void main() {
  late AppDatabase db;
  late PesajesRepository pesajesRepo;
  late SanidadRepository sanidadRepo;
  late LotesRepository lotesRepo;
  late FeatureFlagsRepository featureFlagsRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajesRepo = PesajesRepository(db);
    sanidadRepo = SanidadRepository(db);
    lotesRepo = LotesRepository(db);
    featureFlagsRepo = FeatureFlagsRepository(db);
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
          featureFlagsRepository: featureFlagsRepo,
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

    // El StreamBuilder del ícono de tratamiento al lote (gateado por el
    // flag `sanidad`) deja un timer pendiente si el test no asienta el
    // árbol antes de terminar (mismo patrón que otras pantallas con
    // streams, p. ej. lote_historial_screen_test.dart).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'oculta el ícono de tratamiento al lote cuando sanidad está deshabilitada',
    (tester) async {
      final finca = await seedFinca();
      final ahora = DateTime(2026, 1, 1);
      await db
          .into(db.featureFlags)
          .insert(
            FeatureFlagRow(
              id: 'flag-sanidad',
              scope: 'finca',
              scopeId: 'finca-1',
              clave: 'sanidad',
              habilitado: false,
              createdAt: ahora,
              updatedAt: ahora,
            ),
          );

      await tester.pumpWidget(
        MaterialApp(
          home: CorralScreen(
            finca: finca,
            usuarioId: 'u1',
            pesajesRepository: pesajesRepo,
            sanidadRepository: sanidadRepo,
            lotesRepository: lotesRepo,
            featureFlagsRepository: featureFlagsRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('corral.batchLote')), findsNothing);

      // El ScanField autofocado deja un timer de parpadeo de cursor pendiente
      // (mismo patrón que el resto de tests de esta pantalla): asentarlo
      // antes de que termine el test.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    },
  );
}
