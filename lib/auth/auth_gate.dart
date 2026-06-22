import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';
import '../cuenta/cuenta_gate.dart';

/// Decide qué pantalla mostrar según el estado de la sesión:
/// - Si hay sesión activa  -> HomeScreen
/// - Si no hay sesión      -> LoginScreen
///
/// Escucha los cambios de autenticación en tiempo real, así que al iniciar o
/// cerrar sesión la app cambia de pantalla automáticamente.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const CuentaGate();
        }
        return const LoginScreen();
      },
    );
  }
}
