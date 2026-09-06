import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Avisa si el sistema tiene **escondido** su teclado en pantalla.
///
/// El lector de aretes entra por Bluetooth como teclado (perfil HID), y en
/// cuanto el sistema ve un teclado físico deja de mostrar el suyo: en toda la
/// app, hasta en el login. HatoControl pone entonces el propio (ver
/// `TecladoDelApp`), y para que **nunca** salgan los dos hay que preguntar por
/// lo que de verdad importa —si el del sistema va a salir o no—, no solo si hay
/// un lector conectado:
///
/// - **Android** esconde el suyo con un teclado físico conectado, salvo que el
///   usuario prenda «mostrar teclado en pantalla» (`show_ime_with_hard_keyboard`).
///   El lado nativo mira las dos cosas y avisa si cambian.
/// - **iOS** siempre lo esconde con un teclado físico conectado, y no hay
///   ajuste ni API pública para devolverlo.
class TecladoDelSistema {
  TecladoDelSistema({MethodChannel? canal})
    : _canal = canal ?? const MethodChannel(nombreDelCanal),
      _fijo = false;

  /// Un detector que siempre contesta lo mismo, sin hablar con el lado nativo.
  /// Es el que usan los tests: en la máquina de pruebas no hay lector.
  TecladoDelSistema.fijo(bool valor)
    : _canal = const MethodChannel(nombreDelCanal),
      _fijo = true {
    escondido.value = valor;
    _iniciado = true;
  }

  /// El mismo nombre del lado nativo (Android e iOS).
  static const nombreDelCanal = 'hato_control/teclado_del_sistema';

  final MethodChannel _canal;
  final bool _fijo;

  /// `true` mientras el sistema no vaya a mostrar su teclado en pantalla.
  final ValueNotifier<bool> escondido = ValueNotifier<bool>(false);

  bool _iniciado = false;

  /// Pregunta una vez y se queda oyendo los avisos del lado nativo.
  Future<void> iniciar() async {
    if (_iniciado) return;
    _iniciado = true;
    // En el navegador el teclado es el de la computadora: no hay nada que
    // suplir, y el canal nativo no existe.
    if (kIsWeb) return;
    _canal.setMethodCallHandler((llamada) async {
      if (llamada.method == 'cambio') escondido.value = llamada.arguments == true;
      return null;
    });
    await refrescar();
  }

  /// Vuelve a preguntar. Se usa al volver del fondo, por si emparejaron o
  /// apagaron el lector con la app dormida.
  Future<void> refrescar() async {
    if (kIsWeb || _fijo) return;
    try {
      escondido.value =
          await _canal.invokeMethod<bool>('estaEscondido') ?? false;
    } on MissingPluginException {
      // Plataforma sin la parte nativa (escritorio, tests): manda el sistema.
      escondido.value = false;
    } on PlatformException {
      escondido.value = false;
    }
  }
}

/// El detector de toda la app. Los tests le pasan otro a `TecladoDelApp`.
final tecladoDelSistema = TecladoDelSistema();
