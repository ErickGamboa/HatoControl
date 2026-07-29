import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';

import '../support/local_db_seed.dart';

void main() {
  late AppDatabase db;
  late FincasRepository fincasRepo;
  late LotesRepository lotesRepo;
  late PesajesRepository pesajesRepo;
  late DietasRepository dietasRepo;
  late SanidadRepository sanidadRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    fincasRepo = FincasRepository(db);
    lotesRepo = LotesRepository(db);
    pesajesRepo = PesajesRepository(db);
    dietasRepo = DietasRepository(db);
    sanidadRepo = SanidadRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'flujo offline: dieta asignada, movimiento, sanidad individual y batch',
    () async {
      const usuarioId = 'user-modules-1';
      await seedCuentaLocal(db, usuarioId: usuarioId);

      await fincasRepo.crearFinca(nombre: 'La Esperanza', creadaPor: usuarioId);
      final finca = (await db.select(db.fincas).get()).single;

      await lotesRepo.crearLote(
        fincaId: finca.id,
        nombre: 'Destete',
        numero: 1,
      );
      final lote = (await db.select(db.lotes).get()).single;

      await dietasRepo.crearDieta(
        fincaId: finca.id,
        nombre: 'Concentrado',
        costoAnimalSemana: 150,
      );
      final dieta = (await db.select(db.dietas).get()).single;
      await dietasRepo.asignarDietaALote(loteId: lote.id, dietaId: dieta.id);

      await pesajesRepo.crearAnimalConPesaje(
        fincaId: finca.id,
        loteId: lote.id,
        identificador: 'MOD-001',
        peso: 200,
        registradoPor: usuarioId,
      );
      await pesajesRepo.crearAnimalConPesaje(
        fincaId: finca.id,
        loteId: lote.id,
        identificador: 'MOD-002',
        peso: 195,
        registradoPor: usuarioId,
      );
      final animales = await db.select(db.animales).get();
      expect(animales, hasLength(2));

      final movimientos = await db.select(db.movimientosLote).get();
      expect(movimientos, hasLength(2));
      expect(movimientos.every((m) => m.pendiente), isTrue);

      await sanidadRepo.registrarEvento(
        animalId: animales.first.id,
        tipo: TipoEventoSanitario.vacuna,
        producto: 'Clostridial',
        dosis: '5 ml',
        fecha: DateTime(2026, 3, 1),
        responsableId: usuarioId,
        costo: 3500,
      );
      final batch = await sanidadRepo.registrarEventoEnLote(
        loteId: lote.id,
        tipo: TipoEventoSanitario.desparasitacion,
        producto: 'Ivermectina',
        dosis: '1 ml/50 kg',
        fecha: DateTime(2026, 3, 2),
        responsableId: usuarioId,
        costo: 1200,
      );
      expect(batch, 2);

      final eventos = await db.select(db.eventosSanitarios).get();
      expect(eventos, hasLength(3));
      expect(eventos.every((e) => e.pendiente), isTrue);

      final asignacion = await dietasRepo.observarDietaVigente(lote.id).first;
      expect(asignacion?.dieta.nombre, 'Concentrado');
      expect(
        asignacion?.asignacion.costoAnimalDiaSnapshot,
        closeTo(150 / 7, 0.0001),
      );
    },
  );
}
