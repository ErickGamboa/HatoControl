/// Estadísticas de pesajes: funciones puras, sin acceso a base de datos.
///
/// Decisiones D-01 y A-06 (`docs/DECISIONES.md`):
/// - Los días se cuentan por CALENDARIO (ayer → hoy = 1 día).
/// - El historial de un lote se agrupa por fecha de calendario: cada fecha con
///   pesajes es una "jornada" y un período va entre jornadas consecutivas.
/// - Cada animal se compara contra SU propio pesaje anterior, de modo que un
///   animal que se saltó una jornada no distorsiona el promedio.
library;

/// Un punto (fecha, peso) del historial de un animal.
typedef PuntoPeso = ({DateTime fecha, double peso});

/// Un pesaje de un animal concreto, para agregados por lote.
typedef PesajeDeAnimal = ({String animalId, DateTime fecha, double peso});

/// Días de CALENDARIO entre dos fechas (ignora la hora del día). De ayer a
/// hoy = 1 día aunque hayan pasado menos de 24 horas reales.
int diasCalendario(DateTime anterior, DateTime actual) {
  final a = DateTime(anterior.year, anterior.month, anterior.day);
  final b = DateTime(actual.year, actual.month, actual.day);
  return b.difference(a).inDays;
}

/// Ganancia promedio de kilos por día en TODO el historial de un animal:
/// (último peso − primer peso) / días de calendario entre ambos.
///
/// Devuelve null si hay menos de dos pesajes o si el primero y el último
/// caen el mismo día de calendario (no se puede promediar por día).
double? gananciaDiariaGlobal(List<PuntoPeso> historial) {
  if (historial.length < 2) return null;
  final ordenado = [...historial]..sort((a, b) => a.fecha.compareTo(b.fecha));
  final primero = ordenado.first;
  final ultimo = ordenado.last;
  final dias = diasCalendario(primero.fecha, ultimo.fecha);
  if (dias < 1) return null;
  return (ultimo.peso - primero.peso) / dias;
}

/// Resumen de un período del lote: la jornada de pesaje [hasta] comparada con
/// la jornada anterior [desde] (null si es la primera jornada registrada).
class PeriodoLote {
  const PeriodoLote({
    required this.desde,
    required this.hasta,
    required this.animales,
    required this.pesoPromedio,
    required this.pesoMinimo,
    required this.pesoMaximo,
    required this.gananciaPromedio,
    required this.gananciaDiariaPromedio,
    required this.animalesConGanancia,
  });

  /// Jornada anterior; null en la primera jornada (entrada de datos).
  final DateTime? desde;

  /// Fecha (día de calendario) de esta jornada de pesaje.
  final DateTime hasta;

  /// Animales pesados en esta jornada.
  final int animales;

  final double pesoPromedio;
  final double pesoMinimo;
  final double pesoMaximo;

  /// Promedio de (peso − peso anterior DEL MISMO animal). Null si ningún
  /// animal de la jornada tiene un pesaje previo.
  final double? gananciaPromedio;

  /// Promedio de la ganancia diaria (kg/día) por animal. Null como arriba.
  final double? gananciaDiariaPromedio;

  /// Cuántos animales de la jornada tenían pesaje previo para comparar.
  final int animalesConGanancia;
}

/// Agrupa los pesajes de los animales de un lote en jornadas (por fecha de
/// calendario) y calcula el resumen de cada período. Orden cronológico
/// (jornada más antigua primero).
///
/// Si un animal tiene más de un pesaje el mismo día, se usa el último. La
/// ganancia de cada animal se calcula contra su propio pesaje anterior (en
/// cualquier jornada previa, no necesariamente la inmediata).
List<PeriodoLote> resumenPorPeriodos(List<PesajeDeAnimal> pesajes) {
  if (pesajes.isEmpty) return const [];

  // Por animal: día de calendario → último pesaje de ese día.
  final porAnimal = <String, Map<DateTime, PesajeDeAnimal>>{};
  for (final p in pesajes) {
    final dia = DateTime(p.fecha.year, p.fecha.month, p.fecha.day);
    final delAnimal = porAnimal.putIfAbsent(p.animalId, () => {});
    final existente = delAnimal[dia];
    if (existente == null || p.fecha.isAfter(existente.fecha)) {
      delAnimal[dia] = p;
    }
  }

  final jornadas =
      pesajes
          .map((p) => DateTime(p.fecha.year, p.fecha.month, p.fecha.day))
          .toSet()
          .toList()
        ..sort();

  final resultado = <PeriodoLote>[];
  for (var i = 0; i < jornadas.length; i++) {
    final dia = jornadas[i];
    final pesos = <double>[];
    final ganancias = <double>[];
    final gananciasDiarias = <double>[];

    for (final dias in porAnimal.values) {
      final actual = dias[dia];
      if (actual == null) continue;
      pesos.add(actual.peso);

      // Pesaje previo del mismo animal (la jornada anterior más cercana).
      DateTime? diaPrevio;
      for (final d in dias.keys) {
        if (d.isBefore(dia) && (diaPrevio == null || d.isAfter(diaPrevio))) {
          diaPrevio = d;
        }
      }
      if (diaPrevio != null) {
        final previo = dias[diaPrevio]!;
        final ganancia = actual.peso - previo.peso;
        final numDias = diasCalendario(diaPrevio, dia);
        ganancias.add(ganancia);
        if (numDias >= 1) gananciasDiarias.add(ganancia / numDias);
      }
    }

    double promedio(List<double> xs) => xs.reduce((a, b) => a + b) / xs.length;

    resultado.add(
      PeriodoLote(
        desde: i == 0 ? null : jornadas[i - 1],
        hasta: dia,
        animales: pesos.length,
        pesoPromedio: promedio(pesos),
        pesoMinimo: pesos.reduce((a, b) => a < b ? a : b),
        pesoMaximo: pesos.reduce((a, b) => a > b ? a : b),
        gananciaPromedio: ganancias.isEmpty ? null : promedio(ganancias),
        gananciaDiariaPromedio: gananciasDiarias.isEmpty
            ? null
            : promedio(gananciasDiarias),
        animalesConGanancia: ganancias.length,
      ),
    );
  }
  return resultado;
}
