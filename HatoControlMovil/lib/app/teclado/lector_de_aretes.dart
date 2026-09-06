import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Recoge la lectura del lector de aretes **a nivel de pantalla**.
///
/// El lector entra por Bluetooth como un teclado, y un teclado solo escribe
/// donde está el foco. Escuchando acá, la lectura entra igual aunque el
/// ganadero haya tocado un botón, la lista, o nada: los campos de la app no
/// toman el foco solos, justamente para que el teclado no salte al abrir cada
/// pantalla.
///
/// Solo observa: nunca se queda con las teclas (siempre devuelve `false` al
/// motor de Flutter). El hueco que queda a propósito es el campo del peso: ahí
/// las teclas son del ganadero y Flutter no permite quitárselas.
class LectorDeAretes {
  LectorDeAretes({
    required this.campo,
    required this.puedeLeer,
    required this.alTerminarLaLectura,
  });

  /// Dónde se escribe el arete leído.
  final TextEditingController campo;

  /// Si en este momento la pantalla debe recoger la lectura.
  final bool Function() puedeLeer;

  /// Qué hacer cuando el lector cierra la lectura con Enter.
  final VoidCallback alTerminarLaLectura;

  /// Cuándo llegó la última tecla. Si pasó más de [_pausaLectura] se toma como
  /// una lectura nueva y se reemplaza el arete anterior: en la manga lo que
  /// importa es el animal que se tiene enfrente.
  DateTime? _ultimaTecla;
  static const _pausaLectura = Duration(milliseconds: 400);

  void escuchar() => HardwareKeyboard.instance.addHandler(_alLlegarUnaTecla);

  void soltar() => HardwareKeyboard.instance.removeHandler(_alLlegarUnaTecla);

  bool _alLlegarUnaTecla(KeyEvent evento) {
    if (evento is! KeyDownEvent) return false;
    if (!puedeLeer()) return false;

    final tecla = evento.logicalKey;
    if (tecla == LogicalKeyboardKey.enter ||
        tecla == LogicalKeyboardKey.numpadEnter) {
      if (campo.text.isEmpty) return false;
      _ultimaTecla = null;
      // Se avisa DESPUÉS de que este Enter termine de repartirse. Si se
      // moviera el foco ya, el mismo Enter caería en el campo siguiente, que
      // lo tomaría como "listo" y dispararía el registro a medio llenar.
      scheduleMicrotask(alTerminarLaLectura);
      return false;
    }

    final digito = _digitoDe(evento);
    if (digito == null) return false;

    final ahora = DateTime.now();
    final anterior = _ultimaTecla;
    final lecturaNueva =
        anterior == null || ahora.difference(anterior) > _pausaLectura;
    _ultimaTecla = ahora;
    campo.text = lecturaNueva ? digito : '${campo.text}$digito';
    return false;
  }

  /// El dígito que trae la tecla, o null si no es un dígito. Se mira primero
  /// el carácter y si no viene se cae a la tecla: hay lectores que mandan el
  /// código sin carácter.
  static String? _digitoDe(KeyEvent evento) {
    final c = evento.character;
    if (c != null && c.length == 1) {
      final u = c.codeUnitAt(0);
      if (u >= 0x30 && u <= 0x39) return c;
    }
    return _teclasDigito[evento.logicalKey];
  }

  static final _teclasDigito = <LogicalKeyboardKey, String>{
    LogicalKeyboardKey.digit0: '0',
    LogicalKeyboardKey.digit1: '1',
    LogicalKeyboardKey.digit2: '2',
    LogicalKeyboardKey.digit3: '3',
    LogicalKeyboardKey.digit4: '4',
    LogicalKeyboardKey.digit5: '5',
    LogicalKeyboardKey.digit6: '6',
    LogicalKeyboardKey.digit7: '7',
    LogicalKeyboardKey.digit8: '8',
    LogicalKeyboardKey.digit9: '9',
    LogicalKeyboardKey.numpad0: '0',
    LogicalKeyboardKey.numpad1: '1',
    LogicalKeyboardKey.numpad2: '2',
    LogicalKeyboardKey.numpad3: '3',
    LogicalKeyboardKey.numpad4: '4',
    LogicalKeyboardKey.numpad5: '5',
    LogicalKeyboardKey.numpad6: '6',
    LogicalKeyboardKey.numpad7: '7',
    LogicalKeyboardKey.numpad8: '8',
    LogicalKeyboardKey.numpad9: '9',
  };
}
