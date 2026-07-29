import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/estadisticas/estadisticas_sanidad.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/medicamentos_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

void main() {
  late AppDatabase db;
  late MedicamentosRepository meds;
  late SanidadRepository sanidad;
  late VentasRepository ventas;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    meds = MedicamentosRepository(db);
    sanidad = SanidadRepository(db, medicamentosRepository: meds);
    ventas = VentasRepository(db, sanidadRepository: sanidad);
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
            nombre: 'F',
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
            nombre: 'L',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.animales)
        .insert(
          AnimalesCompanion.insert(
            id: 'a1',
            fincaId: 'f1',
            loteId: 'l1',
            identificador: '100',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  test('aplicar medicamento calcula dosis, costo y retiro', () async {
    await seed();
    final id = await meds.crearMedicamento(
      fincaId: 'f1',
      nombre: 'Catosal',
      costoEnvase: 10000,
      tipoAplicacion: TipoAplicacionMedicamento.porPeso,
      mlEnvase: 10,
      dosisCantidad: 50,
      dosisPorCadaKg: 10,
      diasRetiro: 30,
    );
    await sanidad.aplicarMedicamento(
      animalId: 'a1',
      medicamentoId: id,
      pesoKg: 300,
      fecha: DateTime(2026, 1, 1),
    );
    final hist = await sanidad.observarHistorial('a1').first;
    expect(hist, hasLength(1));
    expect(hist.first.dosis, '1500 ml');
    expect(hist.first.costo, 1500000); // 10000/10 * 1500
    expect(hist.first.retiroHasta, DateTime(2026, 1, 31));
    expect(
      await sanidad.retiroHasta('a1', hoy: DateTime(2026, 1, 15)),
      isNotNull,
    );
  });

  test('venta bloqueada si está en retiro', () async {
    await seed();
    final id = await meds.crearMedicamento(
      fincaId: 'f1',
      nombre: 'X',
      costoEnvase: 100,
      tipoAplicacion: TipoAplicacionMedicamento.dosisFija,
      mlEnvase: 100,
      dosisCantidad: 5,
      diasRetiro: 10,
    );
    await sanidad.aplicarMedicamento(
      animalId: 'a1',
      medicamentoId: id,
      pesoKg: 200,
      fecha: DateTime.now(),
    );
    expect(
      () => ventas.confirmarLoteVenta(
        fincaId: 'f1',
        items: [(animalId: 'a1', peso: 200, precioKg: 5)],
      ),
      throwsA(isA<AnimalEnRetiroException>()),
    );
  });
}
