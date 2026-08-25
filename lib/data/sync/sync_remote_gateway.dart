import 'package:supabase_flutter/supabase_flutter.dart';

/// Marcador de sincronización compuesto: fecha del último registro bajado
/// más su id, para desempatar filas con el mismo `updated_at` (evita que una
/// quede invisible para siempre detrás de un `updated_at.gt` estricto). Los
/// dos campos viajan juntos: [id] solo es null cuando [updatedAt] también lo
/// es (tabla nunca sincronizada).
class SyncCursor {
  const SyncCursor({this.updatedAt, this.id});

  static const vacio = SyncCursor();

  final DateTime? updatedAt;
  final String? id;

  bool get esVacio => updatedAt == null;
}

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

  /// Filas con `(updated_at, [idColumna]) > cursor` en orden ascendente por
  /// `(updated_at, [idColumna])` — ese orden es lo que permite a
  /// [SyncService] tratar "el cursor" como "la última fila aplicada" en vez
  /// de rastrear un máximo. [idColumna] es `id` para casi todas las tablas,
  /// salvo `planes` cuya llave natural es `codigo` (no tiene columna `id`).
  Future<List<Map<String, dynamic>>> consultar(
    String tabla,
    SyncCursor cursor, {
    String idColumna = 'id',
  });

  Future<String?> subirFotoFinca({
    required String fincaId,
    required String imagenBase64,
  });
}

class SupabaseSyncRemoteGateway implements SyncRemoteGateway {
  SupabaseSyncRemoteGateway([SupabaseClient? supabase])
    : _sb = supabase ?? Supabase.instance.client;

  final SupabaseClient _sb;

  // Tiempo límite POR PETICIÓN. Antes el límite era uno solo para TODA la
  // sincronización (20 s en SyncService), así que un día entero de campo se
  // cortaba a la mitad y dejaba filas pendientes. Por petición, una conexión
  // colgada se corta sola, pero una conexión lenta pero viva termina el
  // trabajo por más registros que haya.
  //
  // Cortar una escritura es seguro: `insertarOActualizar` hace UPDATE
  // primero, así que si la escritura llegó al servidor pero la respuesta se
  // perdió, el reintento la actualiza en vez de duplicarla.
  static const _limiteEscritura = Duration(seconds: 30);
  static const _limiteLectura = Duration(seconds: 60);
  static const _limiteFoto = Duration(minutes: 2);

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
        .select()
        .timeout(_limiteEscritura);
    if ((actualizadas as List).isEmpty) {
      // No existía en el servidor -> es una fila nueva.
      await _sb.from(tabla).insert(datos).timeout(_limiteEscritura);
    }
  }

  /// Trae del servidor las filas con `(updated_at, id) > cursor` (o todas si
  /// [cursor] está vacío), ordenadas por `(updated_at, id)` ascendente. El
  /// filtro compuesto evita perder una fila que comparte `updated_at` exacto
  /// con el borde del cursor (ver [SyncCursor]).
  @override
  Future<List<Map<String, dynamic>>> consultar(
    String tabla,
    SyncCursor cursor, {
    String idColumna = 'id',
  }) async {
    var query = _sb.from(tabla).select();
    if (!cursor.esVacio) {
      final ts = cursor.updatedAt!.toIso8601String();
      query = query.or(
        'updated_at.gt.$ts,and(updated_at.eq.$ts,$idColumna.gt.${cursor.id})',
      );
    }
    final res = await query
        .order('updated_at', ascending: true)
        .order(idColumna, ascending: true)
        .timeout(_limiteLectura);
    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<String?> subirFotoFinca({
    required String fincaId,
    required String imagenBase64,
  }) async {
    final res = await _sb.functions
        .invoke(
          'subir-foto-finca',
          body: {'finca_id': fincaId, 'imagen_base64': imagenBase64},
        )
        .timeout(_limiteFoto);
    final data = res.data;
    return data is Map ? data['url'] as String? : null;
  }
}
