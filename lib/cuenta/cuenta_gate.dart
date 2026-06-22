import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../fincas/fincas_screen.dart';
import '../services.dart';
import 'suspendida_screen.dart';

/// Decide, una vez con sesión iniciada, si mostrar la app normal o la pantalla
/// de cuenta suspendida. La cuenta está activa solo si `estado == 'activa'`;
/// cualquier otro valor la bloquea. Es reactivo: si el admin la suspende o la
/// reactiva, al sincronizar la pantalla cambia sola.
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
        // FincasScreen dispara el sync y, si está suspendida, se bloqueará al
        // recibir el dato.
        if (cuenta != null && cuenta.estado != 'activa') {
          return const SuspendidaScreen();
        }
        return const FincasScreen();
      },
    );
  }
}
