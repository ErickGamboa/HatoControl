import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/analisis/analisis_pesos_screen.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';

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
    return (await db.select(db.fincas).get()).single;
  }

  Future<void> seedLote(String id, String nombre, {int? numero}) async {
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: id,
            fincaId: 'finca-1',
            nombre: nombre,
            numero: Value(numero),
            createdAt: base,
            updatedAt: base,
          ),
        );
  }

  Future<void> seedAnimal(
    String id,
    String loteId,
    String identificador,
  ) async {
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: id,
            fincaId: 'finca-1',
            loteId: loteId,
            identificador: identificador,
            createdAt: base,
            updatedAt: base,
          ),
        );
  }

  Future<void> seedPesaje(String animalId, DateTime fecha, double peso) async {
    await db
        .into(db.pesajes)
        .insert(
          PesajesCompanion.insert(
            id: 'p-$animalId-${fecha.day}',
            animalId: animalId,
            peso: peso,
            fecha: fecha,
            registradoPor: const Value('u1'),
            createdAt: fecha,
            updatedAt: fecha,
          ),
        );
  }

  Future<void> abrir(WidgetTester tester, FincaRow finca) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnalisisPesosScreen(
          finca: finca,
          usuarioId: 'u1',
          pesajesRepository: PesajesRepository(db),
          dietasRepository: DietasRepository(db),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Baja hasta que la tarjeta entre en pantalla: el ListView no construye lo
  /// que no se ve, así que sin esto los buscadores no la encuentran.
  Future<void> bajarHasta(WidgetTester tester, Key llave) async {
    await tester.dragUntilVisible(
      find.byKey(llave),
      find.byKey(const ValueKey('analisis.detalle')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
  }

  /// Desmonta y deja correr el temporizador con que drift cierra sus streams.
  Future<void> cerrar(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  /// Dos animales, dos jornadas. Promedios: 1 de marzo (200+300)/2 = 250 kg,
  /// 11 de marzo (250+320)/2 = 285 kg. Ganancias: +50 y +20 → promedio +35.
  Future<FincaRow> seedLoteConDosJornadas() async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña', numero: 1);
    await seedAnimal('a1', 'lote-1', 'A-1');
    await seedAnimal('a2', 'lote-1', 'A-2');
    await seedPesaje('a1', base, 200);
    await seedPesaje('a2', base, 300);
    await seedPesaje('a1', base.add(const Duration(days: 10)), 250);
    await seedPesaje('a2', base.add(const Duration(days: 10)), 320);
    return finca;
  }

  testWidgets('el promedio de cada pesaje es kilos totales entre animales', (
    tester,
  ) async {
    final finca = await seedLoteConDosJornadas();
    await abrir(tester, finca);
    await tester.tap(find.byKey(const ValueKey('analisis.lote.Montaña')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('analisis.cadaPesaje')), findsOneWidget);
    // (200+300)/2 y (250+320)/2, con las dos fechas y la cantidad de animales.
    expect(find.text('250 kg'), findsWidgets);
    expect(find.text('285 kg'), findsWidgets);
    expect(find.text('01/03/26'), findsOneWidget);
    expect(find.text('11/03/26'), findsOneWidget);
    // La primera jornada no tiene contra qué comparar.
    expect(find.text('Entrada'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('la ganancia promedio compara cada animal contra sí mismo', (
    tester,
  ) async {
    final finca = await seedLoteConDosJornadas();
    await abrir(tester, finca);
    await tester.tap(find.byKey(const ValueKey('analisis.lote.Montaña')));
    await tester.pumpAndSettle();

    // (+50 y +20) / 2 = +35 kg en 10 días = 3.50 kg/día.
    expect(find.text('+35 kg'), findsOneWidget);
    expect(find.text('3.50'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('avisa cuando no se pesó a la misma cantidad de animales', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedAnimal('a1', 'lote-1', 'A-1');
    await seedAnimal('a2', 'lote-1', 'A-2');
    await seedPesaje('a1', base, 200);
    await seedPesaje('a2', base, 300);
    // En la segunda jornada solo se pesó uno: el promedio no es comparable.
    await seedPesaje('a1', base.add(const Duration(days: 10)), 250);
    await abrir(tester, finca);
    await tester.tap(find.byKey(const ValueKey('analisis.lote.Montaña')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'la cantidad de animales pesados varía entre jornadas',
      ),
      findsOneWidget,
    );

    await cerrar(tester);
  });

  testWidgets('qué tan parejo usa el mínimo y el máximo del último pesaje', (
    tester,
  ) async {
    final finca = await seedLoteConDosJornadas();
    await abrir(tester, finca);
    await tester.tap(find.byKey(const ValueKey('analisis.lote.Montaña')));
    await tester.pumpAndSettle();

    await bajarHasta(tester, const ValueKey('analisis.parejo'));
    expect(find.byKey(const ValueKey('analisis.parejo')), findsOneWidget);
    // 320 − 250 = 70 kg de diferencia en la jornada del 11 de marzo.
    expect(find.textContaining('el más pesado es de 70 kg'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('la comparativa ordena los lotes de mejor a peor ganancia', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Lento', numero: 1);
    await seedLote('lote-2', 'Rápido', numero: 2);
    await seedAnimal('a1', 'lote-1', 'A-1');
    await seedAnimal('b1', 'lote-2', 'B-1');
    await seedPesaje('a1', base, 200);
    await seedPesaje('b1', base, 200);
    // 10 días: Lento gana 1 kg/día, Rápido 3 kg/día.
    await seedPesaje('a1', base.add(const Duration(days: 10)), 210);
    await seedPesaje('b1', base.add(const Duration(days: 10)), 230);
    await abrir(tester, finca);

    expect(find.byKey(const ValueKey('analisis.comparativa')), findsOneWidget);
    final rapido = tester.getTopLeft(find.text('Rápido')).dy;
    final lento = tester.getTopLeft(find.text('Lento')).dy;
    expect(rapido, lessThan(lento));

    await cerrar(tester);
  });

  testWidgets('separa los lotes a los que les falta un segundo pesaje', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Con datos', numero: 1);
    await seedLote('lote-2', 'Recién', numero: 2);
    await seedAnimal('a1', 'lote-1', 'A-1');
    await seedAnimal('b1', 'lote-2', 'B-1');
    await seedPesaje('a1', base, 200);
    await seedPesaje('a1', base.add(const Duration(days: 10)), 230);
    await seedPesaje('b1', base, 180);
    await abrir(tester, finca);

    expect(find.text('Sin datos suficientes'), findsOneWidget);
    expect(find.text('Recién · 1 jornada'), findsOneWidget);

    await cerrar(tester);
  });

  testWidgets('marca a los animales que bajaron de peso', (tester) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Montaña');
    await seedAnimal('a1', 'lote-1', 'SUBE');
    await seedAnimal('a2', 'lote-1', 'BAJA');
    await seedPesaje('a1', base, 200);
    await seedPesaje('a2', base, 300);
    await seedPesaje('a1', base.add(const Duration(days: 10)), 250);
    await seedPesaje('a2', base.add(const Duration(days: 10)), 280);
    await abrir(tester, finca);
    await tester.tap(find.byKey(const ValueKey('analisis.lote.Montaña')));
    await tester.pumpAndSettle();

    await bajarHasta(tester, const ValueKey('analisis.enBaja'));
    expect(find.byKey(const ValueKey('analisis.enBaja')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('analisis.enBaja')),
        matching: find.text('BAJA'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('analisis.enBaja')),
        matching: find.text('SUBE'),
      ),
      findsNothing,
    );

    await cerrar(tester);
  });

  testWidgets('un lote sin pesajes lo dice en vez de mostrar números', (
    tester,
  ) async {
    final finca = await seedFinca();
    await seedLote('lote-1', 'Vacío');
    await abrir(tester, finca);
    await tester.tap(find.byKey(const ValueKey('analisis.lote.Vacío')));
    await tester.pumpAndSettle();

    expect(find.textContaining('todavía no registra pesajes'), findsOneWidget);

    await cerrar(tester);
  });
}
