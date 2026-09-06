import Flutter
import GameController
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Se guarda para que no lo recoja el recolector: adentro viven el canal y
  /// los avisos de conexion del teclado.
  private var tecladoFisico: TecladoFisicoNativo?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TecladoFisico") {
      tecladoFisico = TecladoFisicoNativo(messenger: registrar.messenger())
    }
  }
}

/// Le avisa a Flutter si hay un teclado fisico conectado.
///
/// El lector de aretes entra por Bluetooth como teclado (HID). En cuanto iOS ve
/// un teclado fisico esconde el teclado en pantalla en todo el sistema, y no hay
/// ajuste ni API publica para devolverlo: por eso la app trae el suyo (ver
/// TecladoDelApp en Dart) y lo prende justo cuando el del sistema se apaga.
///
/// Vive en este archivo a proposito: agregar un .swift nuevo obliga a tocar el
/// proyecto de Xcode, y la parte de iOS se arma en la Mac prestada.
final class TecladoFisicoNativo {
  /// El mismo nombre que en teclado_fisico.dart.
  private static let canalNombre = "hato_control/teclado_fisico"

  private let canal: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    canal = FlutterMethodChannel(name: Self.canalNombre, binaryMessenger: messenger)
    canal.setMethodCallHandler { [weak self] llamada, resultado in
      switch llamada.method {
      case "hayTecladoFisico":
        resultado(self?.hayTecladoFisico() ?? false)
      default:
        resultado(FlutterMethodNotImplemented)
      }
    }
    if #available(iOS 14.0, *) {
      let centro = NotificationCenter.default
      centro.addObserver(
        self, selector: #selector(avisar),
        name: .GCKeyboardDidConnect, object: nil)
      centro.addObserver(
        self, selector: #selector(avisar),
        name: .GCKeyboardDidDisconnect, object: nil)
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    canal.setMethodCallHandler(nil)
  }

  @objc private func avisar() {
    // Al desconectar, GCKeyboard.coalesced todavia trae el teclado que se fue
    // durante el aviso; se pregunta en el siguiente ciclo.
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      self.canal.invokeMethod("cambio", arguments: self.hayTecladoFisico())
    }
  }

  private func hayTecladoFisico() -> Bool {
    if #available(iOS 14.0, *) {
      return GCKeyboard.coalesced != nil
    }
    return false
  }
}
