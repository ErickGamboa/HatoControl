import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../local/database.dart';

/// Estado de la licencia de una cuenta: qué plan tiene, cuántas fincas permite
/// y cuántas tiene usadas. Sirve para mostrar el uso y para validar el límite.
class EstadoLicencia {
  const EstadoLicencia({
    required this.cuentaId,
    required this.planNombre,
    required this.limite,
    required this.usadas,
  });

  final String cuentaId;
  final String planNombre;
  final int limite;
  final int usadas;

  bool get alcanzoLimite => usadas >= limite;
}

/// Se lanza al intentar crear una finca habiendo alcanzado el límite del plan.
class LimiteFincasException implements Exception {
  const LimiteFincasException(this.limite, this.planNombre);
  final int limite;
  final String planNombre;
}

/// Se lanza si todavía no conocemos la cuenta del usuario (no se ha
/// sincronizado). Requiere conectarse a internet una vez.
class LicenciaNoDisponibleException implements Exception {
  const LicenciaNoDisponibleException();
}

/// Acceso a las fincas. SIEMPRE lee y escribe en la base local (instantáneo y
/// offline). La sincronización con Supabase corre por separado (SyncService).
class FincasRepository {
  FincasRepository(this.db);

  final AppDatabase db;
  final _uuid = const Uuid();

  /// Stream reactivo con las fincas del usuario (donde es miembro), no borradas.
  /// La lista se actualiza sola cuando cambian los datos locales.
  Stream<List<FincaRow>> observarFincas(String usuarioId) {
    final consulta = db.select(db.fincas).join([
      innerJoin(
        db.fincaMiembros,
        db.fincaMiembros.fincaId.equalsExp(db.fincas.id),
      ),
    ])
      ..where(db.fincaMiembros.usuarioId.equals(usuarioId) &
          db.fincaMiembros.deletedAt.isNull() &
          db.fincas.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(db.fincas.nombre)]);

    return consulta
        .watch()
        .map((filas) => filas.map((f) => f.readTable(db.fincas)).toList());
  }

  /// Calcula el estado de licencia del usuario (plan, límite y fincas propias
  /// usadas). Devuelve null si todavía no se conoce la cuenta (sin sincronizar).
  Future<EstadoLicencia?> estadoLicencia(String usuarioId) async {
    final usuario = await (db.select(db.usuarios)
          ..where((u) => u.id.equals(usuarioId)))
        .getSingleOrNull();
    final cuentaId = usuario?.cuentaId;
    if (cuentaId == null) return null;

    final cuenta = await (db.select(db.cuentas)
          ..where((c) => c.id.equals(cuentaId)))
        .getSingleOrNull();
    if (cuenta == null) return null;

    final plan = await (db.select(db.planes)
          ..where((p) => p.codigo.equals(cuenta.plan)))
        .getSingleOrNull();

    return EstadoLicencia(
      cuentaId: cuentaId,
      planNombre: plan?.nombre ?? cuenta.plan,
      limite: plan?.limiteFincas ?? 1,
      usadas: await _contarFincasPropias(cuentaId),
    );
  }

  /// Cuenta las fincas PROPIAS de la cuenta (no borradas). Las fincas donde el
  /// usuario solo colabora no cuentan para el límite.
  Future<int> _contarFincasPropias(String cuentaId) async {
    final conteo = db.fincas.id.count();
    final q = db.selectOnly(db.fincas)
      ..addColumns([conteo])
      ..where(db.fincas.cuentaId.equals(cuentaId) &
          db.fincas.deletedAt.isNull());
    final row = await q.getSingle();
    return row.read(conteo) ?? 0;
  }

  /// Crea una finca y, en la misma transacción, agrega al creador como admin.
  /// Valida el límite del plan antes de crear. Ambas filas quedan `pendiente`.
  /// [fotoLocalPath] es opcional: si se pasa, la foto se guarda local y se sube
  /// al sincronizar.
  Future<void> crearFinca({
    required String nombre,
    required String creadaPor,
    String? fotoLocalPath,
  }) async {
    final estado = await estadoLicencia(creadaPor);
    if (estado == null) {
      throw const LicenciaNoDisponibleException();
    }
    if (estado.alcanzoLimite) {
      throw LimiteFincasException(estado.limite, estado.planNombre);
    }

    final ahora = DateTime.now();
    final fincaId = _uuid.v4();
    final tieneFoto = fotoLocalPath != null;

    await db.transaction(() async {
      await db.into(db.fincas).insert(FincasCompanion.insert(
            id: fincaId,
            nombre: nombre,
            creadaPor: creadaPor,
            cuentaId: Value(estado.cuentaId),
            fotoLocalPath: Value(fotoLocalPath),
            fotoPendiente: Value(tieneFoto),
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ));
      await db.into(db.fincaMiembros).insert(FincaMiembrosCompanion.insert(
            id: _uuid.v4(),
            fincaId: fincaId,
            usuarioId: creadaPor,
            rol: 'admin',
            createdAt: ahora,
            updatedAt: ahora,
            pendiente: const Value(true),
          ));
    });
  }
}
