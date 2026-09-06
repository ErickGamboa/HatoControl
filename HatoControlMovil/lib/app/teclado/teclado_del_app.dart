import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'campo_enfocado.dart';
import 'teclado_en_pantalla.dart';
import 'teclado_fisico.dart';

/// Envuelve toda la app y le pone el teclado de HatoControl encima cuando el
/// del sistema no va a salir.
///
/// **Por qué existe.** El lector de aretes se conecta por Bluetooth como
/// teclado (HID). En cuanto el sistema ve un teclado físico esconde el teclado
/// en pantalla —en iOS en toda la app y sin forma de forzarlo, hasta en el
/// login— y el ganadero se queda sin poder escribir nada a mano.
///
/// **Cómo funciona.** Se cuelga del [FocusManager]: cuando el foco cae en un
/// campo de texto y hay un teclado físico conectado, dibuja el teclado propio
/// y le miente al [MediaQuery] de abajo diciéndole que el teclado del sistema
/// está arriba (`viewInsets`), que es lo que ya hace subir los `Scaffold`, los
/// diálogos y los formularios de la app. Ningún campo tuvo que cambiar.
///
/// Cuando **no** hay lector conectado no hace absolutamente nada: sale el
/// teclado del sistema de siempre, con su dictado, su autocorrector y su
/// gestor de contraseñas.
class TecladoDelApp extends StatefulWidget {
  TecladoDelApp({super.key, required this.child, TecladoFisico? detector})
    : detector = detector ?? tecladoFisico;

  final Widget child;

  /// Inyectable para los tests.
  final TecladoFisico detector;

  @override
  State<TecladoDelApp> createState() => _TecladoDelAppState();
}

class _TecladoDelAppState extends State<TecladoDelApp>
    with WidgetsBindingObserver {
  CampoEnfocado? _campo;

  /// El ganadero apretó «ocultar»: se respeta hasta que cambie de campo.
  bool _ocultadoAMano = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_cambioElFoco);
    widget.detector.conectado.addListener(_repintar);
    widget.detector.iniciar();
  }

  @override
  void dispose() {
    widget.detector.conectado.removeListener(_repintar);
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
    setState(() {
      _campo = campo;
      _ocultadoAMano = false;
    });
  }

  bool get _seMuestra =>
      widget.detector.conectado.value && _campo != null && !_ocultadoAMano;

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

  double _altoDelTeclado(BuildContext context) {
    final filas = filasDe(_disposicion);
    final alto = MediaQuery.sizeOf(context).height;
    // Teclas grandes, pero nunca tapando media pantalla.
    final porFila = (alto * 0.44 / filas).clamp(46.0, 68.0);
    return porFila * filas + 8;
  }

  /// Cuánto tiene que tapar el sistema desde abajo para dar por hecho que ya
  /// está mostrando *su* teclado. Con teclado físico iOS deja una barrita de
  /// atajos de unos 50, y Android nada; un teclado de verdad pasa de 200.
  static const _umbralTecladoDelSistema = 120.0;

  @override
  Widget build(BuildContext context) {
    final medios = MediaQuery.of(context);
    if (!_seMuestra) return widget.child;

    // Lo que ya tapa el sistema desde abajo. En Android se puede prender a mano
    // «mostrar teclado en pantalla» aunque haya teclado físico: si el ganadero
    // lo hizo, manda el del sistema y este se quita del medio.
    final tapadoPorElSistema = medios.viewInsets.bottom;
    if (tapadoPorElSistema > _umbralTecladoDelSistema) return widget.child;

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
