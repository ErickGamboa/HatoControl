import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/lotes/animal_historial_screen.dart';

void main() {
  late AppDatabase db;
  late PesajesRepository repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = PesajesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<AnimalRow> seedAnimalConHistorial() async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
            nombre: 'Finca test',
            creadaPor: 'user-1',
            cuentaId: const Value('account-1'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'lote-1',
            fincaId: 'finca-1',
            nombre: 'Levante',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: 'animal-1',
            fincaId: 'finca-1',
            loteId: 'lote-1',
            identificador: 'A-154',
            createdAt: now,
            updatedAt: now,
          ),
        );
    // Ejemplo de la especificación: 210 → 232 (36 días) → 248 (33 días).
    final pesos = [
      (id: 'p-1', peso: 210.0, fecha: DateTime(2026, 1, 10)),
      (id: 'p-2', peso: 232.0, fecha: DateTime(2026, 2, 15)),
      (id: 'p-3', peso: 248.0, fecha: DateTime(2026, 3, 20)),
    ];
    for (final p in pesos) {
      await db
          .into(db.pesajes)
          .insert(
            PesajesCompanion.insert(
              id: p.id,
              animalId: 'animal-1',
              peso: p.peso,
              fecha: p.fecha,
              createdAt: p.fecha,
              updatedAt: p.fecha,
            ),
          );
    }
    return (db.select(
      db.animales,
    )..where((t) => t.id.equals('animal-1'))).getSingle();
  }

  testWidgets('muestra Días, ganancia, kg/día, promedio global y gráfico', (
    tester,
  ) async {
    final animal = await seedAnimalConHistorial();

    await tester.pumpWidget(
      MaterialApp(
        home: AnimalHistorialScreen(animal: animal, repo: repo),
      ),
    );
    await tester.pumpAndSettle();

    // Encabezados de la tabla, incluida la nueva columna Días. ('kg/día'
    // aparece también en la tarjeta de resumen.)
    for (final encabezado in ['Fecha', 'Peso', 'Días', 'Ganancia']) {
      expect(find.text(encabezado), findsOneWidget);
    }
    expect(find.text('kg/día'), findsNWidgets(2));

    // Días entre pesajes (36 y 33, como el ejemplo de la especificación).
    expect(find.text('36'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);

    // Ganancias por fila y kg/día con dos decimales.
    expect(find.text('+22 kg'), findsOneWidget);
    expect(find.text('+16 kg'), findsOneWidget);
    expect(find.text('+0.61'), findsOneWidget); // 22/36
    expect(find.text('+0.48'), findsOneWidget); // 16/33

    // Resumen: aumento total y promedio global (38 kg / 69 días = 0.55).
    expect(find.text('+38 kg'), findsOneWidget);
    expect(find.text('+0.55'), findsOneWidget);

    // Gráfico de evolución del peso.
    expect(find.byType(LineChart), findsOneWidget);

    // Desmontar y drenar el timer de cierre del stream de Drift (necesita
    // avanzar el reloj falso para que dispare).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('sin pesajes muestra mensaje vacío y no revienta', (
    tester,
  ) async {
    final animal = await seedAnimalConHistorial();
    await db.delete(db.pesajes).go();

    await tester.pumpWidget(
      MaterialApp(
        home: AnimalHistorialScreen(animal: animal, repo: repo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Este animal no tiene pesajes.'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
