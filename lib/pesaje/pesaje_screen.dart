import 'package:flutter/material.dart';

import '../data/local/database.dart';

/// Módulo de pesaje (en construcción). Aquí irán los pesajes de los animales
/// y los cálculos de aumento.
class PesajeScreen extends StatelessWidget {
  const PesajeScreen({super.key, required this.finca});

  final FincaRow finca;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pesaje')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.scale,
                  size: 72, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text('Pesaje', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Esta sección estará disponible pronto.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
