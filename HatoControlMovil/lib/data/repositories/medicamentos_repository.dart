import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../estadisticas/estadisticas_sanidad.dart';
import '../local/database.dart';

/// Catálogo de medicamentos por finca (documento oro, Módulo 2).
class MedicamentosRepository {
  MedicamentosRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  Stream<List<MedicamentoRow>> observarMedicamentos(String fincaId) {
    return (db.select(db.medicamentos)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .watch();
  }

  Future<List<MedicamentoRow>> listarMedicamentos(String fincaId) {
    return (db.select(db.medicamentos)
          ..where((t) => t.fincaId.equals(fincaId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nombre)]))
        .get();
  }

  Future<MedicamentoRow?> porId(String id) {
    return (db.select(
      db.medicamentos,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  Future<String> crearMedicamento({
    required String fincaId,
    required String nombre,
    required double costoEnvase,
    required String tipoAplicacion,
    double? mlEnvase,
    double? aplicacionesPorEnvase,
    double? dosisCantidad,
    double? dosisPorCadaKg,
    int diasRetiro = 0,
  }) async {
    final ahora = DateTime.now();
    final id = _uuid.v4();
    await db
        .into(db.medicamentos)
        .insert(
          MedicamentosCompanion.insert(
            id: id,
            fincaId: fincaId,
            nombre: nombre.trim(),
            costoEnvase: costoEnvase,
            tipoAplicacion: tipoAplicacion,
            mlEnvase: Value(mlEnvase),
            aplicacionesPorEnvase: Value(aplicacionesPorEnvase),
            dosisCantidad: Value(dosisCantidad),
            dosisPorCadaKg: Value(dosisPorCadaKg),
            diasRetiro: Value(diasRetiro),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ),
        );
    return id;
  }

  Future<void> editarMedicamento({
    required String medicamentoId,
    required String nombre,
    required double costoEnvase,
    required String tipoAplicacion,
    double? mlEnvase,
    double? aplicacionesPorEnvase,
    double? dosisCantidad,
    double? dosisPorCadaKg,
    int diasRetiro = 0,
  }) async {
    await (db.update(
      db.medicamentos,
    )..where((t) => t.id.equals(medicamentoId))).write(
      MedicamentosCompanion(
        nombre: Value(nombre.trim()),
        costoEnvase: Value(costoEnvase),
        tipoAplicacion: Value(tipoAplicacion),
        mlEnvase: Value(mlEnvase),
        aplicacionesPorEnvase: Value(aplicacionesPorEnvase),
        dosisCantidad: Value(dosisCantidad),
        dosisPorCadaKg: Value(dosisPorCadaKg),
        diasRetiro: Value(diasRetiro),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  Future<void> eliminarMedicamento(String medicamentoId) async {
    await (db.update(
      db.medicamentos,
    )..where((t) => t.id.equals(medicamentoId))).write(
      MedicamentosCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  DosisMedicamentoCalculada dosisParaPeso(MedicamentoRow m, double pesoKg) {
    return calcularDosisMedicamento(
      tipoAplicacion: m.tipoAplicacion,
      costoEnvase: m.costoEnvase,
      pesoKg: pesoKg,
      mlEnvase: m.mlEnvase,
      aplicacionesPorEnvase: m.aplicacionesPorEnvase,
      dosisCantidad: m.dosisCantidad,
      dosisPorCadaKg: m.dosisPorCadaKg,
    );
  }
}
