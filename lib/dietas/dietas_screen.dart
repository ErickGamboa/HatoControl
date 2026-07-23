import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../services.dart';

/// Catálogo de dietas de una finca: crear, editar y ver costo por animal/día.
class DietasScreen extends StatelessWidget {
  DietasScreen({super.key, required this.finca, DietasRepository? repo})
    : repo = repo ?? dietasRepo;

  final FincaRow finca;
  final DietasRepository repo;

  Future<void> _dietaDialog(BuildContext context, {DietaRow? dieta}) async {
    final esEdicion = dieta != null;
    final nombreCtrl = TextEditingController(text: dieta?.nombre ?? '');
    final descCtrl = TextEditingController(text: dieta?.descripcion ?? '');
    final costoCtrl = TextEditingController(
      text: dieta != null ? dieta.costoAnimalDia.toString() : '',
    );
    final ingredientesCtrl = TextEditingController();

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEdicion ? 'Editar dieta' : 'Nueva dieta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costoCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                decoration: const InputDecoration(
                  labelText:
                      'Costo total/animal/día (₡) si no hay ingredientes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'O ingredientes (nombre · ₡/animal/día), uno por línea:\n'
                'Pasto, 50\nConcentrado, 120',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ingredientesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Ingredientes (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(esEdicion ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );

    if (guardar != true) return;
    final nombre = nombreCtrl.text.trim();
    if (nombre.isEmpty) return;

    final ings = <({String nombre, double costoAnimalDia})>[];
    for (final line in ingredientesCtrl.text.split('\n')) {
      final parts = line.split(',');
      if (parts.length < 2) continue;
      final n = parts.first.trim();
      final c = double.tryParse(
        parts.sublist(1).join(',').trim().replaceAll(',', '.'),
      );
      if (n.isEmpty || c == null || c < 0) continue;
      ings.add((nombre: n, costoAnimalDia: c));
    }

    final costo = ings.isNotEmpty
        ? ings.fold<double>(0, (s, i) => s + i.costoAnimalDia)
        : double.tryParse(costoCtrl.text.replaceAll(',', '.'));
    if (costo == null || costo < 0) return;

    if (esEdicion) {
      await repo.editarDieta(
        dietaId: dieta.id,
        nombre: nombre,
        descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        costoAnimalDia: costo,
      );
      if (ings.isNotEmpty) {
        await repo.reemplazarIngredientes(
          dietaId: dieta.id,
          ingredientes: ings,
        );
      }
    } else {
      await repo.crearDieta(
        fincaId: finca.id,
        nombre: nombre,
        descripcion: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        costoAnimalDia: costo,
        ingredientes: ings,
      );
    }
    sincronizarSiSePuede();
  }

  String _fmtCosto(double c) =>
      c == c.roundToDouble() ? c.toInt().toString() : c.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dietas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _dietaDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Dieta'),
      ),
      body: StreamBuilder<List<DietaRow>>(
        stream: repo.observarDietas(finca.id),
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
                  'Esta finca no tiene dietas.\nCreá la primera con el botón de abajo.',
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
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final d = dietas[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      d.nombre.isNotEmpty ? d.nombre[0].toUpperCase() : '?',
                    ),
                  ),
                  title: Text(d.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (d.descripcion != null && d.descripcion!.isNotEmpty)
                        Text(d.descripcion!),
                      Text(
                        '₡${_fmtCosto(d.costoAnimalDia)} / animal / día',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (d.pendiente)
                        Text(
                          'Pendiente de sincronizar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Editar dieta',
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _dietaDialog(context, dieta: d),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
