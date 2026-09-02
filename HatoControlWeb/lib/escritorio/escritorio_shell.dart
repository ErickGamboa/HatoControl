import 'package:flutter/material.dart';
import 'package:hato_control/analisis/analisis_screen.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/dietas/dietas_screen.dart';
import 'package:hato_control/fincas/compartir_finca_screen.dart';
import 'package:hato_control/fincas/editar_finca_flujo.dart';
import 'package:hato_control/gastos_fijos/gastos_fijos_screen.dart';
import 'package:hato_control/lotes/lotes_screen.dart';
import 'package:hato_control/pesaje/pesaje_screen.dart';
import 'package:hato_control/sanidad/sanidad_screen.dart';
import 'package:hato_control/services.dart';
import 'package:hato_control/venta/venta_screen.dart';

import 'barra_lateral.dart';
import 'barra_superior.dart';
import 'contenido_escritorio.dart';
import 'panel_finca.dart';
import 'panel_fincas.dart';
import 'secciones.dart';

/// El marco de la versión de computadora: menú fijo a la izquierda, barra de
/// estado arriba y el módulo abierto en el centro.
///
/// Las pantallas del centro son **las mismas** de la app del teléfono, sin
/// tocarles nada. Cada sección se abre dentro de su propio [Navigator], así
/// que cuando un módulo abre otra pantalla encima (por ejemplo Lotes → los
/// animales de un lote → la ficha de un animal) todo eso pasa dentro del
/// área de contenido, sin tapar el menú.
class EscritorioShell extends StatefulWidget {
  const EscritorioShell({
    super.key,
    required this.usuarioId,
    required this.sinConexion,
    required this.correo,
  });

  final String usuarioId;
  final bool sinConexion;
  final String? correo;

  @override
  State<EscritorioShell> createState() => _EscritorioShellState();
}

class _EscritorioShellState extends State<EscritorioShell> {
  FincaRow? _finca;
  SeccionEscritorio _seccion = SeccionEscritorio.inicio;

  /// Llave del Navigator del contenido. Se cambia por una nueva cada vez que
  /// se entra a otra sección: así Flutter tira el Navigator viejo y arma uno
  /// limpio, y el módulo se abre desde cero, como en el teléfono.
  GlobalKey<NavigatorState> _navegadorContenido = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    permisosFinca.limpiar();
    super.dispose();
  }

  /// Al entrar a una finca se empieza a seguir el rol del usuario, igual que
  /// hace el home de finca en el teléfono: los invitados son de solo lectura
  /// y los módulos esconden sus acciones de escritura.
  void _abrirFinca(FincaRow finca) {
    permisosFinca.seguir(fincasRepo.observarMiRol(finca.id, widget.usuarioId));
    setState(() {
      _finca = finca;
      _seccion = SeccionEscritorio.inicio;
      _navegadorContenido = GlobalKey<NavigatorState>();
    });
  }

  void _volverAFincas() {
    permisosFinca.limpiar();
    setState(() {
      _finca = null;
      _seccion = SeccionEscritorio.inicio;
      _navegadorContenido = GlobalKey<NavigatorState>();
    });
  }

  void _irA(SeccionEscritorio seccion) {
    if (seccion == _seccion) return;
    setState(() {
      _seccion = seccion;
      _navegadorContenido = GlobalKey<NavigatorState>();
    });
  }

  List<String> get _migaDePan {
    final finca = _finca;
    if (finca == null) return const ['Mis fincas'];
    if (_seccion == SeccionEscritorio.inicio) {
      return ['Mis fincas', finca.nombre];
    }
    return ['Mis fincas', finca.nombre, _seccion.etiqueta];
  }

  Widget _pantallaDeSeccion(FincaRow finca) {
    switch (_seccion) {
      case SeccionEscritorio.inicio:
        return PanelFinca(
          finca: finca,
          alElegirSeccion: _irA,
          alCompartir: widget.sinConexion
              ? null
              : () => _abrirEncima(
                  CompartirFincaScreen(
                    finca: finca,
                    usuarioId: widget.usuarioId,
                  ),
                ),
          alEditar: () => flujoEditarFinca(context, finca: finca),
        );
      case SeccionEscritorio.pesaje:
        return ContenidoEscritorio(
          child: PesajeScreen(finca: finca, usuarioId: widget.usuarioId),
        );
      case SeccionEscritorio.lotes:
        return ContenidoEscritorio(
          child: LotesScreen(finca: finca, usuarioId: widget.usuarioId),
        );
      case SeccionEscritorio.sanidad:
        return ContenidoEscritorio(child: SanidadScreen(finca: finca));
      case SeccionEscritorio.dietas:
        return ContenidoEscritorio(child: DietasScreen(finca: finca));
      case SeccionEscritorio.venta:
        return ContenidoEscritorio(
          child: VentaScreen(finca: finca, usuarioId: widget.usuarioId),
        );
      case SeccionEscritorio.gastosFijos:
        return ContenidoEscritorio(child: GastosFijosScreen(finca: finca));
      case SeccionEscritorio.analisis:
        return ContenidoEscritorio(
          child: AnalisisScreen(finca: finca, usuarioId: widget.usuarioId),
        );
    }
  }

  /// Abre una pantalla encima de la sección actual, dentro del área de
  /// contenido (no encima del menú).
  void _abrirEncima(Widget pantalla) {
    _navegadorContenido.currentState?.push(
      MaterialPageRoute(builder: (_) => ContenidoEscritorio(child: pantalla)),
    );
  }

  Widget _contenido() {
    final finca = _finca;
    if (finca == null) {
      return PanelFincas(
        usuarioId: widget.usuarioId,
        sinConexion: widget.sinConexion,
        alAbrirFinca: _abrirFinca,
      );
    }
    return Navigator(
      key: _navegadorContenido,
      // Rearmar el Navigator al cambiar de sección deja cada módulo con su
      // propia pila limpia, como si se acabara de abrir en el teléfono.
      onGenerateRoute: (_) => MaterialPageRoute(
        settings: RouteSettings(name: '${finca.id}/${_seccion.name}'),
        builder: (_) => _pantallaDeSeccion(finca),
      ),
      observers: [
        // Si un módulo se cierra a sí mismo (por ejemplo al terminar una
        // venta), el área de contenido quedaría vacía: se vuelve al inicio de
        // la finca en vez de dejar la pantalla en blanco.
        _ObservadorContenidoVacio(
          () => _irA(SeccionEscritorio.inicio),
          activo: () => _seccion != SeccionEscritorio.inicio,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: permisosFinca.soloLectura,
              builder: (context, soloLectura, _) => BarraLateral(
                finca: _finca,
                seccion: _seccion,
                soloLectura: soloLectura,
                correo: widget.correo,
                alElegirSeccion: _irA,
                alIrAFincas: _volverAFincas,
                alCerrarSesion: cerrarSesion,
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant,
            ),
            Expanded(
              child: Column(
                children: [
                  BarraSuperior(
                    migaDePan: _migaDePan,
                    sinConexion: widget.sinConexion,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  Expanded(child: _contenido()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avisa cuando el área de contenido se quedó sin pantallas.
class _ObservadorContenidoVacio extends NavigatorObserver {
  _ObservadorContenidoVacio(this.alQuedarVacio, {required this.activo});

  final VoidCallback alQuedarVacio;
  final bool Function() activo;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute == null && activo()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => alQuedarVacio());
    }
  }
}
