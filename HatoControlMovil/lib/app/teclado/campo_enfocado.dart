import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// El campo de texto que tiene el foco en este momento.
///
/// Le habla por la API pública de [EditableTextState] —`userUpdateTextEditingValue`
/// y `performAction`, las mismas que usa el teclado del sistema—, así que los
/// `inputFormatters`, el `onChanged` y el `onSubmitted` de cada campo siguen
/// funcionando igual. Ningún campo de la app tuvo que cambiar para esto.
class CampoEnfocado {
  const CampoEnfocado(this.estado);

  final EditableTextState estado;

  /// Devuelve el campo enfocado, o `null` si el foco no está en un campo de
  /// texto donde se pueda escribir.
  static CampoEnfocado? actual() {
    final foco = FocusManager.instance.primaryFocus;
    final contexto = foco?.context;
    if (contexto == null) return null;
    final estado = contexto.findAncestorStateOfType<EditableTextState>();
    // El foco tiene que ser el del campo, no el de algo que viva adentro de
    // un campo más arriba en el árbol.
    if (estado == null || estado.widget.focusNode != foco) return null;
    if (estado.widget.readOnly) return null;
    return CampoEnfocado(estado);
  }

  EditableText get _campo => estado.widget;

  TextInputType get tipoDeTeclado => _campo.keyboardType;

  bool get esDeVariasLineas => _campo.maxLines != 1;

  /// Qué hace la tecla grande de la esquina: seguir al campo siguiente,
  /// terminar, o meter un salto de línea en las notas.
  TextInputAction get accion =>
      _campo.textInputAction ??
      (esDeVariasLineas ? TextInputAction.newline : TextInputAction.done);

  void escribir(String texto) {
    final valor = estado.textEditingValue;
    final donde = _seleccion(valor);
    _aplicar(
      TextEditingValue(
        text: valor.text.replaceRange(donde.start, donde.end, texto),
        selection: TextSelection.collapsed(offset: donde.start + texto.length),
      ),
    );
  }

  void borrar() {
    final valor = estado.textEditingValue;
    final donde = _seleccion(valor);
    if (!donde.isCollapsed) {
      _aplicar(
        TextEditingValue(
          text: valor.text.replaceRange(donde.start, donde.end, ''),
          selection: TextSelection.collapsed(offset: donde.start),
        ),
      );
      return;
    }
    if (donde.start == 0) return;
    // Un emoji o una letra rara ocupa dos unidades: se borran las dos juntas.
    var paso = 1;
    final unidad = valor.text.codeUnitAt(donde.start - 1);
    if (donde.start >= 2 && unidad >= 0xDC00 && unidad <= 0xDFFF) paso = 2;
    final inicio = donde.start - paso;
    _aplicar(
      TextEditingValue(
        text: valor.text.replaceRange(inicio, donde.start, ''),
        selection: TextSelection.collapsed(offset: inicio),
      ),
    );
  }

  void ejecutarAccion() {
    if (accion == TextInputAction.newline) {
      escribir('\n');
      return;
    }
    estado.performAction(accion);
  }

  /// Si el campo nunca tuvo cursor (recién enfocado por el lector, por
  /// ejemplo), se escribe al final.
  TextSelection _seleccion(TextEditingValue valor) {
    final seleccion = valor.selection;
    if (!seleccion.isValid) {
      return TextSelection.collapsed(offset: valor.text.length);
    }
    return seleccion;
  }

  void _aplicar(TextEditingValue nuevo) {
    estado.userUpdateTextEditingValue(nuevo, SelectionChangedCause.keyboard);
    estado.bringIntoView(nuevo.selection.extent);
  }
}
