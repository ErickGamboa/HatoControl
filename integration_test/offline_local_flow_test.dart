import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('flujo offline local: finca, lote, animal y pesajes pendientes', (
    tester,
  ) async {
    final now = DateTime(2026, 1, 1);
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
            id: 'account-1',
            nombre: 'Cuenta offline',
            duenoId: 'user-1',
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
            id: 'user-1',
            email: const Value('offline@example.com'),
            cuentaId: const Value('account-1'),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await fincasRepo.crearFinca(nombre: 'La Esperanza', creadaPor: 'user-1');
    final finca = (await db.select(db.fincas).get()).single;

    await lotesRepo.crearLote(fincaId: finca.id, nombre: 'Destete', numero: 1);
    final lote = (await db.select(db.lotes).get()).single;

    await pesajesRepo.crearAnimalConPesaje(
      fincaId: finca.id,
      loteId: lote.id,
      identificador: 'ARETE-001',
      peso: 180,
      registradoPor: 'user-1',
    );
    final animal = (await db.select(db.animales).get()).single;

    await pesajesRepo.agregarPesaje(
      animalId: animal.id,
      peso: 184.5,
      registradoPor: 'user-1',
    );

    expect((await db.select(db.fincaMiembros).get()).single.rol, 'admin');
    expect((await db.select(db.lotes).get()).single.pendiente, isTrue);
    expect((await db.select(db.animales).get()).single.pendiente, isTrue);
    expect(await db.select(db.pesajes).get(), hasLength(2));
    expect(await pesajesRepo.ultimoPeso(animal.id), 184.5);

    // Todos los datos creados localmente quedan marcados para subirlos cuando
    // SyncService tenga conexión.
    expect((await db.select(db.fincas).get()).single.pendiente, isTrue);
    expect(
      (await db.select(db.pesajes).get()).map((p) => p.pendiente),
      everyElement(isTrue),
    );
  });
}
