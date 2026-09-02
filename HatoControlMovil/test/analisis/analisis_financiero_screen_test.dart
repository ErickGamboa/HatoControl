import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/analisis/analisis_financiero_screen.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

void main() {
  late AppDatabase db;
  final base = DateTime(2026, 3, 1);

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<FincaRow> seedFinca() async {
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
            nombre: 'Finca',
            creadaPor: 'u1',
            createdAt: base,
            updatedAt: base,
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'lote-1',
            fincaId: 'finca-1',
            nombre: 'Engorde',
            createdAt: base,
            updatedAt: base,
          ),
        );
    return (await db.select(db.fincas).get()).single;
  }

  /// Un animal con compra, dos pesajes y (si se pide) su venta liquidada.
  Future<void> seedAnimal(
    String id,
    String identificador, {
    required double precioCompra,
    required double pesoInicial,
    required double pesoFinal,
    double? dineroRecibido,
  }) async {
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: id,
            fincaId: 'finca-1',
            loteId: 'lote-1',
            identificador: identificador,
            precioCompra: Value(precioCompra),
            pesoCompra: Value(pesoInicial),
            precioKgCompra: Value(precioCompra / pesoInicial),
            fechaCompra: Value(base),
            estado: Value(
              dineroRecibido == null
                  ? EstadoAnimal.activo
                  : EstadoAnimal.vendido,
            ),
            createdAt: base,
            updatedAt: base,
          ),
        );
    await db
        .into(db.pesajes)
        .insert(
          PesajesCompanion.insert(
            id: 'p1-$id',
            animalId: id,
            peso: pesoInicial,
            fecha: base,
            createdAt: base,
            updatedAt: base,
          ),
        );
    final fin = base.add(const Duration(days: 100));
    await db
        .into(db.pesajes)
        .insert(
          PesajesCompanion.insert(
            id: 'p2-$id',
            animalId: id,
            peso: pesoFinal,
            fecha: fin,
            createdAt: fin,
            updatedAt: fin,
          ),
        );
    if (dineroRecibido != null) {
      await db
          .into(db.ventas)
          .insert(
            VentasCompanion.insert(
              id: 'v-$id',
              animalId: id,
              precio: dineroRecibido,
              peso: Value(pesoFinal),
              fecha: fin,
              dineroRecibido: Value(dineroRecibido),
              createdAt: fin,
              updatedAt: fin,
            ),
          );
    }
  }

  Future<void> abrir(WidgetTester tester, FincaRow finca) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnalisisFinancieroScreen(
          finca: finca,
          usuarioId: 'u1',
          ventasRepository: VentasRepository(db),
          lotesRepository: LotesRepository(db),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> cerrar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> bajarHasta(WidgetTester tester, Key llave) async {
    await tester.dragUntilVisible(
      find.byKey(llave),
      find.byKey(const ValueKey('financiero.lista')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('el desglose muestra la compra y su porcentaje', (tester) async {
    final finca = await seedFinca();
    // Sin dietas ni sanidad ni gastos fijos: la compra es el 100 %.
    await seedAnimal(
      'a1',
      'A-1',
      precioCompra: 200000,
      pesoInicial: 200,
      pesoFinal: 300,
    );
    await abrir(tester, finca);

    expect(find.byKey(const ValueKey('financiero.desglose')), findsOneWidget);
    expect(find.textContaining('₡200.000'), findsWidgets);
    expect(
      find.textContaining('el rubro de mayor peso es compra'),
      findsOneWidget,
    );

    await cerrar(tester);
  });

  testWidgets('sin costos de engorde no inventa un costo por kilo', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedAnimal(
      'a1',
      'A-1',
      precioCompra: 200000,
      pesoInicial: 200,
      pesoFinal: 300,
    );
    await abrir(tester, finca);

    await bajarHasta(tester, const ValueKey('financiero.costoKilo'));
    // Ganó 100 kg pero no hay dieta/sanidad/gastos: el costo de engorde es ₡0.
    expect(find.text('₡0'), findsWidgets);

    await cerrar(tester);
  });

  testWidgets('la utilidad solo aparece cuando el animal ya se vendió', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedAnimal(
      'enPie',
      'EN-PIE',
      precioCompra: 100000,
      pesoInicial: 200,
      pesoFinal: 300,
    );
    await abrir(tester, finca);

    await bajarHasta(tester, const ValueKey('financiero.utilidad'));
    expect(
      find.textContaining('Todavía no hay animales vendidos y liquidados'),
      findsOneWidget,
    );
    // Y no hay ranking que ordenar.
    expect(find.byKey(const ValueKey('financiero.ranking')), findsNothing);

    await cerrar(tester);
  });

  testWidgets('con un animal vendido muestra su utilidad y lo rankea', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedAnimal(
      'vendido',
      'VENDIDO',
      precioCompra: 100000,
      pesoInicial: 200,
      pesoFinal: 300,
      dineroRecibido: 150000,
    );
    await seedAnimal(
      'enPie',
      'EN-PIE',
      precioCompra: 100000,
      pesoInicial: 200,
      pesoFinal: 300,
    );
    await abrir(tester, finca);

    await bajarHasta(tester, const ValueKey('financiero.utilidad'));
    // 150.000 recibidos − 100.000 de compra = 50.000 de utilidad.
    expect(find.text('₡50.000'), findsWidgets);
    expect(
      find.textContaining('Corresponde a 1 animal vendido y liquidado'),
      findsOneWidget,
    );

    await bajarHasta(tester, const ValueKey('financiero.ranking'));
    // El que está en pie no entra al ranking: no tiene utilidad todavía.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('financiero.ranking')),
        matching: find.text('VENDIDO'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('financiero.ranking')),
        matching: find.text('EN-PIE'),
      ),
      findsNothing,
    );

    await cerrar(tester);
  });

  testWidgets('filtrar por lote no cambia nada si todos son del mismo', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedAnimal(
      'a1',
      'A-1',
      precioCompra: 200000,
      pesoInicial: 200,
      pesoFinal: 300,
    );
    await abrir(tester, finca);

    await tester.tap(find.byKey(const ValueKey('financiero.lote.Engorde')));
    await tester.pumpAndSettle();
    expect(find.textContaining('₡200.000'), findsWidgets);

    await cerrar(tester);
  });

  testWidgets('una finca sin animales lo dice en vez de mostrar ceros', (
    tester,
  ) async {
    final finca = await seedFinca();
    await abrir(tester, finca);

    expect(
      find.textContaining('todavía no tiene animales registrados'),
      findsOneWidget,
    );

    await cerrar(tester);
  });
}
