import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/dietas/dietas_screen.dart';

void main() {
  late AppDatabase db;
  late DietasRepository repo;
  final now = DateTime(2026, 8, 3);

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = DietasRepository(db);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
            nombre: 'Finca Dietas',
            creadaPor: 'u1',
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Future<FincaRow> laFinca() =>
      (db.select(db.fincas)..where((t) => t.id.equals('finca-1'))).getSingle();

  Future<void> abrirPantalla(WidgetTester tester) async {
    final finca = await laFinca();
    await tester.pumpWidget(
      MaterialApp(
        home: DietasScreen(finca: finca, repo: repo),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Desmonta la pantalla dentro de la prueba para que el timer con que Drift
  /// cierra sus streams alcance a correr (si no, el test falla por
  /// "A Timer is still pending").
  Future<void> cerrarPantalla(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('el modal calcula ₡/kg × kg y guarda el costo derivado', (
    tester,
  ) async {
    await abrirPantalla(tester);

    await tester.tap(find.byKey(const ValueKey('dietas.crear')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('dietas.nombre')),
      'Engorde',
    );
    await tester.enterText(find.byKey(const ValueKey('dietas.costoKg')), '500');
    await tester.enterText(
      find.byKey(const ValueKey('dietas.kgAnimalDia')),
      '2',
    );
    await tester.pumpAndSettle();

    // La vista previa muestra el resultado antes de guardar.
    expect(find.byKey(const ValueKey('dietas.equivalenteDia')), findsOneWidget);
    expect(
      find.textContaining('₡500 / kg × 2 kg = ₡1000 / animal / día'),
      findsOneWidget,
    );
    expect(find.textContaining('₡7000 / animal / semana'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('dietas.ingredientes')),
      'Pasto\nConcentrado',
    );
    await tester.tap(find.byKey(const ValueKey('dietas.guardar')));
    await tester.pumpAndSettle();

    final dieta = (await db.select(db.dietas).get()).single;
    expect(dieta.nombre, 'Engorde');
    expect(dieta.costoKg, 500);
    expect(dieta.kgAnimalDia, 2);
    expect(dieta.costoAnimalDia, closeTo(1000, 0.0001));
    expect(dieta.costoAnimalSemana, closeTo(7000, 0.0001));

    final ings = await repo.listarIngredientes(dieta.id);
    expect(ings.map((i) => i.nombre).toSet(), {'Pasto', 'Concentrado'});
    // Los ingredientes siguen siendo solo nombres, sin costo.
    expect(ings.every((i) => i.costoAnimalDia == 0), isTrue);

    await cerrarPantalla(tester);
  });

  testWidgets('si falta un campo avisa y no crea la dieta', (tester) async {
    await abrirPantalla(tester);

    await tester.tap(find.byKey(const ValueKey('dietas.crear')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('dietas.nombre')),
      'Sin kilos',
    );
    await tester.enterText(find.byKey(const ValueKey('dietas.costoKg')), '500');
    await tester.tap(find.byKey(const ValueKey('dietas.guardar')));
    await tester.pumpAndSettle();

    expect(await db.select(db.dietas).get(), isEmpty);
    expect(find.textContaining('Faltan datos'), findsOneWidget);

    await cerrarPantalla(tester);
  });

  testWidgets('editar recarga los kilos y el costo por kilo digitados', (
    tester,
  ) async {
    await repo.crearDieta(
      fincaId: 'finca-1',
      nombre: 'Ración',
      costoKg: 320,
      kgAnimalDia: 2.5,
    );
    await abrirPantalla(tester);

    expect(find.textContaining('₡800 / animal / día'), findsOneWidget);
    expect(
      find.textContaining('₡320 / kg × 2.5 kg por animal al día'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Editar dieta'));
    await tester.pumpAndSettle();

    final costoKgField = tester.widget<TextField>(
      find.byKey(const ValueKey('dietas.costoKg')),
    );
    final kgField = tester.widget<TextField>(
      find.byKey(const ValueKey('dietas.kgAnimalDia')),
    );
    expect(costoKgField.controller?.text, '320');
    expect(kgField.controller?.text, '2.5');

    await tester.enterText(
      find.byKey(const ValueKey('dietas.kgAnimalDia')),
      '4',
    );
    await tester.tap(find.byKey(const ValueKey('dietas.guardar')));
    await tester.pumpAndSettle();

    final dieta = (await db.select(db.dietas).get()).single;
    expect(dieta.kgAnimalDia, 4);
    expect(dieta.costoAnimalDia, closeTo(1280, 0.0001));

    await cerrarPantalla(tester);
  });
}
