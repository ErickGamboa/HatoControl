import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/repositories/medicamentos_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';
import 'package:hato_control/demo/demo_seed.dart';
import 'package:hato_control/demo/demo_seed_ids.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('seedIfAbsent creates demo finca with modules 1-4 data', () async {
    const uid = DemoSeedIds.userId;
    final seed = DemoSeed(
      database: db,
      fincas: FincasRepository(db),
      lotes: LotesRepository(db),
      pesajes: PesajesRepository(db),
      dietas: DietasRepository(db),
      sanidad: SanidadRepository(db),
      ventas: VentasRepository(db),
      medicamentos: MedicamentosRepository(db),
    );

    final snap = await seed.seedIfAbsent(usuarioId: uid);
    expect(snap.fincaNombre, DemoSeedIds.fincaNombre);

    expect(await db.select(db.dietas).get(), hasLength(2));
    expect(await db.select(db.animales).get(), hasLength(4));
    expect(await db.select(db.pesajes).get(), hasLength(greaterThan(4)));
    expect(
      await db.select(db.eventosSanitarios).get(),
      hasLength(greaterThan(2)),
    );
    expect(await db.select(db.ventas).get(), hasLength(1));

    final vendido =
        await (db.select(db.animales)
              ..where((t) => t.identificador.equals(DemoSeedIds.animalVendido)))
            .getSingle();
    expect(vendido.estado, 'vendido');

    // Idempotent second call
    final snap2 = await seed.seedIfAbsent(usuarioId: uid);
    expect(snap2.fincaId, snap.fincaId);
    expect(await db.select(db.fincas).get(), hasLength(1));
  });
}
