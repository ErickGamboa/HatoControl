import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../fincas/fincas_screen.dart';
import '../services.dart';
import 'estado_cuenta.dart';
import 'suscripcion_screen.dart';
import 'suspendida_screen.dart';

/// Decide, una vez con sesión iniciada, qué pantalla mostrar:
///   - cuenta suspendida por el admin (`estado != 'activa'`) → SuspendidaScreen.
///   - prueba gratis vencida y todavía sin licencia pagada → SuscripcionScreen.
///   - en cualquier otro caso (en prueba, pagado o invitado) → la app normal.
/// Es reactivo: cuando el admin la reactiva o le asigna un plan (y se
/// sincroniza), la pantalla cambia sola.
class CuentaGate extends StatefulWidget {
  const CuentaGate({
    super.key,
    required this.usuarioId,
    required this.sinConexion,
  });

  final String usuarioId;
  final bool sinConexion;

  @override
  State<CuentaGate> createState() => _CuentaGateState();
}

class _CuentaGateState extends State<CuentaGate> {
  @override
  void initState() {
    super.initState();
    // Asegurar que bajamos el estado actual de la cuenta.
    sincronizarSiSePuede();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CuentaRow?>(
      stream: cuentasRepo.observarMiCuenta(widget.usuarioId),
      builder: (context, snapshot) {
        switch (evaluarEstadoCuenta(snapshot.data)) {
          case EstadoCuentaApp.suspendida:
            return const SuspendidaScreen();
          case EstadoCuentaApp.pruebaVencida:
            return const SuscripcionScreen();
          case EstadoCuentaApp.normal:
            break;
        }
        return FincasScreen(
          usuarioId: widget.usuarioId,
          sinConexion: widget.sinConexion,
        );
      },
    );
  }
}
