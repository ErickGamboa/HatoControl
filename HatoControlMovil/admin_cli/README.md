# hatoctl

Standalone admin CLI for HatoControl operations that the Supabase CLI
(`supabase db push`, migrations) doesn't cover: feature flags and
account/plan management. Every mutating command writes a row to
`public.admin_audit_log`.

This is a pure-Dart package (`admin_cli/`), independent of the Flutter app —
it does not import or depend on `lib/`.

## Setup

```
cd admin_cli
dart pub get
```

### Required environment variables

`hatoctl` reads credentials from the environment only. It never hardcodes,
logs, or writes them to disk — export them in your shell, or put them in a
local **untracked** `.env` file that you `source` yourself (never commit it).

| Variable | Used by | Where to find it |
|---|---|---|
| `SUPABASE_URL` | `flags`, `accounts` | Supabase dashboard -> Project Settings -> API -> Project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | `flags`, `accounts` | Supabase dashboard -> Project Settings -> API -> `service_role` secret key |
| `HATOCTL_DB_URL` | `db shell` | Supabase dashboard -> Project Settings -> Database -> Connection string |
| `HATOCTL_ACTOR` (optional) | `flags set`, `accounts set-plan` | Free text recorded as `actor` in `admin_audit_log`; defaults to your OS username if unset |

`flags`/`accounts` authenticate to PostgREST as `service_role`, which bypasses
Row Level Security — that's required because `feature_flags` and
`admin_audit_log` have no write policies for the app's `authenticated` role.

Example (do not commit a file containing real values):

```
export SUPABASE_URL="https://<project-ref>.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="<service_role secret key>"
export HATOCTL_DB_URL="postgres://postgres:<password>@<host>:5432/postgres"
export HATOCTL_ACTOR="mainor"
```

## Commands

### `hatoctl flags list [--cuenta <uuid>] [--finca <uuid>]`

Lists global feature flags, plus (if given) the flags scoped to a specific
`cuenta` or `finca`.

```
dart run bin/hatoctl.dart flags list --cuenta 6d1f5e2a-2222-4b7a-9c31-abc123456789
```

### `hatoctl flags set <clave> <on|off> (--global | --cuenta <uuid> | --finca <uuid>) [--nota "<text>"]`

Upserts a feature flag: updates the existing row for that
`(scope, scope_id, clave)` if one exists, otherwise creates it. Exactly one of
`--global`/`--cuenta`/`--finca` is required.

```
dart run bin/hatoctl.dart flags set nueva_ui on --cuenta 6d1f5e2a-2222-4b7a-9c31-abc123456789 --nota "pilot rollout"
```

### `hatoctl accounts set-plan <cuentaId> <plan>`

Sets the plan on `public.cuentas`. `<plan>` is passed through as-is; invalid
values are rejected by the database's own constraints and the Postgres error
is printed directly.

```
dart run bin/hatoctl.dart accounts set-plan 6d1f5e2a-2222-4b7a-9c31-abc123456789 pro
```

### `hatoctl db shell`

Thin wrapper around `psql "$HATOCTL_DB_URL"` for direct SQL access. Requires
the `psql` client to be installed and on `PATH`.

```
dart run bin/hatoctl.dart db shell
```

## Development

From `admin_cli/`:

```
dart format .
dart analyze
dart test
```

Tests use `package:http`'s `MockClient` — no live network calls are made, and
none should be added; `service_role` credentials for the real project must
never be exercised from this test suite.
