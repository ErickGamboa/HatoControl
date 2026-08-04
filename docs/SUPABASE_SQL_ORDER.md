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

## Known gap: the base schema (v1) is still not captured as a migration

`supabase/migrations/` starts from the **bootstrap RLS helpers** (private
schema, `es_miembro`, `set_updated_at`) and modules 2–5. The original v1
schema (`planes`, `cuentas`, `usuarios`, `fincas`, `finca_miembros`,
`lotes`, `animales`, `pesajes`) was created directly on the Supabase
dashboard early on and was never in this repo. As of 2026-07-09 this gap is
worked around, not closed: the 14 remote-only migrations from that era were
marked `reverted` in the CLI's bookkeeping via `supabase migration repair
--status reverted <ids>` so `db push` would stop refusing to run — that
only edits the CLI's local-vs-remote tracking table, it does not touch
actual schema. The v1 schema itself is still only "live in the dashboard,"
not in a migration file. `supabase db pull` (see below) is still the right
way to close this properly when there's time; it wasn't run on 2026-07-09
because it hit the same history-mismatch error as `db push` and fixing that
via `migration repair` was the higher-priority path (a client build was
blocked on the sync error this was causing).

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

**Status: applied 2026-07-09.** Modules 2–5's tables/RLS (dietas, sanidad,
ventas, feature_flags, admin_audit_log) plus the Fase 3 CHECK constraints
are live on the project. This also surfaced that `dietas`, `lote_dietas`,
`movimientos_lote`, `eventos_sanitarios`, `ventas`, `costos_otros`, and the
`animales` economy columns already existed on the remote — created by hand
at some earlier point, without their RLS policies and without being
recorded in migration history. `feature_flags` and `admin_audit_log` did
not exist at all, which is what broke sync (`SyncService` tried to pull a
table that wasn't there yet). Because of that partial prior state, every
`CREATE POLICY` in modules 2–4 and feature_flags now has a `DROP POLICY IF
EXISTS` guard in front of it (plain `CREATE POLICY` isn't idempotent the
way `CREATE TABLE IF NOT EXISTS` is) — keep that pattern for any new RLS
policy added to these files or new ones.

```bash
supabase db push          # applies every migration not yet recorded as applied, in order
supabase migration list   # shows local vs remote status
```

`db push` runs against the real project — review the diff it prints before
confirming. If it refuses with a migration-history-mismatch error pointing
at migrations you don't recognize, that's the known gap above; running the
suggested `migration repair --status reverted` for those specific IDs (not
`--status applied`, which would be a lie — they're not actually applied via
a tracked migration) unblocks `db push` without touching schema.

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

## Oro schema (2026-07-23)

`20260723120000_oro_medicamentos_ventas.sql` — medicamentos catalog,
dieta_ingredientes, lotes_venta, retiro/dosis columns on eventos_sanitarios,
peso/lote_venta_id on ventas. **Pushed to live** `geocoundyilwxrnbhcqu` on
2026-07-23 (`supabase migration list` shows local=remote for that stamp).

## Módulo 7 — gastos fijos (2026-08-03)

`20260803120000_module7_gastos_fijos.sql` — `gastos_fijos` (gasto indirecto de
la finca: peón, luz, agua; mensual o único, con vigencia `desde`/`hasta`) y
`gasto_fijo_cargos` (la parte prorrateada que se congela al vender). RLS por
`private.es_miembro(finca_id)` y, para los cargos, vía `EXISTS` sobre
`animales`. Índice único `(gasto_fijo_id, animal_id, mes)` entre filas no
borradas, espejo del índice local de Drift (schema v14). **Pendiente de
`supabase db push`.**

## Dieta por kilo (2026-08-03)

`20260803130000_dieta_costo_por_kilo.sql` — `dietas.costo_kg` (₡ por kilo de
alimento) y `dietas.kg_animal_dia` (kilos por animal al día). Es lo que digita
el ganadero; `costo_animal_dia` y `costo_animal_semana` quedan como derivados
(`costo_kg × kg_animal_dia` y eso × 7). Espejo del schema local de Drift v15.
Las dietas anteriores se rellenan como `costo_kg = costo_animal_dia,
kg_animal_dia = 1`, lo que deja `costo_animal_dia` idéntico y no mueve los
snapshots de `lote_dietas` ni el historial de utilidad. **Pendiente de
`supabase db push`.**

## Venta: datos de planta (2026-08-04)

`20260803140000_venta_datos_planta.sql` — `ventas.peso_pie`,
`ventas.peso_canal`, `ventas.rendimiento` (derivado `canal/pie*100`) y
`ventas.dinero_recibido`. Por D-19 el grupo de venta se crea solo con los kilos
de salida de finca (`ventas.peso`) y la liquidación de la planta se registra
después, animal por animal. **`dinero_recibido` es la fuente de la utilidad**;
`precio` queda como espejo. Espejo del schema local de Drift v16. El backfill
`dinero_recibido = precio` evita que las ventas ya registradas pierdan su
utilidad. **Pendiente de `supabase db push`.**
