import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';
import 'package:hato_control/venta/venta_screen.dart';

/// Vender el lote completo sin escanear animal por animal: cada uno entra con
/// su ÚLTIMO pesaje, y el que no tenga ninguno entra marcado para digitárselo.
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  late VentasRepository ventas;
  late SanidadRepository sanidad;
  late LotesRepository lotes;
  final hoy = DateTime.now();

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
    ventas = VentasRepository(db);
    sanidad = SanidadRepository(db);
    lotes = LotesRepository(db);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca Venta',
            creadaPor: 'u1',
            createdAt: hoy,
            updatedAt: hoy,
          ),
        );
    await lotes.crearLote(fincaId: 'f1', nombre: 'Engorde', numero: 1);
  });

  tearDown(() async => db.close());

  Future<String> loteId() async => (await lotes.lotesActivos('f1')).single.id;

  Future<AnimalRow> crearAnimal(String ident, {double peso = 200}) async {
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: await loteId(),
      identificador: ident,
      peso: peso,
      registradoPor: 'u1',
      pesoCompra: peso,
      precioKgCompra: 1000,
    );
    return (await pesajes.buscarAnimal('f1', ident))!;
  }

  /// Un animal sin ningún pesaje: se borra el que crea el alta.
  Future<AnimalRow> crearAnimalSinPesaje(String ident) async {
    final a = await crearAnimal(ident);
    final suyos = await (db.select(db.pesajes)
          ..where((t) => t.animalId.equals(a.id)))
        .get();
    for (final p in suyos) {
      await pesajes.eliminarPesaje(p.id);
    }
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
          lotesRepository: lotes,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> elegirLoteCompleto(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('venta.loteCompleto')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('venta.lote.${await loteId()}')));
    await tester.pumpAndSettle();
  }

  Future<void> cerrar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets('agrega todo el lote con el último pesaje de cada animal', (
    tester,
  ) async {
    final a = await crearAnimal('0001', peso: 200);
    await crearAnimal('0002', peso: 300);
    // Un pesaje más nuevo: es el que tiene que entrar a la venta.
    await pesajes.registrarPesajeEnFecha(
      animalId: a.id,
      peso: 260,
      fecha: hoy,
      registradoPor: 'u1',
    );

    await abrir(tester);
    await elegirLoteCompleto(tester);

    expect(find.text('0001'), findsOneWidget);
    expect(find.text('0002'), findsOneWidget);
    expect(find.text('260 kg de salida'), findsOneWidget);
    expect(find.text('300 kg de salida'), findsOneWidget);
    expect(find.textContaining('2 animal(es) · 560 kg'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('el animal sin pesaje entra marcado y bloquea el confirmar', (
    tester,
  ) async {
    await crearAnimal('0001', peso: 200);
    await crearAnimalSinPesaje('0002');

    await abrir(tester);
    await elegirLoteCompleto(tester);

    expect(find.text('Falta el peso: tocá el lápiz'), findsOneWidget);
    expect(find.text('Faltan los kilos de 1'), findsOneWidget);

    final confirmar = tester.widget<FilledButton>(
      find.byKey(const ValueKey('venta.confirmar')),
    );
    expect(confirmar.onPressed, isNull, reason: 'no se puede confirmar');

    await cerrar(tester);
  });

  testWidgets('al digitarle los kilos se destraba el confirmar', (
    tester,
  ) async {
    await crearAnimalSinPesaje('0002');

    await abrir(tester);
    await elegirLoteCompleto(tester);

    await tester.tap(find.byTooltip('Corregir kilos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '280');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('280 kg de salida'), findsOneWidget);
    final confirmar = tester.widget<FilledButton>(
      find.byKey(const ValueKey('venta.confirmar')),
    );
    expect(confirmar.onPressed, isNotNull);

    await cerrar(tester);
  });

  testWidgets('un animal en retiro no entra a la venta del lote', (
    tester,
  ) async {
    await crearAnimal('0001', peso: 200);
    final enRetiro = await crearAnimal('0002', peso: 210);
    await db
        .into(db.eventosSanitarios)
        .insert(
          EventosSanitariosCompanion.insert(
            id: 'e1',
            animalId: enRetiro.id,
            tipo: 'medicamento',
            producto: 'Antibiótico',
            fecha: hoy,
            retiroHasta: Value(hoy.add(const Duration(days: 10))),
            createdAt: hoy,
            updatedAt: hoy,
          ),
        );

    await abrir(tester);
    await elegirLoteCompleto(tester);

    expect(find.text('0001'), findsOneWidget);
    expect(find.text('0002'), findsNothing);
    expect(find.textContaining('1 en retiro'), findsOneWidget);

    await cerrar(tester);
  });
}
