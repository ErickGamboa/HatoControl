import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/deudas_repository.dart';
import 'package:hato_control/data/repositories/gastos_fijos_repository.dart';
import 'package:hato_control/gastos/gastos_screen.dart';

/// El módulo Gastos: dos pestañas, y el botón de PDF arriba a la derecha
/// SOLO cuando se está viendo Deudas (en Gastos no tiene nada que exportar).
void main() {
  late AppDatabase db;
  late DeudasRepository deudas;
  late GastosFijosRepository gastosFijos;
  late FincaRow finca;
  final hoy = DateTime.now();

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    deudas = DeudasRepository(db);
    gastosFijos = GastosFijosRepository(db);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca Gastos',
            creadaPor: 'u1',
            createdAt: hoy,
            updatedAt: hoy,
          ),
        );
    finca = await (db.select(
      db.fincas,
    )..where((t) => t.id.equals('f1'))).getSingle();
  });

  tearDown(() async => db.close());

  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GastosScreen(
          finca: finca,
          deudasRepository: deudas,
          gastosFijosRepository: gastosFijos,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> irADeudas(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('gastos.tab.deudas')));
    await tester.pumpAndSettle();
  }

  Future<void> cerrar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('el módulo se llama Gastos y trae las dos pestañas', (
    tester,
  ) async {
    await abrir(tester);

    expect(find.byType(AppBar), findsOneWidget);
    // "Gastos" sale dos veces: el título y la pestaña.
    expect(find.text('Gastos'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('gastos.tab.gastos')), findsOneWidget);
    expect(find.byKey(const ValueKey('gastos.tab.deudas')), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('el botón de PDF aparece solo en la pestaña de Deudas', (
    tester,
  ) async {
    await abrir(tester);
    expect(
      find.byKey(const ValueKey('deudas.exportar')),
      findsNothing,
      reason: 'en Gastos no hay nada que exportar',
    );

    await irADeudas(tester);
    expect(find.byKey(const ValueKey('deudas.exportar')), findsOneWidget);

    // Y al volverse a Gastos, se va.
    await tester.tap(find.byKey(const ValueKey('gastos.tab.gastos')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('deudas.exportar')), findsNothing);

    await cerrar(tester);
  });

  testWidgets('sin deudas que mostrar, el PDF avisa en vez de abrir una hoja vacía', (
    tester,
  ) async {
    await abrir(tester);
    await irADeudas(tester);

    await tester.tap(find.byKey(const ValueKey('deudas.exportar')));
    await tester.pumpAndSettle();

    expect(find.text('No hay deudas que exportar.'), findsOneWidget);
    expect(find.text('Deudas en PDF'), findsNothing);

    await cerrar(tester);
  });

  testWidgets('con deudas filtradas, el PDF sale con lo que se está viendo', (
    tester,
  ) async {
    await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Cooperativa',
      monto: 450000,
      fecha: hoy,
    );
    final pagada = await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Veterinario',
      monto: 80000,
      fecha: hoy,
    );
    await deudas.marcarPagada(pagada, fecha: hoy);

    await abrir(tester);
    await irADeudas(tester);

    // Se filtra a pagadas: el PDF tiene que llevarse solo esa.
    await tester.tap(find.byKey(const ValueKey('deudas.filtro.pagadas')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('deudas.exportar')));
    // Sin `pumpAndSettle`: la previa del PDF rasteriza con el motor del
    // sistema y en un test nunca termina de asentarse. Con unos cuantos
    // cuadros alcanza para ver que la pantalla se abrió.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Deudas en PDF'), findsOneWidget);

    await cerrar(tester);
  });
}
