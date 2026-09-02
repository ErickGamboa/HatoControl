import 'package:flutter/material.dart';

/// Le pone al contenido un ancho máximo cómodo y lo centra.
///
/// En un monitor ancho, una lista que se estira de borde a borde se vuelve
/// incómoda de leer: el ojo pierde la fila. Con márgenes generosos el módulo
/// se ve como una hoja de trabajo, que es lo que espera alguien sentado
/// frente a una computadora.
class ContenidoEscritorio extends StatelessWidget {
  const ContenidoEscritorio({
    super.key,
    required this.child,
    this.anchoMaximo = 1180,
  });

  final Widget child;
  final double anchoMaximo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: anchoMaximo),
        child: child,
      ),
    );
  }
}

/// Ícono de una sección: los módulos usan PNG de trazo (los mismos del
/// teléfono) y el resto íconos de Material. Se tiñen del color que reciban.
class IconoSeccion extends StatelessWidget {
  const IconoSeccion({
    super.key,
    this.asset,
    this.icono,
    required this.color,
    this.tamano = 22,
  });

  final String? asset;
  final IconData? icono;
  final Color color;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final ruta = asset;
    if (ruta != null) {
      return Image.asset(ruta, width: tamano, height: tamano, color: color);
    }
    return Icon(icono ?? Icons.circle_outlined, size: tamano, color: color);
  }
}
