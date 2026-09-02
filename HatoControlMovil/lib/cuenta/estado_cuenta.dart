import '../data/local/database.dart';

/// En qué situación está la cuenta del usuario. Lo deciden igual el teléfono
/// ([CuentaGate]) y la computadora (la barra lateral de la web), así que la
/// regla vive en un solo lugar.
enum EstadoCuentaApp {
  /// En prueba, pagada o invitada: entra a la app normal.
  normal,

  /// El admin la suspendió (`estado != 'activa'`).
  suspendida,

  /// Se acabó la prueba gratis y todavía no hay licencia pagada.
  pruebaVencida,
}

/// Mientras no conocemos la cuenta (aún sin sincronizar) se deja entrar: la
/// lista de fincas dispara el sync y, si corresponde, se bloquea al recibir
/// el dato.
EstadoCuentaApp evaluarEstadoCuenta(CuentaRow? cuenta) {
  if (cuenta == null) return EstadoCuentaApp.normal;
  if (cuenta.estado != 'activa') return EstadoCuentaApp.suspendida;
  // Los invitados (plan 'invitado') nunca tienen prueba (pruebaTermina null),
  // así que no entran acá: colaboran sin límite de tiempo.
  final fin = cuenta.pruebaTermina;
  if (cuenta.plan != 'invitado' &&
      fin != null &&
      fin.isBefore(DateTime.now())) {
    return EstadoCuentaApp.pruebaVencida;
  }
  return EstadoCuentaApp.normal;
}
