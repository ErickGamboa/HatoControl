import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';

void main() {
  late AppDatabase db;
  late DietasRepository dietasRepo;
  late PesajesRepository pesajesRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    dietasRepo = DietasRepository(db);
    pesajesRepo = PesajesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedFincaYLote() async {
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
  }

  test('crearDieta inserta fila pendiente', () async {
    await seedFincaYLote();
    await dietasRepo.crearDieta(
      fincaId: 'finca-1',
      nombre: 'Concentrado Premium',
      costoAnimalDia: 180,
    );

    final dietas = await db.select(db.dietas).get();
    expect(dietas, hasLength(1));
    expect(dietas.single.nombre, 'Concentrado Premium');
    expect(dietas.single.costoAnimalDia, 180);
    expect(dietas.single.moneda, 'CRC');
    expect(dietas.single.pendiente, isTrue);
  });

  test(
    'asignarDietaALote cierra vigente anterior y congela costo (D-02)',
    () async {
      await seedFincaYLote();
      await dietasRepo.crearDieta(
        fincaId: 'finca-1',
        nombre: 'Dieta A',
        costoAnimalDia: 100,
      );
      await dietasRepo.crearDieta(
        fincaId: 'finca-1',
        nombre: 'Dieta B',
        costoAnimalDia: 180,
      );
      final dietas = await db.select(db.dietas).get();
      final dietaA = dietas.firstWhere((d) => d.nombre == 'Dieta A');
      final dietaB = dietas.firstWhere((d) => d.nombre == 'Dieta B');

      await dietasRepo.asignarDietaALote(loteId: 'lote-1', dietaId: dietaA.id);
      await dietasRepo.editarDieta(
        dietaId: dietaA.id,
        nombre: 'Dieta A',
        costoAnimalDia: 999,
      );
      await dietasRepo.asignarDietaALote(loteId: 'lote-1', dietaId: dietaB.id);

      final asignaciones = await db.select(db.loteDietas).get();
      expect(asignaciones, hasLength(2));
      final cerrada = asignaciones.firstWhere((a) => a.dietaId == dietaA.id);
      final vigente = asignaciones.firstWhere((a) => a.hasta == null);
      expect(cerrada.hasta, isNotNull);
      expect(cerrada.costoAnimalDiaSnapshot, 100);
      expect(vigente.dietaId, dietaB.id);
      expect(vigente.costoAnimalDiaSnapshot, 180);

      final stream = await dietasRepo.observarDietaVigente('lote-1').first;
      expect(stream?.dieta.nombre, 'Dieta B');
    },
  );

  test(
    'crearAnimalConPesaje y moverAnimalDeLote registran movimientos_lote',
    () async {
      await seedFincaYLote();
      await db
          .into(db.lotes)
          .insert(
            LotesCompanion.insert(
              id: 'lote-2',
              fincaId: 'finca-1',
              nombre: 'Engorde',
              createdAt: DateTime(2026, 1, 1),
              updatedAt: DateTime(2026, 1, 1),
            ),
          );

      await pesajesRepo.crearAnimalConPesaje(
        fincaId: 'finca-1',
        loteId: 'lote-1',
        identificador: 'A-001',
        peso: 200,
        registradoPor: 'user-1',
      );
      final animal = await (db.select(db.animales)).getSingle();

      var movs = await db.select(db.movimientosLote).get();
      expect(movs, hasLength(1));
      expect(movs.single.loteOrigen, isNull);
      expect(movs.single.loteDestino, 'lote-1');

      await pesajesRepo.moverAnimalDeLote(
        animalId: animal.id,
        nuevoLoteId: 'lote-2',
      );
      movs = await db.select(db.movimientosLote).get();
      expect(movs, hasLength(2));
      final ultimo = movs.last;
      expect(ultimo.loteOrigen, 'lote-1');
      expect(ultimo.loteDestino, 'lote-2');
      expect(ultimo.pendiente, isTrue);
    },
  );
}
