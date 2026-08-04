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
/// # Optional: watch simulator screenshots while it runs
/// ./scripts/watch_e2e_sim.sh /tmp/hato_e2e_watch 4
///
/// flutter test -d 0583D3FF-F9D0-4D5F-9484-82BDC0817124 \
///   integration_test/ronda1_utilidad_e2e_test.dart \
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
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  e2eAttachBinding(binding);

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

      await e2eStep('bootstrap + signOut');
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await pauseIntegration(tester);

      await Supabase.instance.client.auth.signOut();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await e2eStep('login');
      await waitFor(
        tester,
        find.byKey(const ValueKey('login.email')),
        label: 'login.email',
      );
      await tester.enterText(find.byKey(const ValueKey('login.email')), _email);
      await tester.enterText(
        find.byKey(const ValueKey('login.password')),
        _password,
      );
      await tester.tap(find.byKey(const ValueKey('login.submit')));
      await waitFor(
        tester,
        find.text('Mis fincas'),
        timeoutSeconds: 35,
        label: 'Mis fincas',
      );
      await waitFor(
        tester,
        find.textContaining('Plan'),
        timeoutSeconds: 35,
        label: 'Plan',
      );
      await pauseIntegration(tester);

      await e2eStep('crear/abrir finca');
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
        await waitFor(
          tester,
          find.text(fincaName),
          timeoutSeconds: 20,
          label: fincaName,
        );
      } else {
        e2eLog('create finca blocked — fallback $fincaParaAbrir');
        await waitFor(
          tester,
          find.text(fincaParaAbrir),
          timeoutSeconds: 8,
          label: fincaParaAbrir,
        );
      }
      await tapText(tester, fincaParaAbrir);
      await waitFor(
        tester,
        find.byKey(const ValueKey('fincaDetail.lotes')),
        label: 'fincaDetail.lotes',
      );
      await pauseIntegration(tester);

      // Lote
      await e2eStep('crear lote $loteName');
      await tester.tap(find.byKey(const ValueKey('fincaDetail.lotes')));
      await waitFor(tester, find.text('Lotes'), label: 'Lotes');
      final abrioLote = await tryTapAndWaitFor(
        tester,
        tapTarget: find.byKey(const ValueKey('lotes.create')),
        waitFor: find.byKey(const ValueKey('lotes.name')),
      );
      if (!abrioLote) {
        await e2eDump(tester, reason: 'lote_dialog_missing');
        fail('No abrió diálogo de lote. ${visibleTextOnScreen(tester)}');
      }
      await tester.enterText(
        find.byKey(const ValueKey('lotes.name')),
        loteName,
      );
      await tester.enterText(find.byKey(const ValueKey('lotes.number')), '91');
      await invokeButton(tester, find.byKey(const ValueKey('lotes.save')));
      await waitFor(
        tester,
        find.text(loteName),
        timeoutSeconds: 20,
        label: loteName,
      );

      // Dieta ₡/kg × kg por animal + ingredientes
      await e2eStep('crear dieta por kilo $dietaName');
      await tapBack(tester);
      await waitFor(
        tester,
        find.byKey(const ValueKey('fincaDetail.dietas')),
        label: 'fincaDetail.dietas',
      );
      await tester.tap(find.byKey(const ValueKey('fincaDetail.dietas')));
      await waitFor(
        tester,
        find.byKey(const ValueKey('dietas.crear')),
        label: 'dietas.crear',
      );
      await tester.tap(find.byKey(const ValueKey('dietas.crear')));
      await waitFor(
        tester,
        find.byKey(const ValueKey('dietas.nombre')),
        label: 'dietas.nombre',
      );
      await tester.enterText(
        find.byKey(const ValueKey('dietas.nombre')),
        dietaName,
      );
      await tester.enterText(
        find.byKey(const ValueKey('dietas.costoKg')),
        '500',
      );
      await tester.enterText(
        find.byKey(const ValueKey('dietas.kgAnimalDia')),
        '2',
      );
      await pumpSettleShort(tester);
      await waitFor(
        tester,
        find.byKey(const ValueKey('dietas.equivalenteDia')),
        label: 'dietas.equivalenteDia',
      );
      expect(find.textContaining('₡1000 / animal / día'), findsWidgets);
      await tester.enterText(
        find.byKey(const ValueKey('dietas.ingredientes')),
        'Pasto\nConcentrado\nMelaza',
      );
      await invokeButton(tester, find.byKey(const ValueKey('dietas.guardar')));
      await waitFor(
        tester,
        find.text(dietaName),
        timeoutSeconds: 20,
        label: dietaName,
      );
      await pauseIntegration(tester);

      // Asignar dieta
      await e2eStep('asignar dieta al lote');
      await tapBack(tester);
      await waitFor(
        tester,
        find.byKey(const ValueKey('fincaDetail.lotes')),
        label: 'fincaDetail.lotes',
      );
      await tester.tap(find.byKey(const ValueKey('fincaDetail.lotes')));
      await waitFor(tester, find.text(loteName), label: loteName);
      await tester.tap(find.text(loteName));
      await waitFor(
        tester,
        find.byKey(const ValueKey('lote.asignarDieta')),
        label: 'lote.asignarDieta',
      );
      await tester.tap(find.byKey(const ValueKey('lote.asignarDieta')));
      await waitFor(
        tester,
        find.text(dietaName),
        timeoutSeconds: 10,
        label: dietaName,
      );
      await tester.tap(find.text(dietaName));
      await waitFor(
        tester,
        find.textContaining(dietaName),
        timeoutSeconds: 15,
        label: 'dieta asignada',
      );
      await tapBack(tester);
      await waitFor(
        tester,
        find.byKey(const ValueKey('lotes.create')),
        label: 'lotes.create',
      );
      await tapBack(tester);

      // Trabajo: alta 100 kg × ₡1000
      await e2eStep('alta animal $animalId (₡/kg)');
      await waitFor(
        tester,
        find.byKey(const ValueKey('fincaDetail.pesaje')),
        label: 'fincaDetail.pesaje',
      );
      await tester.tap(find.byKey(const ValueKey('fincaDetail.pesaje')));
      await waitFor(
        tester,
        find.byKey(const ValueKey('pesaje.animalId')),
        label: 'pesaje.animalId',
      );
      await tester.enterText(
        find.byKey(const ValueKey('pesaje.animalId')),
        animalId,
      );
      await tester.enterText(
        find.byKey(const ValueKey('pesaje.weight')),
        '100',
      );
      await invokeButton(tester, find.byKey(const ValueKey('pesaje.submit')));
      await waitFor(
        tester,
        find.textContaining('Animal nuevo'),
        timeoutSeconds: 15,
        label: 'Animal nuevo sheet',
      );
      await waitFor(
        tester,
        find.byKey(ValueKey('pesaje.loteNombre.$loteName')),
        label: 'lote chip',
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
      await pumpSettleShort(tester);
      expect(find.textContaining('Costo del animal: ₡100000'), findsOneWidget);
      // Soft keyboard steals taps on iOS — invoke onPressed directly.
      await invokeButton(
        tester,
        find.byKey(const ValueKey('pesaje.alta.guardar')),
      );
      await waitFor(
        tester,
        find.text(animalId),
        timeoutSeconds: 20,
        label: 'animal en pesaje hoy',
      );
      await pauseIntegration(tester);

      // Hoja de vida → Venta (antes de vender): desglose de compra
      await e2eStep('verificar economía pre-venta');
      await tapBack(tester);
      await waitFor(
        tester,
        find.byKey(const ValueKey('fincaDetail.lotes')),
        label: 'fincaDetail.lotes',
      );
      await tester.tap(find.byKey(const ValueKey('fincaDetail.lotes')));
      await waitFor(tester, find.text(loteName), label: loteName);
      await tester.tap(find.text(loteName));
      await waitFor(
        tester,
        find.text(animalId),
        timeoutSeconds: 15,
        label: animalId,
      );
      await tester.tap(find.text(animalId));
      await waitFor(
        tester,
        find.byKey(const ValueKey('ficha.tab.venta')),
        timeoutSeconds: 15,
        label: 'ficha.tab.venta',
      );
      await selectTabIndex(tester, 4); // Venta
      await waitFor(
        tester,
        find.byKey(const ValueKey('economia.titulo')),
        timeoutSeconds: 15,
        label: 'economia.titulo',
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
      await e2eStep('venta 400kg × ₡1500');
      await tapBack(tester); // ficha
      await tapBack(tester); // lote
      await waitFor(
        tester,
        find.byKey(const ValueKey('lotes.create')),
        label: 'lotes.create',
      );
      await tapBack(tester);
      await waitFor(
        tester,
        find.byKey(const ValueKey('fincaDetail.venta')),
        label: 'fincaDetail.venta',
      );
      await tester.tap(find.byKey(const ValueKey('fincaDetail.venta')));
      await waitFor(
        tester,
        find.byKey(const ValueKey('venta.animalId')),
        label: 'venta.animalId',
      );
      await tester.enterText(
        find.byKey(const ValueKey('venta.animalId')),
        animalId,
      );
      await tester.enterText(find.byKey(const ValueKey('venta.peso')), '400');
      await invokeButton(tester, find.byKey(const ValueKey('venta.agregar')));
      // El grupo se arma solo con kilos de salida: sin dinero todavía (D-19).
      await waitFor(
        tester,
        find.textContaining('400 kg'),
        timeoutSeconds: 15,
        label: 'kilos de salida en la lista',
      );
      await invokeButton(tester, find.byKey(const ValueKey('venta.confirmar')));
      await waitFor(
        tester,
        find.widgetWithText(FilledButton, 'Confirmar'),
        timeoutSeconds: 8,
        label: 'dialog Confirmar',
      );
      await invokeButton(
        tester,
        find.widgetWithText(FilledButton, 'Confirmar').last,
      );
      await waitFor(
        tester,
        find.text('Historial'),
        timeoutSeconds: 25,
        label: 'Historial',
      );
      await tester.tap(find.text('Historial'));
      // Recién creado el grupo, faltan los datos de planta.
      await waitFor(
        tester,
        find.textContaining('faltan datos de planta'),
        timeoutSeconds: 20,
        label: 'grupo de venta sin liquidar',
      );
      // Animal id lives inside a collapsed ExpansionTile.
      await tester.tap(find.textContaining('Grupo ·').first);
      await pumpSettleShort(tester);
      await waitFor(
        tester,
        find.text(animalId),
        timeoutSeconds: 20,
        label: 'venta historial animal',
      );

      // Registrar los datos de planta del animal (D-19).
      await e2eStep('registrar datos de planta');
      await tester.tap(find.text(animalId));
      await waitFor(
        tester,
        find.byKey(const ValueKey('planta.pesoPie')),
        timeoutSeconds: 15,
        label: 'planta.pesoPie',
      );
      await tester.enterText(
        find.byKey(const ValueKey('planta.pesoPie')),
        '400',
      );
      await tester.enterText(
        find.byKey(const ValueKey('planta.pesoCanal')),
        '220',
      );
      await pumpSettleShort(tester);
      // El rendimiento lo calcula la app: 220 ÷ 400 = 55 %.
      expect(find.textContaining('55.0 %'), findsWidgets);
      await tester.enterText(
        find.byKey(const ValueKey('planta.dinero')),
        '600000',
      );
      await pumpSettleShort(tester);
      await invokeButton(tester, find.byKey(const ValueKey('planta.guardar')));

      // Ahora sí hay utilidad y análisis del grupo.
      await waitFor(
        tester,
        find.textContaining('utilidad ₡'),
        timeoutSeconds: 25,
        label: 'utilidad del grupo',
      );
      await tester.tap(find.textContaining('Grupo ·').first);
      await pumpSettleShort(tester);
      expect(find.textContaining('Rendimiento promedio'), findsWidgets);
      expect(find.textContaining('₡500000'), findsWidgets);
      await pauseIntegration(tester, multiplier: 2);

      // Sync real a Supabase (#11)
      await e2eStep('assert sync Supabase');
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
