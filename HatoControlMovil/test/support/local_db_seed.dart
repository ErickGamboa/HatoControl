import 'package:drift/drift.dart' show Value;
import 'package:hato_control/data/local/database.dart';

/// Seeds plan, cuenta, and usuario for offline integration flows.
Future<void> seedCuentaLocal(
  AppDatabase db, {
  required String usuarioId,
  DateTime? now,
  String cuentaId = 'account-offline-1',
  String email = 'offline@example.com',
  String nombre = 'Usuario Offline',
  int limiteFincas = 20,
}) async {
  final ts = now ?? DateTime(2026, 1, 1);
  await db
      .into(db.planes)
      .insert(
        PlanesCompanion.insert(
          codigo: 'pro',
          nombre: 'Pro',
          limiteFincas: limiteFincas,
          updatedAt: ts,
        ),
      );
  await db
      .into(db.cuentas)
      .insert(
        CuentasCompanion.insert(
          id: cuentaId,
          nombre: 'Cuenta offline',
          duenoId: usuarioId,
          plan: 'pro',
          estado: 'activa',
          createdAt: ts,
          updatedAt: ts,
        ),
      );
  await db
      .into(db.usuarios)
      .insert(
        UsuariosCompanion.insert(
          id: usuarioId,
          nombre: Value(nombre),
          email: Value(email),
          cuentaId: Value(cuentaId),
          createdAt: ts,
          updatedAt: ts,
        ),
      );
}
