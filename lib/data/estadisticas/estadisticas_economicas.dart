import '../estadisticas/estadisticas_pesajes.dart';

/// Período de alimentación con costo congelado por día (Module 4).
class PeriodoAlimentacion {
  const PeriodoAlimentacion({
    required this.desde,
    required this.hasta,
    required this.costoAnimalDia,
  });

  final DateTime desde;
  final DateTime? hasta;
  final double costoAnimalDia;
}

/// Desglose de costos e ingresos de un animal.
class ResumenEconomicoAnimal {
  const ResumenEconomicoAnimal({
    required this.precioCompra,
    required this.costoAlimentacion,
    required this.costoSanitario,
    required this.costoOtros,
    required this.precioVenta,
    required this.costoTotal,
    required this.utilidad,
    required this.margenPorcentaje,
    required this.rentabilidadPorcentaje,
    this.costoGastosFijos = 0,
    this.pesoCompra,
    this.precioKgCompra,
    this.pesoVenta,
    this.precioKgVenta,
    this.compraConfiable = true,
  });

  final double? precioCompra;
  final double? pesoCompra;
  final double? precioKgCompra;
  final double costoAlimentacion;
  final double costoSanitario;
  final double costoOtros;

  /// Parte prorrateada de los gastos fijos de la finca (Módulo 7, D-17).
  final double costoGastosFijos;
  final double? precioVenta;
  final double? pesoVenta;
  final double? precioKgVenta;
  final double costoTotal;
  final double? utilidad;
  final double? margenPorcentaje;
  final double? rentabilidadPorcentaje;

  /// false si el animal parece comprado pero falta ₡/kg (utilidad no confiable).
  final bool compraConfiable;
}

/// Días en un período de alimentación (inclusive start, exclusive end if set).
int diasEnPeriodoAlimentacion(DateTime desde, DateTime? hasta, DateTime? fin) {
  final finEfectivo = _finEfectivo(hasta, fin);
  final dias = diasCalendario(desde, finEfectivo);
  return dias < 1 ? 0 : dias;
}

DateTime _finEfectivo(DateTime? hasta, DateTime? fin) {
  if (hasta == null && fin == null) return DateTime.now();
  if (hasta == null) return fin!;
  if (fin == null) return hasta;
  return hasta.isBefore(fin) ? hasta : fin;
}

/// Σ (días × costo_animal_dia) por período.
double costoAlimentacionDesdePeriodos(
  List<PeriodoAlimentacion> periodos, {
  DateTime? hasta,
}) {
  var total = 0.0;
  for (final p in periodos) {
    final dias = diasEnPeriodoAlimentacion(p.desde, p.hasta, hasta);
    total += dias * p.costoAnimalDia;
  }
  return total;
}

/// Σ costos sanitarios (nulls treated as 0).
double costoSanitarioDesdeEventos(List<double?> costos) {
  return costos.fold<double>(0, (s, c) => s + (c ?? 0));
}

/// Σ otros costos.
double costoOtrosDesdeMontos(List<double> montos) {
  return montos.fold<double>(0, (s, m) => s + m);
}

/// Costo total = compra + alimentación + sanidad + otros.
double costoTotalAnimal({
  double? precioCompra,
  required double costoAlimentacion,
  required double costoSanitario,
  required double costoOtros,
}) {
  return (precioCompra ?? 0) + costoAlimentacion + costoSanitario + costoOtros;
}

/// Utilidad = venta − costo total (null si no hay venta).
double? utilidadAnimal({
  required double? precioVenta,
  required double costoTotal,
}) {
  if (precioVenta == null) return null;
  return precioVenta - costoTotal;
}

/// Margen = utilidad / venta × 100.
double? margenPorcentaje({required double? utilidad, required double? venta}) {
  if (utilidad == null || venta == null || venta == 0) return null;
  return (utilidad / venta) * 100;
}

/// Rentabilidad = utilidad / costo total × 100.
double? rentabilidadPorcentaje({
  required double? utilidad,
  required double costoTotal,
}) {
  if (utilidad == null || costoTotal == 0) return null;
  return (utilidad / costoTotal) * 100;
}

ResumenEconomicoAnimal calcularResumenEconomico({
  double? precioCompra,
  required List<PeriodoAlimentacion> periodosAlimentacion,
  required List<double?> costosSanitarios,
  required List<double> costosOtros,
  double? precioVenta,
  DateTime? hasta,
}) {
  final alimentacion = costoAlimentacionDesdePeriodos(
    periodosAlimentacion,
    hasta: hasta,
  );
  final sanitario = costoSanitarioDesdeEventos(costosSanitarios);
  final otros = costoOtrosDesdeMontos(costosOtros);
  final total = costoTotalAnimal(
    precioCompra: precioCompra,
    costoAlimentacion: alimentacion,
    costoSanitario: sanitario,
    costoOtros: otros,
  );
  final utilidad = utilidadAnimal(precioVenta: precioVenta, costoTotal: total);
  return ResumenEconomicoAnimal(
    precioCompra: precioCompra,
    costoAlimentacion: alimentacion,
    costoSanitario: sanitario,
    costoOtros: otros,
    precioVenta: precioVenta,
    costoTotal: total,
    utilidad: utilidad,
    margenPorcentaje: margenPorcentaje(utilidad: utilidad, venta: precioVenta),
    rentabilidadPorcentaje: rentabilidadPorcentaje(
      utilidad: utilidad,
      costoTotal: total,
    ),
  );
}
