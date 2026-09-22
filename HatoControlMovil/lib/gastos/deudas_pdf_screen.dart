import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data/repositories/deudas_repository.dart';
import 'deudas_pdf.dart';

/// Previsualización del PDF de deudas.
///
/// Se abre la hoja en pantalla en vez de mandar el archivo de una porque
/// muchas veces alcanza con verla —o tomarle una foto de pantalla— para
/// pasarla por WhatsApp. El que sí quiera el archivo lo tiene en el botón de
/// compartir de esta misma pantalla.
class DeudasPdfScreen extends StatelessWidget {
  const DeudasPdfScreen({
    super.key,
    required this.nombreFinca,
    required this.descripcionFiltro,
    required this.deudas,
    required this.totales,
    required this.generadoEl,
  });

  final String nombreFinca;
  final String descripcionFiltro;
  final List<DeudaConSaldo> deudas;
  final TotalesDeudas totales;

  /// Se recibe hecha y no se saca acá con `DateTime.now()`: el preview puede
  /// reconstruir el PDF varias veces (al rotar, al cambiar de hoja) y la
  /// fecha del encabezado no tiene por qué moverse en el camino.
  final DateTime generadoEl;

  String get _nombreArchivo =>
      'deudas-${generadoEl.year}-'
      '${_dos(generadoEl.month)}-${_dos(generadoEl.day)}.pdf';

  static String _dos(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deudas en PDF')),
      body: PdfPreview(
        build: (formato) => construirPdfDeudas(
          nombreFinca: nombreFinca,
          descripcionFiltro: descripcionFiltro,
          deudas: deudas,
          totales: totales,
          generadoEl: generadoEl,
        ),
        pdfFileName: _nombreArchivo,
        // Solo compartir. Imprimir no: en la finca no hay impresora, y el
        // botón al lado del de compartir solo daba en qué equivocarse.
        allowSharing: true,
        allowPrinting: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        padding: const EdgeInsets.all(8),
        loadingWidget: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
