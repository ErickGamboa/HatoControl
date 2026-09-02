import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';

import '../support/local_db_seed.dart';

void main() {
  late AppDatabase db;
  late FincasRepository fincasRepo;
  late LotesRepository lotesRepo;
  late PesajesRepository pesajesRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    fincasRepo = FincasRepository(db);
    lotesRepo = LotesRepository(db);
    pesajesRepo = PesajesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'flujo offline local: finca, lote, animal y pesajes pendientes',
    () async {
      const usuarioId = 'user-1';
      await seedCuentaLocal(
        db,
        usuarioId: usuarioId,
        cuentaId: 'account-1',
        email: 'offline@example.com',
        nombre: 'Usuario',
      );

      await fincasRepo.crearFinca(nombre: 'La Esperanza', creadaPor: usuarioId);
      final finca = (await db.select(db.fincas).get()).single;

      await lotesRepo.crearLote(
        fincaId: finca.id,
        nombre: 'Destete',
        numero: 1,
      );
      final lote = (await db.select(db.lotes).get()).single;

      await pesajesRepo.crearAnimalConPesaje(
        fincaId: finca.id,
        loteId: lote.id,
        identificador: 'ARETE-001',
        peso: 180,
        registradoPor: usuarioId,
      );
      final animal = (await db.select(db.animales).get()).single;

      await pesajesRepo.agregarPesaje(
        animalId: animal.id,
        peso: 184.5,
        registradoPor: usuarioId,
      );

      expect((await db.select(db.fincaMiembros).get()).single.rol, 'admin');
      expect((await db.select(db.lotes).get()).single.pendiente, isTrue);
      expect((await db.select(db.animales).get()).single.pendiente, isTrue);
      expect(await db.select(db.pesajes).get(), hasLength(2));
      expect(await pesajesRepo.ultimoPeso(animal.id), 184.5);
      expect((await db.select(db.fincas).get()).single.pendiente, isTrue);
      expect(
        (await db.select(db.pesajes).get()).map((p) => p.pendiente),
        everyElement(isTrue),
      );
    },
  );
}
