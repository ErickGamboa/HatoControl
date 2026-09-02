import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/fincas_repository.dart';
import '../services.dart';
import 'foto_picker.dart';

/// Editar una finca (nombre y foto) es igual en el teléfono y en la
/// computadora, así que el diálogo y el guardado viven acá y los dos clientes
/// llaman al mismo código.
Future<void> flujoEditarFinca(
  BuildContext context, {
  required FincaRow finca,
  FincasRepository? repositorio,
}) async {
  final repo = repositorio ?? fincasRepo;
  final resultado = await showDialog<(String, String?)>(
    context: context,
    builder: (_) => DialogoEditarFinca(finca: finca),
  );
  if (resultado == null) return;
  final (nombre, nuevaFotoPath) = resultado;
  if (nombre.isEmpty) return;

  await repo.editarFinca(
    fincaId: finca.id,
    nombre: nombre,
    nuevaFotoLocalPath: nuevaFotoPath,
  );
  sincronizarSiSePuede();
}

class DialogoEditarFinca extends StatefulWidget {
  const DialogoEditarFinca({super.key, required this.finca});

  final FincaRow finca;

  @override
  State<DialogoEditarFinca> createState() => _DialogoEditarFincaState();
}

class _DialogoEditarFincaState extends State<DialogoEditarFinca> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.finca.nombre,
  );
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
      return imagenFotoLocal(_nuevaFoto!);
    }
    final local = widget.finca.fotoLocalPath;
    if (local != null && existeFotoLocal(local)) {
      return imagenFotoLocal(local);
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
          Icon(
            Icons.add_a_photo_outlined,
            size: 36,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'Agregar foto',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
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
          // En web no hay archivos locales: la foto solo se ve desde el
          // servidor y no se puede cambiar (D-09).
          if (soportaFotoLocal || (widget.finca.fotoUrl?.isNotEmpty ?? false))
            GestureDetector(
              onTap: soportaFotoLocal ? _cambiarFoto : null,
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
