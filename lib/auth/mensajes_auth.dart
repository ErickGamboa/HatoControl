import 'package:supabase_flutter/supabase_flutter.dart';

/// Traduce los errores de autenticación de Supabase (que vienen en inglés) a
/// mensajes claros en español para mostrar al usuario.
String traducirErrorAuth(Object e) {
  if (e is AuthException) {
    // Primero por código (lo más confiable).
    switch (e.code) {
      case 'invalid_credentials':
        return 'Correo o contraseña incorrectos.';
      case 'email_not_confirmed':
        return 'Tenés que confirmar tu correo antes de entrar.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Ese correo ya está registrado. Iniciá sesión.';
      case 'weak_password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Demasiados intentos. Esperá unos minutos y volvé a probar.';
      case 'validation_failed':
        return 'Revisá los datos ingresados.';
    }
    // Respaldo: por el texto del mensaje en inglés.
    final m = e.message.toLowerCase();
    if (m.contains('invalid login')) return 'Correo o contraseña incorrectos.';
    if (m.contains('already registered')) {
      return 'Ese correo ya está registrado. Iniciá sesión.';
    }
    if (m.contains('email not confirmed')) {
      return 'Tenés que confirmar tu correo antes de entrar.';
    }
    if (m.contains('password')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return 'No se pudo iniciar sesión. Intentá de nuevo.';
  }

  // Errores que no son de Auth (típicamente red).
  final s = e.toString().toLowerCase();
  if (s.contains('socketexception') ||
      s.contains('failed host') ||
      s.contains('clientexception') ||
      s.contains('network')) {
    return 'No hay conexión a internet. Revisá tu conexión e intentá de nuevo.';
  }
  return 'Ocurrió un error. Intentá de nuevo.';
}
