import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/feature_flags_repository.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';
import 'package:hato_control/fincas/finca_detalle_screen.dart';

void main() {
  late AppDatabase db;
  late FincasRepository fincasRepo;
  late LotesRepository lotesRepo;
  late FeatureFlagsRepository featureFlagsRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    fincasRepo = FincasRepository(db);
    lotesRepo = LotesRepository(db);
    featureFlagsRepo = FeatureFlagsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<FincaRow> seedFinca() async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
            nombre: 'Finca KPI',
            creadaPor: 'u1',
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
            nombre: 'Destete',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'lote-2',
            fincaId: 'finca-1',
            nombre: 'Engorde',
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
            identificador: 'A-1',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: 'animal-2',
            fincaId: 'finca-1',
            loteId: 'lote-1',
            identificador: 'A-2',
            createdAt: now,
            updatedAt: now,
            estado: const Value(EstadoAnimal.vendido),
          ),
        );
    return (await db.select(db.fincas).get()).single;
  }

  testWidgets('muestra KPIs de lotes y animales activos', (tester) async {
    final finca = await seedFinca();
    await tester.pumpWidget(
      MaterialApp(
        home: FincaDetalleScreen(
          finca: finca,
          usuarioId: 'u1',
          sinConexion: false,
          database: db,
          fincasRepository: fincasRepo,
          lotesRepository: lotesRepo,
          featureFlagsRepository: featureFlagsRepo,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final kpiLotes = find.byKey(const ValueKey('fincaDetail.kpiLotes'));
    final kpiAnimales = find.byKey(const ValueKey('fincaDetail.kpiAnimales'));
    expect(kpiLotes, findsOneWidget);
    expect(kpiAnimales, findsOneWidget);

    expect(
      find.descendant(of: kpiLotes, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: kpiLotes, matching: find.text('Lotes')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: kpiAnimales, matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: kpiAnimales, matching: find.text('Animales activos')),
      findsOneWidget,
    );

    expect(find.byKey(const ValueKey('fincaDetail.corral')), findsOneWidget);
    expect(find.byKey(const ValueKey('fincaDetail.pesaje')), findsOneWidget);
    expect(find.byKey(const ValueKey('fincaDetail.lotes')), findsOneWidget);
    expect(find.byKey(const ValueKey('fincaDetail.dietas')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets(
    'oculta el botón de Dietas cuando el flag está deshabilitado',
    (tester) async {
      final finca = await seedFinca();
      final ahora = DateTime(2026, 1, 1);
      await db
          .into(db.featureFlags)
          .insert(
            FeatureFlagRow(
              id: 'flag-1',
              scope: 'finca',
              scopeId: 'finca-1',
              clave: 'dietas',
              habilitado: false,
              createdAt: ahora,
              updatedAt: ahora,
            ),
          );

      await tester.pumpWidget(
        MaterialApp(
          home: FincaDetalleScreen(
            finca: finca,
            usuarioId: 'u1',
            sinConexion: false,
            database: db,
            fincasRepository: fincasRepo,
            lotesRepository: lotesRepo,
            featureFlagsRepository: featureFlagsRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('fincaDetail.corral')), findsOneWidget);
      expect(find.byKey(const ValueKey('fincaDetail.dietas')), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    },
  );
}
