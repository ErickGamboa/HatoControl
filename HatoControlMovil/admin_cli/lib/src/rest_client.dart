import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when PostgREST returns a non-2xx response. [toString] surfaces the
/// Postgres/PostgREST error message cleanly so callers can print it directly.
class PostgrestException implements Exception {
  PostgrestException({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  @override
  String toString() {
    // PostgREST error bodies look like:
    // {"code":"23503","details":"...","hint":null,"message":"..."}
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final message = decoded['message'];
        final details = decoded['details'];
        final hint = decoded['hint'];
        final code = decoded['code'];
        final parts = <String>[
          'PostgREST error ($statusCode)',
          if (code != null) 'code=$code',
          if (message != null) 'message="$message"',
          if (details != null && details != '') 'details="$details"',
          if (hint != null && hint != '') 'hint="$hint"',
        ];
        return parts.join(', ');
      }
    } catch (_) {
      // Fall through to the raw-body form below.
    }
    return 'PostgREST error ($statusCode): $body';
  }
}

/// Thin client for the Supabase PostgREST HTTP API
/// (`$SUPABASE_URL/rest/v1/<table>`), authenticated as `service_role` (which
/// bypasses RLS).
///
/// Takes an [http.Client] so tests can substitute a fake/mock client instead
/// of making real network calls.
class RestClient {
  RestClient({
    required this.httpClient,
    required String supabaseUrl,
    required this.serviceRoleKey,
  }) : _restRoot = '${supabaseUrl.replaceFirst(RegExp(r'/+$'), '')}/rest/v1';

  final http.Client httpClient;
  final String serviceRoleKey;
  final String _restRoot;

  Map<String, String> _headers({bool returnRepresentation = false}) => {
    'apikey': serviceRoleKey,
    'Authorization': 'Bearer $serviceRoleKey',
    'Content-Type': 'application/json',
    if (returnRepresentation) 'Prefer': 'return=representation',
  };

  Uri _uri(String table, [Map<String, String>? query]) {
    return Uri.parse(
      '$_restRoot/$table',
    ).replace(queryParameters: (query == null || query.isEmpty) ? null : query);
  }

  void _checkOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PostgrestException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
  }

  List<Map<String, dynamic>> _decodeList(http.Response response) {
    if (response.body.trim().isEmpty) return const [];
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw PostgrestException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    return decoded.cast<Map<String, dynamic>>();
  }

  /// `GET /<table>` with the given PostgREST query parameters
  /// (e.g. `{'scope': 'eq.global', 'deleted_at': 'is.null'}`).
  Future<List<Map<String, dynamic>>> select(
    String table,
    Map<String, String> query,
  ) async {
    final response = await httpClient.get(
      _uri(table, query),
      headers: _headers(),
    );
    _checkOk(response);
    return _decodeList(response);
  }

  /// `POST /<table>` with `Prefer: return=representation`, returning the
  /// inserted row(s).
  Future<List<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> body,
  ) async {
    final response = await httpClient.post(
      _uri(table),
      headers: _headers(returnRepresentation: true),
      body: jsonEncode(body),
    );
    _checkOk(response);
    return _decodeList(response);
  }

  /// `PATCH /<table>?<query>` with `Prefer: return=representation`, returning
  /// the updated row(s) (empty list if nothing matched the query).
  Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, String> query,
    Map<String, dynamic> body,
  ) async {
    final response = await httpClient.patch(
      _uri(table, query),
      headers: _headers(returnRepresentation: true),
      body: jsonEncode(body),
    );
    _checkOk(response);
    return _decodeList(response);
  }
}
