import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';
import 'package:hato_control/venta/venta_screen.dart';

/// Historial de venta (D-19): el grupo nace sin dinero y los datos de planta se
/// registran por animal, con el rendimiento calculado.
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  late VentasRepository ventas;
  late SanidadRepository sanidad;
  final now = DateTime(2026, 8, 4);

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
    ventas = VentasRepository(db);
    sanidad = SanidadRepository(db);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca Venta',
            creadaPor: 'u1',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'l1',
            fincaId: 'f1',
            nombre: 'Engorde',
            createdAt: now,
            updatedAt: now,
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Future<AnimalRow> animalVendido(String ident) async {
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: 'l1',
      identificador: ident,
      peso: 200,
      registradoPor: 'u1',
      pesoCompra: 200,
      precioKgCompra: 1000,
      precioCompra: 200000,
    );
    final a = (await pesajes.buscarAnimal('f1', ident))!;
    return a;
  }

  Future<void> abrir(WidgetTester tester) async {
    final finca = await (db.select(
      db.fincas,
    )..where((t) => t.id.equals('f1'))).getSingle();
    await tester.pumpWidget(
      MaterialApp(
        home: VentaScreen(
          finca: finca,
          usuarioId: 'u1',
          pesajesRepository: pesajes,
          ventasRepository: ventas,
          sanidadRepository: sanidad,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
  }

  /// Desmonta la pantalla dentro de la prueba para que el timer con que Drift
  /// cierra sus streams alcance a correr.
  Future<void> cerrar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('el grupo recién creado avisa que faltan datos de planta', (
    tester,
  ) async {
    final a = await animalVendido('V-1');
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      items: [(animalId: a.id, peso: 450)],
    );

    await abrir(tester);

    expect(find.textContaining('faltan datos de planta'), findsOneWidget);
    await tester.tap(find.textContaining('Grupo ·'));
    await tester.pumpAndSettle();

    expect(find.text('V-1'), findsOneWidget);
    expect(
      find.textContaining('tocá para registrar los datos de planta'),
      findsOneWidget,
    );
    // Sin dinero no se inventa utilidad.
    expect(find.text('—'), findsWidgets);
    expect(
      find.textContaining('Ningún animal tiene datos de planta todavía'),
      findsOneWidget,
    );

    await cerrar(tester);
  });

  testWidgets('registra datos de planta: rendimiento en vivo y utilidad', (
    tester,
  ) async {
    final a = await animalVendido('V-2');
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      items: [(animalId: a.id, peso: 450)],
    );

    await abrir(tester);
    await tester.tap(find.textContaining('Grupo ·'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('V-2'));
    await tester.pumpAndSettle();

    // El diálogo recuerda con cuántos kilos salió de la finca.
    expect(find.textContaining('Salió de la finca con 450 kg'), findsOneWidget);
    expect(find.textContaining('digitá los dos pesos'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('planta.pesoPie')), '450');
    await tester.enterText(
      find.byKey(const ValueKey('planta.pesoCanal')),
      '252',
    );
    await tester.pumpAndSettle();

    // 252 ÷ 450 = 56 %, calculado por la app.
    expect(find.textContaining('Rendimiento: 56.0 %'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('planta.dinero')),
      '1260000',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('₡5000 por kilo de canal'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('planta.guardar')));
    await tester.pumpAndSettle();

    final venta = (await db.select(db.ventas).get()).single;
    expect(venta.pesoPie, 450);
    expect(venta.pesoCanal, 252);
    expect(venta.rendimiento, closeTo(56, 0.0001));
    expect(venta.dineroRecibido, 1260000);

    // El análisis del grupo ya reporta utilidad y rendimiento promedio.
    expect(find.textContaining('utilidad ₡'), findsOneWidget);
    expect(find.text('Rendimiento promedio'), findsOneWidget);
    expect(find.text('56.0 %'), findsOneWidget);
    // 1.260.000 − 200.000 de compra
    expect(find.text('₡1060000'), findsWidgets);

    await cerrar(tester);
  });

  testWidgets('no guarda un rendimiento imposible (canal mayor que pie)', (
    tester,
  ) async {
    final a = await animalVendido('V-3');
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      items: [(animalId: a.id, peso: 450)],
    );

    await abrir(tester);
    await tester.tap(find.textContaining('Grupo ·'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('V-3'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('planta.pesoPie')), '200');
    await tester.enterText(
      find.byKey(const ValueKey('planta.pesoCanal')),
      '300',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('planta.guardar')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('no puede ser mayor que el peso en pie'),
      findsOneWidget,
    );
    final venta = (await db.select(db.ventas).get()).single;
    expect(venta.pesoCanal, isNull, reason: 'no se guardó nada');
    expect(venta.dineroRecibido, isNull);

    await cerrar(tester);
  });

  testWidgets('tocar fuera del diálogo no descarta lo digitado', (
    tester,
  ) async {
    final a = await animalVendido('V-4');
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      items: [(animalId: a.id, peso: 450)],
    );

    await abrir(tester);
    await tester.tap(find.textContaining('Grupo ·'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('V-4'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('planta.dinero')),
      '900000',
    );
    await tester.pumpAndSettle();

    // Un toque en el velo, arriba del diálogo: no debe cerrarlo.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('planta.dinero')),
      findsOneWidget,
      reason: 'el diálogo sigue abierto y lo digitado no se perdió',
    );

    await tester.tap(find.byKey(const ValueKey('planta.guardar')));
    await tester.pumpAndSettle();

    expect((await db.select(db.ventas).get()).single.dineroRecibido, 900000);
    expect(find.textContaining('Datos guardados · V-4'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('guardar sin digitar nada avisa y no borra', (tester) async {
    final a = await animalVendido('V-5');
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      items: [(animalId: a.id, peso: 450)],
    );
    await ventas.registrarDatosPlanta(
      ventaId: (await db.select(db.ventas).get()).single.id,
      pesoPie: 440,
      pesoCanal: 220,
      dineroRecibido: 990000,
    );

    await abrir(tester);
    await tester.tap(find.textContaining('Grupo ·'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('V-5'));
    await tester.pumpAndSettle();

    // Vaciar los tres campos y guardar: debe avisar, no dejar la venta en cero.
    for (final k in ['planta.pesoPie', 'planta.pesoCanal', 'planta.dinero']) {
      await tester.enterText(find.byKey(ValueKey(k)), '');
    }
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('planta.guardar')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Digitá al menos un dato'), findsOneWidget);
    final venta = (await db.select(db.ventas).get()).single;
    expect(venta.dineroRecibido, 990000, reason: 'no se borró');
    expect(venta.pesoPie, 440);

    await cerrar(tester);
  });

  testWidgets('la pestaña En curso ya no pide precio por kilo', (tester) async {
    final finca = await (db.select(
      db.fincas,
    )..where((t) => t.id.equals('f1'))).getSingle();
    await tester.pumpWidget(
      MaterialApp(
        home: VentaScreen(
          finca: finca,
          usuarioId: 'u1',
          pesajesRepository: pesajes,
          ventasRepository: ventas,
          sanidadRepository: sanidad,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('venta.animalId')), findsOneWidget);
    expect(find.byKey(const ValueKey('venta.peso')), findsOneWidget);
    expect(find.byKey(const ValueKey('venta.precioLote')), findsNothing);
    expect(find.text('Kilos de salida'), findsOneWidget);

    await cerrar(tester);
  });
}
