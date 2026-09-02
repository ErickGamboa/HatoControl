import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/local/database.dart';
import 'analisis_financiero_screen.dart';
import 'analisis_pesos_screen.dart';

/// Puerta del módulo Análisis: dos caminos, sin menús escondidos.
///
/// La diferencia con la ficha del animal es a propósito: la ficha muestra el
/// detalle de UN animal que se tiene enfrente; acá se compara y se decide
/// (lote contra lote, animal contra animal, en qué se va la plata).
class AnalisisScreen extends StatelessWidget {
  const AnalisisScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
  });

  final FincaRow finca;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análisis')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HatoSpacing.lg),
          children: [
            _OpcionAnalisis(
              key: const ValueKey('analisis.pesos'),
              icono: Icons.monitor_weight_outlined,
              titulo: 'Análisis de pesos',
              detalle: 'Ganancia de peso por lote y por animal',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      AnalisisPesosScreen(finca: finca, usuarioId: usuarioId),
                ),
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            _OpcionAnalisis(
              key: const ValueKey('analisis.financiero'),
              icono: Icons.payments_outlined,
              titulo: 'Análisis financiero',
              detalle: 'Costos, utilidad y rentabilidad por animal',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AnalisisFinancieroScreen(
                    finca: finca,
                    usuarioId: usuarioId,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcionAnalisis extends StatelessWidget {
  const _OpcionAnalisis({
    super.key,
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  /// null = todavía no está listo; se muestra apagado y avisa por qué.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listo = onTap != null;
    final color = listo ? theme.colorScheme.primary : theme.colorScheme.outline;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(HatoSpacing.lg),
          child: Row(
            children: [
              Icon(icono, size: 40, color: color),
              const SizedBox(width: HatoSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: listo ? null : theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listo ? detalle : 'Disponible próximamente',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (listo) Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
