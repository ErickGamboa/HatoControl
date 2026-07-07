import 'package:supabase_flutter/supabase_flutter.dart';

/// Frontera remota del sync.
///
/// Mantiene a [SyncService] testeable: en producción habla con Supabase; en
/// tests se reemplaza por un fake en memoria sin credenciales ni red.
abstract class SyncRemoteGateway {
  bool get tieneUsuario;
  bool get tieneSesion;

  Future<void> insertarOActualizar(
    String tabla,
    String id,
    Map<String, dynamic> datos,
  );

  Future<List<Map<String, dynamic>>> consultar(String tabla, DateTime? cursor);

  Future<String?> subirFotoFinca({
    required String fincaId,
    required String imagenBase64,
  });
}

class SupabaseSyncRemoteGateway implements SyncRemoteGateway {
  SupabaseSyncRemoteGateway([SupabaseClient? supabase])
    : _sb = supabase ?? Supabase.instance.client;

  final SupabaseClient _sb;

  @override
  bool get tieneUsuario => _sb.auth.currentUser != null;

  @override
  bool get tieneSesion => _sb.auth.currentSession != null;

  /// Sube una fila al servidor: ACTUALIZA primero y, si no existía (0 filas),
  /// INSERTA. El orden importa: hacer update-first evita disparar validaciones
  /// de INSERT (como el límite de fincas) al editar filas que ya existen.
  /// Tampoco usamos `upsert` porque evalúa también la RLS de UPDATE y puede
  /// bloquear inserciones nuevas legítimas.
  @override
  Future<void> insertarOActualizar(
    String tabla,
    String id,
    Map<String, dynamic> datos,
  ) async {
    final actualizadas = await _sb
        .from(tabla)
        .update(datos)
        .eq('id', id)
        .select();
    if ((actualizadas as List).isEmpty) {
      // No existía en el servidor -> es una fila nueva.
      await _sb.from(tabla).insert(datos);
    }
  }

  /// Trae del servidor las filas con updated_at > cursor (o todas si es null).
  @override
  Future<List<Map<String, dynamic>>> consultar(
    String tabla,
    DateTime? cursor,
  ) async {
    final base = _sb.from(tabla).select();
    final res = cursor == null
        ? await base.order('updated_at', ascending: true)
        : await base
              .gt('updated_at', cursor.toIso8601String())
              .order('updated_at', ascending: true);
    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<String?> subirFotoFinca({
    required String fincaId,
    required String imagenBase64,
  }) async {
    final res = await _sb.functions.invoke(
      'subir-foto-finca',
      body: {'finca_id': fincaId, 'imagen_base64': imagenBase64},
    );
    final data = res.data;
    return data is Map ? data['url'] as String? : null;
  }
}
