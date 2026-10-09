import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/cambios_en_tablas.dart';
import '../local/database.dart';
import 'reglas_de_fechas.dart';

/// Dieta vigente de un lote con su nombre y costo congelado al asignar.
class DietaVigenteLote {
  const DietaVigenteLote({required this.asignacion, required this.dieta});

  final LoteDietaRow asignacion;
  final DietaRow dieta;
}

/// Dieta recibida por un animal vía los lotes donde estuvo (D-05).
class DietaRecibidaAnimal {
  const DietaRecibidaAnimal({
    required this.loteNombre,
    required this.dietaNombre,
    required this.desde,
    required this.hasta,
    required this.costoAnimalDia,
  });

  final String loteNombre;
  final String dietaNombre;
  final DateTime desde;
  final DateTime? hasta;
  final double costoAnimalDia;
}

/// Acceso local a dietas y asignaciones lote-dieta. Sync corre por separado.
class DietasRepository {
  DietasRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  Stream<List<DietaRow>> observarDietas(String fincaId) {
    return (db.select(db.dietas)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  /// El ganadero digita [costoKg] (₡ por kilo de alimento) y [kgAnimalDia]
  /// (kilos que recibe cada animal por día). De ahí sale el costo por animal:
  /// día = ₡/kg × kg/día, semana = día × 7.
  /// [ingredientes] son solo nombres informativos (costo de ingrediente = 0).
  Future<void> crearDieta({
    required String fincaId,
    required String nombre,
    String? descripcion,
    required double costoKg,
    required double kgAnimalDia,
    String moneda = 'CRC',
    List<String> ingredientes = const [],
  }) async {
    final ahora = DateTime.now();
    final costoDia = costoKg * kgAnimalDia;
    final costoSemana = costoDia * 7;
    final dietaId = _uuid.v4();
    await db.transaction(() async {
      await db
          .into(db.dietas)
          .insert(
            DietasCompanion.insert(
              id: dietaId,
              fincaId: fincaId,
              nombre: nombre,
              descripcion: Value(descripcion),
              costoKg: Value(costoKg),
              kgAnimalDia: Value(kgAnimalDia),
              costoAnimalSemana: Value(costoSemana),
              costoAnimalDia: costoDia,
              moneda: Value(moneda),
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
      for (final nombreIng in ingredientes) {
        final n = nombreIng.trim();
        if (n.isEmpty) continue;
        await db
            .into(db.dietaIngredientes)
            .insert(
              DietaIngredientesCompanion.insert(
                id: _uuid.v4(),
                dietaId: dietaId,
                nombre: n,
                costoAnimalDia: const Value(0),
                createdAt: ahora,
                updatedAt: ahora,
                pendiente: const Value(true),
              ),
            );
      }
    });
  }

  Stream<List<DietaIngredienteRow>> observarIngredientes(String dietaId) {
    return (db.select(db.dietaIngredientes)
          ..where((t) => t.dietaId.equals(dietaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  Future<List<DietaIngredienteRow>> listarIngredientes(String dietaId) {
    return (db.select(db.dietaIngredientes)
          ..where((t) => t.dietaId.equals(dietaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .get();
  }

  /// Reemplaza ingredientes (solo nombres). No toca el costo de la dieta.
  Future<void> reemplazarIngredientes({
    required String dietaId,
    required List<String> ingredientes,
  }) async {
    final ahora = DateTime.now();
    await db.transaction(() async {
      final viejos = await (db.select(
        db.dietaIngredientes,
      )..where((t) => t.dietaId.equals(dietaId) & t.deletedAt.isNull())).get();
      for (final v in viejos) {
        await (db.update(
          db.dietaIngredientes,
        )..where((t) => t.id.equals(v.id))).write(
          DietaIngredientesCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }
      for (final nombreIng in ingredientes) {
        final n = nombreIng.trim();
        if (n.isEmpty) continue;
        await db
            .into(db.dietaIngredientes)
            .insert(
              DietaIngredientesCompanion.insert(
                id: _uuid.v4(),
                dietaId: dietaId,
                nombre: n,
                costoAnimalDia: const Value(0),
                createdAt: ahora,
                updatedAt: ahora,
                pendiente: const Value(true),
              ),
            );
      }
    });
  }

  Future<void> editarDieta({
    required String dietaId,
    required String nombre,
    String? descripcion,
    required double costoKg,
    required double kgAnimalDia,
    String moneda = 'CRC',
  }) async {
    final costoDia = costoKg * kgAnimalDia;
    await (db.update(db.dietas)..where((t) => t.id.equals(dietaId))).write(
      DietasCompanion(
        nombre: Value(nombre),
        descripcion: Value(descripcion),
        costoKg: Value(costoKg),
        kgAnimalDia: Value(kgAnimalDia),
        costoAnimalSemana: Value(costoDia * 7),
        costoAnimalDia: Value(costoDia),
        moneda: Value(moneda),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  /// Cierra la dieta vigente del lote (queda sin dieta) el día [hasta] (hoy
  /// si no se dice). El historial se conserva.
  Future<void> quitarDietaDeLote(String loteId, {DateTime? hasta}) async {
    final ahora = DateTime.now();
    final dia = hasta ?? ahora;
    ReglasDeFechas(db).noFutura(dia, hoy: ahora);
    final vigente =
        await (db.select(db.loteDietas)..where(
              (t) =>
                  t.loteId.equals(loteId) &
                  t.hasta.isNull() &
                  t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (vigente == null) return;
    if (soloDia(dia).isBefore(soloDia(vigente.desde))) {
      throw FechaInvalidaException(
        'La dieta actual empezó el ${fechaCorta(vigente.desde)}: no se puede '
        'quitar antes de esa fecha.',
      );
    }
    final cuando = momentoDe(dia, ahora: ahora);
    await (db.update(
      db.loteDietas,
    )..where((t) => t.id.equals(vigente.id))).write(
      LoteDietasCompanion(
        hasta: Value(cuando.isBefore(vigente.desde) ? vigente.desde : cuando),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  /// Asigna una dieta a un lote desde el día [desde] (hoy si no se dice):
  /// cierra la anterior ese mismo día y abre una nueva con el costo congelado
  /// (D-02). Todo en una transacción.
  ///
  /// Sirve para pasar a la app una dieta que el lote ya venía comiendo: se
  /// le cobra desde el día real. No se permite ir más atrás que el inicio de
  /// la dieta anterior, porque esa ya cobró esos días.
  Future<void> asignarDietaALote({
    required String loteId,
    required String dietaId,
    DateTime? desde,
  }) async {
    final dieta = await (db.select(
      db.dietas,
    )..where((t) => t.id.equals(dietaId) & t.deletedAt.isNull())).getSingle();
    final ahora = DateTime.now();
    final dia = desde ?? ahora;
    ReglasDeFechas(db).noFutura(dia, hoy: ahora);

    await db.transaction(() async {
      // La asignación más reciente del lote, esté abierta o ya cerrada.
      final ultima =
          await (db.select(db.loteDietas)
                ..where((t) => t.loteId.equals(loteId) & t.deletedAt.isNull())
                ..orderBy([(t) => OrderingTerm.desc(t.desde)])
                ..limit(1))
              .getSingleOrNull();
      // La misma dieta que ya tiene, pero desde antes: se corrige el inicio
      // de la que está (se asignó hoy y en realidad la comen desde hace días).
      if (ultima != null &&
          ultima.hasta == null &&
          ultima.dietaId == dietaId &&
          soloDia(dia).isBefore(soloDia(ultima.desde))) {
        await _adelantarInicio(ultima, dia, ahora);
        return;
      }
      if (ultima != null && soloDia(dia).isBefore(soloDia(ultima.desde))) {
        final nombre = await (db.select(
          db.dietas,
        )..where((t) => t.id.equals(ultima.dietaId))).getSingleOrNull();
        throw FechaInvalidaException(
          'La dieta "${nombre?.nombre ?? 'anterior'}" empezó el '
          '${fechaCorta(ultima.desde)}: la nueva no puede empezar antes.',
        );
      }
      if (ultima != null && ultima.hasta == null && ultima.dietaId == dietaId) {
        return;
      }

      var cuando = momentoDe(dia, ahora: ahora);
      if (ultima != null && cuando.isBefore(ultima.desde)) {
        cuando = ultima.desde;
      }
      // La anterior termina el día en que empieza la nueva: abierta, o
      // cerrada después de esa fecha (se había quitado más tarde).
      if (ultima != null &&
          (ultima.hasta == null || ultima.hasta!.isAfter(cuando))) {
        await (db.update(
          db.loteDietas,
        )..where((t) => t.id.equals(ultima.id))).write(
          LoteDietasCompanion(
            hasta: Value(cuando),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }

      await db
          .into(db.loteDietas)
          .insert(
            LoteDietasCompanion.insert(
              id: _uuid.v4(),
              loteId: loteId,
              dietaId: dietaId,
              desde: cuando,
              costoAnimalDiaSnapshot: dieta.costoAnimalDia,
              createdAt: ahora,
              updatedAt: ahora,
              pendiente: const Value(true),
            ),
          );
    });
  }

  /// Mueve hacia atrás el inicio de la asignación [actual] al día [dia]. La
  /// asignación anterior del lote, si la hay, termina ese mismo día; si
  /// empezó después de [dia], no se puede (esos días ya los cobró ella).
  Future<void> _adelantarInicio(
    LoteDietaRow actual,
    DateTime dia,
    DateTime ahora,
  ) async {
    final anterior =
        await (db.select(db.loteDietas)
              ..where(
                (t) =>
                    t.loteId.equals(actual.loteId) &
                    t.deletedAt.isNull() &
                    t.id.equals(actual.id).not() &
                    t.desde.isSmallerOrEqualValue(actual.desde),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.desde)])
              ..limit(1))
            .getSingleOrNull();
    if (anterior != null && soloDia(dia).isBefore(soloDia(anterior.desde))) {
      throw FechaInvalidaException(
        'La dieta anterior de este lote empezó el '
        '${fechaCorta(anterior.desde)}: esta no puede empezar antes.',
      );
    }
    var cuando = momentoDe(dia, ahora: ahora);
    if (anterior != null && cuando.isBefore(anterior.desde)) {
      cuando = anterior.desde;
    }
    if (anterior != null &&
        (anterior.hasta == null || anterior.hasta!.isAfter(cuando))) {
      await (db.update(
        db.loteDietas,
      )..where((t) => t.id.equals(anterior.id))).write(
        LoteDietasCompanion(
          hasta: Value(cuando),
          updatedAt: Value(ahora),
          pendiente: const Value(true),
        ),
      );
    }
    await (db.update(
      db.loteDietas,
    )..where((t) => t.id.equals(actual.id))).write(
      LoteDietasCompanion(
        desde: Value(cuando),
        updatedAt: Value(ahora),
        pendiente: const Value(true),
      ),
    );
  }

  /// Stream con la dieta vigente del lote, o null si no tiene asignación.
  Stream<DietaVigenteLote?> observarDietaVigente(String loteId) {
    final consulta = db.select(db.loteDietas)
      ..where(
        (t) =>
            t.loteId.equals(loteId) & t.hasta.isNull() & t.deletedAt.isNull(),
      );

    // También se escucha `dietas`: el nombre y el costo salen de ahí, y si
    // solo se mirara la asignación, editar la dieta no movería la tarjeta.
    return db
        .cambiosEn('dieta_vigente', {db.loteDietas, db.dietas})
        .asyncMap((_) => consulta.get())
        .asyncMap((filas) async {
          if (filas.isEmpty) return null;
          final asignacion = filas.first;
          final dieta = await (db.select(
            db.dietas,
          )..where((t) => t.id.equals(asignacion.dietaId))).getSingleOrNull();
          if (dieta == null || dieta.deletedAt != null) return null;
          return DietaVigenteLote(asignacion: asignacion, dieta: dieta);
        });
  }

  /// Historial de asignaciones de dieta de un lote (más reciente primero).
  Stream<List<LoteDietaRow>> observarHistorialDietaLote(String loteId) {
    return (db.select(db.loteDietas)
          ..where((t) => t.loteId.equals(loteId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.desde)]))
        .watch();
  }

  /// Dietas que recibió un animal según los lotes por los que pasó y las
  /// asignaciones vigentes en cada periodo.
  Stream<List<DietaRecibidaAnimal>> observarDietasRecibidas(String animalId) {
    final movimientos = db.select(db.movimientosLote)
      ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.fecha)]);

    // Los cuatro ingredientes del cálculo: por dónde pasó el animal, qué
    // dieta tenía cada lote, y cómo se llaman dieta y lote. Si cambia
    // cualquiera, la ficha del animal tiene que mostrarlo.
    return db
        .cambiosEn('dietas_recibidas', {
          db.movimientosLote,
          db.loteDietas,
          db.dietas,
          db.lotes,
        })
        .asyncMap((_) => movimientos.get())
        .asyncMap((movs) async {
          if (movs.isEmpty) return const <DietaRecibidaAnimal>[];
          final catalogo = await _catalogoDeLotes(
            movs.map((m) => m.loteDestino).toSet(),
          );
          return dietasRecibidasCon(
            movimientos: movs,
            catalogo: catalogo,
            ahora: DateTime.now(),
          );
        });
  }

  /// Lo mismo que [observarDietasRecibidas] pero para TODOS los animales de
  /// una finca de una sola pasada: 4 consultas en total en vez de varias por
  /// animal.
  ///
  /// Lo usa Análisis financiero, que calcula la finca entera. El cálculo en sí
  /// es el mismo de siempre ([dietasRecibidasCon]), así que la ficha del
  /// animal y el análisis no se pueden separar.
  Future<Map<String, List<DietaRecibidaAnimal>>> dietasRecibidasDeFinca(
    String fincaId, {
    DateTime? ahora,
  }) async {
    final filas =
        await (db.select(db.movimientosLote).join([
                innerJoin(
                  db.animales,
                  db.animales.id.equalsExp(db.movimientosLote.animalId),
                ),
              ])
              ..where(
                db.animales.fincaId.equals(fincaId) &
                    db.movimientosLote.deletedAt.isNull(),
              )
              ..orderBy([OrderingTerm.asc(db.movimientosLote.fecha)]))
            .get();

    final porAnimal = <String, List<MovimientoLoteRow>>{};
    for (final f in filas) {
      final mov = f.readTable(db.movimientosLote);
      (porAnimal[mov.animalId] ??= []).add(mov);
    }
    if (porAnimal.isEmpty) return const {};

    final catalogo = await _catalogoDeLotes({
      for (final movs in porAnimal.values)
        for (final m in movs) m.loteDestino,
    });
    final momento = ahora ?? DateTime.now();

    return {
      for (final entrada in porAnimal.entries)
        entrada.key: dietasRecibidasCon(
          movimientos: entrada.value,
          catalogo: catalogo,
          ahora: momento,
        ),
    };
  }

  /// Asignaciones, dietas y nombres de lote que hacen falta para calcular las
  /// dietas recibidas, en tres consultas.
  Future<CatalogoDietasLotes> _catalogoDeLotes(Set<String> loteIds) async {
    if (loteIds.isEmpty) return const CatalogoDietasLotes.vacio();
    final ids = loteIds.toList();

    final asignaciones = await (db.select(
      db.loteDietas,
    )..where((t) => t.loteId.isIn(ids) & t.deletedAt.isNull())).get();

    final dietasFilas =
        await (db.select(db.dietas)..where(
              (t) =>
                  t.id.isIn(asignaciones.map((a) => a.dietaId).toList()) &
                  t.deletedAt.isNull(),
            ))
            .get();

    final lotesFilas = await (db.select(
      db.lotes,
    )..where((t) => t.id.isIn(ids))).get();

    final porLote = <String, List<LoteDietaRow>>{};
    for (final a in asignaciones) {
      (porLote[a.loteId] ??= []).add(a);
    }

    return CatalogoDietasLotes(
      asignacionesPorLote: porLote,
      dietasPorId: {for (final d in dietasFilas) d.id: d},
      lotesPorId: {for (final l in lotesFilas) l.id: l},
    );
  }
}

/// Asignaciones de dieta, dietas y lotes ya cargados, para calcular las dietas
/// recibidas sin volver a la base.
class CatalogoDietasLotes {
  const CatalogoDietasLotes({
    required this.asignacionesPorLote,
    required this.dietasPorId,
    required this.lotesPorId,
  });

  const CatalogoDietasLotes.vacio()
    : asignacionesPorLote = const {},
      dietasPorId = const {},
      lotesPorId = const {};

  /// Asignaciones vivas (no borradas) de cada lote.
  final Map<String, List<LoteDietaRow>> asignacionesPorLote;

  /// Solo dietas vivas: una borrada no cuenta, igual que antes.
  final Map<String, DietaRow> dietasPorId;
  final Map<String, LoteRow> lotesPorId;
}

/// Las dietas que recibió un animal, a partir de sus movimientos de lote y del
/// catálogo ya cargado. **Función pura**: no toca la base.
///
/// Es el único lugar donde vive esta regla. La ficha del animal la llama con
/// los datos de un animal y Análisis financiero con los de toda la finca, así
/// que las dos pantallas no pueden decir cosas distintas.
///
/// [movimientos] tiene que venir ordenado por fecha ascendente, y [ahora] es
/// el "hoy" contra el que se miden las asignaciones sin fecha de fin.
List<DietaRecibidaAnimal> dietasRecibidasCon({
  required List<MovimientoLoteRow> movimientos,
  required CatalogoDietasLotes catalogo,
  required DateTime ahora,
}) {
  if (movimientos.isEmpty) return const [];

  final resultado = <DietaRecibidaAnimal>[];
  for (var i = 0; i < movimientos.length; i++) {
    final mov = movimientos[i];
    final periodoFin = i + 1 < movimientos.length
        ? movimientos[i + 1].fecha
        : null;
    final hasta = periodoFin ?? ahora;

    final asignaciones =
        catalogo.asignacionesPorLote[mov.loteDestino] ?? const [];
    for (final asig in asignaciones) {
      if (asig.desde.isAfter(hasta)) continue;

      final finAsig = asig.hasta;
      if (finAsig != null && finAsig.isBefore(mov.fecha)) continue;
      if (periodoFin != null &&
          finAsig != null &&
          finAsig.isBefore(periodoFin) &&
          finAsig.isBefore(mov.fecha)) {
        continue;
      }

      final dieta = catalogo.dietasPorId[asig.dietaId];
      if (dieta == null) continue;

      resultado.add(
        DietaRecibidaAnimal(
          loteNombre: catalogo.lotesPorId[mov.loteDestino]?.nombre ?? 'Lote',
          dietaNombre: dieta.nombre,
          desde: mov.fecha.isAfter(asig.desde) ? mov.fecha : asig.desde,
          hasta: _finPeriodo(periodoFin, asig.hasta),
          costoAnimalDia: asig.costoAnimalDiaSnapshot,
        ),
      );
    }
  }
  return resultado;
}

DateTime? _finPeriodo(DateTime? finMovimiento, DateTime? finAsignacion) {
  if (finMovimiento == null && finAsignacion == null) return null;
  if (finMovimiento == null) return finAsignacion;
  if (finAsignacion == null) return finMovimiento;
  return finMovimiento.isBefore(finAsignacion) ? finMovimiento : finAsignacion;
}
