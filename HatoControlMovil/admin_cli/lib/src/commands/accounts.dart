import '../rest_client.dart';

/// Thrown when a `PATCH public.cuentas` matches zero rows. PostgREST returns
/// an empty array (HTTP 200/204) on no-match rather than an error, so callers
/// must check for this explicitly instead of treating an empty response as
/// silent success.
class AccountNotFoundException implements Exception {
  AccountNotFoundException(this.cuentaId);

  final String cuentaId;

  @override
  String toString() => 'Account not found: $cuentaId';
}

/// `PATCH public.cuentas set plan=<plan> where id=<cuentaId>`. Postgres-side
/// FK/check constraint violations on `plan` propagate as [PostgrestException]
/// from the underlying [RestClient.update] call.
Future<Map<String, dynamic>> setAccountPlan(
  RestClient client, {
  required String cuentaId,
  required String plan,
}) async {
  final result = await client.update(
    'cuentas',
    {'id': 'eq.$cuentaId'},
    {'plan': plan},
  );
  if (result.isEmpty) {
    throw AccountNotFoundException(cuentaId);
  }
  return result.first;
}
