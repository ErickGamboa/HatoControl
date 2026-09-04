import 'package:flutter/material.dart';
import 'package:hato_control/auth/login_screen.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'escritorio_shell.dart';

/// Mismo portero que la app del teléfono (hay sesión → adentro), pero llevando
/// a las pantallas de escritorio. La licencia no decide quién entra: solo
/// limita cuántas fincas puede tener la cuenta, y eso lo aplica el servidor al
/// crear una finca.
class EscritorioGate extends StatelessWidget {
  const EscritorioGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, _) {
        return ValueListenableBuilder<SesionLocalRow?>(
          valueListenable: sesionLocalRepo.sesion,
          builder: (context, sesionLocal, _) {
            final sesion = supabase.auth.currentSession;
            if (sesion != null) {
              return _CuentaEscritorio(
                usuarioId: sesion.user.id,
                correo: sesion.user.email,
                sinConexion: false,
              );
            }
            if (sesionLocal?.offlineActiva == true) {
              return _CuentaEscritorio(
                usuarioId: sesionLocal!.usuarioId,
                correo: sesionLocal.email,
                sinConexion: true,
              );
            }
            // En la computadora se muestra el mismo login y nada más: ni
            // panel de marca ni relleno al lado. Ya se centra solo.
            return const LoginScreen();
          },
        );
      },
    );
  }
}

/// En el teléfono el sync lo dispara la lista de fincas al abrirse; acá la
/// lista vive dentro del shell, así que el empujón lo damos desde aquí.
class _CuentaEscritorio extends StatefulWidget {
  const _CuentaEscritorio({
    required this.usuarioId,
    required this.correo,
    required this.sinConexion,
  });

  final String usuarioId;
  final String? correo;
  final bool sinConexion;

  @override
  State<_CuentaEscritorio> createState() => _CuentaEscritorioState();
}

class _CuentaEscritorioState extends State<_CuentaEscritorio> {
  @override
  void initState() {
    super.initState();
    sincronizarSiSePuede();
  }

  @override
  Widget build(BuildContext context) {
    return EscritorioShell(
      usuarioId: widget.usuarioId,
      correo: widget.correo,
      sinConexion: widget.sinConexion,
    );
  }
}
