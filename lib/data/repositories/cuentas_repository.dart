import 'package:drift/drift.dart';

import '../local/database.dart';

/// Acceso a la cuenta del usuario actual desde la base local.
class CuentasRepository {
  CuentasRepository(this.db);

  final AppDatabase db;

  /// Stream reactivo con la cuenta propia del usuario. Emite null si todavía
  /// no se conoce (no sincronizada). Se actualiza solo cuando cambia (p. ej.
  /// el admin la suspende y se sincroniza).
  Stream<CuentaRow?> observarMiCuenta(String usuarioId) {
    final consulta = db.select(db.usuarios).join([
      innerJoin(
        db.cuentas,
        db.cuentas.id.equalsExp(db.usuarios.cuentaId),
      ),
    ])
      ..where(db.usuarios.id.equals(usuarioId));

    return consulta
        .watchSingleOrNull()
        .map((fila) => fila?.readTable(db.cuentas));
  }
}
