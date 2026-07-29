import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:hato_control/main.dart' as app;
import 'helpers/integration_helpers.dart';
import 'helpers/supabase_assert.dart';

/// E2E visible ronda 1: utilidad ₡/kg, dieta semanal, sync a Supabase.
///
/// ```bash
/// flutter test -d macos integration_test/ronda1_utilidad_e2e_test.dart \
///   --dart-define=HATO_E2E_EMAIL=... \
///   --dart-define=HATO_E2E_PASSWORD=... \
///   --dart-define=HATO_E2E_SLOW_MS=400
/// ```
const _email = String.fromEnvironment('HATO_E2E_EMAIL');
const _password = String.fromEnvironment('HATO_E2E_PASSWORD');
const _fallbackFinca = String.fromEnvironment(
  'HATO_E2E_FALLBACK_FINCA',
  defaultValue: 'Finca acapulco',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'ronda1 e2e: dieta semanal, animal ₡/kg, venta ₡/kg y sync en nube',
    (tester) async {
      if (_email.isEmpty || _password.isEmpty) {
        markTestSkipped(
          'Define HATO_E2E_EMAIL y HATO_E2E_PASSWORD con un usuario Supabase '
          'sembrado para correr este e2e.',
        );
        return;
      }

      final stamp = DateTime.now().millisecondsSinceEpoch;
      final fincaName = 'R1 Finca $stamp';
      final loteName = 'R1 Lote $stamp';
      final dietaName = 'R1 Dieta $stamp';
      final animalId = 'R1${stamp % 100000000}';

      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await pauseIntegration(tester);

      await Supabase.instance.client.auth.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await waitFor(tester, find.byKey(const ValueKey('login.email')));
      await tester.enterText(find.byKey(const ValueKey('login.email')), _email);
      await tester.enterText(
        find.byKey(const ValueKey('login.password')),
        _password,
      );
      await tester.tap(find.byKey(const ValueKey('login.submit')));
      await waitFor(tester, find.text('Mis fincas'), timeoutSeconds: 35);
      await waitFor(tester, find.textContaining('Plan'), timeoutSeconds: 35);
      await pauseIntegration(tester);

      final pudoCrearFinca = await tryTapAndWaitFor(
        tester,
        tapTarget: find.byKey(const ValueKey('fincas.create')),
        waitFor: find.byKey(const ValueKey('fincas.name')),
      );
      final fincaParaAbrir = pudoCrearFinca ? fincaName : _fallbackFinca;
      if (pudoCrearFinca) {
        await tester.enterText(
          find.byKey(const ValueKey('fincas.name')),
          fincaName,
        );
        await tester.tap(find.byKey(const ValueKey('fincas.save')));
        await waitFor(tester, find.text(fincaName), timeoutSeconds: 20);
      } else {
        await waitFor(tester, find.text(fincaParaAbrir), timeoutSeconds: 8);
      }
      await tester.tap(find.text(fincaParaAbrir));
      await waitFor(tester, find.byKey(const ValueKey('fincaDetail.lotes')));
      await pauseIntegration(tester);

      // Lote
      await tester.tap(find.byKey(const ValueKey('fincaDetail.lotes')));
      await waitFor(tester, find.text('Lotes'));
      final abrioLote = await tryTapAndWaitFor(
        tester,
        tapTarget: find.byKey(const ValueKey('lotes.create')),
        waitFor: find.byKey(const ValueKey('lotes.name')),
      );
      if (!abrioLote) {
        fail('No abrió diálogo de lote. ${visibleTextOnScreen(tester)}');
      }
      await tester.enterText(
        find.byKey(const ValueKey('lotes.name')),
        loteName,
      );
      await tester.enterText(find.byKey(const ValueKey('lotes.number')), '91');
      await tester.tap(find.byKey(const ValueKey('lotes.save')));
      await waitFor(tester, find.text(loteName), timeoutSeconds: 20);

      // Dieta semanal + ingredientes
      await tester.pageBack();
      await waitFor(tester, find.byKey(const ValueKey('fincaDetail.dietas')));
      await tester.tap(find.byKey(const ValueKey('fincaDetail.dietas')));
      await waitFor(tester, find.byKey(const ValueKey('dietas.crear')));
      await tester.tap(find.byKey(const ValueKey('dietas.crear')));
      await waitFor(tester, find.byKey(const ValueKey('dietas.nombre')));
      await tester.enterText(
        find.byKey(const ValueKey('dietas.nombre')),
        dietaName,
      );
      await tester.enterText(
        find.byKey(const ValueKey('dietas.costoSemanal')),
        '7000',
      );
      await tester.pumpAndSettle();
      await waitFor(
        tester,
        find.byKey(const ValueKey('dietas.equivalenteDia')),
      );
      expect(find.textContaining('₡1000 / día'), findsWidgets);
      await tester.enterText(
        find.byKey(const ValueKey('dietas.ingredientes')),
        'Pasto\nConcentrado\nMelaza',
      );
      await tester.tap(find.byKey(const ValueKey('dietas.guardar')));
      await waitFor(tester, find.text(dietaName), timeoutSeconds: 20);
      await pauseIntegration(tester);

      // Asignar dieta
      await tester.pageBack();
      await waitFor(tester, find.byKey(const ValueKey('fincaDetail.lotes')));
      await tester.tap(find.byKey(const ValueKey('fincaDetail.lotes')));
      await waitFor(tester, find.text(loteName));
      await tester.tap(find.text(loteName));
      await waitFor(tester, find.byKey(const ValueKey('lote.asignarDieta')));
      await tester.tap(find.byKey(const ValueKey('lote.asignarDieta')));
      await waitFor(tester, find.text(dietaName), timeoutSeconds: 10);
      await tester.tap(find.text(dietaName));
      await waitFor(tester, find.textContaining(dietaName), timeoutSeconds: 15);
      await tester.pageBack();
      await waitFor(tester, find.text('Lotes'));
      await tester.pageBack();

      // Trabajo: alta 100 kg × ₡1000
      await waitFor(tester, find.byKey(const ValueKey('fincaDetail.pesaje')));
      await tester.tap(find.byKey(const ValueKey('fincaDetail.pesaje')));
      await waitFor(tester, find.byKey(const ValueKey('pesaje.animalId')));
      await tester.enterText(
        find.byKey(const ValueKey('pesaje.animalId')),
        animalId,
      );
      await tester.enterText(
        find.byKey(const ValueKey('pesaje.weight')),
        '100',
      );
      await tester.tap(find.byKey(const ValueKey('pesaje.submit')));
      await waitFor(
        tester,
        find.textContaining('Animal nuevo'),
        timeoutSeconds: 15,
      );
      await waitFor(
        tester,
        find.byKey(ValueKey('pesaje.loteNombre.$loteName')),
      );
      await tester.tap(find.byKey(ValueKey('pesaje.loteNombre.$loteName')));
      await tester.enterText(
        find.byKey(const ValueKey('pesaje.alta.pesoCompra')),
        '100',
      );
      await tester.enterText(
        find.byKey(const ValueKey('pesaje.alta.precioKg')),
        '1000',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Costo del animal: ₡100000'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pesaje.alta.guardar')));
      await waitFor(tester, find.text(animalId), timeoutSeconds: 20);
      await pauseIntegration(tester);

      // Hoja de vida → Venta (antes de vender): desglose de compra
      await tester.pageBack();
      await waitFor(tester, find.byKey(const ValueKey('fincaDetail.lotes')));
      await tester.tap(find.byKey(const ValueKey('fincaDetail.lotes')));
      await waitFor(tester, find.text(loteName));
      await tester.tap(find.text(loteName));
      await waitFor(tester, find.text(animalId), timeoutSeconds: 15);
      await tester.tap(find.text(animalId));
      await waitFor(tester, find.text('Venta'), timeoutSeconds: 15);
      await tester.tap(find.text('Venta'));
      await waitFor(
        tester,
        find.byKey(const ValueKey('economia.titulo')),
        timeoutSeconds: 15,
      );
      expect(find.textContaining('100 kg × ₡1000/kg'), findsWidgets);
      expect(find.textContaining('₡100000'), findsWidgets);
      // Sin venta: utilidad se muestra como —
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('economia.utilidad')),
          matching: find.text('—'),
        ),
        findsOneWidget,
      );
      await pauseIntegration(tester);

      // Venta 400 kg × ₡1500
      await tester.pageBack(); // ficha
      await tester.pageBack(); // lote
      await waitFor(tester, find.text('Lotes'));
      await tester.pageBack();
      await waitFor(tester, find.byKey(const ValueKey('fincaDetail.venta')));
      await tester.tap(find.byKey(const ValueKey('fincaDetail.venta')));
      await waitFor(tester, find.byKey(const ValueKey('venta.precioLote')));
      await tester.enterText(
        find.byKey(const ValueKey('venta.precioLote')),
        '1500',
      );
      await tester.enterText(
        find.byKey(const ValueKey('venta.animalId')),
        animalId,
      );
      await tester.enterText(find.byKey(const ValueKey('venta.peso')), '400');
      await tester.tap(find.byKey(const ValueKey('venta.agregar')));
      await waitFor(tester, find.textContaining('₡600000'), timeoutSeconds: 15);
      await tester.tap(find.byKey(const ValueKey('venta.confirmar')));
      await waitFor(
        tester,
        find.widgetWithText(FilledButton, 'Confirmar'),
        timeoutSeconds: 8,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Confirmar').last);
      await waitFor(tester, find.text('Historial'), timeoutSeconds: 25);
      await tester.tap(find.text('Historial'));
      await waitFor(tester, find.text(animalId), timeoutSeconds: 20);
      expect(find.textContaining('400'), findsWidgets);
      expect(find.textContaining('1500'), findsWidgets);
      await pauseIntegration(tester, multiplier: 2);

      // Sync real a Supabase (#11)
      final animalCloud = await waitForSupabaseRow(
        table: 'animales',
        column: 'identificador',
        equals: animalId,
        timeout: const Duration(seconds: 60),
      );
      expect((animalCloud['peso_compra'] as num).toDouble(), 100);
      expect((animalCloud['precio_kg_compra'] as num).toDouble(), 1000);
      expect((animalCloud['precio_compra'] as num).toDouble(), 100000);
      expect(animalCloud['estado'], 'vendido');

      final dietaCloud = await waitForSupabaseRow(
        table: 'dietas',
        column: 'nombre',
        equals: dietaName,
        timeout: const Duration(seconds: 60),
      );
      expect((dietaCloud['costo_animal_semana'] as num).toDouble(), 7000);
      expect(
        (dietaCloud['costo_animal_dia'] as num).toDouble(),
        closeTo(1000, 0.01),
      );

      final ings = await listSupabaseRows(
        table: 'dieta_ingredientes',
        column: 'dieta_id',
        equals: dietaCloud['id'] as String,
      );
      expect(
        ings.map((r) => r['nombre'] as String).toSet(),
        containsAll(['Pasto', 'Concentrado', 'Melaza']),
      );
      expect(ings.every((r) => (r['costo_animal_dia'] as num) == 0), isTrue);

      final ventaCloud = await waitForSupabaseRow(
        table: 'ventas',
        column: 'animal_id',
        equals: animalCloud['id'] as String,
        timeout: const Duration(seconds: 60),
      );
      expect((ventaCloud['peso'] as num).toDouble(), 400);
      expect((ventaCloud['precio_kg'] as num).toDouble(), 1500);
      expect((ventaCloud['precio'] as num).toDouble(), 600000);
    },
  );
}
