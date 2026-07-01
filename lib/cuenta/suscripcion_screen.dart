import 'package:flutter/material.dart';

import '../services.dart';

// ============================================================================
// Contactos de HatoControl que se muestran en la invitación a suscribirse.
// PENDIENTE: reemplazar por los datos reales cuando se tengan.
// ============================================================================
const String kContactoCorreo = 'soporte@hatocontrol.com'; // PENDIENTE
const String kContactoTelefono = '+506 0000 0000'; // PENDIENTE

/// Pantalla que se muestra cuando se venció la prueba gratis de 7 días y la
/// cuenta todavía no tiene una licencia pagada. Invita al usuario a suscribirse
/// y le muestra los contactos de HatoControl. Es reactiva: cuando el admin le
/// asigna un plan pagado (y se sincroniza), la pantalla desaparece sola.
class SuscripcionScreen extends StatelessWidget {
  const SuscripcionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tu prueba gratis terminó',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gracias por probar HatoControl. Para seguir usando la app y '
                  'acceder a tus fincas, suscribite a una licencia.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Contactanos para activar tu licencia',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _Contacto(
                          icono: Icons.email_outlined,
                          texto: kContactoCorreo,
                        ),
                        const SizedBox(height: 10),
                        _Contacto(
                          icono: Icons.phone_outlined,
                          texto: kContactoTelefono,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => sincronizarSiSePuede(),
                  icon: const Icon(Icons.refresh),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                  label: const Text('Ya pagué, actualizar'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: cerrarSesion,
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

class _Contacto extends StatelessWidget {
  const _Contacto({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icono, color: theme.colorScheme.onPrimaryContainer),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            texto,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
