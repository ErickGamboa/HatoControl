import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/cuentas_repository.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sesion_local_repository.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets(
    'cached offline login usa el usuario verificado para datos locales',
    (tester) async {
      const usuarioId = 'user-offline-1';
      final now = DateTime(2026, 1, 1);

      await _seedCuenta(db, usuarioId: usuarioId, now: now);
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

Future<void> _seedCuenta(
  AppDatabase db, {
  required String usuarioId,
  required DateTime now,
}) async {
  await db
      .into(db.planes)
      .insert(
        PlanesCompanion.insert(
          codigo: 'pro',
          nombre: 'Pro',
          limiteFincas: 20,
          updatedAt: now,
        ),
      );
  await db
      .into(db.cuentas)
      .insert(
        CuentasCompanion.insert(
          id: 'account-offline-1',
          nombre: 'Cuenta offline',
          duenoId: usuarioId,
          plan: 'pro',
          estado: 'activa',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await db
      .into(db.usuarios)
      .insert(
        UsuariosCompanion.insert(
          id: usuarioId,
          nombre: const Value('Usuario Offline'),
          email: const Value('offline@example.com'),
          cuentaId: const Value('account-offline-1'),
          createdAt: now,
          updatedAt: now,
        ),
      );
}
