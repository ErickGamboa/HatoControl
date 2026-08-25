/// Totales de plata por grupo de animales (un lote o toda la finca): funciones
/// puras, sin acceso a base de datos.
///
/// Regla acordada con el ganadero: **la utilidad existe solo cuando el animal
/// se vendió y la planta liquidó**. Los animales en pie suman costo, nunca
/// utilidad estimada: es preferible una respuesta incompleta a una inventada.
library;

/// Lo que aporta un animal al total del grupo.
typedef AporteFinanciero = ({
  double compra,
  double alimentacion,
  double sanidad,
  double gastosFijos,

  /// Dinero recibido por el animal. null = no se vendió o no ha liquidado.
  double? dineroRecibido,

  /// Utilidad del animal. null salvo vendido y liquidado (ver arriba).
  double? utilidad,

  /// Kilos que ganó desde su primer pesaje hasta el último.
  double kilosGanados,
});

/// Plata de un grupo de animales.
class ResumenFinanciero {
  const ResumenFinanciero({
    required this.animales,
    required this.compra,
    required this.alimentacion,
    required this.sanidad,
    required this.gastosFijos,
    required this.ventaRecibida,
    required this.utilidad,
    required this.conUtilidad,
    required this.kilosGanados,
  });

  const ResumenFinanciero.vacio()
    : animales = 0,
      compra = 0,
      alimentacion = 0,
      sanidad = 0,
      gastosFijos = 0,
      ventaRecibida = 0,
      utilidad = 0,
      conUtilidad = 0,
      kilosGanados = 0;

  /// Animales considerados (los que están en pie y los ya vendidos).
  final int animales;

  final double compra;
  final double alimentacion;
  final double sanidad;
  final double gastosFijos;

  /// Σ del dinero recibido por los animales que ya liquidaron.
  final double ventaRecibida;

  /// Σ de la utilidad de esos mismos animales. No incluye a los que están en
  /// pie: de esos todavía no se sabe.
  final double utilidad;

  /// Cuántos animales tienen utilidad de verdad (vendidos y liquidados).
  final int conUtilidad;

  /// Σ de kilos ganados por todos los animales del grupo.
  final double kilosGanados;

  double get costoTotal => compra + alimentacion + sanidad + gastosFijos;

  /// Costo sin la compra: lo que costó **engordar**, no adquirir. Es el que se
  /// compara contra el precio de venta por kilo.
  double get costoDeEngorde => alimentacion + sanidad + gastosFijos;

  /// ₡ que cuesta ponerle un kilo encima al ganado. null si el grupo todavía
  /// no ganó kilos (hace falta un segundo pesaje).
  double? get costoPorKiloGanado =>
      kilosGanados <= 0 ? null : costoDeEngorde / kilosGanados;

  /// Cuánto pesa cada tipo de gasto sobre el costo total, de mayor a menor.
  /// Vacío si no hay costo (nada que repartir).
  List<({String tipo, double monto, double porcentaje})> get desglose {
    final total = costoTotal;
    if (total <= 0) return const [];
    final partes = <({String tipo, double monto, double porcentaje})>[
      (tipo: 'Compra', monto: compra, porcentaje: compra / total * 100),
      (
        tipo: 'Dietas',
        monto: alimentacion,
        porcentaje: alimentacion / total * 100,
      ),
      (tipo: 'Sanidad', monto: sanidad, porcentaje: sanidad / total * 100),
      (
        tipo: 'Gastos fijos',
        monto: gastosFijos,
        porcentaje: gastosFijos / total * 100,
      ),
    ]..removeWhere((p) => p.monto <= 0);
    partes.sort((a, b) => b.monto.compareTo(a.monto));
    return partes;
  }
}

/// Suma los aportes de un grupo de animales.
ResumenFinanciero sumarFinanciero(Iterable<AporteFinanciero> aportes) {
  var animales = 0;
  var compra = 0.0;
  var alimentacion = 0.0;
  var sanidad = 0.0;
  var gastosFijos = 0.0;
  var ventaRecibida = 0.0;
  var utilidad = 0.0;
  var conUtilidad = 0;
  var kilosGanados = 0.0;

  for (final a in aportes) {
    animales++;
    compra += a.compra;
    alimentacion += a.alimentacion;
    sanidad += a.sanidad;
    gastosFijos += a.gastosFijos;
    kilosGanados += a.kilosGanados;
    // Solo los vendidos y liquidados entran a la utilidad.
    if (a.utilidad != null) {
      utilidad += a.utilidad!;
      ventaRecibida += a.dineroRecibido ?? 0;
      conUtilidad++;
    }
  }

  return ResumenFinanciero(
    animales: animales,
    compra: compra,
    alimentacion: alimentacion,
    sanidad: sanidad,
    gastosFijos: gastosFijos,
    ventaRecibida: ventaRecibida,
    utilidad: utilidad,
    conUtilidad: conUtilidad,
    kilosGanados: kilosGanados,
  );
}
