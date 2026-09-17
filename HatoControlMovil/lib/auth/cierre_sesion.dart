import '../data/local/database.dart';
import '../data/repositories/sesion_local_repository.dart';
import '../data/sync/sync_service.dart';

/// Cierra la sesión dejando la copia local **siempre** limpia.
///
/// Devuelve cuánto quedaba sin subir: `0` si cerró, o la cantidad de
/// registros pendientes si NO cerró (y entonces no tocó nada).
///
/// Por qué no se puede salir con trabajo sin subir: los marcadores de bajada
/// son del aparato, no de la persona (ver [AppDatabase.borrarDatosLocales]).
/// Si al salir se conserva la copia local, la cuenta que entre después hereda
/// esos marcadores y sus propias filas viejas no bajan nunca — su finca
/// existe sana en la nube y no aparece en la lista. Borrar siempre al salir
/// corta ese problema de raíz; para que borrar no cueste un día de campo,
/// primero hay que subirlo.
///
/// [descartarPendientes] es la salida de emergencia, y solo se usa si la
/// persona aceptó perder ese trabajo: una fila que el servidor rechaza
/// siempre no puede dejar a nadie encerrado en la app para siempre.
///
/// Está aparte de `services.dart` para poder probarlo con una base en memoria
/// (los singletons de la app no se pueden cambiar en un test).
Future<int> cerrarSesionEn({
  required AppDatabase db,
  required SyncService sync,
  required SesionLocalRepository sesiones,
  required Future<void> Function() signOut,
  bool descartarPendientes = false,
}) async {
  final pendientes = await sync.contarPendientes();
  if (pendientes > 0 && !descartarPendientes) return pendientes;

  await sesiones.borrar();
  await db.borrarDatosLocales();
  try {
    await signOut();
  } catch (_) {
    // Sin conexión puede fallar el signOut remoto; la sesión local ya quedó
    // cerrada para este dispositivo.
  }
  return 0;
}
