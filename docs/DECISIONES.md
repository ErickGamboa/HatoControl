# HatoControl — Registro de decisiones / Decision log

Lightweight ADR log. Each entry: context, decision, status. Agents and humans
should check this file before designing a new module, and add an entry when a
significant choice is made or changed.

**Product behavior** is defined by `docs/ESPECIFICACION_FUNCIONAL.md` (documento
oro). Decisions here must not contradict that doc; if they do, update or retire
the decision and align the code.

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

### A-11 — Product behavior source of truth = Especificación funcional (oro)
**Status: Decidida (2026-07-23).** `docs/ESPECIFICACION_FUNCIONAL.md` (Erick)
defines how the app must behave. Features not described there are out of
scope: do not build; existing contradictions are retired or aligned
(`docs/ROADMAP.md` gap list). Technical ADRs below remain valid only when
they serve an oro module; otherwise mark superseded (see D-01, D-11, D-15).

---

## Module decisions / Decisiones por módulo

All propuestas below were adopted as decisions on **2026-07-02**.

### D-01 — "Período" for lote history = group by calendar date
**Needed for: Module 1b. Status: Supercedida por A-11 (2026-07-23).**
Historial agregado por lote / jornadas as a product module is **not** in
`ESPECIFICACION_FUNCIONAL.md`. `LoteHistorialScreen` was **removed**
(2026-07-23). Calendar-day gain math (A-06) remains for per-animal GMD on
Pesaje and Hoja de Vida. Prior implementation note (archaeology): periods
were calendar-date groups in `estadisticas_pesajes.dart`.

### D-02 — Dieta cost model: cost snapshot on assignment
**Needed for: Module 2 (and 4). Status: Decidida (2026-07-02); entrada de datos
enmendada por D-18 (2026-08-03).**
Dieta has a single `costo_animal_dia` column. The historical record is the
`lote_dietas` assignment row, which **snapshots** the diet's cost at
assignment time (`costo_animal_dia_snapshot`), so later price edits don't
rewrite past economics in module 4. **D-18** keeps the snapshot rule intact and
only changes how `costo_animal_dia` is obtained (₡/kg × kg por animal al día
instead of a typed weekly amount ÷ 7).

### D-03 — Dieta scope: per finca
**Needed for: Module 2. Status: Decidida (2026-07-02).**
Diets are defined per finca, matching the RLS pattern of every other domain
table. Cross-finca comparison can match diets by name later.

### D-04 — Sanidad: one `eventos_sanitarios` table with `tipo`
**Needed for: Module 3a. Status: Revisar vs oro (2026-07-23).**
Current model is free-text events with `tipo`. The oro requires a **catálogo
de medicamentos** (nombre, costo envase, rendimiento, tipo de aplicación
peso/fija/spray, días de retiro) plus aplicaciones with calculated dosis and
costo por uso. Keep application history; replace/extend the catalog model to
match Módulo 2 of `ESPECIFICACION_FUNCIONAL.md`.

### D-05 — Track lote movements (`movimientos_lote`): yes, from Module 2
**Needed for: Modules 3b and 4. Status: Decidida (2026-07-02).**
Add `movimientos_lote` (animal_id, lote_origen?, lote_destino, fecha) when
Module 2 lands, written in the same transaction as `moverAnimalDeLote` and on
animal creation. Movement history is cheap to write now and impossible to
reconstruct later; modules 3b (dietas recibidas) and 4 (feeding cost) depend
on it.

### D-06 — Purchase price lives on `animales`
**Needed for: Module 4. Status: Decidida (2026-07-02); costo scope narrowed by A-11.**
Nullable `precio_compra` and `fecha_compra` on `animales` stay. Oro utilidad
= venta − (compra + dietas + sanidad) only — **retire `costos_otros` from
product math/UI** (table may remain until a cleanup PR).

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
**Needed for: platform planning. Status: Supercedida en alcance (A-11).**
Do not build comparison/historial dashboards that are not in the oro. Web
remains optional/later; if revisited, mirror oro field modules only
(mobile-first Pantalla de Trabajo stays primary).

### D-10 — DI convention: constructor injection with global defaults
**Needed for: Phase 0. Status: Decidida (2026-07-02).**
New screens/services take repositories via constructor parameters, defaulting
to the `lib/services.dart` globals, so widget tests can inject fakes or
in-memory-backed repositories. No DI framework unless manual wiring becomes
painful. First applied in `AnimalHistorialScreen` and `LoteHistorialScreen`.

### D-11 — Chart package: `fl_chart`
**Needed for: Modules 1a/1b. Status: Opcional / no oro (A-11).**
Charts are not required by `ESPECIFICACION_FUNCIONAL.md`. Keep dependency
only while existing screens still use it; remove with lote/animal chart UI
retirement. Do not add new chart surfaces for product scope.

### D-12 — CI: GitHub Actions, macOS runner
**Needed for: Phase 0. Status: Decidida (2026-07-02).**
Committed `.github/workflows/ci.yml` (format check, analyze, test) as
specified in `docs/QA_AUTOMATION.md`. An Android build job can be added
later.

**Update 2026-07-07:** added pub/gradle caching, a generated-file drift check
(`build_runner` + `git diff --exit-code -- '*.g.dart'`, enforcing `AGENTS.md`
invariant #10 in CI instead of by convention only), and a separate
`android-build` job (ubuntu runner, `flutter build apk --debug`) so Android
platform breakage is caught without waiting for a macOS runner. Web build
check deferred until D-09's web work lands — `flutter build web` fails today
because of `dart:io` photo handling, so adding it now would just be
permanently red.

### D-13 — Sync observability: local `sync_estado` table
**Needed for: cross-cutting sync track. Status: Decidida (2026-07-02).**
Local table with per-table pending counts, last error, and last success
timestamp, plus a small status sheet in the UI. No server changes needed.
Scheduled with the sync robustness track (before the table count doubles).

### D-14 — Schema migrations: Supabase CLI, `supabase/migrations/`
**Needed for: admin CLI, agent workflow. Status: Decidida (2026-07-07).**
Replaces the "paste `docs/supabase_*.sql` into the Dashboard SQL Editor, in
an order tracked by a markdown doc" process — that process had already
caused at least one real failure (missing bootstrap step, documented in the
old `docs/SUPABASE_SQL_ORDER.md`) and, more importantly, cannot be executed
by an agent (no browser access to the Dashboard). Schema now lives in
timestamped files under `supabase/migrations/`, applied with
`supabase db push` after `supabase login && supabase link`. The four
existing scripts (bootstrap RLS helpers, modules 2–4) were converted
verbatim into the first four migrations; the original v1 schema
(`fincas`/`lotes`/`animales`/etc.) predates this repo and is **not yet**
captured as a migration — see the gap documented in
`docs/SUPABASE_SQL_ORDER.md`, close it once via `supabase db pull` after
linking. `supabase login`/`link` require the developer's own credentials —
never run by an agent unattended. See `docs/ARCHITECTURE_REVIEW.md` and the
admin CLI design for how this underpins feature flags and admin data
operations.

### D-15 — Feature flags: `feature_flags` table, admin-write-only, three scopes
**Needed for: Module 5. Status: Infra ok; gating oro modules out of product scope (A-11).**
Table/CLI may remain for ops. **Do not gate core oro modules** (Pesaje,
Sanidad, Lotes, Dietas, Hoja de Vida, Venta) behind flags in the field UI —
those modules are the product. Prior design (scopes, pull-only Drift mirror,
hatoctl writes) stays for archaeology / optional ops.

### D-16 — Modules 2–5 schema pushed to the live project; RLS policy idempotency
**Status: Decidida (2026-07-09).**
Pushed the 7 pending migrations (bootstrap, dietas, sanidad, ventas,
feature_flags, admin_audit_log, and a new Fase 3 CHECK-constraints
migration for the v1 tables) after a TestFlight build surfaced a sync
error: `feature_flags` didn't exist on the live database. The push also
found `dietas`, `lote_dietas`, `movimientos_lote`, `eventos_sanitarios`,
`ventas`, `costos_otros`, and the `animales` economy columns already
existed remotely — created by hand at some point, without RLS policies and
without being tracked in migration history. `feature_flags` and
`admin_audit_log` genuinely did not exist; that was the actual bug.
Consequence: every `CREATE POLICY` statement in modules 2–4 and
feature_flags now has a `DROP POLICY IF EXISTS` guard in front of it —
`CREATE TABLE`/`CREATE INDEX` already had `IF NOT EXISTS`, but bare
`CREATE POLICY` isn't idempotent in Postgres and failed the push on the
first re-run. Keep the drop-then-create pattern for any new RLS policy.
The new v1-tables constraints migration uses `DROP CONSTRAINT IF EXISTS`
+ `ADD CONSTRAINT ... NOT VALID` + a separate `VALIDATE CONSTRAINT`, since
`cuentas`/`finca_miembros`/`pesajes` have live rows (unlike modules 2-5,
which were brand new) — `NOT VALID` means a stray non-conforming row
reports clearly via `VALIDATE CONSTRAINT` instead of aborting the whole
migration opaquely. Pushing itself required `supabase migration repair
--status reverted` on 14 pre-repo remote migrations first (see the updated
"known gap" note in `docs/SUPABASE_SQL_ORDER.md`) — that only edits the
CLI's local/remote bookkeeping, not schema, and is safe to redo if the
project is ever re-linked from a fresh machine.

### D-17 — Gastos fijos: prorrateo por días-animal y congelado al vender
**Status: Decidida (2026-08-03).**
Los costos indirectos de la finca (salario del peón, luz, agua, combustible)
no existían en el sistema, así que la utilidad por animal estaba inflada.
Se agrega el **Módulo 7 — Gastos fijos** y se amplía la fórmula oro a
`venta − (compra + dietas + sanidad + gastos fijos)`.

Opciones evaluadas para el reparto: (a) partes iguales entre los animales del
mes, (b) **días-animal**, (c) días-kilo (ponderado por peso).
**Decisión: (b) días-animal.** Reparte exactamente el 100% del gasto y es
justo con animales que entran o se venden a mitad de mes; (a) castiga al que
entró tarde y (c) depende de tener pesajes al día y es difícil de explicar al
ganadero.

Consecuencias:
- El gasto recurrente se digita una vez (`periodicidad = mensual`, vigencia
  `desde`/`hasta`) y se devenga solo mes a mes. El mes en curso devenga
  proporcional a los días transcurridos, igual que la dieta.
- La parte de cada animal se **congela al vender** en `gasto_fijo_cargos`
  (una fila por gasto × mes × animal), coherente con la regla 5 de
  `CORRECCIONES.md` §14 (“los costos se congelan cuando ocurren”).
- Un gasto digitado atrasado se reparte **solo entre los animales no
  vendidos**: el prorrateo descuenta lo ya congelado y reparte el resto. Eso
  mantiene la suma en 100% sin reescribir utilidades ya cerradas.
- La tabla `costos_otros` (costos directos por animal) **sigue fuera** de la
  fórmula; los gastos fijos son el único costo indirecto admitido.
- Requirió enmendar `ESPECIFICACION_FUNCIONAL.md` (documento oro), que en su
  lista de “fuera de alcance” excluía toda economía ajena a la fórmula
  anterior. La enmienda es explícita para que código y contrato no queden en
  contradicción (`AGENTS.md` §6).

### D-18 — Dieta: se digita ₡ por kilo × kilos por animal al día
**Status: Decidida (2026-08-03). Enmienda la entrada de datos de D-02 y el
punto 5/14 de `CORRECCIONES.md` (que pedía un único campo semanal).**
El ganadero no conoce el costo semanal por animal: conoce el **precio del
alimento por kilo** (o por saco) y **cuántos kilos** le da a cada animal.
Pedirle el semanal lo obligaba a hacer la multiplicación de cabeza, con riesgo
de errar por 7×.

La dieta ahora guarda dos campos digitados — `costo_kg` y `kg_animal_dia` — y
los costos por animal pasan a ser **derivados**:

```text
costo_animal_dia    = costo_kg × kg_animal_dia
costo_animal_semana = costo_animal_dia × 7
```

Consecuencias:
- **Nada más cambia.** El snapshot al asignar (D-02), el prorrateo por días y
  la fórmula de utilidad siguen leyendo `costo_animal_dia`.
- `costo_animal_semana` se conserva como columna derivada, solo para mostrar;
  ya no es la fuente de verdad.
- Migración: local Drift v15 y
  `supabase/migrations/20260803130000_dieta_costo_por_kilo.sql`. Las dietas
  anteriores quedan como `costo_kg = costo_animal_dia, kg_animal_dia = 1`, lo
  que deja `costo_animal_dia` idéntico y no reescribe utilidades ya cerradas.
- Los **ingredientes siguen siendo solo nombres** sin costo (punto 6 de
  `CORRECCIONES.md` sigue vigente).

### D-19 — Venta en dos momentos: grupo primero, datos de planta después
**Status: Decidida (2026-08-04). Enmienda el punto 14 de `CORRECCIONES.md`, que
definía la venta como `kilos de salida × ₡/kg de venta`.**
El ganadero **no sabe cuánto le pagan** cuando manda los animales: la planta
liquida días después, y paga por la canal. Pedir un ₡/kg al confirmar la venta
obligaba a inventar un número y luego corregirlo.

La venta pasa a tener dos momentos:

1. **Armar el grupo de venta:** identificador + **kilos de salida de la finca**.
   Nada más. La utilidad queda en “—”.
2. **Datos de planta, por animal, desde el historial:** peso en pie, peso en
   canal y **dinero recibido**. El **rendimiento es derivado**
   (`canal ÷ pie × 100`), no se digita — un dato menos y nunca contradice a los
   pesos.

```text
Utilidad = Dinero recibido − (compra + dietas + sanidad + gastos fijos)
```

Consecuencias:
- **`dinero_recibido` es la nueva fuente de la utilidad**, no `precio`. Mientras
  sea NULL la utilidad es “—”, coherente con la regla de `CORRECCIONES.md` §14
  (“sin venta no hay utilidad, nunca ₡0”). `precio` queda como espejo para no
  desalinear nada que lo lea, y `precio_kg` pasa a ser **₡/kg de canal**
  derivado.
- El **peso de salida de finca y el peso en pie son campos distintos**:
  el segundo lo da la planta después del viaje y no tiene por qué coincidir.
  Decisión explícita de Erick al revisar el módulo.
- Se permiten **datos parciales** (solo los pesos, sin dinero): así el ganadero
  registra lo que va sabiendo sin quedar bloqueado.
- Cada grupo de venta muestra **análisis**: utilidad total, rendimiento
  promedio, dinero recibido, kilos por etapa, ₡/kg de canal y cuántos animales
  faltan por liquidar. El promedio de rendimiento **solo cuenta a los que tienen
  los dos pesos** — no se rellena con ceros.
- Migración: local Drift v16 y
  `supabase/migrations/20260803140000_venta_datos_planta.sql`, con
  `dinero_recibido = precio` para las ventas ya registradas, de modo que
  ninguna utilidad cerrada se convierta en “—”.
- `registrarVenta` (venta individual, camino de compatibilidad) sí conoce el
  dinero al registrar, así que llena `dinero_recibido` de una.

---

## How to use this log / Cómo usar este registro

- Before building a module, resolve its **Abierta** entries (or accept the
  Propuesta and mark it Decidida with a date).
- When a decision changes, do not delete the entry — mark it superseded and
  link the replacement.
- Keep entries short: context, options, decision, consequence.
