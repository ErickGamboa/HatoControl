import 'package:supabase_flutter/supabase_flutter.dart';

/// Polls Supabase until a row appears (sync finished) or [timeout] elapses.
Future<Map<String, dynamic>> waitForSupabaseRow({
  required String table,
  required String column,
  required Object equals,
  Duration timeout = const Duration(seconds: 40),
  Duration interval = const Duration(seconds: 2),
}) async {
  final client = Supabase.instance.client;
  final end = DateTime.now().add(timeout);
  Object? lastError;

  while (DateTime.now().isBefore(end)) {
    try {
      final rows = await client
          .from(table)
          .select()
          .eq(column, equals)
          .isFilter('deleted_at', null)
          .limit(1);
      if (rows.isNotEmpty) {
        return Map<String, dynamic>.from(rows.first as Map);
      }
    } catch (e) {
      lastError = e;
    }
    await Future<void>.delayed(interval);
  }

  throw StateError(
    'Timeout esperando fila en $table donde $column=$equals. '
    'Último error: $lastError',
  );
}

Future<List<Map<String, dynamic>>> listSupabaseRows({
  required String table,
  required String column,
  required Object equals,
}) async {
  final rows = await Supabase.instance.client
      .from(table)
      .select()
      .eq(column, equals)
      .isFilter('deleted_at', null);
  return [for (final r in rows) Map<String, dynamic>.from(r as Map)];
}
