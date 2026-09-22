import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../app/widgets/campo_fecha.dart';
import '../data/repositories/deudas_repository.dart';
import 'gastos_fijos_tab.dart' show fmtColones;

/// El PDF de las deudas, para verlo, guardarlo o mandarlo por WhatsApp.
///
/// Sale EXACTAMENTE lo que quedó filtrado en pantalla, y por eso la hoja
/// lleva escrito qué filtro se usó: un PDF viejo no se puede confundir con el
/// de hoy ni con el de otra finca.
///
/// El azul de la marca va repetido acá y no importado del tema porque es un
/// `PdfColor`, no un `Color` de Flutter: son dos tipos distintos.
const _azulHato = PdfColor.fromInt(0xFF12334F);

/// En el PDF los montos van SIN el símbolo del colón y la hoja dice
/// "Montos en colones" debajo del título.
///
/// No es un capricho: ni la fuente por defecto del paquete `pdf` ni la
/// Roboto que trae el SDK tienen el glifo ₡ (U+20A1), así que el símbolo
/// salía impreso como un cuadrito. En pantalla sí se ve bien, porque ahí
/// dibuja Flutter con la fuente del sistema.
String _montoPdf(double v) {
  final texto = fmtColones(v);
  return texto.replaceAll('₡', '');
}

/// Roboto va empacada con la app (no se baja de internet, que en la finca no
/// hay) para que los acentos y el guion largo salgan bien en cualquier
/// aparato.
///
/// Se carga una sola vez y se guarda: el preview reconstruye el PDF varias
/// veces y no tiene por qué leer el archivo cada vez.
pw.ThemeData? _tema;

Future<pw.ThemeData> _temaConColones() async {
  final cacheado = _tema;
  if (cacheado != null) return cacheado;
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fuentes/roboto-regular.ttf'),
  );
  final negrita = pw.Font.ttf(
    await rootBundle.load('assets/fuentes/roboto-bold.ttf'),
  );
  return _tema = pw.ThemeData.withFont(base: regular, bold: negrita);
}

Future<Uint8List> construirPdfDeudas({
  required String nombreFinca,
  required String descripcionFiltro,
  required List<DeudaConSaldo> deudas,
  required TotalesDeudas totales,
  required DateTime generadoEl,
}) async {
  final doc = pw.Document(
    title: 'Deudas',
    author: 'HatoControl',
    theme: await _temaConColones(),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 28),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox()
          // De la segunda hoja en adelante se repite de qué finca es: una
          // hoja suelta tiene que decirlo.
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Text(
                '$nombreFinca · Deudas',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ),
      build: (context) => [
        _encabezado(
          nombreFinca: nombreFinca,
          descripcionFiltro: descripcionFiltro,
          generadoEl: generadoEl,
        ),
        pw.SizedBox(height: 14),
        _tabla(deudas),
        pw.SizedBox(height: 12),
        _totales(totales),
        pw.SizedBox(height: 10),
        pw.Text(
          'Las deudas son una lista de control: no entran en la utilidad de '
          'los animales. Las anuladas se muestran pero no suman en los '
          'totales.',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
        ),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _encabezado({
  required String nombreFinca,
  required String descripcionFiltro,
  required DateTime generadoEl,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Deudas',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _azulHato,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(nombreFinca, style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'HatoControl',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
              pw.Text(
                fmtFecha(generadoEl),
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 6),
      pw.Text(
        '$descripcionFiltro · Montos en colones',
        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
      ),
    ],
  );
}

pw.Widget _tabla(List<DeudaConSaldo> deudas) {
  final encabezado = pw.TextStyle(
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );

  return pw.TableHelper.fromTextArray(
    headers: const [
      'A quién',
      'Fecha',
      'Vence',
      'Monto',
      'Abonado',
      'Saldo',
      'Estado',
    ],
    data: [
      for (final d in deudas)
        [
          d.deuda.acreedor,
          fmtFecha(d.deuda.fecha),
          d.deuda.vence == null ? '—' : fmtFecha(d.deuda.vence!),
          _montoPdf(d.deuda.monto),
          _montoPdf(d.abonado),
          _montoPdf(d.saldo),
          _estado(d),
        ],
    ],
    headerStyle: encabezado,
    headerDecoration: const pw.BoxDecoration(color: _azulHato),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignments: {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.center,
      2: pw.Alignment.center,
      3: pw.Alignment.centerRight,
      4: pw.Alignment.centerRight,
      5: pw.Alignment.centerRight,
      6: pw.Alignment.center,
    },
    columnWidths: {
      0: const pw.FlexColumnWidth(3),
      1: const pw.FlexColumnWidth(1.4),
      2: const pw.FlexColumnWidth(1.4),
      3: const pw.FlexColumnWidth(1.6),
      4: const pw.FlexColumnWidth(1.6),
      5: const pw.FlexColumnWidth(1.6),
      6: const pw.FlexColumnWidth(1.4),
    },
    oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
  );
}

String _estado(DeudaConSaldo d) {
  if (d.anulada) return 'Anulada';
  if (d.pagada) return 'Pagada';
  return d.vencida() ? 'Vencida' : 'Pendiente';
}

pw.Widget _totales(TotalesDeudas totales) {
  pw.Widget fila(String etiqueta, String valor, {bool fuerte = false}) {
    final estilo = pw.TextStyle(
      fontSize: fuerte ? 12 : 10,
      fontWeight: fuerte ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: fuerte ? _azulHato : PdfColors.grey800,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(etiqueta, style: estilo),
          pw.SizedBox(width: 20),
          pw.Text(valor, style: estilo),
        ],
      ),
    );
  }

  return pw.Align(
    alignment: pw.Alignment.centerRight,
    child: pw.Container(
      width: 240,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
      ),
      child: pw.Column(
        children: [
          fila('Deudas listadas', '${totales.cantidad}'),
          fila('Monto total', _montoPdf(totales.total)),
          fila('Abonado', _montoPdf(totales.abonado)),
          pw.Divider(height: 8, color: PdfColors.grey400),
          fila('Saldo', _montoPdf(totales.saldo), fuerte: true),
        ],
      ),
    ),
  );
}
