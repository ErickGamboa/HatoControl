/// Tipos de aplicación de un medicamento (documento oro, Módulo 2).
abstract final class TipoAplicacionMedicamento {
  static const porPeso = 'por_peso';
  static const dosisFija = 'dosis_fija';
  static const porAplicacion = 'por_aplicacion';

  static const todos = [porPeso, dosisFija, porAplicacion];

  static String etiqueta(String tipo) => switch (tipo) {
    porPeso => 'Por peso',
    dosisFija => 'Dosis fija',
    porAplicacion => 'Por aplicación (spray)',
    _ => tipo,
  };
}

/// Resultado de calcular dosis y costo por uso para un peso dado.
class DosisMedicamentoCalculada {
  const DosisMedicamentoCalculada({
    required this.etiquetaDosis,
    required this.costoUso,
    this.mlAplicados,
    this.aplicaciones,
  });

  /// Texto para UI / hoja de vida (ej. "1500 ml", "5 ml", "1 aplicación").
  final String etiquetaDosis;
  final double costoUso;
  final double? mlAplicados;
  final int? aplicaciones;
}

/// Dosis por peso: (cantidad por cada X kg) × (peso / X).
double mlPorPeso({
  required double cantidadMl,
  required double cadaKg,
  required double pesoKg,
}) {
  if (cadaKg <= 0 || cantidadMl < 0 || pesoKg < 0) return 0;
  return (pesoKg / cadaKg) * cantidadMl;
}

/// Costo líquido: costo envase ÷ ml envase × ml aplicados.
double costoUsoLiquido({
  required double costoEnvase,
  required double mlEnvase,
  required double mlAplicados,
}) {
  if (mlEnvase <= 0 || costoEnvase < 0 || mlAplicados < 0) return 0;
  return costoEnvase / mlEnvase * mlAplicados;
}

/// Costo spray: costo envase ÷ aplicaciones que rinde.
double costoUsoSpray({
  required double costoEnvase,
  required double aplicacionesPorEnvase,
}) {
  if (aplicacionesPorEnvase <= 0 || costoEnvase < 0) return 0;
  return costoEnvase / aplicacionesPorEnvase;
}

/// Fecha fin de retiro = fecha aplicación + días de retiro (calendario).
DateTime? fechaFinRetiro(DateTime fechaAplicacion, int diasRetiro) {
  if (diasRetiro <= 0) return null;
  final base = DateTime(
    fechaAplicacion.year,
    fechaAplicacion.month,
    fechaAplicacion.day,
  );
  return base.add(Duration(days: diasRetiro));
}

/// true si [hoy] está en retiro (inclusive hasta retiroHasta).
bool estaEnRetiro(DateTime? retiroHasta, {DateTime? hoy}) {
  if (retiroHasta == null) return false;
  final ahora = hoy ?? DateTime.now();
  final d = DateTime(ahora.year, ahora.month, ahora.day);
  final fin = DateTime(retiroHasta.year, retiroHasta.month, retiroHasta.day);
  return !d.isAfter(fin);
}

/// Calcula dosis y costo según tipo de aplicación del medicamento.
DosisMedicamentoCalculada calcularDosisMedicamento({
  required String tipoAplicacion,
  required double costoEnvase,
  required double pesoKg,
  double? mlEnvase,
  double? aplicacionesPorEnvase,
  double? dosisCantidad,
  double? dosisPorCadaKg,
}) {
  switch (tipoAplicacion) {
    case TipoAplicacionMedicamento.porPeso:
      final cantidad = dosisCantidad ?? 0;
      final cada = dosisPorCadaKg ?? 0;
      final ml = mlPorPeso(cantidadMl: cantidad, cadaKg: cada, pesoKg: pesoKg);
      final costo = costoUsoLiquido(
        costoEnvase: costoEnvase,
        mlEnvase: mlEnvase ?? 0,
        mlAplicados: ml,
      );
      final etiqueta = ml == ml.roundToDouble()
          ? '${ml.toInt()} ml'
          : '${ml.toStringAsFixed(1)} ml';
      return DosisMedicamentoCalculada(
        etiquetaDosis: etiqueta,
        costoUso: costo,
        mlAplicados: ml,
      );
    case TipoAplicacionMedicamento.dosisFija:
      final ml = dosisCantidad ?? 0;
      final costo = costoUsoLiquido(
        costoEnvase: costoEnvase,
        mlEnvase: mlEnvase ?? 0,
        mlAplicados: ml,
      );
      final etiqueta = ml == ml.roundToDouble()
          ? '${ml.toInt()} ml'
          : '${ml.toStringAsFixed(1)} ml';
      return DosisMedicamentoCalculada(
        etiquetaDosis: etiqueta,
        costoUso: costo,
        mlAplicados: ml,
      );
    case TipoAplicacionMedicamento.porAplicacion:
      final costo = costoUsoSpray(
        costoEnvase: costoEnvase,
        aplicacionesPorEnvase: aplicacionesPorEnvase ?? 0,
      );
      return DosisMedicamentoCalculada(
        etiquetaDosis: '1 aplicación',
        costoUso: costo,
        aplicaciones: 1,
      );
    default:
      return const DosisMedicamentoCalculada(etiquetaDosis: '—', costoUso: 0);
  }
}

/// Utilidad oro: venta − (compra + dietas + sanidad + gastos fijos).
/// Sin “otros costos” por animal (`costos_otros` sigue fuera de la fórmula).
///
/// [costoGastosFijos] es la parte prorrateada por días-animal del Módulo 7
/// (D-17); vale 0 cuando la finca no tiene gastos fijos registrados.
double? utilidadOro({
  required double? precioVenta,
  double? precioCompra,
  required double costoDietas,
  required double costoSanidad,
  double costoGastosFijos = 0,
}) {
  if (precioVenta == null) return null;
  return precioVenta -
      ((precioCompra ?? 0) + costoDietas + costoSanidad + costoGastosFijos);
}
