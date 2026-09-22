import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/deudas_repository.dart';
import 'package:hato_control/gastos/deudas_tab.dart';

/// Pestaña Deudas: la lista, los filtros y el total de lo que se está viendo.
void main() {
  late AppDatabase db;
  late DeudasRepository deudas;
  late FincaRow finca;
  final hoy = DateTime.now();

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    deudas = DeudasRepository(db);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca Deudas',
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
        home: DeudasTab(finca: finca, deudasRepository: deudas),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> cerrar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('sin deudas explica para qué sirve la pestaña', (tester) async {
    await abrir(tester);

    expect(find.text('Deudas de la finca'), findsOneWidget);
    expect(
      find.textContaining('no entra en la utilidad'),
      findsOneWidget,
      reason: 'tiene que quedar claro que no es contabilidad',
    );

    await cerrar(tester);
  });

  testWidgets('lista las deudas con su saldo y suma el total abajo', (
    tester,
  ) async {
    final coope = await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Cooperativa',
      monto: 450000,
      fecha: hoy,
    );
    await deudas.registrarAbono(deudaId: coope, monto: 200000, fecha: hoy);
    await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Veterinario',
      monto: 80000,
      fecha: hoy,
    );

    await abrir(tester);

    expect(find.text('Cooperativa'), findsOneWidget);
    expect(find.text('Veterinario'), findsOneWidget);
    expect(find.textContaining('Abonado ₡200.000'), findsOneWidget);
    // 450.000 - 200.000 + 80.000
    expect(find.text('Saldo: ₡330.000'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('el filtro de estado cambia la lista y el total', (tester) async {
    final pagada = await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Veterinario',
      monto: 80000,
      fecha: hoy,
    );
    await deudas.marcarPagada(pagada, fecha: hoy);
    await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Cooperativa',
      monto: 450000,
      fecha: hoy,
    );

    await abrir(tester);
    expect(find.text('Saldo: ₡450.000'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('deudas.filtro.${'pagadas'}')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Veterinario'), findsOneWidget);
    expect(find.text('Cooperativa'), findsNothing);
    expect(find.text('Saldo: ₡0'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('el buscador deja solo lo que coincide', (tester) async {
    await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Cooperativa',
      monto: 450000,
      fecha: hoy,
    );
    await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Veterinario',
      monto: 80000,
      fecha: hoy,
    );

    await abrir(tester);
    await tester.enterText(
      find.byKey(const ValueKey('deudas.buscar')),
      'veter',
    );
    await tester.pumpAndSettle();

    expect(find.text('Veterinario'), findsOneWidget);
    expect(find.text('Cooperativa'), findsNothing);
    expect(find.text('Saldo: ₡80.000'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('el botón de PDF está a mano junto al total', (tester) async {
    await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Cooperativa',
      monto: 450000,
      fecha: hoy,
    );

    await abrir(tester);
    expect(find.byKey(const ValueKey('deudas.exportar')), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('se registra una deuda desde el formulario', (tester) async {
    await abrir(tester);

    await tester.tap(find.byKey(const ValueKey('deudas.agregar')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('deudas.acreedor')),
      'Casa comercial',
    );
    await tester.enterText(
      find.byKey(const ValueKey('deudas.monto')),
      '125000',
    );
    await tester.tap(find.byKey(const ValueKey('deudas.guardar')));
    await tester.pumpAndSettle();

    final guardadas = await deudas.deudasDe('f1');
    expect(guardadas.single.deuda.acreedor, 'Casa comercial');
    expect(guardadas.single.saldo, 125000);
    expect(find.text('Casa comercial'), findsOneWidget);

    await cerrar(tester);
  });
}
