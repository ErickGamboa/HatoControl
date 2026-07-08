import 'package:drift/drift.dart';

import '../local/database.dart';

/// Acceso local a `feature_flags` (D-15). Solo lectura: la tabla la escribe
/// el CLI (`hatoctl`) vía `service_role`, la app nunca la modifica, solo
/// consume lo que baja el sync.
class FeatureFlagsRepository {
  FeatureFlagsRepository(this.db);

  final AppDatabase db;

  /// Todas las flags sincronizadas localmente (no borradas).
  Stream<List<FeatureFlagRow>> observarFlags() {
    return (db.select(
      db.featureFlags,
    )..where((t) => t.deletedAt.isNull())).watch();
  }

  /// Resuelve si `clave` está habilitada, con precedencia
  /// **finca > cuenta > global > [defaultValue]** (fail-open, D-15): si no
  /// hay fila para `clave` en ningún scope, se asume habilitado (o lo que
  /// diga [defaultValue]) para no bloquear el módulo por un flag ausente.
  Future<bool> isEnabled(
    String clave, {
    String? fincaId,
    String? cuentaId,
    bool defaultValue = true,
  }) async {
    final filas = await (db.select(
      db.featureFlags,
    )..where((t) => t.clave.equals(clave) & t.deletedAt.isNull())).get();
    return resolverPrecedenciaFlag(
      filas,
      fincaId: fincaId,
      cuentaId: cuentaId,
      defaultValue: defaultValue,
    );
  }
}

/// Función pura que aplica la precedencia finca > cuenta > global sobre las
/// filas ya cargadas de `feature_flags` para una sola `clave`. Separada de
/// [FeatureFlagsRepository.isEnabled] para poder testear la lógica de
/// resolución sin depender de Drift.
bool resolverPrecedenciaFlag(
  List<FeatureFlagRow> filas, {
  String? fincaId,
  String? cuentaId,
  bool defaultValue = true,
}) {
  FeatureFlagRow? buscar(String scope, String? scopeId) {
    for (final fila in filas) {
      if (fila.scope == scope && fila.scopeId == scopeId) return fila;
    }
    return null;
  }

  if (fincaId != null) {
    final fila = buscar('finca', fincaId);
    if (fila != null) return fila.habilitado;
  }
  if (cuentaId != null) {
    final fila = buscar('cuenta', cuentaId);
    if (fila != null) return fila.habilitado;
  }
  final global = buscar('global', null);
  if (global != null) return global.habilitado;

  return defaultValue;
}
