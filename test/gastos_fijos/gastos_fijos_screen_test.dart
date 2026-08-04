import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/gastos_fijos_repository.dart';
import 'package:hato_control/gastos_fijos/gastos_fijos_screen.dart';

void main() {
  late AppDatabase db;
  late GastosFijosRepository repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = GastosFijosRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<FincaRow> seedFinca() async {
    final now = DateTime(2026, 8, 1);
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
    return (await db.select(db.fincas).get()).single;
  }

  Future<void> abrir(WidgetTester tester, FincaRow finca) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GastosFijosScreen(finca: finca, gastosFijosRepository: repo),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('formato de colones con punto de miles', () {
    expect(fmtColones(300000), '₡300.000');
    expect(fmtColones(931.68), '₡932');
    expect(fmtColones(0), '₡0');
    expect(fmtColones(1234567), '₡1.234.567');
  });

  testWidgets('vacío explica para qué sirve el módulo', (tester) async {
    final finca = await seedFinca();
    await abrir(tester, finca);

    expect(find.text('Gastos de la finca'), findsOneWidget);
    expect(find.byKey(const ValueKey('gastosFijos.agregar')), findsOneWidget);
    expect(find.byKey(const ValueKey('gastosFijos.resumen')), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('lista un gasto mensual con su monto y vigencia', (tester) async {
    final finca = await seedFinca();
    await repo.crearGasto(
      fincaId: finca.id,
      concepto: 'Salario peón',
      monto: 300000,
      periodicidad: PeriodicidadGasto.mensual,
      desde: DateTime(2026, 7, 1),
    );
    await abrir(tester, finca);

    expect(find.text('Salario peón'), findsOneWidget);
    expect(find.text('₡300.000 cada mes · desde julio 2026'), findsOneWidget);
    expect(find.byKey(const ValueKey('gastosFijos.resumen')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('el formulario guarda un gasto nuevo', (tester) async {
    final finca = await seedFinca();
    await abrir(tester, finca);

    await tester.tap(find.byKey(const ValueKey('gastosFijos.agregar')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('gastosFijos.concepto')),
      'Luz',
    );
    await tester.enterText(
      find.byKey(const ValueKey('gastosFijos.monto')),
      '25000',
    );
    await tester.tap(find.byKey(const ValueKey('gastosFijos.guardar')));
    await tester.pumpAndSettle();

    final guardado = (await repo.gastosDe(finca.id)).single;
    expect(guardado.concepto, 'Luz');
    expect(guardado.monto, 25000);
    expect(guardado.periodicidad, PeriodicidadGasto.mensual);
    expect(guardado.desde.day, 1);
    expect(find.text('Gasto guardado'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('sin concepto ni monto avisa y no guarda', (tester) async {
    final finca = await seedFinca();
    await abrir(tester, finca);

    await tester.tap(find.byKey(const ValueKey('gastosFijos.agregar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('gastosFijos.guardar')));
    await tester.pumpAndSettle();

    expect(find.text('Escribí el concepto y el monto'), findsOneWidget);
    expect(await repo.gastosDe(finca.id), isEmpty);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('dar de baja llena `hasta` sin borrar el gasto', (tester) async {
    final finca = await seedFinca();
    await repo.crearGasto(
      fincaId: finca.id,
      concepto: 'Salario peón',
      monto: 300000,
      periodicidad: PeriodicidadGasto.mensual,
      desde: DateTime(2026, 7, 1),
    );
    await abrir(tester, finca);

    await tester.tap(find.text('Salario peón'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('gastosFijos.darDeBaja')));
    await tester.pumpAndSettle();

    final fila = (await repo.gastosDe(finca.id)).single;
    expect(fila.hasta, isNotNull);
    expect(find.text('Gasto dado de baja'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
