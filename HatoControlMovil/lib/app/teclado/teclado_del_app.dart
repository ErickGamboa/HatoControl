import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'campo_enfocado.dart';
import 'teclado_del_sistema.dart';
import 'teclado_en_pantalla.dart';

/// Envuelve toda la app y le pone el teclado de HatoControl encima cuando el
/// del sistema no va a salir.
///
/// **Por qué existe.** El lector de aretes se conecta por Bluetooth como
/// teclado (HID). En cuanto el sistema ve un teclado físico esconde el teclado
/// en pantalla —en iOS en toda la app y sin forma de forzarlo, hasta en el
/// login— y el ganadero se queda sin poder escribir nada a mano.
///
/// **Cómo funciona.** Se cuelga del [FocusManager]: cuando el foco cae en un
/// campo de texto y el sistema tiene escondido el suyo, dibuja el teclado
/// propio y le miente al [MediaQuery] de abajo diciéndole que el teclado del
/// sistema está arriba (`viewInsets`), que es lo que ya hace subir los
/// `Scaffold`, los diálogos y los formularios de la app. Ningún campo tuvo que
/// cambiar.
///
/// **Nunca salen los dos teclados.** Tres cosas lo sostienen:
/// 1. [TecladoDelSistema] contesta si el del sistema va a salir, no solo si hay
///    lector: en Android eso incluye el ajuste «mostrar teclado en pantalla».
/// 2. Al enfocar un campo se espera [_esperaAntesDeMostrar] antes de dibujar el
///    propio, que es lo que tarda el del sistema en subir. Sin esa espera se
///    verían los dos por un parpadeo en cualquier equipo donde el ajuste esté
///    prendido o el fabricante lo ignore.
/// 3. Si aun así el sistema tapa la pantalla desde abajo
///    ([_umbralTecladoDelSistema]), el propio se quita del medio.
///
/// Cuando **no** hay lector conectado no hace absolutamente nada: sale el
/// teclado del sistema de siempre, con su dictado, su autocorrector y su
/// gestor de contraseñas.
class TecladoDelApp extends StatefulWidget {
  TecladoDelApp({super.key, required this.child, TecladoDelSistema? detector})
    : detector = detector ?? tecladoDelSistema;

  final Widget child;

  /// Inyectable para los tests.
  final TecladoDelSistema detector;

  /// Lo que se le da al teclado del sistema para asomarse antes de dibujar el
  /// propio. Es imperceptible al escribir y ahorra el parpadeo de los dos.
  static const esperaAntesDeMostrar = Duration(milliseconds: 250);

  /// Cuánto tiene que tapar el sistema desde abajo para dar por hecho que ya
  /// está mostrando *su* teclado. Con teclado físico iOS deja una barrita de
  /// atajos de unos 50, y Android nada; un teclado de verdad pasa de 200.
  static const umbralTecladoDelSistema = 120.0;

  @override
  State<TecladoDelApp> createState() => _TecladoDelAppState();
}

class _TecladoDelAppState extends State<TecladoDelApp>
    with WidgetsBindingObserver {
  CampoEnfocado? _campo;

  /// El ganadero apretó «ocultar»: se respeta hasta que cambie de campo.
  bool _ocultadoAMano = false;

  /// Ya pasó la espera de [TecladoDelApp.esperaAntesDeMostrar] para este campo.
  bool _pasoLaEspera = false;
  Timer? _espera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_cambioElFoco);
    widget.detector.escondido.addListener(_repintar);
    widget.detector.iniciar();
  }

  @override
  void dispose() {
    _espera?.cancel();
    widget.detector.escondido.removeListener(_repintar);
    FocusManager.instance.removeListener(_cambioElFoco);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    // Pudieron emparejar o apagar el lector con la app dormida.
    if (estado == AppLifecycleState.resumed) widget.detector.refrescar();
  }

  void _repintar() {
    if (mounted) setState(() {});
  }

  void _cambioElFoco() {
    // El foco puede moverse mientras se está construyendo un frame (una
    // pantalla que pide foco al aparecer). Buscar el campo ahí adentro es
    // ilegal, así que se espera al final del frame.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => _cambioElFoco());
      return;
    }
    if (!mounted) return;
    final campo = CampoEnfocado.actual();
    // El FocusManager avisa por muchas cosas; solo importa cambiar de campo.
    if (campo?.estado == _campo?.estado) return;

    _espera?.cancel();
    setState(() {
      _campo = campo;
      _ocultadoAMano = false;
      _pasoLaEspera = false;
    });
    if (campo == null) return;
    _espera = Timer(TecladoDelApp.esperaAntesDeMostrar, () {
      if (mounted) setState(() => _pasoLaEspera = true);
    });
  }

  bool get _seMuestra =>
      widget.detector.escondido.value &&
      _campo != null &&
      _pasoLaEspera &&
      !_ocultadoAMano;

  /// El teclado sale del tipo que ya declara cada campo: los aretes piden
  /// `number`, los pesos y precios `numberWithOptions(decimal: true)`, y todo
  /// lo demás letras.
  DisposicionTeclado get _disposicion {
    final tipo = _campo?.tipoDeTeclado;
    if (tipo == null) return DisposicionTeclado.letras;
    if (tipo.index == TextInputType.number.index) {
      return tipo.decimal == true
          ? DisposicionTeclado.decimal
          : DisposicionTeclado.digitos;
    }
    if (tipo.index == TextInputType.phone.index) {
      return DisposicionTeclado.digitos;
    }
    return DisposicionTeclado.letras;
  }

  String get _etiquetaAccion => switch (_campo?.accion) {
    TextInputAction.next => 'Siguiente',
    TextInputAction.search => 'Buscar',
    TextInputAction.send => 'Enviar',
    TextInputAction.newline => 'Salto',
    _ => 'Listo',
  };

  /// El teclado propio tiene que ser **más bajo que el del sistema**.
  ///
  /// Las pantallas de la app están armadas para el hueco que deja el teclado de
  /// Android/iOS (en un teléfono normal, entre el 35 % y el 40 % de la
  /// pantalla). Cuando el propio pasaba de eso, la lista del día de Trabajo se
  /// quedaba sin espacio y los diálogos —el de Dietas, por ejemplo— dejaban
  /// componentes fuera. Con estas medidas ocupa cerca del 30 %.
  double _altoDelTeclado(BuildContext context) {
    final alto = MediaQuery.sizeOf(context).height;
    // Teclas grandes igual: 46 de mínimo es más que el mínimo que pide
    // Material para tocar con el dedo.
    final porFila = (alto * 0.30 / filasDelTeclado).clamp(46.0, 62.0);
    return porFila * filasDelTeclado + 8;
  }

  @override
  Widget build(BuildContext context) {
    final medios = MediaQuery.of(context);
    if (!_seMuestra) return widget.child;

    // Lo que ya tapa el sistema desde abajo. En Android se puede prender a mano
    // «mostrar teclado en pantalla» aunque haya teclado físico, y algún
    // fabricante podría ignorar el ajuste: si el del sistema está arriba, este
    // se quita del medio.
    final tapadoPorElSistema = medios.viewInsets.bottom;
    if (tapadoPorElSistema > TecladoDelApp.umbralTecladoDelSistema) {
      return widget.child;
    }

    final alto = _altoDelTeclado(context);

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        Positioned.fill(
          child: MediaQuery(
            data: medios.copyWith(
              viewInsets: medios.viewInsets.copyWith(
                bottom: tapadoPorElSistema + alto,
              ),
            ),
            child: widget.child,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          // Con teclado físico iOS deja abajo una barrita de atajos («Scan
          // Text»): el teclado propio va encima de ella, no debajo.
          bottom: tapadoPorElSistema,
          // La app entera cierra el teclado al tocar cualquier espacio vacío
          // (ver el `builder` del MaterialApp). Sin esto, tocar entre dos
          // teclas apagaría el campo.
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: TecladoEnPantalla(
              disposicion: _disposicion,
              etiquetaAccion: _etiquetaAccion,
              alto: alto,
              alEscribir: (texto) => _campo?.escribir(texto),
              alBorrar: () => _campo?.borrar(),
              alAceptar: () => _campo?.ejecutarAccion(),
              alOcultar: () => setState(() => _ocultadoAMano = true),
            ),
          ),
        ),
      ],
    );
  }
}
