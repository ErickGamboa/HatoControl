import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hato_control/main.dart' as app;
import 'helpers/integration_helpers.dart';

const _email = String.fromEnvironment('HATO_E2E_EMAIL');
const _password = String.fromEnvironment('HATO_E2E_PASSWORD');
const _fallbackFinca = String.fromEnvironment(
  'HATO_E2E_FALLBACK_FINCA',
  defaultValue: 'Finca acapulco',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('visible: login, finca, lote, animal, segundo pesaje e historial', (
    tester,
  ) async {
    if (_email.isEmpty || _password.isEmpty) {
      markTestSkipped(
        'Define HATO_E2E_EMAIL y HATO_E2E_PASSWORD con un usuario Supabase '
        'sembrado para correr este e2e visible.',
      );
      return;
    }

    final stamp = DateTime.now().millisecondsSinceEpoch;
    final fincaName = 'E2E Finca $stamp';
    final loteName = 'E2E Lote $stamp';
    final animalId = '${stamp % 1000000000}';

    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await pauseIntegration(tester);

    // Empezar siempre desde la pantalla de login, aunque el simulador conserve
    // una sesión de una corrida anterior.
    await Supabase.instance.client.auth.signOut();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 1) Login real contra Supabase.
    await waitFor(tester, find.byKey(const ValueKey('login.email')));
    await tester.enterText(find.byKey(const ValueKey('login.email')), _email);
    await pauseIntegration(tester);
    await tester.enterText(
      find.byKey(const ValueKey('login.password')),
      _password,
    );
    await pauseIntegration(tester);
    await tester.tap(find.byKey(const ValueKey('login.submit')));

    await waitFor(tester, find.text('Mis fincas'), timeoutSeconds: 35);
    await pauseIntegration(tester);
    // La cuenta/licencia debe haber bajado desde Supabase antes de crear la
    // finca; si no aparece, el usuario de prueba no está bien sembrado.
    await waitFor(tester, find.textContaining('Plan'), timeoutSeconds: 35);

    // 2) Crear finca si hay cupo; si el usuario e2e está en el límite del
    // plan, usar una finca sembrada existente para continuar el flujo visible.
    final pudoCrearFinca = await tryTapAndWaitFor(
      tester,
      tapTarget: find.byKey(const ValueKey('fincas.create')),
      waitFor: find.byKey(const ValueKey('fincas.name')),
    );

    final fincaParaAbrir = pudoCrearFinca ? fincaName : _fallbackFinca;
    if (pudoCrearFinca) {
      await pauseIntegration(tester);
      await tester.enterText(
        find.byKey(const ValueKey('fincas.name')),
        fincaName,
      );
      await pauseIntegration(tester);
      await tester.tap(find.byKey(const ValueKey('fincas.save')));
      await waitFor(tester, find.text(fincaName), timeoutSeconds: 20);
    } else {
      await waitFor(tester, find.text(fincaParaAbrir), timeoutSeconds: 5);
    }
    await pauseIntegration(tester);

    await tester.tap(find.text(fincaParaAbrir));
    await waitFor(tester, find.byKey(const ValueKey('fincaDetail.lotes')));
    await pauseIntegration(tester);

    // 3) Crear un lote real en la finca.
    await tester.tap(find.byKey(const ValueKey('fincaDetail.lotes')));
    await waitFor(tester, find.text('Lotes'));
    await pauseIntegration(tester);
    final abrioLote = await tryTapAndWaitFor(
      tester,
      tapTarget: find.byKey(const ValueKey('lotes.create')),
      waitFor: find.byKey(const ValueKey('lotes.name')),
    );
    if (!abrioLote) {
      fail('No abrió el diálogo de nuevo lote. ${visibleTextOnScreen(tester)}');
    }
    await tester.enterText(find.byKey(const ValueKey('lotes.name')), loteName);
    await pauseIntegration(tester);
    await tester.enterText(find.byKey(const ValueKey('lotes.number')), '1');
    await pauseIntegration(tester);
    await tester.tap(find.byKey(const ValueKey('lotes.save')));
    await waitFor(tester, find.text(loteName), timeoutSeconds: 20);
    await pauseIntegration(tester);

    // 4) Registrar animal nuevo + primer pesaje desde pantalla Pesaje.
    await tester.pageBack();
    await waitFor(tester, find.byKey(const ValueKey('fincaDetail.pesaje')));
    await tester.tap(find.byKey(const ValueKey('fincaDetail.pesaje')));
    await waitFor(tester, find.byKey(const ValueKey('pesaje.animalId')));
    await pauseIntegration(tester);

    await tester.enterText(
      find.byKey(const ValueKey('pesaje.animalId')),
      animalId,
    );
    await pauseIntegration(tester);
    await tester.enterText(
      find.byKey(const ValueKey('pesaje.weight')),
      '235.5',
    );
    await pauseIntegration(tester);
    await tester.tap(find.byKey(const ValueKey('pesaje.submit')));

    await waitFor(
      tester,
      find.text('El animal "$animalId" es nuevo. ¿En qué lote lo ponés?'),
    );
    await pauseIntegration(tester);
    await tester.tap(find.text(loteName));

    await waitFor(tester, find.text(loteName), timeoutSeconds: 20);
    await waitFor(tester, find.text(animalId), timeoutSeconds: 20);
    expect(find.textContaining('235.5'), findsWidgets);
    await pauseIntegration(tester);

    // 5) Segundo pesaje del mismo animal: evalúa la rama de animal existente
    // (no debe pedir lote otra vez) y actualiza el peso visible del día.
    await tester.enterText(
      find.byKey(const ValueKey('pesaje.animalId')),
      animalId,
    );
    await pauseIntegration(tester);
    await tester.enterText(
      find.byKey(const ValueKey('pesaje.weight')),
      '241.5',
    );
    await pauseIntegration(tester);
    await tester.tap(find.byKey(const ValueKey('pesaje.submit')));
    await waitFor(tester, find.text(animalId), timeoutSeconds: 20);
    await waitFor(tester, find.textContaining('241.5'), timeoutSeconds: 20);
    expect(
      find.text('El animal "$animalId" es nuevo. ¿En qué lote lo ponés?'),
      findsNothing,
    );
    await pauseIntegration(tester);

    // 6) Revisar en Lotes que el animal quedó en el lote y su peso actual es
    // el último pesaje.
    await tester.pageBack();
    await waitFor(tester, find.byKey(const ValueKey('fincaDetail.lotes')));
    await tester.tap(find.byKey(const ValueKey('fincaDetail.lotes')));
    await waitFor(tester, find.text('Lotes'));
    await scrollUntilVisible(tester, find.text(loteName));
    await pauseIntegration(tester);
    await tester.tap(find.text(loteName));
    await waitFor(tester, find.text(animalId), timeoutSeconds: 20);
    await waitFor(tester, find.text('241.5 kg'), timeoutSeconds: 20);
    await waitFor(tester, find.textContaining('Total de animales:'));
    await pauseIntegration(tester);

    // 7) Ficha del animal: pestaña Pesajes con resumen e historial.
    await tester.tap(find.text(animalId));
    await waitFor(tester, find.text('Animal $animalId'), timeoutSeconds: 20);
    await tester.tap(find.text('Pesajes'));
    await waitFor(
      tester,
      find.text('Peso actual: 241.5 kg · 2 pesaje(s)'),
      timeoutSeconds: 20,
    );
    await waitFor(tester, find.text('+6 kg'));
    expect(find.text('235.5 kg'), findsWidgets);
    expect(find.text('241.5 kg'), findsWidgets);
    await pauseIntegration(tester, multiplier: 2);
  });
}
