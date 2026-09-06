import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Avisa si hay un teclado físico conectado.
///
/// El lector de aretes entra por Bluetooth **como teclado** (perfil HID). En
/// cuanto el sistema ve un teclado físico deja de mostrar el teclado en
/// pantalla: en Android se puede devolver con un ajuste escondido, y en iOS no
/// hay ni ajuste ni API pública para forzarlo. Se apaga en toda la app, hasta
/// en el login. Por eso HatoControl trae su propio teclado y lo enciende
/// exactamente cuando el del sistema se apaga.
class TecladoFisico {
  TecladoFisico({MethodChannel? canal})
    : _canal = canal ?? const MethodChannel(nombreDelCanal),
      _fijo = false;

  /// Un detector que siempre contesta lo mismo, sin hablar con el lado nativo.
  /// Es el que usan los tests: en la máquina de pruebas no hay lector.
  TecladoFisico.fijo(bool valor)
    : _canal = const MethodChannel(nombreDelCanal),
      _fijo = true {
    conectado.value = valor;
    _iniciado = true;
  }

  /// El mismo nombre del lado nativo (Android e iOS).
  static const nombreDelCanal = 'hato_control/teclado_fisico';

  final MethodChannel _canal;
  final bool _fijo;

  /// `true` mientras haya un teclado físico (el lector) conectado.
  final ValueNotifier<bool> conectado = ValueNotifier<bool>(false);

  bool _iniciado = false;

  /// Pregunta una vez y se queda oyendo los avisos del lado nativo.
  Future<void> iniciar() async {
    if (_iniciado) return;
    _iniciado = true;
    // En el navegador el teclado es el de la computadora: no hay nada que
    // suplir, y el canal nativo no existe.
    if (kIsWeb) return;
    _canal.setMethodCallHandler((llamada) async {
      if (llamada.method == 'cambio') conectado.value = llamada.arguments == true;
      return null;
    });
    await refrescar();
  }

  /// Vuelve a preguntar. Se usa al volver del fondo, por si emparejaron o
  /// apagaron el lector con la app dormida.
  Future<void> refrescar() async {
    if (kIsWeb || _fijo) return;
    try {
      conectado.value =
          await _canal.invokeMethod<bool>('hayTecladoFisico') ?? false;
    } on MissingPluginException {
      // Plataforma sin la parte nativa (escritorio, tests): no hay lector.
      conectado.value = false;
    } on PlatformException {
      conectado.value = false;
    }
  }
}

/// El detector de toda la app. Los tests le pasan otro a `TecladoDelApp`.
final tecladoFisico = TecladoFisico();
