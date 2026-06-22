import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/local/database.dart';
import '../services.dart';
import 'foto_picker.dart';

/// Detalle de una finca: muestra y permite crear sus lotes, y editar la finca.
class FincaDetalleScreen extends StatefulWidget {
  const FincaDetalleScreen({super.key, required this.finca});

  final FincaRow finca;

  @override
  State<FincaDetalleScreen> createState() => _FincaDetalleScreenState();
}

class _FincaDetalleScreenState extends State<FincaDetalleScreen> {
  Future<void> _crearLoteDialog() async {
    final nombreCtrl = TextEditingController();
    final numeroCtrl = TextEditingController();

    final creado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo lote'),
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
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (creado != true) return;
    final nombre = nombreCtrl.text.trim();
    if (nombre.isEmpty) return;
    final numero = int.tryParse(numeroCtrl.text.trim());

    await lotesRepo.crearLote(
      fincaId: widget.finca.id,
      nombre: nombre,
      numero: numero,
    );
    syncService.sincronizar();
  }

  Future<void> _editarFincaDialog(FincaRow finca) async {
    final resultado = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => _DialogoEditarFinca(finca: finca),
    );
    if (resultado == null) return;
    final (nombre, nuevaFotoPath) = resultado;
    if (nombre.isEmpty) return;

    await fincasRepo.editarFinca(
      fincaId: finca.id,
      nombre: nombre,
      nuevaFotoLocalPath: nuevaFotoPath,
    );
    syncService.sincronizar();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FincaRow?>(
      stream: fincasRepo.observarFinca(widget.finca.id),
      initialData: widget.finca,
      builder: (context, snapshot) {
        final finca = snapshot.data ?? widget.finca;
        return Scaffold(
          appBar: AppBar(
            title: Text(finca.nombre),
            actions: [
              IconButton(
                tooltip: 'Editar finca',
                icon: const Icon(Icons.edit),
                onPressed: () => _editarFincaDialog(finca),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _crearLoteDialog,
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
                return _VacioLotes(onCrear: _crearLoteDialog);
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
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Próximo paso: abrir el lote (animales).
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Diálogo para editar una finca: nombre + (opcional) reemplazar la foto.
/// Devuelve (nombre, nuevaFotoLocalPath?). nuevaFotoLocalPath null = no cambió.
class _DialogoEditarFinca extends StatefulWidget {
  const _DialogoEditarFinca({required this.finca});

  final FincaRow finca;

  @override
  State<_DialogoEditarFinca> createState() => _DialogoEditarFincaState();
}

class _DialogoEditarFincaState extends State<_DialogoEditarFinca> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.finca.nombre);
  String? _nuevaFoto;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _cambiarFoto() async {
    final path = await elegirFotoFinca(context);
    if (path != null && mounted) setState(() => _nuevaFoto = path);
  }

  Widget _fotoActual() {
    if (_nuevaFoto != null) {
      return Image.file(File(_nuevaFoto!), fit: BoxFit.cover);
    }
    final local = widget.finca.fotoLocalPath;
    if (local != null && File(local).existsSync()) {
      return Image.file(File(local), fit: BoxFit.cover);
    }
    final url = widget.finca.fotoUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.cover);
    }
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined,
              size: 36, color: theme.colorScheme.outline),
          const SizedBox(height: 8),
          Text('Agregar foto',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Editar finca'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _cambiarFoto,
            child: Container(
              height: 140,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: _fotoActual(),
            ),
          ),
          TextButton.icon(
            onPressed: _cambiarFoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Cambiar foto'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre de la finca',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (_ctrl.text.trim(), _nuevaFoto)),
          child: const Text('Guardar'),
        ),
      ],
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
            Icon(Icons.grid_view_outlined,
                size: 72, color: theme.colorScheme.outline),
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
