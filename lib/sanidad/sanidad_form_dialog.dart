import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/repositories/sanidad_repository.dart';

/// Datos del formulario de un evento sanitario.
typedef DatosEventoSanitario = ({
  String tipo,
  String producto,
  String? dosis,
  String? observaciones,
  double? costo,
});

/// Diálogo reutilizable para registrar vacunas, medicamentos, etc.
Future<DatosEventoSanitario?> mostrarFormularioSanidad(
  BuildContext context, {
  required String titulo,
  List<String> sugerenciasProducto = const [],
  String tipoInicial = TipoEventoSanitario.medicamento,
}) {
  return showDialog<DatosEventoSanitario>(
    context: context,
    builder: (ctx) => _FormularioSanitarioDialog(
      titulo: titulo,
      sugerenciasProducto: sugerenciasProducto,
      tipoInicial: tipoInicial,
    ),
  );
}

class _FormularioSanitarioDialog extends StatefulWidget {
  const _FormularioSanitarioDialog({
    required this.titulo,
    required this.sugerenciasProducto,
    required this.tipoInicial,
  });

  final String titulo;
  final List<String> sugerenciasProducto;
  final String tipoInicial;

  @override
  State<_FormularioSanitarioDialog> createState() =>
      _FormularioSanitarioDialogState();
}

class _FormularioSanitarioDialogState
    extends State<_FormularioSanitarioDialog> {
  late String _tipo = widget.tipoInicial;
  final _productoCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();

  @override
  void dispose() {
    _productoCtrl.dispose();
    _dosisCtrl.dispose();
    _obsCtrl.dispose();
    _costoCtrl.dispose();
    super.dispose();
  }

  void _usarSugerencia(String producto) {
    setState(() => _productoCtrl.text = producto);
  }

  void _guardar() {
    final producto = _productoCtrl.text.trim();
    if (producto.isEmpty) return;
    final costoRaw = _costoCtrl.text.trim().replaceAll(',', '.');
    final costo = costoRaw.isEmpty ? null : double.tryParse(costoRaw);
    Navigator.pop(context, (
      tipo: _tipo,
      producto: producto,
      dosis: _dosisCtrl.text.trim().isEmpty ? null : _dosisCtrl.text.trim(),
      observaciones: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      costo: costo,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final t in TipoEventoSanitario.todos)
                  DropdownMenuItem(
                    value: t,
                    child: Text(TipoEventoSanitario.etiqueta(t)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _tipo = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _productoCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Producto / medicamento',
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.sugerenciasProducto.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in widget.sugerenciasProducto.take(6))
                    ActionChip(
                      label: Text(s, overflow: TextOverflow.ellipsis),
                      onPressed: () => _usarSugerencia(s),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _dosisCtrl,
              decoration: const InputDecoration(
                labelText: 'Dosis (opcional)',
                border: OutlineInputBorder(),
                hintText: 'ej. 5 ml',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costoCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Costo ₡ (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _obsCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
