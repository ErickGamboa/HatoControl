import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/medicamentos_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

/// Criterio de aceptación del punto 14 (utilidad por kg / dieta semanal).
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  late DietasRepository dietas;
  late MedicamentosRepository meds;
  late SanidadRepository sanidad;
  late VentasRepository ventas;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
    dietas = DietasRepository(db);
    meds = MedicamentosRepository(db);
    sanidad = SanidadRepository(db);
    ventas = VentasRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seed() async {
    final now = DateTime(2026, 1, 1);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca',
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
            nombre: 'Lote',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('ejemplo Erick: utilidad exacta ₡281.000', () async {
    await seed();

    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: 'l1',
      identificador: 'X-1',
      peso: 100,
      registradoPor: 'u1',
      pesoCompra: 100,
      precioKgCompra: 1000,
      precioCompra: 100000,
    );
    final animal = await pesajes.buscarAnimal('f1', 'X-1');
    expect(animal!.precioCompra, 100000);

    // Congelar fecha de compra/movimiento al inicio del período de dieta.
    final entrada = DateTime(2025, 1, 1);
    await (db.update(db.animales)..where((t) => t.id.equals(animal.id))).write(
      AnimalesCompanion(fechaCompra: Value(entrada), updatedAt: Value(entrada)),
    );
    await (db.update(
      db.movimientosLote,
    )..where((t) => t.animalId.equals(animal.id))).write(
      MovimientosLoteCompanion(
        fecha: Value(entrada),
        updatedAt: Value(entrada),
      ),
    );

    await dietas.crearDieta(
      fincaId: 'f1',
      nombre: 'Engorde',
      costoKg: 500,
      kgAnimalDia: 2,
      ingredientes: ['Pasto', 'Concentrado', 'Melaza'],
    );
    final dieta = (await db.select(db.dietas).get()).single;
    expect(dieta.costoAnimalDia, closeTo(1000, 0.0001));
    final ings = await dietas.listarIngredientes(dieta.id);
    expect(ings.map((i) => i.nombre).toList(), [
      'Concentrado',
      'Melaza',
      'Pasto',
    ]);
    expect(ings.every((i) => i.costoAnimalDia == 0), isTrue);

    // Asignar dieta desde la entrada (ajustar `desde` después).
    await dietas.asignarDietaALote(loteId: 'l1', dietaId: dieta.id);
    final asig = (await db.select(db.loteDietas).get()).single;
    await (db.update(db.loteDietas)..where((t) => t.id.equals(asig.id))).write(
      LoteDietasCompanion(desde: Value(entrada), updatedAt: Value(entrada)),
    );

    final medId = await meds.crearMedicamento(
      fincaId: 'f1',
      nombre: 'Catosal',
      costoEnvase: 10000,
      tipoAplicacion: 'dosis_fija',
      mlEnvase: 10,
      dosisCantidad: 4,
      diasRetiro: 0,
    );
    await sanidad.aplicarMedicamento(
      animalId: animal.id,
      medicamentoId: medId,
      pesoKg: 100,
    );

    final ventaFecha = entrada.add(const Duration(days: 215));
    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      fecha: ventaFecha,
      items: [(animalId: animal.id, peso: 400, precioKg: 1500)],
    );

    final r = await ventas.resumenDe(animal.id);
    expect(r.precioCompra, 100000);
    expect(r.costoAlimentacion, closeTo(215000, 0.5));
    expect(r.costoSanitario, closeTo(4000, 0.01));
    expect(r.precioVenta, 600000);
    expect(r.utilidad, closeTo(281000, 1));

    // La dieta no sigue corriendo después de la venta.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final r2 = await ventas.resumenDe(animal.id);
    expect(r2.utilidad, r.utilidad);
  });

  test('dieta semanal ₡7.000 × 7 días = ₡7.000 (no ₡49.000)', () async {
    await seed();
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: 'l1',
      identificador: 'Y-1',
      peso: 100,
      registradoPor: 'u1',
      pesoCompra: 100,
      precioKgCompra: 1000,
    );
    final animal = await pesajes.buscarAnimal('f1', 'Y-1');
    final desde = DateTime(2026, 1, 1);
    await (db.update(db.movimientosLote)
          ..where((t) => t.animalId.equals(animal!.id)))
        .write(MovimientosLoteCompanion(fecha: Value(desde)));

    await dietas.crearDieta(
      fincaId: 'f1',
      nombre: 'Semanal',
      costoKg: 500,
      kgAnimalDia: 2,
    );
    final dieta = (await db.select(db.dietas).get()).single;
    await dietas.asignarDietaALote(loteId: 'l1', dietaId: dieta.id);
    final asig = (await db.select(db.loteDietas).get()).single;
    await (db.update(db.loteDietas)..where((t) => t.id.equals(asig.id))).write(
      LoteDietasCompanion(desde: Value(desde)),
    );

    await ventas.confirmarLoteVenta(
      fincaId: 'f1',
      fecha: DateTime(2026, 1, 8), // 7 días de calendario
      items: [(animalId: animal!.id, peso: 110, precioKg: 1000)],
    );

    final r = await ventas.resumenDe(animal.id);
    expect(r.costoAlimentacion, closeTo(7000, 0.5));
  });

  test('nació en la finca: compra ₡0', () async {
    await seed();
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: 'l1',
      identificador: 'N-1',
      peso: 80,
      registradoPor: 'u1',
      precioKgCompra: 0,
      precioCompra: 0,
    );
    final animal = await pesajes.buscarAnimal('f1', 'N-1');
    expect(animal!.precioCompra, 0);
    expect(animal.precioKgCompra, 0);
  });

  test('quitar dieta del lote deja sin dieta vigente', () async {
    await seed();
    await dietas.crearDieta(
      fincaId: 'f1',
      nombre: 'Temp',
      costoKg: 500,
      kgAnimalDia: 2,
    );
    final dieta = (await db.select(db.dietas).get()).single;
    await dietas.asignarDietaALote(loteId: 'l1', dietaId: dieta.id);
    expect(await dietas.observarDietaVigente('l1').first, isNotNull);
    await dietas.quitarDietaDeLote('l1');
    expect(await dietas.observarDietaVigente('l1').first, isNull);
  });
}
