import 'package:flutter/material.dart';

import '../theme.dart';

/// Qué juego de teclas se dibuja.
enum DisposicionTeclado {
  /// Aretes: solo dígitos.
  digitos,

  /// Pesos, precios, cantidades: dígitos y coma decimal.
  decimal,

  /// Correos, nombres, notas: letras, números y acentos.
  letras,
}

/// Todas las disposiciones tienen cuatro filas a propósito: el teclado no debe
/// ser más alto que el del sistema, porque las pantallas de la app están
/// pensadas para el hueco que deja ese. El pad numérico llevaba cinco y en
/// Trabajo dejaba la lista del día sin espacio.
const filasDelTeclado = 4;

/// El teclado que trae la app.
///
/// Existe porque con el lector de aretes conectado por Bluetooth el sistema
/// esconde el suyo (ver `TecladoFisico`). Teclas grandes y bien separadas, que
/// es lo que pide la app: se usa en la manga, a una mano y a veces con guantes.
class TecladoEnPantalla extends StatefulWidget {
  const TecladoEnPantalla({
    super.key,
    required this.disposicion,
    required this.etiquetaAccion,
    required this.alEscribir,
    required this.alBorrar,
    required this.alAceptar,
    required this.alOcultar,
    required this.alto,
  });

  final DisposicionTeclado disposicion;

  /// Texto de la tecla grande: «Listo», «Siguiente»…
  final String etiquetaAccion;

  final ValueChanged<String> alEscribir;
  final VoidCallback alBorrar;
  final VoidCallback alAceptar;
  final VoidCallback alOcultar;
  final double alto;

  @override
  State<TecladoEnPantalla> createState() => _TecladoEnPantallaState();
}

class _TecladoEnPantallaState extends State<TecladoEnPantalla> {
  bool _mayusculas = false;
  bool _simbolos = false;

  @override
  void didUpdateWidget(TecladoEnPantalla anterior) {
    super.didUpdateWidget(anterior);
    // Al cambiar de campo se vuelve a empezar en letras minúsculas.
    if (anterior.disposicion != widget.disposicion) {
      _mayusculas = false;
      _simbolos = false;
    }
  }

  void _escribirLetra(String letra) {
    widget.alEscribir(_mayusculas ? letra.toUpperCase() : letra);
    if (_mayusculas) setState(() => _mayusculas = false);
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Material(
      color: colores.surfaceContainerHighest,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: widget.alto,
          child: Padding(
            padding: const EdgeInsets.all(HatoSpacing.xs),
            child: Column(children: _filas().map(_fila).toList()),
          ),
        ),
      ),
    );
  }

  Widget _fila(List<Widget> teclas) => Expanded(child: Row(children: teclas));

  List<List<Widget>> _filas() => switch (widget.disposicion) {
    DisposicionTeclado.digitos => _numerico(conComa: false),
    DisposicionTeclado.decimal => _numerico(conComa: true),
    DisposicionTeclado.letras => _simbolos ? _simbolosYNumeros() : _letras(),
  };

  // --- Numérico -------------------------------------------------------------

  /// Los dígitos en la cuadrícula de siempre y las teclas de servicio en la
  /// columna de la derecha, para que quepa en cuatro filas.
  List<List<Widget>> _numerico({required bool conComa}) => [
    [_digito('1'), _digito('2'), _digito('3'), _borrar()],
    [_digito('4'), _digito('5'), _digito('6'), _ocultar()],
    [
      _digito('7'),
      _digito('8'),
      _digito('9'),
      conComa ? _digito(',') : const _Hueco(),
    ],
    [_digito('0', flex: 3), _aceptar(flex: 5)],
  ];

  // --- Letras ---------------------------------------------------------------

  static const _fila1 = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'];
  static const _fila2 = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ñ'];
  static const _fila3 = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];

  List<List<Widget>> _letras() => [
    [for (final l in _fila1) _letra(l)],
    [for (final l in _fila2) _letra(l)],
    [
      _especial(
        etiqueta: 'Mayus',
        resaltada: _mayusculas,
        flex: 3,
        alTocar: () => setState(() => _mayusculas = !_mayusculas),
      ),
      for (final l in _fila3) _letra(l),
      _borrar(flex: 3),
    ],
    [
      _especial(
        etiqueta: '123',
        flex: 3,
        alTocar: () => setState(() => _simbolos = true),
      ),
      _ocultar(flex: 2),
      _especial(
        etiqueta: 'espacio',
        flex: 8,
        alTocar: () => widget.alEscribir(' '),
      ),
      _tecla('.', flex: 2),
      _aceptar(flex: 5),
    ],
  ];

  static const _numeros = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const _signos = ['@', '.', ',', '-', '_', '/', ':', '(', ')', '%'];
  // Los acentos y la apertura de signos importan más, en español, que los
  // símbolos raros que traen otros teclados en esta fila.
  static const _acentos = ['á', 'é', 'í', 'ó', 'ú', '¿', '¡', '°'];

  List<List<Widget>> _simbolosYNumeros() => [
    [for (final c in _numeros) _tecla(c)],
    [for (final c in _signos) _tecla(c)],
    [for (final c in _acentos) _tecla(c), _borrar(flex: 4)],
    [
      _especial(
        etiqueta: 'ABC',
        flex: 3,
        alTocar: () => setState(() => _simbolos = false),
      ),
      _ocultar(flex: 2),
      _especial(
        etiqueta: 'espacio',
        flex: 8,
        alTocar: () => widget.alEscribir(' '),
      ),
      _aceptar(flex: 5),
    ],
  ];

  // --- Piezas ---------------------------------------------------------------

  Widget _letra(String letra) => _Tecla(
    etiqueta: _mayusculas ? letra.toUpperCase() : letra,
    alTocar: () => _escribirLetra(letra),
  );

  Widget _tecla(String texto, {int flex = 2}) =>
      _Tecla(etiqueta: texto, flex: flex, alTocar: () => widget.alEscribir(texto));

  Widget _digito(String texto, {int flex = 2}) => _Tecla(
    etiqueta: texto,
    flex: flex,
    grande: true,
    alTocar: () => widget.alEscribir(texto),
  );

  Widget _borrar({int flex = 2}) => _Tecla(
    etiqueta: _borrarIcono,
    flex: flex,
    tenue: true,
    repetible: true,
    semantica: 'Borrar',
    alTocar: widget.alBorrar,
  );

  Widget _ocultar({int flex = 2}) => _Tecla(
    etiqueta: _ocultarIcono,
    flex: flex,
    tenue: true,
    semantica: 'Ocultar el teclado',
    alTocar: widget.alOcultar,
  );

  Widget _aceptar({required int flex}) => _Tecla(
    etiqueta: widget.etiquetaAccion,
    flex: flex,
    principal: true,
    alTocar: widget.alAceptar,
  );

  Widget _especial({
    required String etiqueta,
    required int flex,
    required VoidCallback alTocar,
    bool resaltada = false,
  }) => _Tecla(
    etiqueta: etiqueta,
    flex: flex,
    tenue: !resaltada,
    resaltada: resaltada,
    alTocar: alTocar,
  );
}

const _borrarIcono = '⌫';
const _ocultarIcono = '⌄';

/// Un espacio del ancho de una tecla, para que la fila no se descuadre.
class _Hueco extends StatelessWidget {
  const _Hueco();

  @override
  Widget build(BuildContext context) =>
      const Expanded(flex: 2, child: SizedBox());
}

class _Tecla extends StatefulWidget {
  const _Tecla({
    required this.etiqueta,
    required this.alTocar,
    this.flex = 2,
    this.grande = false,
    this.tenue = false,
    this.principal = false,
    this.resaltada = false,
    this.repetible = false,
    this.semantica,
  });

  final String etiqueta;
  final VoidCallback alTocar;
  final int flex;

  /// Las teclas del pad numérico llevan el número más grande.
  final bool grande;
  final bool tenue;
  final bool principal;
  final bool resaltada;

  /// Si se deja apretada, repite (solo el borrar).
  final bool repetible;
  final String? semantica;

  @override
  State<_Tecla> createState() => _TeclaState();
}

class _TeclaState extends State<_Tecla> {
  bool _repitiendo = false;

  void _empezarARepetir() {
    if (!widget.repetible) return;
    _repitiendo = true;
    _repetir(const Duration(milliseconds: 400));
  }

  void _repetir(Duration espera) {
    Future<void>.delayed(espera, () {
      if (!_repitiendo || !mounted) return;
      widget.alTocar();
      _repetir(const Duration(milliseconds: 70));
    });
  }

  void _pararDeRepetir() => _repitiendo = false;

  @override
  void dispose() {
    _repitiendo = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final Color fondo;
    final Color tinta;
    if (widget.principal) {
      fondo = colores.primary;
      tinta = colores.onPrimary;
    } else if (widget.resaltada) {
      fondo = colores.secondary;
      tinta = colores.onSecondary;
    } else if (widget.tenue) {
      fondo = colores.surfaceContainer;
      tinta = colores.onSurfaceVariant;
    } else {
      fondo = colores.surface;
      tinta = colores.onSurface;
    }
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: fondo,
          borderRadius: BorderRadius.circular(HatoSpacing.sm),
          child: InkWell(
            // Sin esto la tecla le roba el foco al campo y el teclado se cierra
            // solo en cuanto el ganadero aprieta la primera letra.
            canRequestFocus: false,
            borderRadius: BorderRadius.circular(HatoSpacing.sm),
            onTap: widget.alTocar,
            onTapDown: (_) => _empezarARepetir(),
            onTapUp: (_) => _pararDeRepetir(),
            onTapCancel: _pararDeRepetir,
            child: Semantics(
              label: widget.semantica,
              button: true,
              // El lector de pantalla debe decir «Borrar», no leer el dibujito.
              excludeSemantics: widget.semantica != null,
              child: Center(
                child: Text(
                  widget.etiqueta,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: widget.grande ? 26 : 18,
                    fontWeight: widget.principal
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: tinta,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
