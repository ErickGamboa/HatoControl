import 'package:flutter/material.dart';

/// Secciones del menú lateral de la versión de computadora.
///
/// Son exactamente los mismos módulos que tiene la finca en el teléfono; lo
/// único que cambia es cómo se llega a ellos: en el teléfono se toca una
/// tarjeta y se abre una pantalla encima, y en la computadora se quedan
/// siempre a la vista en la barra de la izquierda.
enum SeccionEscritorio {
  inicio(etiqueta: 'Inicio de finca', icono: Icons.space_dashboard_outlined),
  pesaje(
    etiqueta: 'Recolección de datos',
    asset: 'assets/iconos/recoleccion.png',
    esRegistro: true,
  ),
  lotes(etiqueta: 'Lotes', asset: 'assets/iconos/lotes.png'),
  sanidad(etiqueta: 'Sanidad', asset: 'assets/iconos/sanidad.png'),
  dietas(etiqueta: 'Dietas', asset: 'assets/iconos/dietas.png'),
  venta(etiqueta: 'Venta', asset: 'assets/iconos/venta.png'),
  gastosFijos(etiqueta: 'Gastos fijos', icono: Icons.receipt_long_outlined),
  analisis(etiqueta: 'Análisis', icono: Icons.insights_outlined);

  const SeccionEscritorio({
    required this.etiqueta,
    this.icono,
    this.asset,
    this.esRegistro = false,
  });

  final String etiqueta;
  final IconData? icono;
  final String? asset;

  /// Recolección de datos es puro registro: un invitado de solo lectura no
  /// entra a la manga, igual que en el teléfono.
  final bool esRegistro;

  /// Las secciones que se le muestran a este usuario dentro de una finca.
  static List<SeccionEscritorio> paraFinca({required bool soloLectura}) {
    return values.where((s) => !soloLectura || !s.esRegistro).toList();
  }
}
