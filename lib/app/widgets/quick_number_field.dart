import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo numérico rápido (p. ej. peso en kg): teclado decimal y filtra la
/// entrada a dígitos, punto y coma (tolera coma como separador decimal).
class QuickNumberField extends StatelessWidget {
  const QuickNumberField({
    super.key,
    required this.controller,
    required this.labelText,
    this.focusNode,
    this.suffixText,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String labelText;
  final String? suffixText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        labelText: labelText,
        suffixText: suffixText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
