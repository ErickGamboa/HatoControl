import 'package:flutter/material.dart';

import '../config/support_config.dart';

/// Card with HatoControl support contact details for account-related screens.
class SupportContactCard extends StatelessWidget {
  const SupportContactCard({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            _Contacto(icono: Icons.email_outlined, texto: SupportConfig.email),
            if (SupportConfig.phone case final phone?) ...[
              const SizedBox(height: 10),
              _Contacto(icono: Icons.phone_outlined, texto: phone),
            ],
          ],
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
