import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

/// Cubre el motor genérico (`TableSyncSpec`/`_subirTabla`/`_bajarTabla`) en
/// tablas con formas distintas de spec: solo bajada sin guard (`planes`),
/// solo bajada con guard (`cuentas`), y el registro de estado en
/// `sync_estado` (D-13). El caso push+pull con guard ya está cubierto en
/// `sync_service_pending_guard_test.dart` (tabla `animales`).
void main() {
  late AppDatabase db;
  late FakeSyncRemoteGateway remote;
  late SyncService sync;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    remote = FakeSyncRemoteGateway();
    sync = SyncService(db, remote: remote);
  });

  tearDown(() async {
    await db.close();
  });

  Map<String, dynamic> planRemoto({
    String codigo = 'pro',
    DateTime? updatedAt,
  }) => {
    'codigo': codigo,
    'nombre': 'Pro',
    'limite_fincas': 5,
    'updated_at': (updatedAt ?? DateTime(2026, 1, 1)).toIso8601String(),
  };

  Map<String, dynamic> cuentaRemota({
    String id = 'cuenta-1',
    DateTime? updatedAt,
  }) => {
    'id': id,
    'nombre': 'Finca del Valle',
    'dueno_id': 'user-1',
    'plan': 'light',
    'estado': 'activa',
    'prueba_termina': null,
    'created_at': DateTime(2026, 1, 1).toIso8601String(),
    'updated_at': (updatedAt ?? DateTime(2026, 1, 2)).toIso8601String(),
    'deleted_at': null,
  };

  test('baja una tabla sin guard (planes) y avanza su cursor', () async {
    remote.descargas['planes'] = [planRemoto()];

    await sync.sincronizar();

    final plan = await (db.select(
      db.planes,
    )..where((t) => t.codigo.equals('pro'))).getSingle();
    expect(plan.nombre, 'Pro');

    final cursor = await (db.select(
      db.syncCursores,
    )..where((t) => t.tabla.equals('planes'))).getSingle();
    expect(cursor.ultimaBajada, DateTime(2026, 1, 1));
    expect(cursor.ultimaBajadaId, 'pro');
  });

  test(
    'baja una tabla de solo lectura con guard (cuentas) respetando cambios locales',
    () async {
      await db
          .into(db.cuentas)
          .insert(
            CuentaRow(
              id: 'cuenta-1',
              nombre: 'Nombre local sin subir',
              duenoId: 'user-1',
              plan: 'light',
              estado: 'activa',
              createdAt: DateTime(2026, 1, 1),
              updatedAt: DateTime(2026, 1, 1),
              pendiente: true,
            ),
          );
      remote.descargas['cuentas'] = [cuentaRemota(updatedAt: DateTime(2026, 1, 3))];

      await sync.sincronizar();

      final cuenta = await (db.select(
        db.cuentas,
      )..where((t) => t.id.equals('cuenta-1'))).getSingle();
      expect(cuenta.nombre, 'Nombre local sin subir');

      final cursor = await (db.select(
        db.syncCursores,
      )..where((t) => t.tabla.equals('cuentas'))).getSingleOrNull();
      expect(cursor, isNull);
    },
  );

  test(
    'el cursor compuesto no salta una fila con el mismo updated_at que el borde',
    () async {
      final mismoInstante = DateTime(2026, 1, 5);
      remote.descargas['planes'] = [
        planRemoto(codigo: 'light', updatedAt: mismoInstante),
        planRemoto(codigo: 'medium', updatedAt: mismoInstante),
      ];

      await sync.sincronizar();
      // Segunda pasada: sin filas nuevas, pero si el cursor solo guardara el
      // timestamp (sin el id) y el filtro remoto usara `gt` estricto, esto
      // seguiría devolviendo ambas filas cada vez sin avanzar nunca del
      // todo. Confirmamos que las dos entraron y que una segunda sync no
      // duplica ni pierde nada.
      await sync.sincronizar();

      final planes = await db.select(db.planes).get();
      expect(planes.map((p) => p.codigo), containsAll(['light', 'medium']));

      final cursor = await (db.select(
        db.syncCursores,
      )..where((t) => t.tabla.equals('planes'))).getSingle();
      expect(cursor.ultimaBajada, mismoInstante);
      expect(cursor.ultimaBajadaId, 'medium'); // último en orden (updated_at, id)
    },
  );

  test('registra el error en sync_estado cuando falla una bajada', () async {
    remote.fallarConsultas.add('planes');

    await sync.sincronizar();

    final estado = await (db.select(
      db.syncEstados,
    )..where((t) => t.tabla.equals('planes'))).getSingle();
    expect(estado.ultimoError, isNotNull);
    expect(estado.ultimaSincronizacionOk, isNull);
  });

  test(
    'un éxito posterior limpia el error sin perder la última sincronización ok',
    () async {
      remote.fallarConsultas.add('planes');
      await sync.sincronizar();
      var estado = await (db.select(
        db.syncEstados,
      )..where((t) => t.tabla.equals('planes'))).getSingle();
      expect(estado.ultimoError, isNotNull);

      remote.fallarConsultas.remove('planes');
      await sync.sincronizar();

      estado = await (db.select(
        db.syncEstados,
      )..where((t) => t.tabla.equals('planes'))).getSingle();
      expect(estado.ultimoError, isNull);
      expect(estado.ultimoErrorEn, isNull);
      expect(estado.ultimaSincronizacionOk, isNotNull);
    },
  );

  test('pendientesPorTabla cuenta solo filas pendiente=true', () async {
    await db
        .into(db.lotes)
        .insert(
          LoteRow(
            id: 'lote-1',
            fincaId: 'finca-1',
            nombre: 'Potrero 1',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            pendiente: true,
          ),
        );
    await db
        .into(db.lotes)
        .insert(
          LoteRow(
            id: 'lote-2',
            fincaId: 'finca-1',
            nombre: 'Potrero 2',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            pendiente: false,
          ),
        );

    final pendientes = await sync.pendientesPorTabla();

    expect(pendientes['lotes'], 1);
    expect(pendientes.containsKey('planes'), isFalse); // sin subida
  });
}
