import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/database.dart';
import 'sync_remote_gateway.dart';

/// Motor de sincronización entre la base local (Drift/SQLite) y Supabase.
///
/// Estrategia:
///  - SUBIR: envía al servidor las filas marcadas como `pendiente` (upsert) y
///    luego las marca como sincronizadas.
///  - BAJAR: trae del servidor las filas con `updated_at` mayor al último
///    marcador guardado, y las guarda localmente. Avanza el marcador.
///  - Conflictos: "gana el último que escribe" (el servidor fija `updated_at`).
///  - Borrados: viajan como `deleted_at` (borrado suave).
///
/// Por ahora sincroniza `fincas` y `finca_miembros`. Al construir las demás
/// pantallas agregaremos lotes, animales y pesajes con el mismo patrón.
class SyncService {
  SyncService(this.db, {SyncRemoteGateway? remote})
    : _remote = remote ?? SupabaseSyncRemoteGateway();

  final AppDatabase db;
  final SyncRemoteGateway _remote;

  /// Para que la UI pueda mostrar un indicador de "sincronizando…".
  final ValueNotifier<bool> sincronizando = ValueNotifier(false);

  bool _enCurso = false;

  Future<void> sincronizar() async {
    if (!_remote.tieneUsuario) return; // sin sesión, nada que hacer
    if (_enCurso) return; // evitar solapamientos
    _enCurso = true;
    sincronizando.value = true;
    try {
      // Tiempo límite: si la red se cuelga (p. ej. se cae a mitad), no dejamos
      // el sync trabado para siempre; se cancela y se libera para reintentar.
      await _ejecutarSync().timeout(const Duration(seconds: 20));
    } catch (e) {
      // Si no hay internet o falla la red, reintentaremos en la próxima.
      debugPrint('Sync: no se pudo completar ($e)');
    } finally {
      _enCurso = false;
      sincronizando.value = false;
    }
  }

  Future<void> _ejecutarSync() async {
    // Cada paso va aislado: si uno falla (p. ej. un registro con conflicto),
    // los demás igual se ejecutan. Al BAJAR protegemos filas con cambios
    // locales pendientes para no pisarlas con una copia vieja del servidor.
    // Subir primero (para no pisar cambios locales al bajar).
    await _paso(_subirFincas);
    await _paso(_subirMiembros);
    await _paso(_subirLotes);
    await _paso(_subirAnimales);
    await _paso(_subirPesajes);
    // Fotos: después de la membresía (la RLS de update exige ser admin).
    await _paso(_subirFotosFincas);
    // Bajar después. Planes y cuentas primero (la finca necesita su cuenta).
    await _paso(_bajarPlanes);
    await _paso(_bajarCuentas);
    await _paso(_bajarUsuarios);
    await _paso(_bajarFincas);
    await _paso(_bajarMiembros);
    await _paso(_bajarLotes);
    await _paso(_bajarAnimales);
    await _paso(_bajarPesajes);
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

  // ---------------------------------------------------------------- SUBIR

  Future<void> _subirFincas() async {
    final pendientes = await (db.select(
      db.fincas,
    )..where((t) => t.pendiente.equals(true))).get();
    await _subirPendientes<FincaRow>(
      tabla: 'fincas',
      filas: pendientes,
      id: (f) => f.id,
      datos: (f) => {
        'id': f.id,
        'nombre': f.nombre,
        'foto_url': f.fotoUrl,
        'creada_por': f.creadaPor,
        'cuenta_id': f.cuentaId,
        'created_at': f.createdAt.toIso8601String(),
        'deleted_at': f.deletedAt?.toIso8601String(),
        // updated_at lo fija el servidor.
      },
      marcarSubida: (id) =>
          (db.update(db.fincas)..where((t) => t.id.equals(id))).write(
            const FincasCompanion(pendiente: Value(false)),
          ),
    );
  }

  Future<void> _subirMiembros() async {
    final pendientes = await (db.select(
      db.fincaMiembros,
    )..where((t) => t.pendiente.equals(true))).get();
    await _subirPendientes<FincaMiembroRow>(
      tabla: 'finca_miembros',
      filas: pendientes,
      id: (m) => m.id,
      datos: (m) => {
        'id': m.id,
        'finca_id': m.fincaId,
        'usuario_id': m.usuarioId,
        'rol': m.rol,
        'created_at': m.createdAt.toIso8601String(),
        'deleted_at': m.deletedAt?.toIso8601String(),
      },
      marcarSubida: (id) =>
          (db.update(db.fincaMiembros)..where((t) => t.id.equals(id))).write(
            const FincaMiembrosCompanion(pendiente: Value(false)),
          ),
    );
  }

  /// Sube filas pendientes con resiliencia POR FILA: si una falla (conflicto,
  /// red, RLS, etc.) se registra y se sigue con las demás — una fila con
  /// problema NUNCA bloquea ni descarta al resto. Cada fila se marca como
  /// subida solo si su subida tuvo éxito; si falla, queda `pendiente` y se
  /// reintenta en la próxima sincronización. Así un dato local sin subir no se
  /// pierde: insiste hasta lograrlo.
  Future<void> _subirPendientes<T>({
    required String tabla,
    required List<T> filas,
    required String Function(T) id,
    required Map<String, dynamic> Function(T) datos,
    required Future<void> Function(String id) marcarSubida,
  }) async {
    for (final fila in filas) {
      try {
        await _remote.insertarOActualizar(tabla, id(fila), datos(fila));
        await marcarSubida(id(fila));
      } catch (e) {
        debugPrint(
          'Sync: no se pudo subir $tabla ${id(fila)}; queda pendiente '
          'para reintentar ($e)',
        );
      }
    }
  }

  Future<void> _subirLotes() async {
    final pendientes = await (db.select(
      db.lotes,
    )..where((t) => t.pendiente.equals(true))).get();
    await _subirPendientes<LoteRow>(
      tabla: 'lotes',
      filas: pendientes,
      id: (l) => l.id,
      datos: (l) => {
        'id': l.id,
        'finca_id': l.fincaId,
        'nombre': l.nombre,
        'numero': l.numero,
        'created_at': l.createdAt.toIso8601String(),
        'deleted_at': l.deletedAt?.toIso8601String(),
      },
      marcarSubida: (id) => (db.update(db.lotes)..where((t) => t.id.equals(id)))
          .write(const LotesCompanion(pendiente: Value(false))),
    );
  }

  Future<void> _subirAnimales() async {
    final pendientes = await (db.select(
      db.animales,
    )..where((t) => t.pendiente.equals(true))).get();
    await _subirPendientes<AnimalRow>(
      tabla: 'animales',
      filas: pendientes,
      id: (a) => a.id,
      datos: (a) => {
        'id': a.id,
        'finca_id': a.fincaId,
        'lote_id': a.loteId,
        'identificador': a.identificador,
        'created_at': a.createdAt.toIso8601String(),
        'deleted_at': a.deletedAt?.toIso8601String(),
      },
      marcarSubida: (id) =>
          (db.update(db.animales)..where((t) => t.id.equals(id))).write(
            const AnimalesCompanion(pendiente: Value(false)),
          ),
    );
  }

  Future<void> _subirPesajes() async {
    final pendientes = await (db.select(
      db.pesajes,
    )..where((t) => t.pendiente.equals(true))).get();
    await _subirPendientes<PesajeRow>(
      tabla: 'pesajes',
      filas: pendientes,
      id: (p) => p.id,
      datos: (p) => {
        'id': p.id,
        'animal_id': p.animalId,
        'peso': p.peso,
        'fecha': p.fecha.toIso8601String(),
        'registrado_por': p.registradoPor,
        'created_at': p.createdAt.toIso8601String(),
        'deleted_at': p.deletedAt?.toIso8601String(),
      },
      marcarSubida: (id) =>
          (db.update(db.pesajes)..where((t) => t.id.equals(id))).write(
            const PesajesCompanion(pendiente: Value(false)),
          ),
    );
  }

  /// Sube las fotos de fincas marcadas `fotoPendiente` a través de la Edge
  /// Function `subir-foto-finca` (que valida al usuario y escribe con permisos
  /// de servidor), guarda la URL pública devuelta y limpia la bandera.
  Future<void> _subirFotosFincas() async {
    if (!_remote.tieneSesion) return;

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

  // ---------------------------------------------------------------- BAJAR

  /// Indica si una fila local todavía tiene cambios sin subir.
  ///
  /// Las descargas nunca deben borrar `pendiente=true`: si una subida falló y
  /// luego baja una versión vieja del servidor, se perdería el cambio local.
  @visibleForTesting
  Future<bool> tieneCambiosLocalesPendientes(String tabla, String id) async {
    switch (tabla) {
      case 'cuentas':
        final fila = await (db.select(
          db.cuentas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      case 'usuarios':
        final fila = await (db.select(
          db.usuarios,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      case 'fincas':
        final fila = await (db.select(
          db.fincas,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      case 'finca_miembros':
        final fila = await (db.select(
          db.fincaMiembros,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      case 'lotes':
        final fila = await (db.select(
          db.lotes,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      case 'animales':
        final fila = await (db.select(
          db.animales,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      case 'pesajes':
        final fila = await (db.select(
          db.pesajes,
        )..where((t) => t.id.equals(id))).getSingleOrNull();
        return fila?.pendiente ?? false;
      default:
        return false;
    }
  }

  /// Catálogo de licencias (solo lectura). No usa borrado suave.
  Future<void> _bajarPlanes() async {
    final cursor = await _leerCursor('planes');
    final filas = await _consultar('planes', cursor);
    DateTime? maxU = cursor;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      await db
          .into(db.planes)
          .insertOnConflictUpdate(
            PlanRow(
              codigo: r['codigo'] as String,
              nombre: r['nombre'] as String,
              limiteFincas: r['limite_fincas'] as int,
              updatedAt: u,
            ),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (maxU != null) await _guardarCursor('planes', maxU);
  }

  Future<void> _bajarCuentas() async {
    final cursor = await _leerCursor('cuentas');
    final filas = await _consultar('cuentas', cursor);
    DateTime? maxU = cursor;
    var retuvoCambioLocal = false;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      final id = r['id'] as String;
      if (await tieneCambiosLocalesPendientes('cuentas', id)) {
        retuvoCambioLocal = true;
        continue;
      }
      await db
          .into(db.cuentas)
          .insertOnConflictUpdate(
            CuentaRow(
              id: id,
              nombre: r['nombre'] as String,
              duenoId: r['dueno_id'] as String,
              plan: r['plan'] as String,
              estado: r['estado'] as String,
              pruebaTermina: r['prueba_termina'] != null
                  ? DateTime.parse(r['prueba_termina'] as String)
                  : null,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: u,
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (!retuvoCambioLocal && maxU != null) {
      await _guardarCursor('cuentas', maxU);
    }
  }

  /// Perfiles de usuario (el propio + compañeros de finca). Trae `cuenta_id`,
  /// necesario para saber la cuenta del usuario actual.
  Future<void> _bajarUsuarios() async {
    final cursor = await _leerCursor('usuarios');
    final filas = await _consultar('usuarios', cursor);
    DateTime? maxU = cursor;
    var retuvoCambioLocal = false;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      final id = r['id'] as String;
      if (await tieneCambiosLocalesPendientes('usuarios', id)) {
        retuvoCambioLocal = true;
        continue;
      }
      await db
          .into(db.usuarios)
          .insertOnConflictUpdate(
            UsuarioRow(
              id: id,
              nombre: r['nombre'] as String?,
              email: r['email'] as String?,
              cuentaId: r['cuenta_id'] as String?,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: u,
              pendiente: false,
            ),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (!retuvoCambioLocal && maxU != null) {
      await _guardarCursor('usuarios', maxU);
    }
  }

  Future<void> _bajarFincas() async {
    final cursor = await _leerCursor('fincas');
    final filas = await _consultar('fincas', cursor);
    DateTime? maxU = cursor;
    var retuvoCambioLocal = false;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      final id = r['id'] as String;
      if (await tieneCambiosLocalesPendientes('fincas', id)) {
        retuvoCambioLocal = true;
        continue;
      }
      final deletedAt = r['deleted_at'] != null
          ? DateTime.parse(r['deleted_at'] as String)
          : null;

      // Solo columnas del servidor; NO tocamos fotoLocalPath/fotoPendiente
      // (son locales) para no perder una foto aún sin subir.
      FincasCompanion datosServidor({required bool conId}) => FincasCompanion(
        id: conId ? Value(id) : const Value.absent(),
        nombre: Value(r['nombre'] as String),
        fotoUrl: Value(r['foto_url'] as String?),
        creadaPor: Value(r['creada_por'] as String),
        cuentaId: Value(r['cuenta_id'] as String?),
        createdAt: Value(DateTime.parse(r['created_at'] as String)),
        updatedAt: Value(u),
        deletedAt: Value(deletedAt),
        pendiente: const Value(false),
      );

      await db
          .into(db.fincas)
          .insert(
            datosServidor(conId: true),
            onConflict: DoUpdate((_) => datosServidor(conId: false)),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (!retuvoCambioLocal && maxU != null) {
      await _guardarCursor('fincas', maxU);
    }
  }

  Future<void> _bajarMiembros() async {
    final cursor = await _leerCursor('finca_miembros');
    final filas = await _consultar('finca_miembros', cursor);
    DateTime? maxU = cursor;
    var retuvoCambioLocal = false;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      final id = r['id'] as String;
      if (await tieneCambiosLocalesPendientes('finca_miembros', id)) {
        retuvoCambioLocal = true;
        continue;
      }
      await db
          .into(db.fincaMiembros)
          .insertOnConflictUpdate(
            FincaMiembroRow(
              id: id,
              fincaId: r['finca_id'] as String,
              usuarioId: r['usuario_id'] as String,
              rol: r['rol'] as String,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: u,
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (!retuvoCambioLocal && maxU != null) {
      await _guardarCursor('finca_miembros', maxU);
    }
  }

  Future<void> _bajarLotes() async {
    final cursor = await _leerCursor('lotes');
    final filas = await _consultar('lotes', cursor);
    DateTime? maxU = cursor;
    var retuvoCambioLocal = false;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      final id = r['id'] as String;
      if (await tieneCambiosLocalesPendientes('lotes', id)) {
        retuvoCambioLocal = true;
        continue;
      }
      await db
          .into(db.lotes)
          .insertOnConflictUpdate(
            LoteRow(
              id: id,
              fincaId: r['finca_id'] as String,
              nombre: r['nombre'] as String,
              numero: r['numero'] as int?,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: u,
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (!retuvoCambioLocal && maxU != null) {
      await _guardarCursor('lotes', maxU);
    }
  }

  Future<void> _bajarAnimales() async {
    final cursor = await _leerCursor('animales');
    final filas = await _consultar('animales', cursor);
    DateTime? maxU = cursor;
    var retuvoCambioLocal = false;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      final id = r['id'] as String;
      if (await tieneCambiosLocalesPendientes('animales', id)) {
        retuvoCambioLocal = true;
        continue;
      }
      await db
          .into(db.animales)
          .insertOnConflictUpdate(
            AnimalRow(
              id: id,
              fincaId: r['finca_id'] as String,
              loteId: r['lote_id'] as String,
              identificador: r['identificador'] as String,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: u,
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (!retuvoCambioLocal && maxU != null) {
      await _guardarCursor('animales', maxU);
    }
  }

  Future<void> _bajarPesajes() async {
    final cursor = await _leerCursor('pesajes');
    final filas = await _consultar('pesajes', cursor);
    DateTime? maxU = cursor;
    var retuvoCambioLocal = false;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      final id = r['id'] as String;
      if (await tieneCambiosLocalesPendientes('pesajes', id)) {
        retuvoCambioLocal = true;
        continue;
      }
      await db
          .into(db.pesajes)
          .insertOnConflictUpdate(
            PesajeRow(
              id: id,
              animalId: r['animal_id'] as String,
              peso: (r['peso'] as num).toDouble(),
              fecha: DateTime.parse(r['fecha'] as String),
              registradoPor: r['registrado_por'] as String?,
              createdAt: DateTime.parse(r['created_at'] as String),
              updatedAt: u,
              deletedAt: r['deleted_at'] != null
                  ? DateTime.parse(r['deleted_at'] as String)
                  : null,
              pendiente: false,
            ),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (!retuvoCambioLocal && maxU != null) {
      await _guardarCursor('pesajes', maxU);
    }
  }

  Future<List<Map<String, dynamic>>> _consultar(
    String tabla,
    DateTime? cursor,
  ) async {
    return _remote.consultar(tabla, cursor);
  }

  // -------------------------------------------------------------- MARCADORES

  Future<DateTime?> _leerCursor(String tabla) async {
    final row = await (db.select(
      db.syncCursores,
    )..where((t) => t.tabla.equals(tabla))).getSingleOrNull();
    return row?.ultimaBajada;
  }

  Future<void> _guardarCursor(String tabla, DateTime fecha) async {
    await db
        .into(db.syncCursores)
        .insertOnConflictUpdate(
          SyncCursorRow(tabla: tabla, ultimaBajada: fecha),
        );
  }
}
