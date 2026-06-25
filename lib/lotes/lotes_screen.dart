import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/local/database.dart';
import '../services.dart';

/// Lista y creación de lotes de una finca.
class LotesScreen extends StatelessWidget {
  const LotesScreen({super.key, required this.finca});

  final FincaRow finca;

  /// Diálogo para crear o editar un lote. Si [lote] es null, crea uno nuevo.
  Future<void> _loteDialog(BuildContext context, {LoteRow? lote}) async {
    final esEdicion = lote != null;
    final nombreCtrl = TextEditingController(text: lote?.nombre ?? '');
    final numeroCtrl =
        TextEditingController(text: lote?.numero?.toString() ?? '');

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(esEdicion ? 'Editar lote' : 'Nuevo lote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre del lote',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numeroCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Número (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
    final numero = int.tryParse(numeroCtrl.text.trim());

    if (esEdicion) {
      await lotesRepo.editarLote(
        loteId: lote.id,
        nombre: nombre,
        numero: numero,
      );
    } else {
      await lotesRepo.crearLote(
        fincaId: finca.id,
        nombre: nombre,
        numero: numero,
      );
    }
    syncService.sincronizar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lotes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _loteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Lote'),
      ),
      body: StreamBuilder<List<LoteRow>>(
        stream: lotesRepo.observarLotes(finca.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final lotes = snapshot.data ?? const [];
          if (lotes.isEmpty) {
            return _VacioLotes(onCrear: () => _loteDialog(context));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: lotes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final l = lotes[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(l.numero?.toString() ?? '–'),
                  ),
                  title: Text(l.nombre),
                  subtitle: l.pendiente
                      ? const Text('Pendiente de sincronizar')
                      : null,
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: () => _loteDialog(context, lote: l),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VacioLotes extends StatelessWidget {
  const _VacioLotes({required this.onCrear});

  final VoidCallback onCrear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/iconos/lotes.png',
              width: 72,
              height: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('Esta finca no tiene lotes',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Creá el primer lote con el botón de abajo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
