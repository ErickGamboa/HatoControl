import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';
import 'package:hato_control/pesaje/pesaje_screen.dart';

void main() {
  late AppDatabase db;
  final ahora = DateTime.now();

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
            createdAt: ahora,
            updatedAt: ahora,
          ),
        );
    return (await db.select(db.fincas).get()).single;
  }

  Future<void> seedLote(String id, String nombre) async {
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: id,
            fincaId: 'finca-1',
            nombre: nombre,
            createdAt: ahora,
            updatedAt: ahora,
          ),
        );
  }

  /// Un animal con un pesaje registrado hoy (así aparece en la lista del día).
  Future<void> seedPesado(
    String animalId,
    String loteId,
    String identificador,
    double peso, {
    double? pesoCompra,
    double? precioKgCompra,
    DateTime? fechaCompra,
  }) async {
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: animalId,
            fincaId: 'finca-1',
            loteId: loteId,
            identificador: identificador,
            pesoCompra: Value(pesoCompra),
            precioKgCompra: Value(precioKgCompra),
            fechaCompra: Value(fechaCompra),
            createdAt: ahora,
            updatedAt: ahora,
          ),
        );
    await db
        .into(db.pesajes)
        .insert(
          PesajesCompanion.insert(
            id: 'pesaje-$animalId',
            animalId: animalId,
            peso: peso,
            fecha: ahora,
            registradoPor: const Value('u1'),
            createdAt: ahora,
            updatedAt: ahora,
          ),
        );
  }

  Future<void> abrirPantalla(WidgetTester tester, FincaRow finca) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PesajeScreen(
          finca: finca,
          usuarioId: 'u1',
          pesajesRepository: PesajesRepository(db),
          lotesRepository: LotesRepository(db),
          sanidadRepository: SanidadRepository(db),
          ventasRepository: VentasRepository(db),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Toca la fila de la lista del día y espera la hoja de corrección.
  Future<void> abrirCorreccion(WidgetTester tester, String animalId) async {
    await tester.tap(find.byKey(ValueKey('pesaje.fila.pesaje-$animalId')));
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, Key key) async {
    await tester.ensureVisible(find.byKey(key));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
  }

  /// Desmonta la pantalla y deja correr el temporizador con que drift cierra
  /// sus streams; si no, el test falla por "a Timer is still pending".
  Future<void> cerrarPantalla(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<AnimalRow> animal(String id) =>
      (db.select(db.animales)..where((t) => t.id.equals(id))).getSingle();

  testWidgets('con un solo lote igual hay pestaña y contador', (tester) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedPesado('animal-1', 'lote-1', 'A-1', 300);
    await abrirPantalla(tester, finca);

    expect(find.text('Montaña'), findsOneWidget);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('pesaje.contadorLote.Montaña')),
          )
          .data,
      '1',
    );

    await cerrarPantalla(tester);
  });

  testWidgets('el contador de cada lote cuenta solo sus animales', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedLote('lote-2', 'Engorde');
    await seedPesado('animal-1', 'lote-1', 'A-1', 300);
    await seedPesado('animal-2', 'lote-1', 'A-2', 310);
    await seedPesado('animal-3', 'lote-2', 'B-1', 420);
    await abrirPantalla(tester, finca);

    String contador(String lote) => tester
        .widget<Text>(find.byKey(ValueKey('pesaje.contadorLote.$lote')))
        .data!;

    expect(contador('Montaña'), '2');
    expect(contador('Engorde'), '1');
    expect(find.text('3 pesados'), findsOneWidget);

    await cerrarPantalla(tester);
  });

  testWidgets('corrige el peso del día', (tester) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedPesado('animal-1', 'lote-1', 'A-1', 300);
    await abrirPantalla(tester, finca);

    await abrirCorreccion(tester, 'animal-1');
    await tester.enterText(
      find.byKey(const ValueKey('pesaje.corregir.peso')),
      '325',
    );
    await tocar(tester, const ValueKey('pesaje.corregir.guardar'));

    final pesaje = (await db.select(db.pesajes).get()).single;
    expect(pesaje.peso, 325);
    expect(pesaje.pendiente, isTrue);
    expect(find.text('325'), findsOneWidget);

    await cerrarPantalla(tester);
  });

  testWidgets('corrige el lote y deja el movimiento registrado', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedLote('lote-2', 'Engorde');
    await seedPesado('animal-1', 'lote-1', 'A-1', 300);
    await abrirPantalla(tester, finca);

    await abrirCorreccion(tester, 'animal-1');
    await tocar(tester, const ValueKey('pesaje.corregir.lote.Engorde'));
    await tocar(tester, const ValueKey('pesaje.corregir.guardar'));

    final a = await animal('animal-1');
    expect(a.loteId, 'lote-2');
    expect(a.pendiente, isTrue);
    final movimiento = (await db.select(db.movimientosLote).get()).single;
    expect(movimiento.loteOrigen, 'lote-1');
    expect(movimiento.loteDestino, 'lote-2');
    // La pestaña del lote nuevo ya trae el animal.
    expect(find.text('Engorde'), findsOneWidget);

    await cerrarPantalla(tester);
  });

  testWidgets('corrige el precio por kilo y recalcula el total de compra', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    final compra = DateTime(2026, 3, 1);
    await seedPesado(
      'animal-1',
      'lote-1',
      'A-1',
      300,
      pesoCompra: 200,
      precioKgCompra: 1000,
      fechaCompra: compra,
    );
    await abrirPantalla(tester, finca);

    await abrirCorreccion(tester, 'animal-1');
    await tester.enterText(
      find.byKey(const ValueKey('pesaje.corregir.precioKg')),
      '1500',
    );
    await tester.pumpAndSettle();
    expect(find.text('Compra: ₡300000'), findsOneWidget);
    await tocar(tester, const ValueKey('pesaje.corregir.guardar'));

    final a = await animal('animal-1');
    expect(a.precioKgCompra, 1500);
    expect(a.precioCompra, 300000);
    expect(a.pesoCompra, 200);
    // La fecha de compra original no se mueve: mueve la fecha de ingreso y con
    // ella el prorrateo de gastos fijos.
    expect(a.fechaCompra, compra);
    expect(a.pendiente, isTrue);

    await cerrarPantalla(tester);
  });

  testWidgets('precio por kilo 0 lo deja como nacido en la finca', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedPesado(
      'animal-1',
      'lote-1',
      'A-1',
      300,
      pesoCompra: 200,
      precioKgCompra: 1000,
      fechaCompra: DateTime(2026, 3, 1),
    );
    await abrirPantalla(tester, finca);

    await abrirCorreccion(tester, 'animal-1');
    await tester.enterText(
      find.byKey(const ValueKey('pesaje.corregir.precioKg')),
      '0',
    );
    await tocar(tester, const ValueKey('pesaje.corregir.guardar'));

    final a = await animal('animal-1');
    expect(a.precioKgCompra, 0);
    expect(a.precioCompra, 0);
    expect(a.pesoCompra, isNull);
    expect(a.fechaCompra, isNull);

    await cerrarPantalla(tester);
  });

  testWidgets('dejar el precio vacío no toca la compra', (tester) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedPesado('animal-1', 'lote-1', 'A-1', 300);
    await abrirPantalla(tester, finca);

    await abrirCorreccion(tester, 'animal-1');
    await tester.enterText(
      find.byKey(const ValueKey('pesaje.corregir.peso')),
      '310',
    );
    await tocar(tester, const ValueKey('pesaje.corregir.guardar'));

    final a = await animal('animal-1');
    expect(a.precioKgCompra, isNull);
    expect(a.precioCompra, isNull);
    expect((await db.select(db.pesajes).get()).single.peso, 310);

    await cerrarPantalla(tester);
  });

  testWidgets('elimina el pesaje desde la hoja de corrección', (tester) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedPesado('animal-1', 'lote-1', 'A-1', 300);
    await seedPesado('animal-2', 'lote-1', 'A-2', 310);
    await abrirPantalla(tester, finca);

    await abrirCorreccion(tester, 'animal-1');
    await tocar(tester, const ValueKey('pesaje.corregir.eliminar'));
    await tocar(tester, const ValueKey('pesaje.eliminar.confirmar'));

    final borrado = (await db.select(db.pesajes).get()).firstWhere(
      (p) => p.id == 'pesaje-animal-1',
    );
    expect(borrado.deletedAt, isNotNull);
    expect(borrado.pendiente, isTrue);
    // El lote sigue con el otro animal, así que el contador baja a 1.
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('pesaje.contadorLote.Montaña')),
          )
          .data,
      '1',
    );

    await cerrarPantalla(tester);
  });

  // ---- Lector de aretes (entra por Bluetooth como teclado) ----

  /// Simula que el ganadero tocó otra parte de la pantalla: ninguna casilla de
  /// texto queda encendida. Es el caso en que hoy se pierde la lectura.
  Future<void> soltarFoco(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  Future<void> leerArete(WidgetTester tester, String arete) async {
    for (final d in arete.split('')) {
      await tester.sendKeyEvent(_teclaDe(d));
    }
    await tester.pump();
  }

  String areteEnPantalla(WidgetTester tester) => tester
      .widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('pesaje.animalId')),
          matching: find.byType(TextField),
        ),
      )
      .controller!
      .text;

  testWidgets('la lectura entra al arete aunque nadie tenga el foco', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await abrirPantalla(tester, finca);
    await soltarFoco(tester);

    await leerArete(tester, '188000002093951');

    expect(areteEnPantalla(tester), '188000002093951');

    await cerrarPantalla(tester);
  });

  testWidgets('el Enter del lector pasa el foco al peso', (tester) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await abrirPantalla(tester, finca);
    await soltarFoco(tester);

    await leerArete(tester, '77');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextField>(
            find.descendant(
              of: find.byKey(const ValueKey('pesaje.weight')),
              matching: find.byType(TextField),
            ),
          )
          .focusNode!
          .hasFocus,
      isTrue,
    );
    // Y ese mismo Enter no debe caer en el campo del peso: si cayera, lo
    // tomaría como "listo" y dispararía Registrar con el peso vacío.
    expect(find.text('Ingresá el peso (kg).'), findsNothing);

    await cerrarPantalla(tester);
  });

  testWidgets('una lectura nueva reemplaza el arete anterior', (tester) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await abrirPantalla(tester, finca);
    await soltarFoco(tester);

    await leerArete(tester, '11');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await soltarFoco(tester);
    await leerArete(tester, '22');

    expect(areteEnPantalla(tester), '22');

    await cerrarPantalla(tester);
  });
}

LogicalKeyboardKey _teclaDe(String digito) => const {
  '0': LogicalKeyboardKey.digit0,
  '1': LogicalKeyboardKey.digit1,
  '2': LogicalKeyboardKey.digit2,
  '3': LogicalKeyboardKey.digit3,
  '4': LogicalKeyboardKey.digit4,
  '5': LogicalKeyboardKey.digit5,
  '6': LogicalKeyboardKey.digit6,
  '7': LogicalKeyboardKey.digit7,
  '8': LogicalKeyboardKey.digit8,
  '9': LogicalKeyboardKey.digit9,
}[digito]!;
