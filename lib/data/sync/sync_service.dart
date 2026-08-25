import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/database.dart';
import 'sync_remote_gateway.dart';

/// Cómo subir las filas `pendiente=true` de una tabla: qué mandar y cómo
/// marcarlas subidas al terminar. `pendientes()` devuelve pares (id, datos)
/// para no acoplar el motor genérico al tipo de fila de cada tabla.
class PushSpec {
  const PushSpec({required this.pendientes, required this.marcarSubida});

  final Future<List<(String id, Map<String, dynamic> datos)>> Function()
  pendientes;
  final Future<void> Function(String id) marcarSubida;
}

/// Cómo aplicar una fila bajada del servidor, y (si la tabla tiene
/// `pendiente`) cómo saber si la fila local tiene cambios sin subir que no
/// hay que pisar. `tieneCambioLocalPendiente` es null para tablas sin guard
/// (sin columna `pendiente`, como `planes` y `feature_flags`).
///
/// `idDe` extrae el identificador de la fila remota para el guard y el
/// cursor compuesto — por defecto `r['id']`, salvo `planes` cuya llave
/// natural es `codigo` (no tiene columna `id`).
class PullSpec {
  const PullSpec({
    required this.aplicar,
    this.tieneCambioLocalPendiente,
    this.idDe = _idPorDefecto,
    this.idColumnaRemota = 'id',
  });

  final Future<void> Function(Map<String, dynamic> fila) aplicar;
  final Future<bool> Function(String id)? tieneCambioLocalPendiente;
  final String Function(Map<String, dynamic> fila) idDe;

  /// Nombre de la columna remota que identifica la fila, para el filtro y
  /// orden del cursor compuesto (ver [SyncRemoteGateway.consultar]). Debe
  /// coincidir con lo que [idDe] lee del mapa remoto.
  final String idColumnaRemota;

  static String _idPorDefecto(Map<String, dynamic> fila) =>
      fila['id'] as String;
}

/// Todo lo que el motor de sync necesita saber de una tabla. `subida` es
/// null para tablas de solo lectura (`planes`, `cuentas`, `usuarios`,
/// `feature_flags`): el motor genérico (`_subirTabla`/`_bajarTabla`) hace el
/// resto igual para todas.
class TableSyncSpec {
  const TableSyncSpec({required this.tabla, this.subida, required this.bajada});

  final String tabla;
  final PushSpec? subida;
  final PullSpec bajada;
}

/// Avance de la subida en curso, para que la pantalla pueda decir
/// "subiendo 34 de 210" en vez de mostrar una ruedita sin fin. El usuario
/// que ve que avanza no siente la necesidad de apretar el botón otra vez.
class SyncProgreso {
  const SyncProgreso({required this.hechas, required this.total});

  static const inactivo = SyncProgreso(hechas: 0, total: 0);

  final int hechas;
  final int total;

  bool get activo => total > 0;
}

/// Cuánto se movió una vuelta de subida: filas que lograron subir y filas
/// que quedaron pendientes. Es lo que decide si vale la pena insistir: si
/// algo subió, la red está viva y seguimos de una; si no subió nada, hay que
/// esperar antes de reintentar.
class ResultadoSubida {
  const ResultadoSubida({required this.subidas, required this.pendientes});

  static const nada = ResultadoSubida(subidas: 0, pendientes: 0);

  final int subidas;
  final int pendientes;
}

/// Motor de sincronización entre la base local (Drift/SQLite) y Supabase.
///
/// Estrategia:
///  - SUBIR: envía al servidor las filas marcadas como `pendiente` (upsert) y
///    luego las marca como sincronizadas.
///  - BAJAR: trae del servidor las filas con `(updated_at, id)` mayor al
///    último marcador guardado ([SyncCursor]), y las guarda localmente.
///    Avanza el marcador.
///  - Conflictos: "gana el último que escribe" (el servidor fija `updated_at`).
///  - Borrados: viajan como `deleted_at` (borrado suave).
///
/// Cada tabla es un [TableSyncSpec] en [_specs]; `_subirTabla`/`_bajarTabla`
/// son el único código de orquestación (antes había un par de métodos casi
/// idénticos por tabla — ver docs/ARCHITECTURE_REVIEW.md #2).
class SyncService {
  SyncService(
    this.db, {
    SyncRemoteGateway? remote,
    List<Duration>? esperasReintento,
  }) : _remote = remote ?? SupabaseSyncRemoteGateway(),
       _esperasReintento = esperasReintento ?? esperasReintentoPorDefecto;

  final AppDatabase db;
  final SyncRemoteGateway _remote;

  /// Cuánto esperar antes de cada reintento, cuando una vuelta de subida no
  /// logró subir ni una fila. Se agotan y el resto queda pendiente para el
  /// próximo intento: si la red está caída de verdad, insistir para siempre
  /// solo gasta batería. Los tests las ponen en `[]` para no dormir.
  static const esperasReintentoPorDefecto = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 15),
  ];

  final List<Duration> _esperasReintento;

  /// Para que la UI pueda mostrar un indicador de "sincronizando…".
  final ValueNotifier<bool> sincronizando = ValueNotifier(false);

  /// Avance de la subida en curso (ver [SyncProgreso]).
  final ValueNotifier<SyncProgreso> progreso = ValueNotifier(
    SyncProgreso.inactivo,
  );

  bool _enCurso = false;
  bool _pedidoDeNuevo = false;

  Future<void> sincronizar() async {
    if (!_remote.tieneUsuario) return; // sin sesión, nada que hacer
    if (_enCurso) {
      // No descartamos el pedido: al terminar la vuelta actual damos otra,
      // así lo que se guardó mientras subíamos también sale. Antes esto era
      // un `return` seco y el botón no hacía nada durante la subida.
      _pedidoDeNuevo = true;
      return;
    }
    _enCurso = true;
    sincronizando.value = true;
    try {
      do {
        _pedidoDeNuevo = false;
        await _ejecutarSync();
      } while (_pedidoDeNuevo);
    } catch (e) {
      // Si no hay internet o falla la red, reintentaremos en la próxima.
      debugPrint('Sync: no se pudo completar ($e)');
    } finally {
      _enCurso = false;
      sincronizando.value = false;
      progreso.value = SyncProgreso.inactivo;
    }
  }

  /// Una sincronización completa: SUBIR todo lo pendiente —insistiendo hasta
  /// que no quede nada— y después BAJAR los cambios del servidor.
  ///
  /// La subida NO tiene tiempo límite global. Antes había uno de 20 s para
  /// TODA la sincronización, y con muchos registros (un día entero de campo)
  /// se cortaba a la mitad y dejaba el resto pendiente: el usuario tenía que
  /// apretar el botón una y otra vez, subiendo un pedazo cada vez. El límite
  /// ahora es por petición, dentro del gateway: una conexión colgada se corta
  /// sola, pero una conexión lenta pero viva termina el trabajo.
  Future<void> _ejecutarSync() async {
    var vueltasSinProgreso = 0;
    while (true) {
      final resultado = await _subirFilasPendientes();
      if (resultado.pendientes == 0) break; // subió todo
      if (resultado.subidas > 0) {
        // Hubo avance, la red responde: seguimos de una, sin esperar.
        vueltasSinProgreso = 0;
        continue;
      }
      // Ni una fila pasó: probablemente la red se cayó otra vez. Esperamos y
      // reintentamos; si no hay caso, lo dejamos pendiente para la próxima
      // (no se pierde nada, sigue marcado `pendiente`).
      if (vueltasSinProgreso >= _esperasReintento.length) break;
      await Future.delayed(_esperasReintento[vueltasSinProgreso]);
      vueltasSinProgreso++;
    }

    // Las fotos van después de la membresía (la RLS de update exige ser
    // admin), y con un solo intento por sincronización: son una llamada a la
    // Edge Function, no el grueso del trabajo.
    await _paso(_subirFotosFincas);

    // Bajar al final, en el orden de _specs (planes/cuentas antes que fincas,
    // que las necesita). Cada paso va aislado: si uno falla, los demás igual
    // se ejecutan.
    for (final spec in _specs) {
      await _paso(() => _bajarTabla(spec));
    }
  }

  /// Ejecuta un paso del sync de forma aislada: si lanza una excepción, la
  /// registra y sigue con los demás pasos (no aborta toda la sincronización).
  Future<void> _paso(Future<void> Function() accion) async {
    try {
      await accion();
    } catch (e) {
      debugPrint('Sync: un paso falló y se omite ($e)');
    }
  }

  // ------------------------------------------------------------- MOTOR

  /// Una vuelta de subida: recorre todas las tablas que suben algo, en orden
  /// de dependencia (los lotes antes que los animales), y devuelve cuánto
  /// subió y cuánto quedó pendiente.
  Future<ResultadoSubida> _subirFilasPendientes() async {
    // Juntamos primero todo lo que hay que subir, para poder mostrar
    // "subiendo 12 de 210" mientras avanza.
    final porTabla = <String, List<(String, Map<String, dynamic>)>>{};
    for (final spec in _specs) {
      final subida = spec.subida;
      if (subida == null) continue;
      await _paso(() async {
        porTabla[spec.tabla] = await subida.pendientes();
      });
    }
    final total = porTabla.values.fold<int>(0, (n, filas) => n + filas.length);
    if (total == 0) {
      progreso.value = SyncProgreso.inactivo;
      return ResultadoSubida.nada;
    }

    var subidas = 0;
    var pendientes = 0;
    var hechas = 0;
    progreso.value = SyncProgreso(hechas: 0, total: total);

    for (final spec in _specs) {
      final filas = porTabla[spec.tabla];
      final subida = spec.subida;
      if (subida == null || filas == null || filas.isEmpty) continue;
      // Resiliencia POR FILA: si una falla (conflicto, red, RLS, etc.) se
      // registra y se sigue con las demás — nunca bloquea ni descarta al
      // resto. Cada fila se marca subida solo si tuvo éxito; si falla, queda
      // `pendiente` y se reintenta en la vuelta siguiente.
      for (final (id, datos) in filas) {
        try {
          await _remote.insertarOActualizar(spec.tabla, id, datos);
          await subida.marcarSubida(id);
          subidas++;
        } catch (e) {
          pendientes++;
          debugPrint(
            'Sync: no se pudo subir ${spec.tabla} $id; queda pendiente '
            'para reintentar ($e)',
          );
        }
        hechas++;
        progreso.value = SyncProgreso(hechas: hechas, total: total);
      }
    }
    return ResultadoSubida(subidas: subidas, pendientes: pendientes);
  }

  Future<void> _bajarTabla(TableSyncSpec spec) async {
    var cursorNuevo = SyncCursor.vacio;
    var retuvoCambioLocal = false;
    try {
      final cursorActual = await _leerCursor(spec.tabla);
      cursorNuevo = cursorActual;
      final filas = await _consultar(
        spec.tabla,
        cursorActual,
        idColumna: spec.bajada.idColumnaRemota,
      );
      for (final r in filas) {
        final id = spec.bajada.idDe(r);
        final guard = spec.bajada.tieneCambioLocalPendiente;
        // Las descargas nunca deben pisar cambios locales sin subir: si una
        // subida falló y luego baja una versión vieja del servidor, se
        // perdería el cambio local.
        if (guard != null && await guard(id)) {
          retuvoCambioLocal = true;
          continue;
        }
        await spec.bajada.aplicar(r);
        cursorNuevo = SyncCursor(
          updatedAt: DateTime.parse(r['updated_at'] as String),
          id: id,
        );
      }
      if (!retuvoCambioLocal && !cursorNuevo.esVacio) {
        await _guardarCursor(spec.tabla, cursorNuevo);
      }
      await _registrarExito(spec.tabla);
    } catch (e) {
      await _registrarError(spec.tabla, e);
      rethrow; // _paso() lo registra y sigue con la próxima tabla.
    }
  }

  TableSyncSpec? _specPara(String tabla) {
    for (final spec in _specs) {
      if (spec.tabla == tabla) return spec;
    }
    return null;
  }

  /// Indica si una fila local todavía tiene cambios sin subir. Expuesto para
  /// tests; delega en el guard del spec de esa tabla (null = sin guard).
  @visibleForTesting
  Future<bool> tieneCambiosLocalesPendientes(String tabla, String id) async {
    final guard = _specPara(tabla)?.bajada.tieneCambioLocalPendiente;
    if (guard == null) return false;
    return guard(id);
  }

  /// Nombres de las tablas registradas en el sync, en orden de dependencia.
  /// Expuesto para que un test verifique el invariante de
  /// `docs/CORRECCIONES.md`: ningún módulo queda afuera del sync.
  @visibleForTesting
  List<String> get tablasRegistradas => [for (final s in _specs) s.tabla];

  /// Estado de sync por tabla (D-13): para una pantalla de "sincronizando…"
  /// con detalle, o para soporte/debug.
  Future<List<SyncEstadoRow>> estadoPorTabla() =>
      db.select(db.syncEstados).get();

  /// Si queda algo sin subir. Barato: corta en la primera tabla con
  /// pendientes en vez de contarlas todas. Lo usa el reintento automático
  /// para no tocar la red cuando no hay nada que mandar.
  Future<bool> hayPendientes() async {
    for (final spec in _specs) {
      final subida = spec.subida;
      if (subida == null) continue;
      if ((await subida.pendientes()).isNotEmpty) return true;
    }
    return false;
  }

  /// Cantidad de filas `pendiente=true` por tabla (solo las que suben algo).
  Future<Map<String, int>> pendientesPorTabla() async {
    final resultado = <String, int>{};
    for (final spec in _specs) {
      final subida = spec.subida;
      if (subida == null) continue;
      resultado[spec.tabla] = (await subida.pendientes()).length;
    }
    return resultado;
  }

  Future<void> _registrarExito(String tabla) async {
    await db
        .into(db.syncEstados)
        .insertOnConflictUpdate(
          SyncEstadosCompanion.insert(
            tabla: tabla,
            ultimaSincronizacionOk: Value(DateTime.now()),
            ultimoError: const Value(null),
            ultimoErrorEn: const Value(null),
          ),
        );
  }

  Future<void> _registrarError(String tabla, Object error) async {
    await db
        .into(db.syncEstados)
        .insertOnConflictUpdate(
          SyncEstadosCompanion.insert(
            tabla: tabla,
            ultimoError: Value(error.toString()),
            ultimoErrorEn: Value(DateTime.now()),
          ),
        );
  }

  // ------------------------------------------------------------ FOTOS

  /// Sube las fotos de fincas marcadas `fotoPendiente` a través de la Edge
  /// Function `subir-foto-finca` (que valida al usuario y escribe con permisos
  /// de servidor), guarda la URL pública devuelta y limpia la bandera.
  Future<void> _subirFotosFincas() async {
    if (!_remote.tieneSesion) return;
    if (kIsWeb) return; // captura de fotos deshabilitada en web (D-09).

    final conFoto =
        await (db.select(db.fincas)..where(
              (t) => t.fotoPendiente.equals(true) & t.fotoLocalPath.isNotNull(),
            ))
            .get();

    for (final f in conFoto) {
      final ruta = f.fotoLocalPath;
      if (ruta == null) continue;
      final archivo = File(ruta);
      if (!await archivo.exists()) {
        // El archivo local ya no está; no insistir.
        await (db.update(db.fincas)..where((t) => t.id.equals(f.id))).write(
          const FincasCompanion(fotoPendiente: Value(false)),
        );
        continue;
      }
      try {
        final bytes = await archivo.readAsBytes();
        final url = await _remote.subirFotoFinca(
          fincaId: f.id,
          imagenBase64: base64Encode(bytes),
        );
        if (url != null && url.isNotEmpty) {
          await (db.update(db.fincas)..where((t) => t.id.equals(f.id))).write(
            FincasCompanion(
              fotoUrl: Value(url),
              fotoPendiente: const Value(false),
            ),
          );
        }
      } catch (e) {
        // Que un fallo de foto no rompa el resto de la sincronización.
        debugPrint('No se pudo subir la foto de la finca ${f.id}: $e');
      }
    }
  }

  // -------------------------------------------------------------- MARCADORES

  Future<SyncCursor> _leerCursor(String tabla) async {
    final row = await (db.select(
      db.syncCursores,
    )..where((t) => t.tabla.equals(tabla))).getSingleOrNull();
    if (row == null || row.ultimaBajada == null) return SyncCursor.vacio;
    return SyncCursor(updatedAt: row.ultimaBajada, id: row.ultimaBajadaId);
  }

  Future<void> _guardarCursor(String tabla, SyncCursor cursor) async {
    await db
        .into(db.syncCursores)
        .insertOnConflictUpdate(
          SyncCursorRow(
            tabla: tabla,
            ultimaBajada: cursor.updatedAt,
            ultimaBajadaId: cursor.id,
          ),
        );
  }

  Future<List<Map<String, dynamic>>> _consultar(
    String tabla,
    SyncCursor cursor, {
    String idColumna = 'id',
  }) {
    return _remote.consultar(tabla, cursor, idColumna: idColumna);
  }

  // --------------------------------------------------------------- SPECS
  //
  // Orden: primero las tablas de solo bajada que no dependen de nada
  // (planes, cuentas, usuarios), luego el resto en el mismo orden que antes
  // tenían los métodos _subirX/_bajarX. El bucle de SUBIR filtra las que
  // tienen `subida` (así queda: fincas, miembros, lotes, dietas, lote_dietas,
  // gastos_fijos, animales, movimientos_lote, eventos_sanitarios, ventas,
  // costos_otros, gasto_fijo_cargos, pesajes).

  List<TableSyncSpec> get _specs => [
    _planesSpec,
    _cuentasSpec,
    _usuariosSpec,
    _fincasSpec,
    _fincaMiembrosSpec,
    _lotesSpec,
    _dietasSpec,
    _dietaIngredientesSpec,
    _loteDietasSpec,
    _gastosFijosSpec,
    _animalesSpec,
    _movimientosLoteSpec,
    _medicamentosSpec,
    _eventosSanitariosSpec,
    _lotesVentaSpec,
    _ventasSpec,
    _costosOtrosSpec,
    _gastoFijoCargosSpec,
    _pesajesSpec,
    _featureFlagsSpec,
  ];

  /// Catálogo de licencias (solo lectura). No usa borrado suave ni `pendiente`.
  TableSyncSpec get _planesSpec => TableSyncSpec(
    tabla: 'planes',
    bajada: PullSpec(
      idDe: (r) => r['codigo'] as String,
      idColumnaRemota: 'codigo',
      aplicar: (r) => db
          .into(db.planes)
          .insertOnConflictUpdate(
            PlanRow(
              codigo: r['codigo'] as String,
              nombre: r['nombre'] as String,
              limiteFincas: r['limite_fincas'] as int,
              updatedAt: DateTime.parse(r['updated_at'] as String),
            ),
          ),
    ),
  );

  TableSyncSpec get _cuentasSpec => TableSyncSpec(
    tabla: 'cuentas',
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.cuentas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.cuentas)
          .insertOnConflictUpdate(
            CuentaRow(
              id: r['id'] as String,
              nombre: r['nombre'] as String,
              duenoId: r['dueno_id'] as String,
              plan: r['plan'] as String,
              estado: r['estado'] as String,
              pruebaTermina: r['prueba_termina'] != null
                  ? DateTime.parse(r['prueba_termina'] as String)
                  : null,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  /// Perfiles de usuario (el propio + compañeros de finca). Trae `cuenta_id`,
  /// necesario para saber la cuenta del usuario actual.
  TableSyncSpec get _usuariosSpec => TableSyncSpec(
    tabla: 'usuarios',
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.usuarios,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.usuarios)
          .insertOnConflictUpdate(
            UsuarioRow(
              id: r['id'] as String,
              nombre: r['nombre'] as String?,
              email: r['email'] as String?,
              cuentaId: r['cuenta_id'] as String?,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _fincasSpec => TableSyncSpec(
    tabla: 'fincas',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.fincas,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final f in filas)
            (
              f.id,
              {
                'id': f.id,
                'nombre': f.nombre,
                'foto_url': f.fotoUrl,
                'creada_por': f.creadaPor,
                'cuenta_id': f.cuentaId,
                'created_at': f.createdAt.toIso8601String(),
                'deleted_at': f.deletedAt?.toIso8601String(),
                // updated_at lo fija el servidor.
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.fincas)..where((t) => t.id.equals(id))).write(
            const FincasCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.fincas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) async {
        final id = r['id'] as String;
        // Solo columnas del servidor; NO tocamos fotoLocalPath/fotoPendiente
        // (son locales) para no perder una foto aún sin subir.
        FincasCompanion datosServidor({required bool conId}) => FincasCompanion(
          id: conId ? Value(id) : const Value.absent(),
          nombre: Value(r['nombre'] as String),
          fotoUrl: Value(r['foto_url'] as String?),
          creadaPor: Value(r['creada_por'] as String),
          cuentaId: Value(r['cuenta_id'] as String?),
          createdAt: Value(DateTime.parse(r['created_at'] as String)),
          updatedAt: Value(DateTime.parse(r['updated_at'] as String)),
          deletedAt: Value(
            r['deleted_at'] != null
                ? DateTime.parse(r['deleted_at'] as String)
                : null,
          ),
          pendiente: const Value(false),
        );
        await db
            .into(db.fincas)
            .insert(
              datosServidor(conId: true),
              onConflict: DoUpdate((_) => datosServidor(conId: false)),
            );
      },
    ),
  );

  TableSyncSpec get _fincaMiembrosSpec => TableSyncSpec(
    tabla: 'finca_miembros',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.fincaMiembros,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final m in filas)
            (
              m.id,
              {
                'id': m.id,
                'finca_id': m.fincaId,
                'usuario_id': m.usuarioId,
                'rol': m.rol,
                'created_at': m.createdAt.toIso8601String(),
                'deleted_at': m.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.fincaMiembros)..where((t) => t.id.equals(id))).write(
            const FincaMiembrosCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.fincaMiembros,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.fincaMiembros)
          .insertOnConflictUpdate(
            FincaMiembroRow(
              id: r['id'] as String,
              fincaId: r['finca_id'] as String,
              usuarioId: r['usuario_id'] as String,
              rol: r['rol'] as String,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _lotesSpec => TableSyncSpec(
    tabla: 'lotes',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.lotes,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final l in filas)
            (
              l.id,
              {
                'id': l.id,
                'finca_id': l.fincaId,
                'nombre': l.nombre,
                'numero': l.numero,
                'created_at': l.createdAt.toIso8601String(),
                'deleted_at': l.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) => (db.update(db.lotes)..where((t) => t.id.equals(id)))
          .write(const LotesCompanion(pendiente: Value(false))),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.lotes,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.lotes)
          .insertOnConflictUpdate(
            LoteRow(
              id: r['id'] as String,
              fincaId: r['finca_id'] as String,
              nombre: r['nombre'] as String,
              numero: r['numero'] as int?,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _dietasSpec => TableSyncSpec(
    tabla: 'dietas',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.dietas,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final d in filas)
            (
              d.id,
              {
                'id': d.id,
                'finca_id': d.fincaId,
                'nombre': d.nombre,
                'descripcion': d.descripcion,
                'costo_kg': d.costoKg,
                'kg_animal_dia': d.kgAnimalDia,
                'costo_animal_dia': d.costoAnimalDia,
                'costo_animal_semana': d.costoAnimalSemana,
                'moneda': d.moneda,
                'created_at': d.createdAt.toIso8601String(),
                'deleted_at': d.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.dietas)..where((t) => t.id.equals(id))).write(
            const DietasCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.dietas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.dietas)
          .insertOnConflictUpdate(
            DietaRow(
              id: r['id'] as String,
              fincaId: r['finca_id'] as String,
              nombre: r['nombre'] as String,
              descripcion: r['descripcion'] as String?,
              // Dietas creadas antes del modelo ₡/kg no traen costo_kg: se
              // interpretan como 1 kg al costo por animal/día ya guardado.
              costoKg: r['costo_kg'] != null
                  ? (r['costo_kg'] as num).toDouble()
                  : (r['costo_animal_dia'] as num).toDouble(),
              kgAnimalDia: r['kg_animal_dia'] != null
                  ? (r['kg_animal_dia'] as num).toDouble()
                  : 1,
              costoAnimalSemana: r['costo_animal_semana'] != null
                  ? (r['costo_animal_semana'] as num).toDouble()
                  : (r['costo_animal_dia'] as num).toDouble() * 7,
              costoAnimalDia: (r['costo_animal_dia'] as num).toDouble(),
              moneda: r['moneda'] as String? ?? 'CRC',
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _dietaIngredientesSpec => TableSyncSpec(
    tabla: 'dieta_ingredientes',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.dietaIngredientes,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final i in filas)
            (
              i.id,
              {
                'id': i.id,
                'dieta_id': i.dietaId,
                'nombre': i.nombre,
                'costo_animal_dia': i.costoAnimalDia,
                'created_at': i.createdAt.toIso8601String(),
                'deleted_at': i.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.dietaIngredientes)..where((t) => t.id.equals(id)))
              .write(const DietaIngredientesCompanion(pendiente: Value(false))),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.dietaIngredientes,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.dietaIngredientes)
          .insertOnConflictUpdate(
            DietaIngredienteRow(
              id: r['id'] as String,
              dietaId: r['dieta_id'] as String,
              nombre: r['nombre'] as String,
              costoAnimalDia: (r['costo_animal_dia'] as num).toDouble(),
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _loteDietasSpec => TableSyncSpec(
    tabla: 'lote_dietas',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.loteDietas,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final a in filas)
            (
              a.id,
              {
                'id': a.id,
                'lote_id': a.loteId,
                'dieta_id': a.dietaId,
                'desde': a.desde.toIso8601String(),
                'hasta': a.hasta?.toIso8601String(),
                'costo_animal_dia_snapshot': a.costoAnimalDiaSnapshot,
                'created_at': a.createdAt.toIso8601String(),
                'deleted_at': a.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.loteDietas)..where((t) => t.id.equals(id))).write(
            const LoteDietasCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.loteDietas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.loteDietas)
          .insertOnConflictUpdate(
            LoteDietaRow(
              id: r['id'] as String,
              loteId: r['lote_id'] as String,
              dietaId: r['dieta_id'] as String,
              desde: DateTime.parse(r['desde'] as String),
              hasta: r['hasta'] != null
                  ? DateTime.parse(r['hasta'] as String)
                  : null,
              costoAnimalDiaSnapshot: (r['costo_animal_dia_snapshot'] as num)
                  .toDouble(),
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _animalesSpec => TableSyncSpec(
    tabla: 'animales',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.animales,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final a in filas)
            (
              a.id,
              {
                'id': a.id,
                'finca_id': a.fincaId,
                'lote_id': a.loteId,
                'identificador': a.identificador,
                'estado': a.estado,
                'precio_compra': a.precioCompra,
                'peso_compra': a.pesoCompra,
                'precio_kg_compra': a.precioKgCompra,
                'fecha_compra': a.fechaCompra?.toIso8601String(),
                'created_at': a.createdAt.toIso8601String(),
                'deleted_at': a.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.animales)..where((t) => t.id.equals(id))).write(
            const AnimalesCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.animales,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.animales)
          .insertOnConflictUpdate(
            AnimalRow(
              id: r['id'] as String,
              fincaId: r['finca_id'] as String,
              loteId: r['lote_id'] as String,
              identificador: r['identificador'] as String,
              estado: r['estado'] as String? ?? 'activo',
              precioCompra: r['precio_compra'] != null
                  ? (r['precio_compra'] as num).toDouble()
                  : null,
              pesoCompra: r['peso_compra'] != null
                  ? (r['peso_compra'] as num).toDouble()
                  : null,
              precioKgCompra: r['precio_kg_compra'] != null
                  ? (r['precio_kg_compra'] as num).toDouble()
                  : null,
              fechaCompra: r['fecha_compra'] != null
                  ? DateTime.parse(r['fecha_compra'] as String)
                  : null,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _movimientosLoteSpec => TableSyncSpec(
    tabla: 'movimientos_lote',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.movimientosLote,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final m in filas)
            (
              m.id,
              {
                'id': m.id,
                'animal_id': m.animalId,
                'lote_origen': m.loteOrigen,
                'lote_destino': m.loteDestino,
                'fecha': m.fecha.toIso8601String(),
                'created_at': m.createdAt.toIso8601String(),
                'deleted_at': m.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.movimientosLote)..where((t) => t.id.equals(id))).write(
            const MovimientosLoteCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.movimientosLote,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.movimientosLote)
          .insertOnConflictUpdate(
            MovimientoLoteRow(
              id: r['id'] as String,
              animalId: r['animal_id'] as String,
              loteOrigen: r['lote_origen'] as String?,
              loteDestino: r['lote_destino'] as String,
              fecha: DateTime.parse(r['fecha'] as String),
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _medicamentosSpec => TableSyncSpec(
    tabla: 'medicamentos',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.medicamentos,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final m in filas)
            (
              m.id,
              {
                'id': m.id,
                'finca_id': m.fincaId,
                'nombre': m.nombre,
                'costo_envase': m.costoEnvase,
                'tipo_aplicacion': m.tipoAplicacion,
                'ml_envase': m.mlEnvase,
                'aplicaciones_por_envase': m.aplicacionesPorEnvase,
                'dosis_cantidad': m.dosisCantidad,
                'dosis_por_cada_kg': m.dosisPorCadaKg,
                'dias_retiro': m.diasRetiro,
                'created_at': m.createdAt.toIso8601String(),
                'deleted_at': m.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.medicamentos)..where((t) => t.id.equals(id))).write(
            const MedicamentosCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.medicamentos,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.medicamentos)
          .insertOnConflictUpdate(
            MedicamentoRow(
              id: r['id'] as String,
              fincaId: r['finca_id'] as String,
              nombre: r['nombre'] as String,
              costoEnvase: (r['costo_envase'] as num).toDouble(),
              tipoAplicacion: r['tipo_aplicacion'] as String,
              mlEnvase: r['ml_envase'] != null
                  ? (r['ml_envase'] as num).toDouble()
                  : null,
              aplicacionesPorEnvase: r['aplicaciones_por_envase'] != null
                  ? (r['aplicaciones_por_envase'] as num).toDouble()
                  : null,
              dosisCantidad: r['dosis_cantidad'] != null
                  ? (r['dosis_cantidad'] as num).toDouble()
                  : null,
              dosisPorCadaKg: r['dosis_por_cada_kg'] != null
                  ? (r['dosis_por_cada_kg'] as num).toDouble()
                  : null,
              diasRetiro: r['dias_retiro'] as int? ?? 0,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _eventosSanitariosSpec => TableSyncSpec(
    tabla: 'eventos_sanitarios',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.eventosSanitarios,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final e in filas)
            (
              e.id,
              {
                'id': e.id,
                'animal_id': e.animalId,
                'tipo': e.tipo,
                'producto': e.producto,
                'dosis': e.dosis,
                'fecha': e.fecha.toIso8601String(),
                'responsable_id': e.responsableId,
                'observaciones': e.observaciones,
                'costo': e.costo,
                'medicamento_id': e.medicamentoId,
                'ml_aplicados': e.mlAplicados,
                'aplicaciones': e.aplicaciones,
                'dias_retiro': e.diasRetiro,
                'retiro_hasta': e.retiroHasta?.toIso8601String(),
                'created_at': e.createdAt.toIso8601String(),
                'deleted_at': e.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.eventosSanitarios)..where((t) => t.id.equals(id)))
              .write(const EventosSanitariosCompanion(pendiente: Value(false))),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.eventosSanitarios,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.eventosSanitarios)
          .insertOnConflictUpdate(
            EventoSanitarioRow(
              id: r['id'] as String,
              animalId: r['animal_id'] as String,
              tipo: r['tipo'] as String,
              producto: r['producto'] as String,
              dosis: r['dosis'] as String?,
              fecha: DateTime.parse(r['fecha'] as String),
              responsableId: r['responsable_id'] as String?,
              observaciones: r['observaciones'] as String?,
              costo: r['costo'] != null ? (r['costo'] as num).toDouble() : null,
              medicamentoId: r['medicamento_id'] as String?,
              mlAplicados: r['ml_aplicados'] != null
                  ? (r['ml_aplicados'] as num).toDouble()
                  : null,
              aplicaciones: r['aplicaciones'] as int?,
              diasRetiro: r['dias_retiro'] as int?,
              retiroHasta: r['retiro_hasta'] != null
                  ? DateTime.parse(r['retiro_hasta'] as String)
                  : null,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _lotesVentaSpec => TableSyncSpec(
    tabla: 'lotes_venta',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.lotesVenta,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final l in filas)
            (
              l.id,
              {
                'id': l.id,
                'finca_id': l.fincaId,
                'fecha': l.fecha.toIso8601String(),
                'created_at': l.createdAt.toIso8601String(),
                'deleted_at': l.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.lotesVenta)..where((t) => t.id.equals(id))).write(
            const LotesVentaCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.lotesVenta,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.lotesVenta)
          .insertOnConflictUpdate(
            LoteVentaRow(
              id: r['id'] as String,
              fincaId: r['finca_id'] as String,
              fecha: DateTime.parse(r['fecha'] as String),
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _ventasSpec => TableSyncSpec(
    tabla: 'ventas',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.ventas,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final v in filas)
            (
              v.id,
              {
                'id': v.id,
                'animal_id': v.animalId,
                'lote_venta_id': v.loteVentaId,
                'fecha': v.fecha.toIso8601String(),
                'precio': v.precio,
                'peso': v.peso,
                'precio_kg': v.precioKg,
                'peso_pie': v.pesoPie,
                'peso_canal': v.pesoCanal,
                'rendimiento': v.rendimiento,
                'dinero_recibido': v.dineroRecibido,
                'comprador': v.comprador,
                'observaciones': v.observaciones,
                'created_at': v.createdAt.toIso8601String(),
                'deleted_at': v.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.ventas)..where((t) => t.id.equals(id))).write(
            const VentasCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.ventas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.ventas)
          .insertOnConflictUpdate(
            VentaRow(
              id: r['id'] as String,
              animalId: r['animal_id'] as String,
              loteVentaId: r['lote_venta_id'] as String?,
              fecha: DateTime.parse(r['fecha'] as String),
              precio: (r['precio'] as num).toDouble(),
              peso: r['peso'] != null ? (r['peso'] as num).toDouble() : null,
              precioKg: r['precio_kg'] != null
                  ? (r['precio_kg'] as num).toDouble()
                  : null,
              pesoPie: r['peso_pie'] != null
                  ? (r['peso_pie'] as num).toDouble()
                  : null,
              pesoCanal: r['peso_canal'] != null
                  ? (r['peso_canal'] as num).toDouble()
                  : null,
              rendimiento: r['rendimiento'] != null
                  ? (r['rendimiento'] as num).toDouble()
                  : null,
              // Ventas subidas antes de D-19 no traen dinero recibido: el total
              // cobrado cumple ese papel para no perder su utilidad.
              dineroRecibido: r['dinero_recibido'] != null
                  ? (r['dinero_recibido'] as num).toDouble()
                  : ((r['precio'] as num).toDouble() > 0
                        ? (r['precio'] as num).toDouble()
                        : null),
              comprador: r['comprador'] as String?,
              observaciones: r['observaciones'] as String?,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _costosOtrosSpec => TableSyncSpec(
    tabla: 'costos_otros',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.costosOtros,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final c in filas)
            (
              c.id,
              {
                'id': c.id,
                'animal_id': c.animalId,
                'concepto': c.concepto,
                'monto': c.monto,
                'fecha': c.fecha.toIso8601String(),
                'created_at': c.createdAt.toIso8601String(),
                'deleted_at': c.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.costosOtros)..where((t) => t.id.equals(id))).write(
            const CostosOtrosCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.costosOtros,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.costosOtros)
          .insertOnConflictUpdate(
            CostoOtroRow(
              id: r['id'] as String,
              animalId: r['animal_id'] as String,
              concepto: r['concepto'] as String,
              monto: (r['monto'] as num).toDouble(),
              fecha: DateTime.parse(r['fecha'] as String),
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  /// Gastos fijos de la finca (Módulo 7, D-17). Depende de `fincas`.
  TableSyncSpec get _gastosFijosSpec => TableSyncSpec(
    tabla: 'gastos_fijos',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.gastosFijos,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final g in filas)
            (
              g.id,
              {
                'id': g.id,
                'finca_id': g.fincaId,
                'concepto': g.concepto,
                'monto': g.monto,
                'periodicidad': g.periodicidad,
                'desde': g.desde.toIso8601String(),
                'hasta': g.hasta?.toIso8601String(),
                'moneda': g.moneda,
                'created_at': g.createdAt.toIso8601String(),
                'deleted_at': g.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.gastosFijos)..where((t) => t.id.equals(id))).write(
            const GastosFijosCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.gastosFijos,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.gastosFijos)
          .insertOnConflictUpdate(
            GastoFijoRow(
              id: r['id'] as String,
              fincaId: r['finca_id'] as String,
              concepto: r['concepto'] as String,
              monto: (r['monto'] as num).toDouble(),
              periodicidad: r['periodicidad'] as String,
              desde: DateTime.parse(r['desde'] as String),
              hasta: r['hasta'] != null
                  ? DateTime.parse(r['hasta'] as String)
                  : null,
              moneda: (r['moneda'] as String?) ?? 'CRC',
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  /// Partes congeladas de gastos fijos al vender (Módulo 7, D-17).
  /// Depende de `gastos_fijos` y `animales`.
  TableSyncSpec get _gastoFijoCargosSpec => TableSyncSpec(
    tabla: 'gasto_fijo_cargos',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.gastoFijoCargos,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final c in filas)
            (
              c.id,
              {
                'id': c.id,
                'gasto_fijo_id': c.gastoFijoId,
                'animal_id': c.animalId,
                'mes': c.mes.toIso8601String(),
                'dias': c.dias,
                'monto': c.monto,
                'created_at': c.createdAt.toIso8601String(),
                'deleted_at': c.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.gastoFijoCargos)..where((t) => t.id.equals(id))).write(
            const GastoFijoCargosCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.gastoFijoCargos,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.gastoFijoCargos)
          .insertOnConflictUpdate(
            GastoFijoCargoRow(
              id: r['id'] as String,
              gastoFijoId: r['gasto_fijo_id'] as String,
              animalId: r['animal_id'] as String,
              mes: DateTime.parse(r['mes'] as String),
              dias: (r['dias'] as num).toInt(),
              monto: (r['monto'] as num).toDouble(),
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  TableSyncSpec get _pesajesSpec => TableSyncSpec(
    tabla: 'pesajes',
    subida: PushSpec(
      pendientes: () async {
        final filas = await (db.select(
          db.pesajes,
        )..where((t) => t.pendiente.equals(true))).get();
        return [
          for (final p in filas)
            (
              p.id,
              {
                'id': p.id,
                'animal_id': p.animalId,
                'peso': p.peso,
                'fecha': p.fecha.toIso8601String(),
                'registrado_por': p.registradoPor,
                'created_at': p.createdAt.toIso8601String(),
                'deleted_at': p.deletedAt?.toIso8601String(),
              },
            ),
        ];
      },
      marcarSubida: (id) =>
          (db.update(db.pesajes)..where((t) => t.id.equals(id))).write(
            const PesajesCompanion(pendiente: Value(false)),
          ),
    ),
    bajada: PullSpec(
      tieneCambioLocalPendiente: (id) async {
        final fila = await (db.select(
          db.pesajes,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      },
      aplicar: (r) => db
          .into(db.pesajes)
          .insertOnConflictUpdate(
            PesajeRow(
              id: r['id'] as String,
              animalId: r['animal_id'] as String,
              peso: (r['peso'] as num).toDouble(),
              fecha: DateTime.parse(r['fecha'] as String),
              registradoPor: r['registrado_por'] as String?,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          ),
    ),
  );

  /// Feature flags (D-15): solo BAJAR, nunca SUBIR. La tabla la escribe el
  /// CLI (`hatoctl`) vía `service_role`; la app nunca la modifica, así que no
  /// hace falta guard de `tieneCambioLocalPendiente` (no hay filas locales
  /// pendientes que proteger).
  TableSyncSpec get _featureFlagsSpec => TableSyncSpec(
    tabla: 'feature_flags',
    bajada: PullSpec(
      aplicar: (r) => db
          .into(db.featureFlags)
          .insertOnConflictUpdate(
            FeatureFlagRow(
              id: r['id'] as String,
              scope: r['scope'] as String,
              scopeId: r['scope_id'] as String?,
              clave: r['clave'] as String,
              habilitado: r['habilitado'] as bool,
              nota: r['nota'] as String?,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: DateTime.parse(r['updated_at'] as String),
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
            ),
          ),
    ),
  );
}
