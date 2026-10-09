import 'package:drift/drift.dart';

import '../local/database.dart';

/// Se lanza cuando la fecha que se digitó no puede ser: una fecha que todavía
/// no llega, o algo anterior a que el animal entrara a la finca. [mensaje] ya
/// viene listo para mostrárselo al ganadero.
class FechaInvalidaException implements Exception {
  const FechaInvalidaException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// El día de calendario de [d], sin la hora.
DateTime soloDia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Si [a] y [b] caen el mismo día de calendario.
bool mismoDia(DateTime a, DateTime b) => soloDia(a) == soloDia(b);

/// La hora con que se guarda algo que pasó en [dia].
///
/// Si es hoy, la hora de este momento (así el orden del día se respeta). Si
/// es otro día, el mediodía: el día queda bien parado aunque el registro
/// viaje entre husos horarios, y lo de un día viejo no compite con lo de hoy
/// al ordenar por fecha.
DateTime momentoDe(DateTime dia, {DateTime? ahora}) {
  final n = ahora ?? DateTime.now();
  if (mismoDia(dia, n)) return n;
  return DateTime(dia.year, dia.month, dia.day, 12);
}

/// "21/09/2026", como en el cuaderno.
String fechaCorta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Las reglas que impiden fechas imposibles. Todo lo que se registra con
/// fecha (pesaje, sanidad, movimiento, venta, muerte) pasa por acá, para que
/// la regla sea una sola en toda la app.
class ReglasDeFechas {
  ReglasDeFechas(this.db);

  final AppDatabase db;

  /// Nada se registra con una fecha que todavía no llega.
  void noFutura(DateTime fecha, {DateTime? hoy}) {
    if (soloDia(fecha).isAfter(soloDia(hoy ?? DateTime.now()))) {
      throw const FechaInvalidaException(
        'Esa fecha todavía no llega: escogé hoy o un día anterior.',
      );
    }
  }

  /// Primer día del animal en la finca: lo más temprano entre su fecha de
  /// ingreso (compra o primer movimiento de lote) y su primer pesaje.
  ///
  /// Se toma lo más temprano y no solo la fecha de compra porque hay datos
  /// viejos con la compra corrida hacia adelante: si se mirara solo esa, un
  /// pesaje que ya existía quedaría "antes de que el animal entrara".
  Future<DateTime> primerDia(AnimalRow animal) async {
    final primerMovimiento =
        await (db.select(db.movimientosLote)
              ..where(
                (t) => t.animalId.equals(animal.id) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    final primerPesaje =
        await (db.select(db.pesajes)
              ..where(
                (t) => t.animalId.equals(animal.id) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    final candidatos = [
      ?animal.fechaCompra,
      ?primerMovimiento?.fecha,
      ?primerPesaje?.fecha,
    ];
    if (candidatos.isEmpty) return animal.createdAt;
    return candidatos.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// [fecha] no es futura ni anterior al ingreso del animal.
  Future<AnimalRow> desdeElIngreso(
    String animalId,
    DateTime fecha, {
    DateTime? hoy,
  }) async {
    noFutura(fecha, hoy: hoy);
    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals(animalId))).getSingle();
    final inicio = await primerDia(animal);
    if (soloDia(fecha).isBefore(soloDia(inicio))) {
      throw FechaInvalidaException(
        'El animal ${animal.identificador} entró el ${fechaCorta(inicio)}: '
        'no se puede registrar nada antes de esa fecha.',
      );
    }
    return animal;
  }

  /// [fecha] no es anterior al último pesaje del animal: no se vende ni se
  /// muere antes de la última vez que se pesó.
  Future<void> despuesDelUltimoPesaje(
    AnimalRow animal,
    DateTime fecha, {
    required String que,
  }) async {
    final ultimo =
        await (db.select(db.pesajes)
              ..where(
                (t) => t.animalId.equals(animal.id) & t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    if (ultimo != null && soloDia(fecha).isBefore(soloDia(ultimo.fecha))) {
      throw FechaInvalidaException(
        'El animal ${animal.identificador} tiene un pesaje del '
        '${fechaCorta(ultimo.fecha)}: $que no puede ser antes.',
      );
    }
  }
}
