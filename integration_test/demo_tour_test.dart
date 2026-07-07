import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:hato_control/app_bootstrap.dart' as app;
import 'package:hato_control/demo/demo_seed_ids.dart';
import 'helpers/integration_helpers.dart';

/// Visible tour of demo data (modules 1–4) on simulator/macOS.
///
/// Run:
/// ```bash
/// ./scripts/run_demo_tour.sh
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo tour: finca, corral, ficha, economía', (tester) async {
    await binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => binding.setSurfaceSize(null));

    await app.bootstrapHatoControl();
    app.runHatoControlApp();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await pauseIntegration(tester, multiplier: 2);

    // Mis fincas (offline demo)
    await waitFor(tester, find.text('Mis fincas'), timeoutSeconds: 20);
    await waitFor(
      tester,
      find.text(DemoSeedIds.fincaNombre),
      timeoutSeconds: 10,
    );
    await pauseIntegration(tester);
    await tester.tap(find.text(DemoSeedIds.fincaNombre));
    await tester.pumpAndSettle();

    // Corral — animal 1001
    await waitFor(tester, find.byKey(const ValueKey('fincaDetail.corral')));
    await tester.tap(find.byKey(const ValueKey('fincaDetail.corral')));
    await tester.pumpAndSettle();
    await pauseIntegration(tester);
    await tester.enterText(
      find.byKey(const ValueKey('corral.animalId')),
      DemoSeedIds.animalCorral,
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await waitFor(tester, find.byKey(const ValueKey('corral.animalCard')));
    await waitFor(
      tester,
      find.textContaining('Clostridial'),
      timeoutSeconds: 15,
    );
    await pauseIntegration(tester, multiplier: 2);

    // Ficha — animal 1002 economía
    await tester.pageBack();
    await tester.pumpAndSettle();
    final lotesBtn = find.byKey(const ValueKey('fincaDetail.lotes'));
    await waitFor(tester, lotesBtn);
    final grid = find.byType(GridView);
    for (var i = 0; i < 8; i++) {
      if (lotesBtn.evaluate().isNotEmpty) {
        final rect = tester.getRect(lotesBtn);
        if (rect.center.dy <= 850) break;
      }
      await tester.drag(grid, const Offset(0, -180));
      await tester.pumpAndSettle();
    }
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

    await tester.tap(find.text('Economía'));
    await tester.pumpAndSettle();
    expect(find.text('Resumen económico'), findsOneWidget);
    expect(find.textContaining('520'), findsWidgets);
    expect(find.textContaining('18000'), findsWidgets);
    await pauseIntegration(tester, multiplier: 3);
  });
}
