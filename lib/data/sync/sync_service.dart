import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/database.dart';

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
  SyncService(this.db);

  final AppDatabase db;

  SupabaseClient get _sb => Supabase.instance.client;

  /// Para que la UI pueda mostrar un indicador de "sincronizando…".
  final ValueNotifier<bool> sincronizando = ValueNotifier(false);

  bool _enCurso = false;

  Future<void> sincronizar() async {
    if (_sb.auth.currentUser == null) return; // sin sesión, nada que hacer
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
    // Subir primero (para no pisar cambios locales al bajar).
    await _subirFincas();
    await _subirMiembros();
    await _subirLotes();
    // Fotos: después de la membresía (la RLS de update exige ser admin).
    await _subirFotosFincas();
    // Bajar después. Planes y cuentas primero (la finca necesita su cuenta).
    await _bajarPlanes();
    await _bajarCuentas();
    await _bajarUsuarios();
    await _bajarFincas();
    await _bajarMiembros();
    await _bajarLotes();
  }

  // ---------------------------------------------------------------- SUBIR

  Future<void> _subirFincas() async {
    final pendientes =
        await (db.select(db.fincas)..where((t) => t.pendiente.equals(true)))
            .get();
    for (final f in pendientes) {
      final datos = {
        'id': f.id,
        'nombre': f.nombre,
        'foto_url': f.fotoUrl,
        'creada_por': f.creadaPor,
        'cuenta_id': f.cuentaId,
        'created_at': f.createdAt.toIso8601String(),
        'deleted_at': f.deletedAt?.toIso8601String(),
        // updated_at lo fija el servidor.
      };
      await _insertarOActualizar('fincas', f.id, datos);
      await (db.update(db.fincas)..where((t) => t.id.equals(f.id)))
          .write(const FincasCompanion(pendiente: Value(false)));
    }
  }

  Future<void> _subirMiembros() async {
    final pendientes = await (db.select(db.fincaMiembros)
          ..where((t) => t.pendiente.equals(true)))
        .get();
    for (final m in pendientes) {
      final datos = {
        'id': m.id,
        'finca_id': m.fincaId,
        'usuario_id': m.usuarioId,
        'rol': m.rol,
        'created_at': m.createdAt.toIso8601String(),
        'deleted_at': m.deletedAt?.toIso8601String(),
      };
      await _insertarOActualizar('finca_miembros', m.id, datos);
      await (db.update(db.fincaMiembros)..where((t) => t.id.equals(m.id)))
          .write(const FincaMiembrosCompanion(pendiente: Value(false)));
    }
  }

  /// Inserta una fila nueva en el servidor. Si ya existe (clave duplicada),
  /// la actualiza. Hacemos esto en vez de `upsert` porque `upsert` evalúa
  /// también la política RLS de UPDATE, que puede bloquear inserciones nuevas
  /// (p. ej. crear una finca cuando todavía no sos admin de ella).
  Future<void> _insertarOActualizar(
      String tabla, String id, Map<String, dynamic> datos) async {
    try {
      await _sb.from(tabla).insert(datos);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Ya existe en el servidor → actualizar.
        await _sb.from(tabla).update(datos).eq('id', id);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _subirLotes() async {
    final pendientes =
        await (db.select(db.lotes)..where((t) => t.pendiente.equals(true)))
            .get();
    for (final l in pendientes) {
      final datos = {
        'id': l.id,
        'finca_id': l.fincaId,
        'nombre': l.nombre,
        'numero': l.numero,
        'created_at': l.createdAt.toIso8601String(),
        'deleted_at': l.deletedAt?.toIso8601String(),
      };
      await _insertarOActualizar('lotes', l.id, datos);
      await (db.update(db.lotes)..where((t) => t.id.equals(l.id)))
          .write(const LotesCompanion(pendiente: Value(false)));
    }
  }

  /// Sube las fotos de fincas marcadas `fotoPendiente` a través de la Edge
  /// Function `subir-foto-finca` (que valida al usuario y escribe con permisos
  /// de servidor), guarda la URL pública devuelta y limpia la bandera.
  Future<void> _subirFotosFincas() async {
    if (_sb.auth.currentSession == null) return;

    final conFoto = await (db.select(db.fincas)
          ..where((t) =>
              t.fotoPendiente.equals(true) & t.fotoLocalPath.isNotNull()))
        .get();

    for (final f in conFoto) {
      final ruta = f.fotoLocalPath;
      if (ruta == null) continue;
      final archivo = File(ruta);
      if (!await archivo.exists()) {
        // El archivo local ya no está; no insistir.
        await (db.update(db.fincas)..where((t) => t.id.equals(f.id)))
            .write(const FincasCompanion(fotoPendiente: Value(false)));
        continue;
      }
      try {
        final bytes = await archivo.readAsBytes();
        final res = await _sb.functions.invoke(
          'subir-foto-finca',
          body: {
            'finca_id': f.id,
            'imagen_base64': base64Encode(bytes),
          },
        );
        final data = res.data;
        final url = data is Map ? data['url'] as String? : null;
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

  /// Catálogo de licencias (solo lectura). No usa borrado suave.
  Future<void> _bajarPlanes() async {
    final cursor = await _leerCursor('planes');
    final filas = await _consultar('planes', cursor);
    DateTime? maxU = cursor;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      await db.into(db.planes).insertOnConflictUpdate(PlanRow(
            codigo: r['codigo'] as String,
            nombre: r['nombre'] as String,
            limiteFincas: r['limite_fincas'] as int,
            updatedAt: u,
          ));
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (maxU != null) await _guardarCursor('planes', maxU);
  }

  Future<void> _bajarCuentas() async {
    final cursor = await _leerCursor('cuentas');
    final filas = await _consultar('cuentas', cursor);
    DateTime? maxU = cursor;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      await db.into(db.cuentas).insertOnConflictUpdate(CuentaRow(
            id: r['id'] as String,
            nombre: r['nombre'] as String,
            duenoId: r['dueno_id'] as String,
            plan: r['plan'] as String,
            estado: r['estado'] as String,
            createdAt: DateTime.parse(r['created_at'] as String),
            updatedAt: u,
            deletedAt: r['deleted_at'] != null
                ? DateTime.parse(r['deleted_at'] as String)
                : null,
            pendiente: false,
          ));
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (maxU != null) await _guardarCursor('cuentas', maxU);
  }

  /// Perfiles de usuario (el propio + compañeros de finca). Trae `cuenta_id`,
  /// necesario para saber la cuenta del usuario actual.
  Future<void> _bajarUsuarios() async {
    final cursor = await _leerCursor('usuarios');
    final filas = await _consultar('usuarios', cursor);
    DateTime? maxU = cursor;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      await db.into(db.usuarios).insertOnConflictUpdate(UsuarioRow(
            id: r['id'] as String,
            nombre: r['nombre'] as String?,
            email: r['email'] as String?,
            cuentaId: r['cuenta_id'] as String?,
            createdAt: DateTime.parse(r['created_at'] as String),
            updatedAt: u,
            pendiente: false,
          ));
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (maxU != null) await _guardarCursor('usuarios', maxU);
  }

  Future<void> _bajarFincas() async {
    final cursor = await _leerCursor('fincas');
    final filas = await _consultar('fincas', cursor);
    DateTime? maxU = cursor;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      final deletedAt = r['deleted_at'] != null
          ? DateTime.parse(r['deleted_at'] as String)
          : null;

      // Solo columnas del servidor; NO tocamos fotoLocalPath/fotoPendiente
      // (son locales) para no perder una foto aún sin subir.
      FincasCompanion datosServidor({required bool conId}) => FincasCompanion(
            id: conId ? Value(r['id'] as String) : const Value.absent(),
            nombre: Value(r['nombre'] as String),
            fotoUrl: Value(r['foto_url'] as String?),
            creadaPor: Value(r['creada_por'] as String),
            cuentaId: Value(r['cuenta_id'] as String?),
            createdAt: Value(DateTime.parse(r['created_at'] as String)),
            updatedAt: Value(u),
            deletedAt: Value(deletedAt),
            pendiente: const Value(false),
          );

      await db.into(db.fincas).insert(
            datosServidor(conId: true),
            onConflict: DoUpdate((_) => datosServidor(conId: false)),
          );
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (maxU != null) await _guardarCursor('fincas', maxU);
  }

  Future<void> _bajarMiembros() async {
    final cursor = await _leerCursor('finca_miembros');
    final filas = await _consultar('finca_miembros', cursor);
    DateTime? maxU = cursor;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      await db.into(db.fincaMiembros).insertOnConflictUpdate(FincaMiembroRow(
            id: r['id'] as String,
            fincaId: r['finca_id'] as String,
            usuarioId: r['usuario_id'] as String,
            rol: r['rol'] as String,
            createdAt: DateTime.parse(r['created_at'] as String),
            updatedAt: u,
            deletedAt: r['deleted_at'] != null
                ? DateTime.parse(r['deleted_at'] as String)
                : null,
            pendiente: false,
          ));
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (maxU != null) await _guardarCursor('finca_miembros', maxU);
  }

  Future<void> _bajarLotes() async {
    final cursor = await _leerCursor('lotes');
    final filas = await _consultar('lotes', cursor);
    DateTime? maxU = cursor;
    for (final r in filas) {
      final u = DateTime.parse(r['updated_at'] as String);
      await db.into(db.lotes).insertOnConflictUpdate(LoteRow(
            id: r['id'] as String,
            fincaId: r['finca_id'] as String,
            nombre: r['nombre'] as String,
            numero: r['numero'] as int?,
            createdAt: DateTime.parse(r['created_at'] as String),
            updatedAt: u,
            deletedAt: r['deleted_at'] != null
                ? DateTime.parse(r['deleted_at'] as String)
                : null,
            pendiente: false,
          ));
      if (maxU == null || u.isAfter(maxU)) maxU = u;
    }
    if (maxU != null) await _guardarCursor('lotes', maxU);
  }

  /// Trae del servidor las filas con updated_at > cursor (o todas si es null).
  Future<List<Map<String, dynamic>>> _consultar(
      String tabla, DateTime? cursor) async {
    final base = _sb.from(tabla).select();
    final res = cursor == null
        ? await base.order('updated_at', ascending: true)
        : await base
            .gt('updated_at', cursor.toIso8601String())
            .order('updated_at', ascending: true);
    return (res as List).cast<Map<String, dynamic>>();
  }

  // -------------------------------------------------------------- MARCADORES

  Future<DateTime?> _leerCursor(String tabla) async {
    final row = await (db.select(db.syncCursores)
          ..where((t) => t.tabla.equals(tabla)))
        .getSingleOrNull();
    return row?.ultimaBajada;
  }

  Future<void> _guardarCursor(String tabla, DateTime fecha) async {
    await db.into(db.syncCursores).insertOnConflictUpdate(
          SyncCursorRow(tabla: tabla, ultimaBajada: fecha),
        );
  }
}
