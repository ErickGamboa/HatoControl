/// Environment/config loading for hatoctl.
///
/// Nothing in this file ever writes secrets to disk or logs their value;
/// callers should only ever print the *names* of env vars, never their
/// contents.
library;

/// Resolved Supabase connection details used to talk to PostgREST.
class SupabaseConfig {
  SupabaseConfig({required this.url, required this.serviceRoleKey});

  final String url;
  final String serviceRoleKey;
}

/// Thrown when a required environment variable is missing or empty.
///
/// [message] is meant to be printed as-is: a single clear line telling the
/// operator which variable to export and where to find the value.
class MissingEnvException implements Exception {
  MissingEnvException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reads [SupabaseConfig] out of [environment] (normally
/// `Platform.environment`), failing with a clear message if either var is
/// missing.
SupabaseConfig loadSupabaseConfig(Map<String, String> environment) {
  final url = environment['SUPABASE_URL'];
  if (url == null || url.trim().isEmpty) {
    throw MissingEnvException(
      'Missing SUPABASE_URL. Export it, e.g.\n'
      '  export SUPABASE_URL="https://<project-ref>.supabase.co"\n'
      'Find it in the Supabase dashboard -> Project Settings -> API.',
    );
  }
  final key = environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (key == null || key.trim().isEmpty) {
    throw MissingEnvException(
      'Missing SUPABASE_SERVICE_ROLE_KEY. Export it (never commit it):\n'
      '  export SUPABASE_SERVICE_ROLE_KEY="<service_role secret key>"\n'
      'Find it in the Supabase dashboard -> Project Settings -> API -> '
      '"service_role" secret key.',
    );
  }
  return SupabaseConfig(
    url: url.trim().replaceFirst(RegExp(r'/+$'), ''),
    serviceRoleKey: key.trim(),
  );
}

/// Resolves the actor name recorded in `admin_audit_log`: `HATOCTL_ACTOR` if
/// set, otherwise the OS username, otherwise `'unknown'`.
String resolveActor(Map<String, String> environment) {
  final actor = environment['HATOCTL_ACTOR'];
  if (actor != null && actor.trim().isNotEmpty) return actor.trim();
  final osUser =
      environment['USER'] ?? environment['USERNAME'] ?? environment['LOGNAME'];
  if (osUser != null && osUser.trim().isNotEmpty) return osUser.trim();
  return 'unknown';
}

/// Returns `HATOCTL_DB_URL` from [environment], or `null` if unset/empty.
String? loadDbUrl(Map<String, String> environment) {
  final url = environment['HATOCTL_DB_URL'];
  if (url == null || url.trim().isEmpty) return null;
  return url.trim();
}

/// The one-line message printed when `db shell` can't find `HATOCTL_DB_URL`.
const String missingDbUrlMessage =
    'Missing HATOCTL_DB_URL. Export the full postgres:// connection string '
    '(never commit it):\n'
    '  export HATOCTL_DB_URL="postgres://...";\n'
    'Find it in the Supabase dashboard -> Project Settings -> Database -> '
    'Connection string.';
