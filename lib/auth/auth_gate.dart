import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/database.dart';
import 'login_screen.dart';
import '../cuenta/cuenta_gate.dart';
import '../services.dart';

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
        return ValueListenableBuilder<SesionLocalRow?>(
          valueListenable: sesionLocalRepo.sesion,
          builder: (context, sesionLocal, _) {
            final session = Supabase.instance.client.auth.currentSession;
            if (session != null) {
              return CuentaGate(usuarioId: session.user.id, sinConexion: false);
            }
            if (sesionLocal?.offlineActiva == true) {
              return CuentaGate(
                usuarioId: sesionLocal!.usuarioId,
                sinConexion: true,
              );
            }
            return const LoginScreen();
          },
        );
      },
    );
  }
}
