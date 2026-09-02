/// Prorrateo de gastos fijos por días-animal: funciones puras, sin acceso a
/// base de datos ni a Flutter (Módulo 7, D-17).
///
/// Reglas de `docs/ESPECIFICACION_FUNCIONAL.md` (Módulo 7):
/// - El gasto de un mes se reparte entre el total de **días-animal** de ese
///   mes: `parte = monto × días del animal ÷ días-animal del mes`. Así la suma
///   de todas las partes es exactamente el monto del gasto.
/// - Los días son de CALENDARIO e **inclusivos**: un animal que entró el día 20
///   de un mes de 31 días estuvo 12 días.
/// - El mes en curso devenga solo lo transcurrido (`monto × días vigentes ÷
///   días del mes`), igual que la dieta corre día por día.
/// - Lo ya **congelado** (animales vendidos) se descuenta del monto antes de
///   repartir, así un gasto digitado atrasado lo absorben solo los animales que
///   siguen en la finca y nunca se reparte más del 100%.
library;

import 'estadisticas_pesajes.dart';

/// Estancia de un animal en la finca. `salida` null = sigue en la finca.
class EstanciaAnimal {
  const EstanciaAnimal({
    required this.animalId,
    required this.ingreso,
    this.salida,
  });

  final String animalId;
  final DateTime ingreso;
  final DateTime? salida;
}

/// Gasto fijo con su vigencia, sin depender de Drift.
/// `mensual` false = gasto de una sola vez en la fecha [desde].
class GastoFijoVigencia {
  const GastoFijoVigencia({
    required this.gastoFijoId,
    required this.monto,
    required this.mensual,
    required this.desde,
    this.hasta,
  });

  final String gastoFijoId;

  /// ₡ por mes si [mensual]; ₡ del gasto completo si no.
  final double monto;
  final bool mensual;
  final DateTime desde;

  /// null = sigue vigente.
  final DateTime? hasta;
}

/// Un gasto aterrizado en un mes concreto, con lo que devenga ese mes.
class GastoMes {
  const GastoMes({
    required this.gastoFijoId,
    required this.mes,
    required this.montoDevengado,
  });

  final String gastoFijoId;

  /// Primer día del mes.
  final DateTime mes;
  final double montoDevengado;
}

/// Parte de un gasto fijo ya congelada (animal que salió de la finca).
class CargoCongelado {
  const CargoCongelado({
    required this.gastoFijoId,
    required this.mes,
    required this.monto,
  });

  final String gastoFijoId;
  final DateTime mes;
  final double monto;
}

/// Parte que le corresponde a un animal de un gasto en un mes.
class ParteGastoMes {
  const ParteGastoMes({
    required this.gastoFijoId,
    required this.animalId,
    required this.mes,
    required this.dias,
    required this.monto,
  });

  final String gastoFijoId;
  final String animalId;
  final DateTime mes;

  /// Días-animal que le tocaron en ese mes (para poder auditar el reparto).
  final int dias;
  final double monto;
}

/// Primer día del mes de [fecha] (sin hora).
DateTime primerDiaDelMes(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, 1);

/// Mes siguiente al de [mes].
DateTime mesSiguiente(DateTime mes) => DateTime(mes.year, mes.month + 1, 1);

/// Último día del mes de [mes] (sin hora).
DateTime ultimoDiaDelMes(DateTime mes) =>
    DateTime(mes.year, mes.month, diasDelMes(mes));

/// Cantidad de días del mes de [mes] (contempla años bisiestos).
int diasDelMes(DateTime mes) {
  if (mes.month == 2) {
    final a = mes.year;
    final bisiesto = (a % 4 == 0 && a % 100 != 0) || a % 400 == 0;
    return bisiesto ? 29 : 28;
  }
  const dias = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return dias[mes.month - 1];
}

/// Días de calendario entre [desde] y [hasta] contando ambos extremos.
/// 0 si [hasta] es anterior a [desde].
int diasInclusive(DateTime desde, DateTime hasta) {
  final dias = diasCalendario(desde, hasta);
  return dias < 0 ? 0 : dias + 1;
}

DateTime _menor(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
DateTime _mayor(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

/// Expande un gasto a los meses que devenga hasta [hoy].
///
/// - `mensual`: un [GastoMes] por mes de vigencia. Cada mes devenga
///   `monto × días vigentes en el mes ÷ días del mes`, así que un mes completo
///   devenga el monto exacto y el mes en curso (o el mes en que se dio de baja)
///   devenga solo su parte.
/// - único: un solo [GastoMes] en el mes de su fecha, por el monto completo.
///
/// Devuelve vacío si el gasto todavía no empezó o si el monto es 0.
List<GastoMes> mesesDeGasto(GastoFijoVigencia gasto, {required DateTime hoy}) {
  final hoyDia = DateTime(hoy.year, hoy.month, hoy.day);
  final inicio = DateTime(gasto.desde.year, gasto.desde.month, gasto.desde.day);
  if (inicio.isAfter(hoyDia) || gasto.monto <= 0) return const [];

  if (!gasto.mensual) {
    return [
      GastoMes(
        gastoFijoId: gasto.gastoFijoId,
        mes: primerDiaDelMes(inicio),
        montoDevengado: gasto.monto,
      ),
    ];
  }

  final baja = gasto.hasta;
  final fin = baja == null
      ? hoyDia
      : _menor(DateTime(baja.year, baja.month, baja.day), hoyDia);
  if (fin.isBefore(inicio)) return const [];

  final meses = <GastoMes>[];
  var mes = primerDiaDelMes(inicio);
  final ultimoMes = primerDiaDelMes(fin);
  while (!mes.isAfter(ultimoMes)) {
    final desdeMes = _mayor(inicio, mes);
    final hastaMes = _menor(fin, ultimoDiaDelMes(mes));
    final diasVigentes = diasInclusive(desdeMes, hastaMes);
    if (diasVigentes > 0) {
      meses.add(
        GastoMes(
          gastoFijoId: gasto.gastoFijoId,
          mes: mes,
          montoDevengado: gasto.monto * diasVigentes / diasDelMes(mes),
        ),
      );
    }
    mes = mesSiguiente(mes);
  }
  return meses;
}

/// Días que el animal estuvo en la finca dentro de [mes] (inclusivos).
/// Un período abierto se corta en [hoy]: el gasto no corre hacia el futuro.
int diasEnMes(EstanciaAnimal estancia, DateTime mes, {required DateTime hoy}) {
  final hoyDia = DateTime(hoy.year, hoy.month, hoy.day);
  final ingreso = DateTime(
    estancia.ingreso.year,
    estancia.ingreso.month,
    estancia.ingreso.day,
  );
  final salida = estancia.salida;
  final fin = salida == null
      ? hoyDia
      : _menor(DateTime(salida.year, salida.month, salida.day), hoyDia);
  if (fin.isBefore(ingreso)) return 0;

  final desde = _mayor(ingreso, mes);
  final hasta = _menor(fin, ultimoDiaDelMes(mes));
  return diasInclusive(desde, hasta);
}

/// Reparte un [GastoMes] entre las estancias [activos] por días-animal,
/// descontando primero lo que ya está [congelado] de ese mismo gasto y mes.
///
/// Devuelve vacío si no hay nada por repartir o si ningún animal estuvo
/// presente ese mes (el gasto queda registrado sin cargo, no es un error).
List<ParteGastoMes> prorratearGastoMes({
  required GastoMes gastoMes,
  required List<EstanciaAnimal> activos,
  required List<CargoCongelado> congelados,
  required DateTime hoy,
}) {
  final yaCongelado = congelados
      .where(
        (c) =>
            c.gastoFijoId == gastoMes.gastoFijoId &&
            c.mes.isAtSameMomentAs(gastoMes.mes),
      )
      .fold<double>(0, (s, c) => s + c.monto);
  final porRepartir = gastoMes.montoDevengado - yaCongelado;
  if (porRepartir <= 0) return const [];

  final dias = <String, int>{};
  var totalDias = 0;
  for (final e in activos) {
    final d = diasEnMes(e, gastoMes.mes, hoy: hoy);
    if (d <= 0) continue;
    dias[e.animalId] = (dias[e.animalId] ?? 0) + d;
    totalDias += d;
  }
  if (totalDias == 0) return const [];

  return [
    for (final entrada in dias.entries)
      ParteGastoMes(
        gastoFijoId: gastoMes.gastoFijoId,
        animalId: entrada.key,
        mes: gastoMes.mes,
        dias: entrada.value,
        monto: porRepartir * entrada.value / totalDias,
      ),
  ];
}

/// Reparte todos los [gastos] de una finca entre las estancias [activos],
/// mes por mes, descontando los cargos ya [congelados].
List<ParteGastoMes> prorratearGastos({
  required List<GastoFijoVigencia> gastos,
  required List<EstanciaAnimal> activos,
  required List<CargoCongelado> congelados,
  required DateTime hoy,
}) {
  final partes = <ParteGastoMes>[];
  for (final gasto in gastos) {
    for (final mes in mesesDeGasto(gasto, hoy: hoy)) {
      partes.addAll(
        prorratearGastoMes(
          gastoMes: mes,
          activos: activos,
          congelados: congelados,
          hoy: hoy,
        ),
      );
    }
  }
  return partes;
}

/// Σ de las partes de un animal (₡ de gasto fijo que absorbió).
double totalDeAnimal(List<ParteGastoMes> partes, String animalId) => partes
    .where((p) => p.animalId == animalId)
    .fold<double>(0, (s, p) => s + p.monto);
