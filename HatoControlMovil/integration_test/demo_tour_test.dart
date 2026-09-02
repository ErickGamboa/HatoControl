import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:hato_control/app_bootstrap.dart' as app;
import 'package:hato_control/demo/demo_seed_ids.dart';
import 'helpers/integration_helpers.dart';

/// Visible tour of demo data (documento oro) on simulator/macOS.
///
/// Run:
/// ```bash
/// ./scripts/run_demo_tour.sh "iPhone 17"
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo tour oro: Trabajo, Sanidad, Lotes, Hoja de vida', (
    tester,
  ) async {
    await binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => binding.setSurfaceSize(null));

    await app.bootstrapHatoControl();
    app.runHatoControlApp();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await pauseIntegration(tester, multiplier: 2);

    await waitFor(tester, find.text('Mis fincas'), timeoutSeconds: 20);
    await waitFor(
      tester,
      find.text(DemoSeedIds.fincaNombre),
      timeoutSeconds: 10,
    );
    await pauseIntegration(tester);
    await tester.tap(find.text(DemoSeedIds.fincaNombre));
    await tester.pumpAndSettle();

    // Pantalla de Trabajo (Pesaje)
    await waitFor(tester, find.byKey(const ValueKey('fincaDetail.pesaje')));
    await waitFor(tester, find.text('Trabajo'));
    await tester.tap(find.byKey(const ValueKey('fincaDetail.pesaje')));
    await tester.pumpAndSettle();
    await waitFor(tester, find.byKey(const ValueKey('pesaje.animalId')));
    await pauseIntegration(tester);
    await tester.enterText(
      find.byKey(const ValueKey('pesaje.animalId')),
      DemoSeedIds.animalCorral,
    );
    await tester.enterText(find.byKey(const ValueKey('pesaje.weight')), '215');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pesaje.submit')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // Si el animal ya se pesó hoy (demo re-run), confirmar corrección.
    final corregir = find.text('Corregir');
    if (corregir.evaluate().isNotEmpty) {
      await tester.tap(corregir);
      await tester.pumpAndSettle();
    }
    await waitFor(tester, find.textContaining('1001'));
    await pauseIntegration(tester, multiplier: 2);

    // Sanidad FAB after weigh
    final fab = find.byKey(const ValueKey('pesaje.sanidadFab'));
    await waitFor(tester, fab);
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await pauseIntegration(tester);
    // Catalog should list Catosal / Ivermectina from demo seed
    expect(find.textContaining('Catosal'), findsWidgets);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Módulos oro visibles
    expect(find.byKey(const ValueKey('fincaDetail.sanidad')), findsOneWidget);
    expect(find.byKey(const ValueKey('fincaDetail.venta')), findsOneWidget);

    final lotesBtn = find.byKey(const ValueKey('fincaDetail.lotes'));
    await waitFor(tester, lotesBtn);
    await tester.ensureVisible(lotesBtn);
    final okLotes = await tryTapAndWaitFor(
      tester,
      tapTarget: lotesBtn,
      waitFor: find.text(DemoSeedIds.loteDestete),
      timeoutSeconds: 12,
    );
    expect(okLotes, isTrue);
    await tester.pumpAndSettle();
    await tester.tap(find.text(DemoSeedIds.loteDestete));
    await tester.pumpAndSettle();
    await waitFor(tester, find.text(DemoSeedIds.animalEconomia));
    await tester.tap(find.text(DemoSeedIds.animalEconomia));
    await tester.pumpAndSettle();
    await pauseIntegration(tester);

    await tester.tap(find.text('Pesajes'));
    await tester.pumpAndSettle();
    expect(find.textContaining('200'), findsWidgets);
    await pauseIntegration(tester);

    await tester.tap(find.text('Sanidad'));
    await tester.pumpAndSettle();
    expect(find.text('Ivermectina'), findsWidgets);
    await pauseIntegration(tester);

    await tester.tap(find.text('Venta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Utilidad'), findsWidgets);
    expect(find.textContaining('520'), findsWidgets);
    await pauseIntegration(tester, multiplier: 3);
  });
}
