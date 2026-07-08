import 'package:flutter/material.dart';

/// Campo para escanear/ingresar un identificador (p. ej. arete): toma foco al
/// aparecer y selecciona todo el texto al recibir foco, para que escribir
/// encima reemplace el valor anterior en vez de agregarlo.
class ScanField extends StatefulWidget {
  const ScanField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    this.prefixIcon,
    this.keyboardType = TextInputType.number,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<ScanField> createState() => _ScanFieldState();
}

class _ScanFieldState extends State<ScanField> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_seleccionarTodo);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.focusNode.requestFocus();
      });
    }
  }

  void _seleccionarTodo() {
    final texto = widget.controller.text;
    if (widget.focusNode.hasFocus && texto.isNotEmpty) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: texto.length,
      );
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_seleccionarTodo);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
