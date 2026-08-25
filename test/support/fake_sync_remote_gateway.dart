import 'package:hato_control/data/sync/sync_remote_gateway.dart';

class RemoteWrite {
  const RemoteWrite({
    required this.tabla,
    required this.id,
    required this.datos,
  });

  final String tabla;
  final String id;
  final Map<String, dynamic> datos;
}

/// Fake en memoria de [SyncRemoteGateway] para tests de [SyncService] sin
/// credenciales ni red. Replica el filtro compuesto `(updated_at, id) >
/// cursor` del gateway real (ver `SupabaseSyncRemoteGateway.consultar`) para
/// que los tests de desempate en timestamps iguales sean representativos.
class FakeSyncRemoteGateway implements SyncRemoteGateway {
  FakeSyncRemoteGateway({this.tieneUsuario = true, this.tieneSesion = false});

  @override
  final bool tieneUsuario;

  @override
  final bool tieneSesion;

  final descargas = <String, List<Map<String, dynamic>>>{};
  final subidas = <RemoteWrite>[];
  final fallarSubidas = <String>{};
  final fallarConsultas = <String>{};

  /// `'tabla:id'` que falla la primera vez y funciona en el reintento, para
  /// simular la red que se corta a mitad de una subida grande.
  final fallarSubidasUnaVez = <String>{};

  /// Cuántas veces se llamó a [insertarOActualizar] por `'tabla:id'`,
  /// contando los intentos fallidos.
  final intentosPorFila = <String, int>{};

  @override
  Future<void> insertarOActualizar(
    String tabla,
    String id,
    Map<String, dynamic> datos,
  ) async {
    final clave = '$tabla:$id';
    intentosPorFila[clave] = (intentosPorFila[clave] ?? 0) + 1;
    if (fallarSubidasUnaVez.remove(clave)) {
      throw StateError('fallo remoto simulado (solo la primera vez)');
    }
    if (fallarSubidas.contains(clave)) {
      throw StateError('fallo remoto simulado');
    }
    subidas.add(RemoteWrite(tabla: tabla, id: id, datos: Map.of(datos)));
  }

  @override
  Future<List<Map<String, dynamic>>> consultar(
    String tabla,
    SyncCursor cursor, {
    String idColumna = 'id',
  }) async {
    if (fallarConsultas.contains(tabla)) {
      throw StateError('fallo remoto simulado al consultar $tabla');
    }
    final filas = descargas[tabla] ?? const <Map<String, dynamic>>[];

    bool pasaCursor(Map<String, dynamic> fila) {
      if (cursor.esVacio) return true;
      final u = DateTime.parse(fila['updated_at'] as String);
      if (u.isAfter(cursor.updatedAt!)) return true;
      if (u.isAtSameMomentAs(cursor.updatedAt!)) {
        return (fila[idColumna] as String).compareTo(cursor.id!) > 0;
      }
      return false;
    }

    final filtradas =
        filas.where(pasaCursor).map(Map<String, dynamic>.of).toList()
          ..sort((a, b) {
            final fechaA = DateTime.parse(a['updated_at'] as String);
            final fechaB = DateTime.parse(b['updated_at'] as String);
            final cmp = fechaA.compareTo(fechaB);
            if (cmp != 0) return cmp;
            return (a[idColumna] as String).compareTo(b[idColumna] as String);
          });
    return filtradas;
  }

  @override
  Future<String?> subirFotoFinca({
    required String fincaId,
    required String imagenBase64,
  }) async {
    return null;
  }
}
