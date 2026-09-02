import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/cuentas_repository.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sesion_local_repository.dart';

import '../support/local_db_seed.dart';

void main() {
  late AppDatabase db;
  late SesionLocalRepository sesionRepo;
  late CuentasRepository cuentasRepo;
  late FincasRepository fincasRepo;
  late LotesRepository lotesRepo;
  late PesajesRepository pesajesRepo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    sesionRepo = SesionLocalRepository(db);
    cuentasRepo = CuentasRepository(db);
    fincasRepo = FincasRepository(db);
    lotesRepo = LotesRepository(db);
    pesajesRepo = PesajesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'cached offline login usa el usuario verificado para datos locales',
    () async {
      const usuarioId = 'user-offline-1';
      final now = DateTime(2026, 1, 1);

      await seedCuentaLocal(db, usuarioId: usuarioId, now: now);
      await sesionRepo.guardarUsuarioVerificado(
        usuarioId: usuarioId,
        email: 'offline@example.com',
        nombre: 'Usuario Offline',
      );
      await sesionRepo.activarOffline();

      final sesion = await sesionRepo.obtener();
      expect(sesion, isNotNull);
      expect(sesion!.offlineActiva, isTrue);

      final cuenta = await cuentasRepo.observarMiCuenta(usuarioId).first;
      expect(cuenta, isNotNull);
      expect(cuenta!.estado, 'activa');

      await fincasRepo.crearFinca(
        nombre: 'La Esperanza Offline',
        creadaPor: sesion.usuarioId,
      );
      final finca = (await fincasRepo.observarFincas(usuarioId).first).single;
      expect(finca.nombre, 'La Esperanza Offline');
      expect(finca.pendiente, isTrue);

      await lotesRepo.crearLote(
        fincaId: finca.id,
        nombre: 'Destete Offline',
        numero: 1,
      );
      final lote = (await db.select(db.lotes).get()).single;

      await pesajesRepo.crearAnimalConPesaje(
        fincaId: finca.id,
        loteId: lote.id,
        identificador: 'OFF-001',
        peso: 180,
        registradoPor: sesion.usuarioId,
      );

      final pesaje = (await db.select(db.pesajes).get()).single;
      expect(pesaje.registradoPor, usuarioId);
      expect(pesaje.pendiente, isTrue);

      await sesionRepo.borrar();
      expect(await sesionRepo.obtener(), isNull);
    },
  );
}
