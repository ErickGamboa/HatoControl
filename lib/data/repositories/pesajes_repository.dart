import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Acceso a animales y pesajes (base local; el sync corre por separado).
class PesajesRepository {
  PesajesRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  /// Busca un animal por su identificador (arete) dentro de una finca.
  /// Devuelve null si no existe.
  Future<AnimalRow?> buscarAnimal(String fincaId, String identificador) {
    return (db.select(db.animales)
          ..where((t) =>
              t.fincaId.equals(fincaId) &
              t.identificador.equals(identificador) &
              t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Crea un animal nuevo en un lote y registra su primer pesaje (peso de
  /// entrada), todo en una transacción. Ambas filas quedan pendientes de subir.
  Future<void> crearAnimalConPesaje({
    required String fincaId,
    required String loteId,
    required String identificador,
    required double peso,
    required String registradoPor,
  }) async {
    final ahora = DateTime.now();
    final animalId = _uuid.v4();
    await db.transaction(() async {
      await db.into(db.animales).insert(AnimalesCompanion.insert(
            id: animalId,
            fincaId: fincaId,
            loteId: loteId,
            identificador: identificador,
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ));
      await db.into(db.pesajes).insert(PesajesCompanion.insert(
            id: _uuid.v4(),
            animalId: animalId,
            peso: peso,
            fecha: ahora,
            registradoPor: Value(registradoPor),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ));
    });
  }

  /// Devuelve el peso del pesaje más reciente de un animal (o null si no tiene
  /// ninguno todavía). Sirve para calcular la ganancia respecto al anterior.
  Future<double?> ultimoPeso(String animalId) async {
    final fila = await (db.select(db.pesajes)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.fecha)])
          ..limit(1))
        .getSingleOrNull();
    return fila?.peso;
  }

  /// Registra un pesaje para un animal existente.
  Future<void> agregarPesaje({
    required String animalId,
    required double peso,
    required String registradoPor,
  }) async {
    final ahora = DateTime.now();
    await db.into(db.pesajes).insert(PesajesCompanion.insert(
          id: _uuid.v4(),
          animalId: animalId,
          peso: peso,
          fecha: ahora,
          registradoPor: Value(registradoPor),
          createdAt: ahora,
          updatedAt: ahora,
          pendiente: const Value(true),
        ));
  }
}
