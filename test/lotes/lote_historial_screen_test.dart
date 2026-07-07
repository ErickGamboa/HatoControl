import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/lotes/lote_historial_screen.dart';

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

  Future<LoteRow> seedLoteConJornadas() async {
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
    for (final id in ['animal-1', 'animal-2']) {
      await db
          .into(db.animales)
          .insert(
            AnimalesCompanion.insert(
              id: id,
              fincaId: 'finca-1',
              loteId: 'lote-1',
              identificador: 'A-$id',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    // Dos jornadas: 10 Ene y 15 Feb (36 días).
    final pesajes = [
      (
        id: 'p-1',
        animal: 'animal-1',
        peso: 210.0,
        fecha: DateTime(2026, 1, 10),
      ),
      (
        id: 'p-2',
        animal: 'animal-2',
        peso: 190.0,
        fecha: DateTime(2026, 1, 10),
      ),
      (
        id: 'p-3',
        animal: 'animal-1',
        peso: 232.0,
        fecha: DateTime(2026, 2, 15),
      ),
      (
        id: 'p-4',
        animal: 'animal-2',
        peso: 210.0,
        fecha: DateTime(2026, 2, 15),
      ),
    ];
    for (final p in pesajes) {
      await db
          .into(db.pesajes)
          .insert(
            PesajesCompanion.insert(
              id: p.id,
              animalId: p.animal,
              peso: p.peso,
              fecha: p.fecha,
              createdAt: p.fecha,
              updatedAt: p.fecha,
            ),
          );
    }
    return (db.select(
      db.lotes,
    )..where((t) => t.id.equals('lote-1'))).getSingle();
  }

  testWidgets('muestra períodos con conteo, promedio, ganancia y gráfico', (
    tester,
  ) async {
    final lote = await seedLoteConJornadas();

    await tester.pumpWidget(
      MaterialApp(
        home: LoteHistorialScreen(lote: lote, repo: repo),
      ),
    );
    await tester.pumpAndSettle();

    for (final encabezado in [
      'Período',
      'Animales',
      'Promedio',
      'Ganancia',
      'kg/día',
    ]) {
      expect(find.text(encabezado), findsOneWidget);
    }

    // Períodos: primera jornada sola y luego 10 Ene → 15 Feb.
    expect(find.text('10 Ene'), findsOneWidget);
    expect(find.text('10 Ene → 15 Feb'), findsOneWidget);

    // Jornada de febrero: 2 animales, promedio 221, ganancia +21, 0.58 kg/día.
    expect(find.text('221 kg'), findsOneWidget);
    expect(find.text('+21 kg'), findsOneWidget);
    expect(find.text('+0.58'), findsOneWidget); // (22/36 + 20/36) / 2

    expect(find.byType(LineChart), findsOneWidget);

    // Desmontar y drenar el timer de cierre del stream de Drift (necesita
    // avanzar el reloj falso para que dispare).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('sin pesajes muestra mensaje vacío', (tester) async {
    final lote = await seedLoteConJornadas();
    await db.delete(db.pesajes).go();

    await tester.pumpWidget(
      MaterialApp(
        home: LoteHistorialScreen(lote: lote, repo: repo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Este lote no tiene pesajes todavía.'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
