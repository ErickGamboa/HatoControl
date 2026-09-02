import 'dart:io';

/// Execs `psql "$HATOCTL_DB_URL"` with inherited stdio, returning its exit
/// code. This is a thin wrapper only — hatoctl doesn't implement its own
/// query engine.
Future<int> runDbShell(String dbUrl) async {
  final process = await Process.start('psql', [
    dbUrl,
  ], mode: ProcessStartMode.inheritStdio);
  return process.exitCode;
}
