import 'package:flutter/material.dart';

import '../services.dart';

/// Pantalla que se muestra cuando la cuenta del usuario está suspendida.
/// Puede iniciar sesión, pero no accede a sus datos hasta que se reactive.
class SuspendidaScreen extends StatelessWidget {
  const SuspendidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tu cuenta está suspendida',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Por el momento no podés acceder a tus fincas. '
                  'Comunicate con soporte para reactivar tu cuenta.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => syncService.sincronizar(),
                  icon: const Icon(Icons.refresh),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  label: const Text('Actualizar'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => supabase.auth.signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
