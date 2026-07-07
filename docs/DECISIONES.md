# HatoControl — Registro de decisiones / Decision log

Lightweight ADR log. Each entry: context, decision, status. Agents and humans
should check this file before designing a new module, and add an entry when a
significant choice is made or changed.

Statuses: **Decidida** (made, reflected in code/docs), **Abierta** (needs a
product/tech decision before building), **Propuesta** (recommended default;
build with it unless overridden).

> 2026-07-02: all pending propuestas (D-01..D-13) were adopted as decisions.

---

## Decisions already made / Decisiones ya tomadas

### A-01 — Offline-first with local Drift/SQLite as source of writes
**Status: Decidida.** All writes go to the local Drift database first with
`pendiente=true`; `SyncService` uploads later. Supabase is the remote
backend, never called directly from screens. Enforced by `AGENTS.md`
invariants 1–2 and repository/sync tests.

### A-02 — Client-generated UUID primary keys
**Status: Decidida.** Every domain row gets a UUID v4 generated on the
client so offline-created rows have stable ids before sync
(`docs/MODELO_DATOS.md`, convenciones).

### A-03 — Soft delete everywhere
**Status: Decidida.** Domain rows are never hard-deleted; `deletedAt` +
`updatedAt` + `pendiente=true`. Unique constraints are partial
(`WHERE deleted_at IS NULL`) so identifiers can be reused after deletion.

### A-04 — Sync design: per-table cursors, LWW, pending guard
**Status: Decidida (v1).** Pull uses per-table `updated_at > cursor`;
conflicts resolve last-write-wins by server `updated_at`; pull never
overwrites rows that are locally `pendiente`, and the cursor does not advance
past skipped rows. Remote I/O is behind the `SyncRemoteGateway` interface so
sync is testable with a fake. Known improvement queued: cursor by
`(updated_at, id)` (ARCHITECTURE_REVIEW §5).

### A-05 — Multi-row domain actions are single local transactions
**Status: Decidida.** Create finca ⇒ finca + admin membership; create animal
⇒ animal + first pesaje. New modules follow the same pattern (e.g. assign
dieta ⇒ close previous assignment + open new one).

### A-06 — Ganancia math: calendar days, derived not stored
**Status: Decidida.** Peso actual, ganancia entre pesajes, and kg/día are
computed from `pesajes`, never persisted. Day counts use calendar-day
difference (`_diasCalendario`), not 24-hour blocks, so ayer→hoy = 1 día.
Same-day repeat weighings yield no kg/día (dias < 1 → null).

### A-07 — Licensing by cuenta + plan (fincas propias)
**Status: Decidida.** Cuenta = paying tenant; plans light/medium/pro limit
owned fincas; collaborating on others' fincas is free. Server trigger is the
hard limit, client check is UX.

### A-08 — Spanish-first domain language
**Status: Decidida.** Domain names stay in Spanish (`finca`, `lote`,
`pesaje`, `dieta`, `sanidad`, `venta`) in code, schema, and UI. Developer
docs understandable in English.

### A-09 — Security: RLS is the source of truth
**Status: Decidida.** Client-side role checks are UX only. Supabase RLS +
constraints + triggers are authoritative. Never commit `service_role` keys.

### A-10 — State management: streams + ValueNotifier, no framework (yet)
**Status: Decidida (v1).** Drift streams + `StreamBuilder`,
`ValueNotifier` for app state, `setState` for forms. Global singletons live
in `lib/services.dart` but new code must accept injected dependencies
(constructor injection) so it is testable. See D-10 for the open follow-up.

---

## Module decisions / Decisiones por módulo

All propuestas below were adopted as decisions on **2026-07-02**.

### D-01 — "Período" for lote history = group by calendar date
**Needed for: Module 1b. Status: Decidida (2026-07-02).**
Pesajes are per-animal; nothing marks a "lote weighing session". Decision:
group the lote's pesajes by **calendar date** — each weighing date is a
"jornada" and a period runs between consecutive dates. Zero schema change,
works with existing data. Each animal is compared against **its own previous
pesaje** (so a missed weighing doesn't corrupt the average), and headcount is
reported per date. Implemented as pure functions in
`lib/data/estadisticas/estadisticas_pesajes.dart`. A `jornadas_pesaje`
entity remains the upgrade path only if field usage shows one lote weighing
spanning several days.

### D-02 — Dieta cost model: cost snapshot on assignment
**Needed for: Module 2 (and 4). Status: Decidida (2026-07-02).**
Dieta has a single `costo_animal_dia` column. The historical record is the
`lote_dietas` assignment row, which **snapshots** the diet's cost at
assignment time (`costo_animal_dia_snapshot`), so later price edits don't
rewrite past economics in module 4.

### D-03 — Dieta scope: per finca
**Needed for: Module 2. Status: Decidida (2026-07-02).**
Diets are defined per finca, matching the RLS pattern of every other domain
table. Cross-finca comparison can match diets by name later.

### D-04 — Sanidad: one `eventos_sanitarios` table with `tipo`
**Needed for: Module 3a. Status: Decidida (2026-07-02).**
One table with `tipo` (`vacuna` | `medicamento` | `desparasitacion` |
`otro`); fields are identical across types (producto, dosis, fecha,
responsable, observaciones, costo). Products are free text with local
suggestions from history; a `productos_sanitarios` catalog only if needed.

### D-05 — Track lote movements (`movimientos_lote`): yes, from Module 2
**Needed for: Modules 3b and 4. Status: Decidida (2026-07-02).**
Add `movimientos_lote` (animal_id, lote_origen?, lote_destino, fecha) when
Module 2 lands, written in the same transaction as `moverAnimalDeLote` and on
animal creation. Movement history is cheap to write now and impossible to
reconstruct later; modules 3b (dietas recibidas) and 4 (feeding cost) depend
on it.

### D-06 — Purchase price lives on `animales`
**Needed for: Module 4. Status: Decidida (2026-07-02).**
Nullable `precio_compra` and `fecha_compra` columns on `animales` (one
purchase per animal). "Otros costos" get their own small table
(`costos_otros`). Migrate to a generic cost ledger only if more cost types
emerge.

### D-07 — Currency: `moneda` on cuenta, numeric amounts, no FX
**Needed for: Modules 2 and 4. Status: Decidida (2026-07-02).**
`moneda` (ISO code, default `CRC`) at cuenta level; money stored as numeric;
no currency conversion in v1. Applies from the first money column
(dietas.costo_animal_dia).

### D-08 — Animal lifecycle: `estado` column, not `deletedAt`
**Needed for: Module 4 (affects lote stats). Status: Decidida (2026-07-02).**
Add `animales.estado` (`activo` | `vendido` | `muerto`). Sold/dead animals
keep their full historial (hoja de vida) but drop out of active lote counts
and the corral screen. `deletedAt` remains "created by mistake" only.

### D-09 — Web: read-mostly dashboard, after Module 2
**Needed for: platform planning. Status: Decidida (2026-07-02).**
Ship web as a read-mostly analysis experience (historial, comparisons,
ventas reports) after Module 2; the corral workflow stays mobile-first.
Requires Drift WASM setup, `XFile`-based photo code with conditional imports,
and a web pass of the auth/sync flow.

### D-10 — DI convention: constructor injection with global defaults
**Needed for: Phase 0. Status: Decidida (2026-07-02).**
New screens/services take repositories via constructor parameters, defaulting
to the `lib/services.dart` globals, so widget tests can inject fakes or
in-memory-backed repositories. No DI framework unless manual wiring becomes
painful. First applied in `AnimalHistorialScreen` and `LoteHistorialScreen`.

### D-11 — Chart package: `fl_chart`
**Needed for: Modules 1a/1b. Status: Decidida (2026-07-02).**
`fl_chart` (pure Dart — works on iOS/Android/macOS/web, no platform
channels). Added as a dependency and first used for the weight evolution
chart in the animal historial.

### D-12 — CI: GitHub Actions, macOS runner
**Needed for: Phase 0. Status: Decidida (2026-07-02).**
Committed `.github/workflows/ci.yml` (format check, analyze, test) as
specified in `docs/QA_AUTOMATION.md`. An Android build job can be added
later.

### D-13 — Sync observability: local `sync_estado` table
**Needed for: cross-cutting sync track. Status: Decidida (2026-07-02).**
Local table with per-table pending counts, last error, and last success
timestamp, plus a small status sheet in the UI. No server changes needed.
Scheduled with the sync robustness track (before the table count doubles).

---

## How to use this log / Cómo usar este registro

- Before building a module, resolve its **Abierta** entries (or accept the
  Propuesta and mark it Decidida with a date).
- When a decision changes, do not delete the entry — mark it superseded and
  link the replacement.
- Keep entries short: context, options, decision, consequence.
