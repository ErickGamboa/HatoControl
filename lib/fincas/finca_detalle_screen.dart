import 'dart:io';

import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../lotes/lotes_screen.dart';
import '../pesaje/pesaje_screen.dart';
import '../services.dart';
import 'foto_picker.dart';

/// Detalle de una finca: menú de opciones (botonera) + editar la finca.
class FincaDetalleScreen extends StatefulWidget {
  const FincaDetalleScreen({super.key, required this.finca});

  final FincaRow finca;

  @override
  State<FincaDetalleScreen> createState() => _FincaDetalleScreenState();
}

class _FincaDetalleScreenState extends State<FincaDetalleScreen> {
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

  void _abrir(Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
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
          body: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: [
              _BotonOpcion(
                icon: Icons.scale,
                label: 'Pesaje',
                onTap: () => _abrir(PesajeScreen(finca: finca)),
              ),
              _BotonOpcion(
                icon: Icons.fence,
                label: 'Lotes',
                onTap: () => _abrir(LotesScreen(finca: finca)),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Botón cuadrado con ícono y etiqueta para el menú de la finca.
class _BotonOpcion extends StatelessWidget {
  const _BotonOpcion({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
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
