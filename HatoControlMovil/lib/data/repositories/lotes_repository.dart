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

  static String _unidad(String? unidad) => UnidadArea.normalizar(unidad);

  static double? _aM2(double? area, String? unidad) =>
      area == null || area <= 0 ? null : UnidadArea.aM2(area, _unidad(unidad));
}
