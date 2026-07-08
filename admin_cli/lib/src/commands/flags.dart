import '../rest_client.dart';
import '../uuid.dart';

/// Resolved scope + scope_id for a `flags set` invocation.
class ScopeSelection {
  ScopeSelection(this.scope, this.scopeId);

  final String scope; // 'global' | 'cuenta' | 'finca'
  final String? scopeId; // null iff scope == 'global'
}

/// Thrown when the caller didn't pass exactly one of `--global`, `--cuenta`,
/// `--finca`.
class ScopeSelectionException implements Exception {
  ScopeSelectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Validates that exactly one of `--global` / `--cuenta` / `--finca` was
/// given and returns the resolved [ScopeSelection]. Pure logic, no I/O, so
/// it's cheap to unit test directly.
ScopeSelection resolveScope({
  required bool global,
  String? cuentaId,
  String? fincaId,
}) {
  final chosen = <String>[
    if (global) '--global',
    if (cuentaId != null) '--cuenta',
    if (fincaId != null) '--finca',
  ];
  if (chosen.isEmpty) {
    throw ScopeSelectionException(
      'Exactly one of --global, --cuenta <uuid>, --finca <uuid> is required '
      '(none given).',
    );
  }
  if (chosen.length > 1) {
    throw ScopeSelectionException(
      'Exactly one of --global, --cuenta <uuid>, --finca <uuid> is required '
      '(got ${chosen.join(', ')}).',
    );
  }
  if (global) return ScopeSelection('global', null);
  if (cuentaId != null) return ScopeSelection('cuenta', cuentaId);
  return ScopeSelection('finca', fincaId);
}

/// `GET feature_flags`: global rows, plus (if given) the rows for the
/// `cuenta`/`finca` scope requested.
Future<List<Map<String, dynamic>>> listFlags(
  RestClient client, {
  String? cuentaId,
  String? fincaId,
}) async {
  final orParts = <String>['scope.eq.global'];
  if (cuentaId != null) {
    orParts.add('and(scope.eq.cuenta,scope_id.eq.$cuentaId)');
  }
  if (fincaId != null) {
    orParts.add('and(scope.eq.finca,scope_id.eq.$fincaId)');
  }
  final query = <String, String>{
    'select': '*',
    'deleted_at': 'is.null',
    'or': '(${orParts.join(',')})',
    'order': 'scope.asc,clave.asc',
  };
  return client.select('feature_flags', query);
}

/// Outcome of [setFlag]: whether a new row was created or an existing one
/// updated, plus the resulting row (for printing/audit detalle).
class SetFlagResult {
  SetFlagResult({required this.created, required this.row});

  final bool created;
  final Map<String, dynamic> row;
}

/// Upserts `feature_flags` matched by `(scope, scope_id, clave)`: queries
/// first for an existing non-deleted row, PATCHes it if found, otherwise
/// POSTs a new row with a client-generated id.
Future<SetFlagResult> setFlag(
  RestClient client, {
  required String clave,
  required bool habilitado,
  required String scope,
  String? scopeId,
  String? nota,
}) async {
  final matchQuery = <String, String>{
    'select': '*',
    'clave': 'eq.$clave',
    'scope': 'eq.$scope',
    'scope_id': scopeId == null ? 'is.null' : 'eq.$scopeId',
    'deleted_at': 'is.null',
  };
  final existing = await client.select('feature_flags', matchQuery);
  final nowIso = DateTime.now().toUtc().toIso8601String();

  if (existing.isNotEmpty) {
    final id = existing.first['id'];
    final body = <String, dynamic>{
      'habilitado': habilitado,
      'updated_at': nowIso,
    };
    if (nota != null) body['nota'] = nota;
    final updated = await client.update('feature_flags', {
      'id': 'eq.$id',
    }, body);
    return SetFlagResult(created: false, row: updated.first);
  }

  final body = <String, dynamic>{
    'id': generateUuidV4(),
    'scope': scope,
    'scope_id': scopeId,
    'clave': clave,
    'habilitado': habilitado,
    'nota': nota,
    'created_at': nowIso,
    'updated_at': nowIso,
  };
  final created = await client.insert('feature_flags', body);
  return SetFlagResult(created: true, row: created.first);
}
