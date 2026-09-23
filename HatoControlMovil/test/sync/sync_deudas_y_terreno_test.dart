import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/deudas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';
import 'package:hato_control/data/sync/sync_service.dart';

import '../support/fake_sync_remote_gateway.dart';

/// Lo nuevo (deudas, abonos y el terreno del lote) tiene que ir y venir del
/// servidor como cualquier otro dato de la app: si solo subiera, el ganadero
/// cambiaría de teléfono y no encontraría sus deudas; si solo bajara, lo que
/// anota en el campo no saldría de ese aparato.
///
/// Este test hace el viaje completo contra el servidor falso: primero baja
/// filas del servidor y revisa que queden bien guardadas, y después crea filas
/// locales y revisa qué se manda exactamente.
void main() {
  late AppDatabase db;
  late FakeSyncRemoteGateway remote;
  late SyncService sync;
  late DeudasRepository deudas;
  late LotesRepository lotes;

  final ahora = DateTime(2026, 9, 22, 10);

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    remote = FakeSyncRemoteGateway();
    sync = SyncService(db, remote: remote, esperasReintento: const []);
    deudas = DeudasRepository(db);
    lotes = LotesRepository(db);
  });

  tearDown(() async => db.close());

  Future<void> sembrarFincaLocal() {
    return db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca',
            creadaPor: 'u1',
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(false),
          ),
        );
  }

  group('bajar del servidor', () {
    test('una deuda con sus abonos queda igualita en el aparato', () async {
      remote.descargas
        ..['deudas'] = [
          {
            'id': 'deuda-1',
            'finca_id': 'f1',
            'acreedor': 'Cooperativa',
            'monto': 450000,
            'fecha': DateTime(2026, 9, 1).toIso8601String(),
            'vence': DateTime(2026, 10, 15).toIso8601String(),
            'estado': 'pendiente',
            'nota': 'Alimento de agosto',
            'moneda': 'CRC',
            'created_at': DateTime(2026, 9, 1).toIso8601String(),
            'updated_at': DateTime(2026, 9, 1).toIso8601String(),
            'deleted_at': null,
          },
        ]
        ..['deuda_abonos'] = [
          {
            'id': 'abono-1',
            'deuda_id': 'deuda-1',
            'monto': 200000,
            'fecha': DateTime(2026, 9, 10).toIso8601String(),
            'nota': null,
            'created_at': DateTime(2026, 9, 10).toIso8601String(),
            'updated_at': DateTime(2026, 9, 10).toIso8601String(),
            'deleted_at': null,
          },
        ];

      await sync.sincronizar();

      final enElAparato = (await deudas.deudasDe('f1')).single;
      expect(enElAparato.deuda.acreedor, 'Cooperativa');
      expect(enElAparato.deuda.monto, 450000);
      expect(enElAparato.deuda.fecha, DateTime(2026, 9, 1));
      expect(enElAparato.deuda.vence, DateTime(2026, 10, 15));
      expect(enElAparato.deuda.estado, EstadoDeuda.pendiente);
      expect(enElAparato.deuda.nota, 'Alimento de agosto');
      expect(enElAparato.abonado, 200000, reason: 'el abono también bajó');
      expect(enElAparato.saldo, 250000);
      expect(
        enElAparato.deuda.pendiente,
        isFalse,
        reason: 'lo que viene del servidor no está pendiente de subir',
      );
    });

    test('lo que el servidor manda vacío queda vacío acá', () async {
      remote.descargas['deudas'] = [
        {
          'id': 'deuda-1',
          'finca_id': 'f1',
          'acreedor': 'Veterinario',
          'monto': 80000,
          'fecha': DateTime(2026, 9, 1).toIso8601String(),
          'vence': null,
          'estado': 'pagada',
          'nota': null,
          'moneda': 'CRC',
          'created_at': DateTime(2026, 9, 1).toIso8601String(),
          'updated_at': DateTime(2026, 9, 1).toIso8601String(),
          'deleted_at': null,
        },
      ];

      await sync.sincronizar();

      final fila = (await deudas.deudasDe('f1')).single.deuda;
      expect(fila.vence, isNull);
      expect(fila.nota, isNull);
      expect(fila.estado, EstadoDeuda.pagada);
    });

    test('una deuda borrada en la nube desaparece de la lista', () async {
      remote.descargas['deudas'] = [
        {
          'id': 'deuda-1',
          'finca_id': 'f1',
          'acreedor': 'Cooperativa',
          'monto': 450000,
          'fecha': DateTime(2026, 9, 1).toIso8601String(),
          'vence': null,
          'estado': 'pendiente',
          'nota': null,
          'moneda': 'CRC',
          'created_at': DateTime(2026, 9, 1).toIso8601String(),
          'updated_at': DateTime(2026, 9, 2).toIso8601String(),
          'deleted_at': DateTime(2026, 9, 2).toIso8601String(),
        },
      ];

      await sync.sincronizar();

      expect(await deudas.deudasDe('f1'), isEmpty);
    });

    test('el terreno del lote baja con su unidad', () async {
      remote.descargas['lotes'] = [
        {
          'id': 'l1',
          'finca_id': 'f1',
          'nombre': 'Engorde',
          'numero': 1,
          'area_m2': 20000,
          'area_unidad': 'ha',
          'created_at': DateTime(2026, 9, 1).toIso8601String(),
          'updated_at': DateTime(2026, 9, 1).toIso8601String(),
          'deleted_at': null,
        },
      ];

      await sync.sincronizar();

      final lote = (await lotes.lotesActivos('f1')).single;
      expect(lote.areaM2, 20000);
      expect(lote.areaUnidad, UnidadArea.hectarea);
      expect(UnidadArea.formatear(lote.areaM2!, lote.areaUnidad!), '2 hectáreas');
    });

    test('un lote viejo, sin terreno en la nube, no se inventa uno', () async {
      remote.descargas['lotes'] = [
        {
          'id': 'l1',
          'finca_id': 'f1',
          'nombre': 'Engorde',
          'numero': null,
          'area_m2': null,
          'area_unidad': null,
          'created_at': DateTime(2026, 9, 1).toIso8601String(),
          'updated_at': DateTime(2026, 9, 1).toIso8601String(),
          'deleted_at': null,
        },
      ];

      await sync.sincronizar();

      final lote = (await lotes.lotesActivos('f1')).single;
      expect(lote.areaM2, isNull);
      expect(lote.areaUnidad, isNull);
    });
  });

  group('subir al servidor', () {
    test('la deuda y su abono se suben y dejan de estar pendientes', () async {
      await sembrarFincaLocal();
      final id = await deudas.crearDeuda(
        fincaId: 'f1',
        acreedor: 'Cooperativa',
        monto: 450000,
        fecha: DateTime(2026, 9, 1),
        vence: DateTime(2026, 10, 15),
        nota: 'Alimento de agosto',
      );
      await deudas.registrarAbono(
        deudaId: id,
        monto: 200000,
        fecha: DateTime(2026, 9, 10),
      );

      await sync.sincronizar();

      final deudaSubida = remote.subidas
          .firstWhere((s) => s.tabla == 'deudas')
          .datos;
      expect(deudaSubida['finca_id'], 'f1');
      expect(deudaSubida['acreedor'], 'Cooperativa');
      expect(deudaSubida['monto'], 450000);
      expect(deudaSubida['estado'], EstadoDeuda.pendiente);
      expect(deudaSubida['nota'], 'Alimento de agosto');
      expect(deudaSubida['vence'], DateTime(2026, 10, 15).toIso8601String());
      expect(
        deudaSubida.containsKey('updated_at'),
        isFalse,
        reason: 'el updated_at lo pone el servidor, como en las demás tablas',
      );

      final abonoSubido = remote.subidas
          .firstWhere((s) => s.tabla == 'deuda_abonos')
          .datos;
      expect(abonoSubido['deuda_id'], id);
      expect(abonoSubido['monto'], 200000);

      // Y no quedan marcadas para reintentar.
      expect(await sync.contarPendientes(), 0);
      expect((await deudas.deudasDe('f1')).single.deuda.pendiente, isFalse);
    });

    test('marcar pagada y anular también viajan', () async {
      await sembrarFincaLocal();
      final id = await deudas.crearDeuda(
        fincaId: 'f1',
        acreedor: 'Banco',
        monto: 100000,
        fecha: DateTime(2026, 9, 1),
      );
      await sync.sincronizar();
      remote.subidas.clear();

      await deudas.marcarPagada(id, fecha: DateTime(2026, 9, 20));
      await sync.sincronizar();

      final estados = remote.subidas
          .where((s) => s.tabla == 'deudas')
          .map((s) => s.datos['estado'])
          .toList();
      expect(estados, contains(EstadoDeuda.pagada));
      expect(
        remote.subidas.where((s) => s.tabla == 'deuda_abonos'),
        isNotEmpty,
        reason: 'marcar pagada registra el abono del saldo, y ese también sube',
      );
      expect(await sync.contarPendientes(), 0);
    });

    test('el terreno del lote se sube en m² con su unidad', () async {
      await sembrarFincaLocal();
      await lotes.crearLote(
        fincaId: 'f1',
        nombre: 'Potrero',
        area: 1,
        areaUnidad: UnidadArea.manzana,
      );

      await sync.sincronizar();

      final subido = remote.subidas.firstWhere((s) => s.tabla == 'lotes').datos;
      expect(subido['nombre'], 'Potrero');
      expect(subido['area_m2'], closeTo(6988.96, 0.001));
      expect(subido['area_unidad'], UnidadArea.manzana);
      expect(await sync.contarPendientes(), 0);
    });
  });
}
