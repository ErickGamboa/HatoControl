import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:hatoctl/src/audit.dart';
import 'package:hatoctl/src/commands/accounts.dart';
import 'package:hatoctl/src/commands/db_shell.dart';
import 'package:hatoctl/src/commands/flags.dart';
import 'package:hatoctl/src/env.dart';
import 'package:hatoctl/src/rest_client.dart';
import 'package:hatoctl/src/table.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> arguments) async {
  final runner =
      CommandRunner<int>(
          'hatoctl',
          'Admin CLI for HatoControl feature flags and account/plan management.',
        )
        ..addCommand(FlagsCommand())
        ..addCommand(AccountsCommand())
        ..addCommand(DbCommand());

  try {
    final code = await runner.run(arguments);
    exit(code ?? 0);
  } on UsageException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln();
    stderr.writeln(e.usage);
    exit(64);
  } on MissingEnvException catch (e) {
    stderr.writeln(e.message);
    exit(1);
  } on ScopeSelectionException catch (e) {
    stderr.writeln('Error: $e');
    exit(64);
  } on AccountNotFoundException catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  } on PostgrestException catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  }
}

RestClient _buildClient(SupabaseConfig config) => RestClient(
  httpClient: http.Client(),
  supabaseUrl: config.url,
  serviceRoleKey: config.serviceRoleKey,
);

const _jsonPretty = JsonEncoder.withIndent('  ');

class FlagsCommand extends Command<int> {
  FlagsCommand() {
    addSubcommand(FlagsListCommand());
    addSubcommand(FlagsSetCommand());
  }

  @override
  final name = 'flags';

  @override
  final description = 'Manage feature flags (global/cuenta/finca scoped).';
}

class FlagsListCommand extends Command<int> {
  FlagsListCommand() {
    argParser
      ..addOption(
        'cuenta',
        help: 'Also include rows scoped to this cuenta uuid.',
      )
      ..addOption(
        'finca',
        help: 'Also include rows scoped to this finca uuid.',
      );
  }

  @override
  final name = 'list';

  @override
  final description =
      'List feature flags: global rows, plus --cuenta/--finca scoped rows if given.';

  @override
  Future<int> run() async {
    final config = loadSupabaseConfig(Platform.environment);
    final client = _buildClient(config);
    try {
      final rows = await listFlags(
        client,
        cuentaId: argResults!['cuenta'] as String?,
        fincaId: argResults!['finca'] as String?,
      );
      final tableRows = rows
          .map(
            (r) => [
              '${r['scope'] ?? ''}',
              '${r['scope_id'] ?? ''}',
              '${r['clave'] ?? ''}',
              '${r['habilitado'] ?? ''}',
              '${r['nota'] ?? ''}',
              '${r['updated_at'] ?? ''}',
            ],
          )
          .toList();
      print(
        renderTable(const [
          'scope',
          'scope_id',
          'clave',
          'habilitado',
          'nota',
          'updated_at',
        ], tableRows),
      );
      return 0;
    } finally {
      client.httpClient.close();
    }
  }
}

class FlagsSetCommand extends Command<int> {
  FlagsSetCommand() {
    argParser
      ..addFlag('global', help: 'Target the global scope.', negatable: false)
      ..addOption('cuenta', help: 'Target this cuenta uuid scope.')
      ..addOption('finca', help: 'Target this finca uuid scope.')
      ..addOption('nota', help: 'Optional free-text note.');
  }

  @override
  final name = 'set';

  @override
  final description = 'Upsert a feature flag value for exactly one scope.';

  @override
  final invocation =
      'hatoctl flags set <clave> <on|off> (--global | --cuenta <uuid> | --finca <uuid>) [--nota "<text>"]';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.length != 2) {
      usageException(
        'Expected exactly 2 positional arguments: <clave> <on|off>.',
      );
    }
    final clave = rest[0];
    final onOff = rest[1];
    final bool habilitado;
    if (onOff == 'on') {
      habilitado = true;
    } else if (onOff == 'off') {
      habilitado = false;
    } else {
      usageException('Second argument must be "on" or "off", got "$onOff".');
    }

    final scope = resolveScope(
      global: argResults!['global'] as bool,
      cuentaId: argResults!['cuenta'] as String?,
      fincaId: argResults!['finca'] as String?,
    );
    final nota = argResults!['nota'] as String?;

    final config = loadSupabaseConfig(Platform.environment);
    final client = _buildClient(config);
    try {
      final result = await setFlag(
        client,
        clave: clave,
        habilitado: habilitado,
        scope: scope.scope,
        scopeId: scope.scopeId,
        nota: nota,
      );
      final actor = resolveActor(Platform.environment);
      await writeAuditLog(
        client,
        actor: actor,
        accion: 'flags.set',
        detalle: {
          'clave': clave,
          'scope': scope.scope,
          'scope_id': scope.scopeId,
          'habilitado': habilitado,
          'nota': ?nota,
          'created': result.created,
        },
      );
      final verb = result.created ? 'Created' : 'Updated';
      final scopeLabel = scope.scopeId != null
          ? '${scope.scope}:${scope.scopeId}'
          : scope.scope;
      print(
        '$verb feature flag "$clave" ($scopeLabel) -> habilitado=$habilitado',
      );
      return 0;
    } finally {
      client.httpClient.close();
    }
  }
}

class AccountsCommand extends Command<int> {
  AccountsCommand() {
    addSubcommand(AccountsSetPlanCommand());
  }

  @override
  final name = 'accounts';

  @override
  final description = 'Manage cuentas (accounts).';
}

class AccountsSetPlanCommand extends Command<int> {
  @override
  final name = 'set-plan';

  @override
  final description = 'Set the plan for a cuenta.';

  @override
  final invocation = 'hatoctl accounts set-plan <cuentaId> <plan>';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.length != 2) {
      usageException(
        'Expected exactly 2 positional arguments: <cuentaId> <plan>.',
      );
    }
    final cuentaId = rest[0];
    final plan = rest[1];

    final config = loadSupabaseConfig(Platform.environment);
    final client = _buildClient(config);
    try {
      final row = await setAccountPlan(client, cuentaId: cuentaId, plan: plan);
      final actor = resolveActor(Platform.environment);
      await writeAuditLog(
        client,
        actor: actor,
        accion: 'accounts.set_plan',
        detalle: {'cuenta_id': cuentaId, 'plan': plan},
      );
      print('Updated cuenta $cuentaId -> plan=$plan');
      print(_jsonPretty.convert(row));
      return 0;
    } finally {
      client.httpClient.close();
    }
  }
}

class DbCommand extends Command<int> {
  DbCommand() {
    addSubcommand(DbShellCommand());
  }

  @override
  final name = 'db';

  @override
  final description = 'Direct database access helpers.';
}

class DbShellCommand extends Command<int> {
  @override
  final name = 'shell';

  @override
  final description = 'Open a psql shell against HATOCTL_DB_URL.';

  @override
  Future<int> run() async {
    final dbUrl = loadDbUrl(Platform.environment);
    if (dbUrl == null) {
      stderr.writeln(missingDbUrlMessage);
      return 1;
    }
    return runDbShell(dbUrl);
  }
}
