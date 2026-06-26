import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../fincas/fincas_screen.dart';
import '../services.dart';
import 'suscripcion_screen.dart';
import 'suspendida_screen.dart';

/// Decide, una vez con sesión iniciada, qué pantalla mostrar:
///   - cuenta suspendida por el admin (`estado != 'activa'`) → SuspendidaScreen.
///   - prueba gratis vencida y todavía sin licencia pagada → SuscripcionScreen.
///   - en cualquier otro caso (en prueba, pagado o invitado) → la app normal.
/// Es reactivo: cuando el admin la reactiva o le asigna un plan (y se
/// sincroniza), la pantalla cambia sola.
class CuentaGate extends StatefulWidget {
  const CuentaGate({super.key});

  @override
  State<CuentaGate> createState() => _CuentaGateState();
}

class _CuentaGateState extends State<CuentaGate> {
  @override
  void initState() {
    super.initState();
    // Asegurar que bajamos el estado actual de la cuenta.
    syncService.sincronizar();
  }

  String get _usuarioId => supabase.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CuentaRow?>(
      stream: cuentasRepo.observarMiCuenta(_usuarioId),
      builder: (context, snapshot) {
        final cuenta = snapshot.data;
        // Mientras no conocemos la cuenta (aún sin sincronizar), dejamos entrar;
        // FincasScreen dispara el sync y, si corresponde, se bloqueará al
        // recibir el dato.
        if (cuenta != null) {
          if (cuenta.estado != 'activa') {
            return const SuspendidaScreen();
          }
          // Prueba gratis vencida sin licencia pagada. Los invitados (plan
          // 'invitado') nunca tienen prueba (pruebaTermina null), así que no
          // entran acá: colaboran sin límite de tiempo.
          final fin = cuenta.pruebaTermina;
          if (cuenta.plan != 'invitado' &&
              fin != null &&
              fin.isBefore(DateTime.now())) {
            return const SuscripcionScreen();
          }
        }
        return const FincasScreen();
      },
    );
  }
}
