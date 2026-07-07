# HatoControl — Product roadmap / Hoja de ruta

Living document. It connects the product vision ("ERP del ciclo de producción
ganadera") with what already exists in the code, and defines the order and the
quality bar for building the remaining modules.

Companion docs:
- `docs/DECISIONES.md` — decisions already made and decisions still open.
- `docs/MODELO_DATOS.md` — current data model (must be extended per module).
- `docs/ARCHITECTURE_REVIEW.md` — technical hardening plan (globals, sync, CI).
- `docs/QA_AUTOMATION.md` — test pyramid, invariants, evaluator sets.

## Vision / Visión

Connect alimentación, sanidad, crecimiento y ventas so the producer can answer:

- ¿Cómo evolucionó este lote entre un pesaje y otro?
- ¿Con cuál dieta crecieron más rápido? ¿Cuál tuvo mejor costo/beneficio?
- ¿Cuánto costó este animal y cuánta utilidad dejó al venderlo?

```text
                 Lotes
                    │
      ┌─────────────┼─────────────┐
      │             │             │
   Dietas       Pesajes      Animales
                                  │
                              Sanidad
                                  │
                               Venta
```

Full cycle: comprar animal → asignar a lote → lote recibe dieta → pesajes
periódicos → tratamientos sanitarios → análisis de ganancia diaria y efecto de
la dieta → venta → cálculo automático de costos, ganancia y rentabilidad.

## Current state / Estado actual (jul 2026)

Implemented and tested:
- Auth (online + offline login with cached session), cuentas/licencias, fincas
  compartidas con roles, lotes, animales, pesajes.
- Offline-first core: Drift schema v6 with local unique indexes, repositories
  that write locally with `pendiente=true`, bidirectional `SyncService` with
  per-table cursors, pending-row guard, and an extracted `SyncRemoteGateway`
  that enables sync tests with a fake remote.
- **Historial por animal (module 1, ~80% done):** `AnimalHistorialScreen`
  already shows fecha, peso, ganancia entre pesajes, kg/día per row, and total
  gain. `PesajesRepository` computes calendar-day gains.

Not started (no code traces): historial agregado por lote, dietas, sanidad,
hoja de vida del animal (tabs), pantalla de corral, ventas/costos.

Platforms: iOS, Android, macOS are first-class. `web/` scaffold exists but the
app is not web-ready (uses `dart:io` for photos). No `windows/` folder.

## Quality bar for every module / Barra de calidad por módulo

Every module below ships only when ALL of these hold. This is what keeps the
codebase maintainable by humans and agents:

1. **Data model doc updated** — new tables added to `docs/MODELO_DATOS.md`
   (local Drift + Supabase + RLS expectations) before or with the code.
2. **Offline-first invariants** — client UUIDs, `pendiente=true` on write,
   `updatedAt` bumped, soft delete via `deletedAt`, multi-row actions in one
   local transaction. Sync support added in the same PR as the schema.
3. **Repository layer** — UI never touches Supabase; business math (gains,
   aggregates, costs) lives in repositories with pure, testable functions.
4. **Evaluator set** — each module defines its named evaluator tests in
   `docs/QA_AUTOMATION.md` (like the offline-login set): unit tests for the
   math, repository tests on in-memory Drift, sync tests with the fake
   gateway, and at least one widget or integration test for the main screen.
5. **Format/analyze/test green** — `dart format`, `flutter analyze`,
   `flutter test` before handing back. Drift regenerated if schema changed.

## Phase 0 — Foundations (before new modules) / Fundaciones

Small, high-leverage items that every later module depends on. See
`docs/DECISIONES.md` D-10..D-13 for the open choices here.

- [x] Commit CI (`.github/workflows/ci.yml` from `docs/QA_AUTOMATION.md`).
- [ ] Land the in-flight sync work (gateway extraction, pending guard,
      constraint tests) — already on this branch, finish and merge.
- [x] Dependency injection convention decided (D-10): new screens take
      repositories via constructor parameters defaulting to the globals.
      First applied in `AnimalHistorialScreen` and `LoteHistorialScreen`.
- [x] Chart package: `fl_chart` (D-11), added and first used in module 1.
- [ ] Add a shared `Clock`/date utility so gain and period math is testable
      without `DateTime.now()` scattered in repositories. (Partially covered:
      period/gain math now lives in pure functions in
      `lib/data/estadisticas/estadisticas_pesajes.dart`.)

## Module 1 — Historial (animal + lote) / Weight history

### 1a. Historial por animal — finish the gap

Target table (from product spec):

| Fecha | Peso | Días | Ganancia | Kg/día |
|---|---|---|---|---|
| 10 Ene | 210 kg | – | – | – |
| 15 Feb | 232 kg | 36 | +22 kg | 0.61 |

Gap vs. current `AnimalHistorialScreen` — **shipped 2026-07-02**:
- [x] Add the **Días** column (data already exists in `PesajeHistorial.dias`).
- [x] Add **ganancia promedio kg/día global** (last peso − first peso over
      calendar days since entry) to the summary card.
- [x] Add a **weight evolution chart** (line chart of peso over fecha).
- [x] Evaluator: unit tests for global average gain edge cases (single pesaje,
      same-day pesajes, weight loss). See the "historial evaluator set" in
      `docs/QA_AUTOMATION.md`.

### 1b. Historial por lote — new

Target: per period between consecutive lot weighings show cantidad de
animales, peso promedio, mínimo, máximo, ganancia promedio, kg/día promedio.

| Período | Animales | Peso promedio | Ganancia promedio | Kg/día promedio |
|---|---|---|---|---|
| Ene → Feb | 48 | 231 kg | +21 kg | 0.58 |

Key design problem: pesajes are per-animal rows; nothing groups them into a
"lote weighing session". **Decision D-01** (see `docs/DECISIONES.md`) defines
periods by grouping pesajes of the lote's animals by calendar date (no new
entity), with a `jornadas_pesaje` entity as a later upgrade if real usage
shows multi-day weighing sessions.

**Shipped 2026-07-02**:
- [x] Pure aggregation `resumenPorPeriodos()` in
      `lib/data/estadisticas/estadisticas_pesajes.dart` plus
      `PesajesRepository.observarResumenLote(loteId)` returning periods with
      count, avg, min, max, avg gain, avg kg/día.
- [x] `LoteHistorialScreen` with the period table and average-weight
      evolution chart, reachable from the stats icon in `LoteAnimalesScreen`.
- [x] Animals that enter/leave the lote between periods: each animal is
      compared only against its own previous pesaje; headcount reported per
      period.
- [x] Evaluator: unit tests with fixture herds (animal added mid-period,
      animal missing a weighing, same-day duplicates, weight loss).

Follow-up (not blocking): pesajes of animals *moved out* of the lote no
longer count toward its history (the query filters by current `loteId`);
D-05 (`movimientos_lote`) will make historical membership exact.

No schema change is required for 1a/1b — this is derived data.

## Module 2 — Dietas / Diets

Each lote can have an assigned diet; a diet has nombre, descripción,
ingredientes (opcional), costo (per animal per day). Goal: relate feeding to
lot performance and later compare diets across lotes.

Data model (details and open questions in D-02, D-03):
- `dietas` — per finca: id, finca_id, nombre, descripcion, costo_animal_dia,
  moneda, timestamps + sync columns.
- `dieta_ingredientes` (optional, can ship later) — dieta_id, nombre,
  cantidad, unidad.
- `lote_dietas` — assignment **history**, not a single FK on lotes: id,
  lote_id, dieta_id, desde, hasta (null = current). History is required to
  answer "¿con cuál dieta crecieron más rápido?" and to compute feeding cost
  per animal later (module 4).

Work items — **local app shipped 2026-07-07**; run `docs/supabase_module2_dietas.sql`
on Supabase before enabling sync to production:
- [x] Drift tables + migration v7 + `SyncService` mappers + `MODELO_DATOS.md`.
- [ ] Supabase tables/RLS applied (SQL script ready for you).
- [x] `DietasRepository`: CRUD, asignar dieta (cierra anterior + snapshot),
      dieta vigente, historial.
- [x] `movimientos_lote` written on create animal and move lote (D-05).
- [x] UI: `DietasScreen` in finca menu; dieta vigente + kg/día card on lote.
- [ ] Comparison view across lotes/dietas (later in module 2).
- [x] Evaluator: `test/repositories/dietas_repository_test.dart`.

## Module 3 — Sanidad + Hoja de vida + Corral

### 3a. Sanidad / Health records — **local app shipped 2026-07-07**

Per-animal applications (D-04). Run `docs/supabase_module3_sanidad.sql` before sync.

- [x] Drift v8 + migration + `SyncService` mappers + `MODELO_DATOS.md`.
- [ ] Supabase tables/RLS applied (SQL script ready).
- [x] `SanidadRepository`: registrar, historial, batch por lote, sugerencias.
- [x] Evaluator: `test/repositories/sanidad_repository_test.dart`.

### 3b. Hoja de vida del animal — **shipped 2026-07-07**

- [x] `AnimalFichaScreen` with tabs: General, Pesajes, Sanidad, Dietas, Economía.
- [x] Dietas tab derived from `movimientos_lote` + `lote_dietas` (D-05).
- [x] Batch sanidad from lote screen (vaccine icon in app bar).
- [x] Economía tab: compra, venta, costos, rentabilidad (Module 4 UI).
- [x] Repeat-last-treatment on Sanidad tab and Corral.
- [x] Widget tests: `test/lotes/animal_ficha_screen_test.dart`.

### 3c. Pantalla de trabajo (Corral) / Work screen — **shipped 2026-07-07**

Main field screen, optimized for minimum touches (the existing RFID/ear-tag
keyboard-scanner flow in `PesajeScreen` is the pattern to extend):

- [x] `CorralScreen`: scan/type arete → animal card → pesaje, sanidad,
      repetir último, mover de lote, hoja de vida.
- [x] Batch mode from corral app bar (tratamiento al lote).
- [x] Entry from finca detail grid; `PesajeScreen` retained for legacy flow.
- [x] Evaluator: `test/corral/corral_screen_test.dart` (scan → weight → save).

## Module 4 — Ventas y costos / Sales and economics — **local app shipped 2026-07-07**

Closes the economic cycle. Per animal: precio de compra, costos de
alimentación (derived from dietas), costos sanitarios (derived from sanidad),
otros costos, precio de venta → costo total, utilidad, margen, rentabilidad.

- [x] Drift v9: `animales.estado`, `precio_compra`, `fecha_compra`; `ventas`;
      `costos_otros`; sync mappers.
- [ ] Supabase tables/RLS applied (SQL: `docs/supabase_module4_ventas.sql`).
- [x] `VentasRepository` + `estadisticas_economicas.dart` (pure math).
- [x] UI: Economía tab in hoja de vida; venta marca animal `vendido`.
- [x] Evaluators: `test/estadisticas/estadisticas_economicas_test.dart`,
      `test/repositories/ventas_repository_test.dart`.
- [ ] Finca-level sales summary (later).

## Cross-cutting tracks / Pistas transversales

These run alongside the modules, not after them.

### Sync robustness (always-on requirement)

The offline+sync behavior must stay "super good" as tables multiply:
- Every new table gets: push/pull mappers, per-table cursor, pending guard
  coverage in `test/sync/`, and a fake-gateway round-trip test.
- Adopt the safer cursor scheme `(updated_at, id)` before the table count
  doubles (open item from `ARCHITECTURE_REVIEW.md` §5).
- Add a lightweight sync status/error table for observability so field users
  can see "N cambios pendientes" per module.
- Document the conflict policy (LWW) in user-facing terms; add a conflict log
  when dietas/ventas make conflicting edits financially meaningful.

### Platforms: iPhone, Android, web

- iOS + Android remain the primary targets; every module's evaluator set must
  run on both (CI runs the device-independent tests; the manual checklist in
  `QA_AUTOMATION.md` covers device passes).
- **Web** is feasible but needs deliberate work (see D-09): Drift via WASM
  (`drift_flutter` supports web), replace `dart:io` photo handling with
  `XFile`/bytes + conditional imports, verify `connectivity_plus` and
  Supabase auth persistence on web. Recommended timing: after module 2, as a
  read-mostly "dashboard" experience first (historial + comparisons), since
  the corral workflow is inherently mobile.
- Windows stays optional/documented-only.

### Testing & evaluators for humans and agents

- Keep `docs/QA_AUTOMATION.md` as the registry: every module adds a named
  evaluator set (like the offline-login set) with exact `flutter test`
  commands, so agents can verify without guessing.
- Business math (gains, aggregates, costs) must be pure functions — that is
  what makes the evaluator suites fast and deterministic.
- Widget tests use injected fake repositories; no Supabase in unit/widget CI.
- Integration tests extend `test/integration/offline_local_flow_test.dart` per
  module: offline create → reopen → sync.

## Suggested order / Orden sugerido

1. **Phase 0** foundations (CI, land sync branch, DI convention, chart pkg).
2. **Module 1a** (finish animal historial: Días column, promedio global,
   chart) — small, immediately visible.
3. **Module 1b** (historial por lote) — unlocks the core product question.
4. **Module 2** (dietas) — unlocks dieta/performance comparison.
5. **Module 3a + 3b** (sanidad + hoja de vida tabs).
6. **Module 3c** (corral work screen) — after pesaje+sanidad exist so quick
   actions are meaningful.
7. **Web read-mostly experience** (optional, in parallel after module 2).
8. **Module 4** (ventas/costos) — needs dietas + sanidad history to compute
   real costs.

Each step is one or a few small PRs (one domain behavior or one screen at a
time, per `AGENTS.md`).
