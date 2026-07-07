import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../services.dart';

/// Pestaña de dietas recibidas por el animal vía sus lotes (D-05).
class AnimalDietasTab extends StatelessWidget {
  AnimalDietasTab({
    super.key,
    required this.animal,
    DietasRepository? dietasRepository,
  }) : dietasRepository = dietasRepository ?? dietasRepo;

  final AnimalRow animal;
  final DietasRepository dietasRepository;

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<DietaRecibidaAnimal>>(
      stream: dietasRepository.observarDietasRecibidas(animal.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final dietas = snapshot.data ?? const [];
        if (dietas.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Este animal no tiene dietas registradas en sus lotes.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: dietas.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final d = dietas[i];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
                title: Text(d.dietaNombre),
                subtitle: Text(
                  'Lote: ${d.loteNombre}\n'
                  '${_fecha(d.desde)} → ${d.hasta != null ? _fecha(d.hasta!) : 'vigente'}\n'
                  '₡${d.costoAnimalDia == d.costoAnimalDia.roundToDouble() ? d.costoAnimalDia.toInt() : d.costoAnimalDia.toStringAsFixed(0)} / animal / día',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
