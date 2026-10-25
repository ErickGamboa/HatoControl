import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Unidades en que un ganadero mide el terreno de un lote.
///
/// El terreno se guarda SIEMPRE en metros cuadrados ([Lotes.areaM2]) y la
/// unidad solo dice cómo mostrárselo. Así "Todos" puede sumar un lote medido
/// en hectáreas con otro medido en manzanas sin inventar una conversión al
/// vuelo ni obligar a nadie a digitar en una unidad que no usa.
abstract final class UnidadArea {
  static const hectarea = 'ha';

  /// Manzana: la medida de finca más usada en Costa Rica.
  static const manzana = 'mz';
  static const metrosCuadrados = 'm2';

  static const todas = [hectarea, manzana, metrosCuadrados];

  /// Metros cuadrados que vale una unidad. La manzana son 10.000 varas²
  /// (6.988,96 m²); se usa el valor exacto y no el redondeo de 7.000 para que
  /// el total no se vaya corriendo al sumar varios lotes.
  static const _enM2 = <String, double>{
    hectarea: 10000,
    manzana: 6988.96,
    metrosCuadrados: 1,
  };

  static const _etiquetas = <String, String>{
    hectarea: 'hectáreas',
    manzana: 'manzanas',
    metrosCuadrados: 'm²',
  };

  static const _etiquetasSingular = <String, String>{
    hectarea: 'hectárea',
    manzana: 'manzana',
    metrosCuadrados: 'm²',
  };

  /// Unidad válida o [hectarea] si viene algo desconocido (dato viejo o de
  /// una versión más nueva de la app).
  static String normalizar(String? unidad) =>
      _enM2.containsKey(unidad) ? unidad! : hectarea;

  static double aM2(double valor, String unidad) =>
      valor * _enM2[normalizar(unidad)]!;

  static double desdeM2(double m2, String unidad) =>
      m2 / _enM2[normalizar(unidad)]!;

  static String etiqueta(String unidad, {bool singular = false}) =>
      (singular ? _etiquetasSingular : _etiquetas)[normalizar(unidad)]!;

  /// "2,5 hectáreas" / "1 manzana" / "5.000 m²": el número con la unidad
  /// como se escribe al lado, sin decimales de sobra.
  static String formatear(double m2, String unidad) {
    final valor = desdeM2(m2, unidad);
    final texto = valor == valor.roundToDouble()
        ? valor.round().toString()
        : valor.toStringAsFixed(2);
    return '$texto ${etiqueta(unidad, singular: valor == 1)}';
  }
}

/// Acceso a los lotes de una finca. Lee y escribe en la base local; la
/// sincronización con Supabase corre por separado (SyncService).
class LotesRepository {
  LotesRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  /// Stream reactivo con los lotes (no borrados) de una finca, ordenados por
  /// número y luego por nombre.
  Stream<List<LoteRow>> observarLotes(String fincaId) {
    return (db.select(db.lotes)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.numero),
            (t) => OrderingTerm.asc(t.nombre),
          ]))
        .watch();
  }

  /// Lista (una sola vez) los lotes activos de una finca, ordenados.
  Future<List<LoteRow>> lotesActivos(String fincaId) {
    return (db.select(db.lotes)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.asc(t.numero),
            (t) => OrderingTerm.asc(t.nombre),
          ]))
        .get();
  }

  /// [area] y [areaUnidad] son el terreno en el que se maneja el lote, como
  /// lo digita el ganadero (2 hectáreas, 1 manzana, 5.000 m²). Se guarda
  /// convertido a m²; null = no se registró terreno.
  Future<void> crearLote({
    required String fincaId,
    required String nombre,
    int? numero,
    double? area,
    String? areaUnidad,
  }) async {
    final ahora = DateTime.now();
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: _uuid.v4(),
            fincaId: fincaId,
            nombre: nombre,
            numero: Value(numero),
            areaM2: Value(_aM2(area, areaUnidad)),
            areaUnidad: Value(area == null ? null : _unidad(areaUnidad)),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
  }

  /// Edita nombre, número y/o terreno de un lote. Queda pendiente de
  /// sincronizar.
  Future<void> editarLote({
    required String loteId,
    required String nombre,
    int? numero,
    double? area,
    String? areaUnidad,
  }) async {
    await (db.update(db.lotes)..where((t) => t.id.equals(loteId))).write(
      LotesCompanion(
        nombre: Value(nombre),
        numero: Value(numero),
        areaM2: Value(_aM2(area, areaUnidad)),
        areaUnidad: Value(area == null ? null : _unidad(areaUnidad)),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  /// Lo que se pierde si se elimina el lote: sus animales (activos,
  /// vendidos y muertos) y todo lo que cuelga de ellos. Se le muestra al
  /// ganadero antes de confirmar.
  Future<ResumenBorradoLote> resumenParaBorrar(String loteId) async {
    final animales = await _animalesDelLote(loteId);
    final ids = [for (final a in animales) a.id];
    if (ids.isEmpty) return const ResumenBorradoLote();

    Future<int> contar(TableInfo tabla, Expression<bool> filtro) async {
      final total = countAll();
      final fila =
          await (db.selectOnly(tabla)
                ..addColumns([total])
                ..where(filtro))
              .getSingle();
      return fila.read(total) ?? 0;
    }

    return ResumenBorradoLote(
      animales: animales.length,
      vendidos: animales.where((a) => a.estado == 'vendido').length,
      pesajes: await contar(
        db.pesajes,
        db.pesajes.animalId.isIn(ids) & db.pesajes.deletedAt.isNull(),
      ),
      sanidad: await contar(
        db.eventosSanitarios,
        db.eventosSanitarios.animalId.isIn(ids) &
            db.eventosSanitarios.deletedAt.isNull(),
      ),
    );
  }

  /// Elimina el lote y todo lo de los animales que están en él: los animales
  /// (activos, vendidos y muertos), sus pesajes, su sanidad, sus ventas, sus
  /// otros costos, sus cargos de gastos fijos y su historial de movimientos.
  /// Los grupos de venta que se quedan sin ninguna venta también se van.
  ///
  /// Es borrado suave (`deletedAt`) y sincroniza como cualquier cambio, así
  /// que se borra también en la nube y en los otros aparatos.
  ///
  /// No toca el historial de dietas del lote: los animales que pasaron por él
  /// y ahora están en otro lote siguen debiendo esa comida.
  Future<void> eliminarLoteConTodo(String loteId) async {
    final ahora = DateTime.now();
    await db.transaction(() async {
      final animales = await _animalesDelLote(loteId);
      final ids = [for (final a in animales) a.id];
      if (ids.isNotEmpty) {
        await (db.update(
          db.pesajes,
        )..where((t) => t.animalId.isIn(ids) & t.deletedAt.isNull())).write(
          PesajesCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
        await (db.update(
          db.eventosSanitarios,
        )..where((t) => t.animalId.isIn(ids) & t.deletedAt.isNull())).write(
          EventosSanitariosCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
        await (db.update(
          db.movimientosLote,
        )..where((t) => t.animalId.isIn(ids) & t.deletedAt.isNull())).write(
          MovimientosLoteCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
        await (db.update(
          db.costosOtros,
        )..where((t) => t.animalId.isIn(ids) & t.deletedAt.isNull())).write(
          CostosOtrosCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
        await (db.update(
          db.gastoFijoCargos,
        )..where((t) => t.animalId.isIn(ids) & t.deletedAt.isNull())).write(
          GastoFijoCargosCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );

        final ventas = await (db.select(
          db.ventas,
        )..where((t) => t.animalId.isIn(ids) & t.deletedAt.isNull())).get();
        await (db.update(
          db.ventas,
        )..where((t) => t.animalId.isIn(ids) & t.deletedAt.isNull())).write(
          VentasCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
        // Grupos de venta que quedaron sin ninguna venta.
        final grupos = {
          for (final v in ventas)
            if (v.loteVentaId != null) v.loteVentaId!,
        };
        for (final grupo in grupos) {
          final quedan =
              await (db.select(db.ventas)
                    ..where(
                      (t) => t.loteVentaId.equals(grupo) & t.deletedAt.isNull(),
                    )
                    ..limit(1))
                  .getSingleOrNull();
          if (quedan != null) continue;
          await (db.update(
            db.lotesVenta,
          )..where((t) => t.id.equals(grupo) & t.deletedAt.isNull())).write(
            LotesVentaCompanion(
              deletedAt: Value(ahora),
              updatedAt: Value(ahora),
              pendiente: const Value(true),
            ),
          );
        }

        await (db.update(db.animales)..where((t) => t.id.isIn(ids))).write(
          AnimalesCompanion(
            deletedAt: Value(ahora),
            updatedAt: Value(ahora),
            pendiente: const Value(true),
          ),
        );
      }
      await (db.update(db.lotes)..where((t) => t.id.equals(loteId))).write(
        LotesCompanion(
          deletedAt: Value(ahora),
          updatedAt: Value(ahora),
          pendiente: const Value(true),
        ),
      );
    });
  }

  Future<List<AnimalRow>> _animalesDelLote(String loteId) {
    return (db.select(
      db.animales,
    )..where((t) => t.loteId.equals(loteId) & t.deletedAt.isNull())).get();
  }

  static String _unidad(String? unidad) => UnidadArea.normalizar(unidad);

  static double? _aM2(double? area, String? unidad) =>
      area == null || area <= 0 ? null : UnidadArea.aM2(area, _unidad(unidad));
}

/// Lo que se pierde al eliminar un lote (ver
/// [LotesRepository.resumenParaBorrar]).
class ResumenBorradoLote {
  const ResumenBorradoLote({
    this.animales = 0,
    this.vendidos = 0,
    this.pesajes = 0,
    this.sanidad = 0,
  });

  /// Todos los animales del lote, incluidos los [vendidos] y los muertos.
  final int animales;
  final int vendidos;
  final int pesajes;
  final int sanidad;
}
