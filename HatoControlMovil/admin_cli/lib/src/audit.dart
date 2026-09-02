import 'rest_client.dart';
import 'uuid.dart';

/// Inserts one row into `public.admin_audit_log`. Every mutating hatoctl
/// command must call this after the mutation succeeds.
Future<void> writeAuditLog(
  RestClient client, {
  required String actor,
  required String accion,
  required Map<String, dynamic> detalle,
}) async {
  await client.insert('admin_audit_log', {
    'id': generateUuidV4(),
    'actor': actor,
    'accion': accion,
    'detalle': detalle,
    'created_at': DateTime.now().toUtc().toIso8601String(),
  });
}
