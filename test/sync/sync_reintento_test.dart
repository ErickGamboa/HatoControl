import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

/// El bug que estos tests cuidan: al volver del campo con muchos registros,
/// la sincronización subía un pedazo y se cortaba, y había que apretar el
/// botón una y otra vez hasta que subiera todo. Ahora una sola llamada a
/// `sincronizar()` tiene que dejar la cola vacía.
void main() {
  late AppDatabase db;
  late FakeSyncRemoteGateway remote;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    remote = FakeSyncRemoteGateway();
    // Sin esperas: la lógica de reintento es la misma, pero el test no duerme.
    sync = SyncService(db, remote: remote, esperasReintento: const []);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedAnimales(int cuantos) async {
    final now = DateTime(2026, 1, 1);
    for (var i = 0; i < cuantos; i++) {
      await db
          .into(db.animales)
          .insert(
            AnimalesCompanion.insert(
              id: 'animal-$i',
              fincaId: 'finca-1',
              loteId: 'lote-1',
              identificador: 'A-${i.toString().padLeft(3, '0')}',
              createdAt: now,
              updatedAt: now,
              pendiente: const Value(true),
            ),
          );
    }
  }

  Future<int> pendientesDeAnimales() async {
    final filas = await (db.select(
      db.animales,
    )..where((t) => t.pendiente.equals(true))).get();
    return filas.length;
  }

  test('una sola sincronización sube una tanda grande completa', () async {
    await seedAnimales(120);

    await sync.sincronizar();

    expect(await pendientesDeAnimales(), 0);
    expect(remote.subidas.where((s) => s.tabla == 'animales').length, 120);
  });

  test('las filas que fallan por un corte de red suben en la misma '
      'sincronización, sin volver a apretar el botón', () async {
    await seedAnimales(10);
    // La red se corta en tres filas del medio: fallan una vez y en el
    // reintento pasan.
    remote.fallarSubidasUnaVez.addAll([
      'animales:animal-3',
      'animales:animal-4',
      'animales:animal-7',
    ]);

    await sync.sincronizar();

    expect(await pendientesDeAnimales(), 0);
    expect(remote.intentosPorFila['animales:animal-3'], 2);
    expect(remote.intentosPorFila['animales:animal-7'], 2);
    // Las que ya subieron no se reenvían en la segunda vuelta.
    expect(remote.intentosPorFila['animales:animal-0'], 1);
  });

  test('reporta el avance para que la pantalla pueda mostrarlo', () async {
    await seedAnimales(5);
    final vistos = <String>[];
    void anotar() {
      final p = sync.progreso.value;
      vistos.add('${p.hechas}/${p.total}');
    }

    sync.progreso.addListener(anotar);
    await sync.sincronizar();
    sync.progreso.removeListener(anotar);

    expect(vistos, contains('0/5'));
    expect(vistos, contains('5/5'));
    // Al terminar queda inactivo, así la UI no deja un contador pegado.
    expect(sync.progreso.value.activo, isFalse);
  });

  test('una fila que falla siempre no deja el sync dando vueltas', () async {
    await seedAnimales(3);
    remote.fallarSubidas.add('animales:animal-1');

    await sync.sincronizar();

    // Las buenas subieron; la mala queda pendiente para el próximo intento.
    expect(await pendientesDeAnimales(), 1);
    final pendiente = await (db.select(
      db.animales,
    )..where((t) => t.pendiente.equals(true))).getSingle();
    expect(pendiente.id, 'animal-1');
  });

  test('hayPendientes dice si todavía queda algo por subir', () async {
    expect(await sync.hayPendientes(), isFalse);
    await seedAnimales(1);
    expect(await sync.hayPendientes(), isTrue);
    await sync.sincronizar();
    expect(await sync.hayPendientes(), isFalse);
  });
}
