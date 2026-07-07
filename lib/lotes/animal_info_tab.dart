import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../services.dart';

/// Pestaña de información general del animal.
class AnimalInfoTab extends StatelessWidget {
  const AnimalInfoTab({super.key, required this.animal});

  final AnimalRow animal;

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<LoteRow?>(
      future: (db.select(
        db.lotes,
      )..where((t) => t.id.equals(animal.loteId))).getSingleOrNull(),
      builder: (context, snapshot) {
        final lote = snapshot.data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FilaInfo('Identificador', animal.identificador),
            _FilaInfo('Lote actual', lote?.nombre ?? '—'),
            _FilaInfo('Fecha de ingreso', _fecha(animal.createdAt)),
            if (animal.pendiente)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Cambios pendientes de sincronizar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              etiqueta,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
