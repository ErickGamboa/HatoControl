# Supabase schema migrations

**Status: this replaces the old "paste SQL into the Dashboard, in this order"
process.** Schema now lives in `supabase/migrations/` (Supabase CLI format,
one timestamped file per change) instead of the standalone
`docs/supabase_*.sql` scripts. See D-14 in `docs/DECISIONES.md` for why.

## One-time setup (per machine)

```bash
brew install supabase/tap/supabase   # CLI, already done on this machine
supabase login                       # opens a browser, ties the CLI to your Supabase account
supabase link --project-ref geocoundyilwxrnbhcqu
```

`supabase login`/`link` need your own Supabase credentials — run them
yourself in a terminal (or via `! <command>` in Claude Code), don't hand the
access token to an agent.

## Known gap: the base schema (v1) is not captured as a migration yet

`supabase/migrations/` currently starts from the **bootstrap RLS helpers**
(private schema, `es_miembro`, `set_updated_at`) and modules 2–4. The
original v1 schema (`planes`, `cuentas`, `usuarios`, `fincas`,
`finca_miembros`, `lotes`, `animales`, `pesajes`) was created directly on the
Supabase dashboard early on and was never in this repo (see the old note in
this file's git history). **Before relying on `supabase db reset` locally or
treating this migrations folder as the full source of truth**, run once,
after linking:

```bash
supabase db pull
```

This introspects the live project and writes a `...remote_schema.sql`
migration capturing everything that exists today (v1 schema + anything
applied by hand since). Reorder it to sort before the bootstrap/module
migrations (rename its timestamp prefix to something earlier), then commit
it. After that, `supabase/migrations/` is a complete, ordered history and
`supabase db reset` (local) / `supabase db push` (remote) both work from a
clean slate.

## Applying pending migrations to the real project

Modules 2–4's tables/RLS have **not** been applied to the live project yet
(see the unchecked "Supabase tables/RLS applied" boxes in `docs/ROADMAP.md`).
Once linked and the base-schema gap above is closed:

```bash
supabase db push          # applies every migration not yet recorded as applied, in order
supabase migration list   # shows local vs remote status
```

`db push` runs against the real project — review the diff it prints before
confirming.

## Adding a new schema change from now on

```bash
supabase migration new <short_name>
# edit the generated supabase/migrations/<timestamp>_<short_name>.sql
supabase db push
```

Same quality bar as before (`AGENTS.md` / `docs/ROADMAP.md`): update
`docs/MODELO_DATOS.md`, the Drift schema + migration, and `SyncService`
mappers in the same PR as the SQL migration.

## Local dev loop (optional, uses Docker)

```bash
supabase start   # spins up local Postgres + Studio via Docker
supabase db reset  # drops and rebuilds the local DB from supabase/migrations/, in order
```

Lets you test a migration against a throwaway local Postgres before pushing
to the real project — useful once the base-schema gap above is closed.

## Troubleshooting: `function private.es_miembro(uuid, uuid) does not exist`

Means the bootstrap migration
(`supabase/migrations/20260707203013_bootstrap_rls_helpers.sql`) hasn't been
applied yet. Run `supabase db push` (after linking) to apply it along with
everything after it, in order.
