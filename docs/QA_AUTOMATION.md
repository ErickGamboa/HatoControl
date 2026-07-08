# QA automation and invariants plan

## Test pyramid

1. **Unit tests**: validators, date/weight calculations, sync mappers.
2. **Repository tests**: local-first behavior using an in-memory Drift DB.
3. **Sync tests**: fake remote gateway; no real Supabase in CI.
4. **Widget tests**: key screens with fake repositories/services.
5. **Integration/manual device tests**: real iPhone/Mac + Supabase staging.

## Critical invariants to automate

### Local-first sync
- Every repository write to a syncable table sets `pendiente=true`.
- Every update changes `updatedAt`.
- Soft delete sets `deletedAt`, `updatedAt`, and `pendiente=true`.
- Failed upload leaves the row pending.
- Successful upload clears only that row's pending flag.

### Fincas and licensing
- Cannot create a finca without known local account/license state.
- Cannot create more fincas than the local plan limit allows.
- Creating a finca also creates admin membership in the same transaction.
- Collaborator fincas do not count toward the owner account limit.

### Members and roles
- User cannot be duplicated in the same finca.
- Role must be `admin` or `operario`.
- Removing access is a soft delete, not a hard delete.

### Lotes, animals, pesajes
- Animal identifier is unique inside a finca.
- Creating an animal also creates the first pesaje in the same transaction.
- Peso must be positive.
- Moving an animal updates `loteId`, `updatedAt`, and `pendiente`.
- Current weight is the latest non-deleted pesaje.
- Daily gain uses calendar-day difference, not exact 24-hour blocks.

### Historial y estadísticas (módulo 1)
- Global average gain = (last peso − first peso) / calendar days; null with
  fewer than two pesajes or when first and last fall on the same day.
- Lote periods group pesajes by calendar date (D-01); each animal is compared
  only against its own previous pesaje.
- Animals without a previous pesaje count in the headcount but never in the
  gain averages.
- Soft-deleted pesajes and animals from other lotes are excluded from lote
  aggregates.

### Sync cursors
- Cursors are per table.
- A cursor must not advance past rows that were not applied locally.
- Downloads must preserve local-only fields such as `fotoLocalPath` and `fotoPendiente`.

## Historial evaluator set (módulo 1)

These tests protect the weight-history math and screens. Keep them passing:

- `test/estadisticas/estadisticas_pesajes_test.dart` — pure math: calendar
  days, global average gain edge cases, and lote period aggregation fixtures
  (animal added mid-period, missed weighing, same-day duplicates, weight
  loss).
- `test/repositories/pesajes_repository_test.dart` — includes
  `observarResumenLote` filtering (other lotes and soft-deleted pesajes
  excluded).
- `test/lotes/animal_historial_screen_test.dart` — Días column, per-row
  ganancia and kg/día, global average, and evolution chart render.
- `test/lotes/lote_historial_screen_test.dart` — period table (count,
  promedio, ganancia, kg/día) and average-weight chart render.

Run the historial evaluator set:

```bash
flutter test test/estadisticas test/lotes test/repositories/pesajes_repository_test.dart
```

## Dietas evaluator set (módulo 2)

- `test/repositories/dietas_repository_test.dart` — CRUD dietas, asignación con
  costo congelado, movimientos_lote en crear/mover animal.
- Apply server schema: `supabase/migrations/20260707203015_module2_dietas.sql`
  via `supabase db push` (see `docs/SUPABASE_SQL_ORDER.md`).

Run the dietas evaluator set:

```bash
flutter test test/repositories/dietas_repository_test.dart
```

## Sanidad evaluator set (módulo 3)

- `test/repositories/sanidad_repository_test.dart` — registro individual,
  batch por lote, borrado suave, sugerencias de producto.
- Apply server schema: `supabase/migrations/20260707203017_module3_sanidad.sql`
  via `supabase db push` (see `docs/SUPABASE_SQL_ORDER.md`).

Run the sanidad evaluator set:

```bash
flutter test test/repositories/sanidad_repository_test.dart
```

## Corral evaluator set (módulo 3c)

- `test/corral/corral_screen_test.dart` — arete + peso + guardar (≤3 taps).

```bash
flutter test test/corral
```

## Ventas / economía evaluator set (módulo 4)

- `test/estadisticas/estadisticas_economicas_test.dart` — utilidad, margen,
  rentabilidad; fixture roadmap (₡520k + ₡95k + ₡18k → ₡147k on ₡780k venta).
- `test/repositories/ventas_repository_test.dart` — venta, resumen con sanidad,
  repetir último evento.
- `test/lotes/animal_ficha_screen_test.dart` — pestaña Economía.

```bash
flutter test test/estadisticas/estadisticas_economicas_test.dart test/repositories/ventas_repository_test.dart test/lotes/animal_ficha_screen_test.dart
```

## Feature flags evaluator set (módulo 5)

- `test/repositories/feature_flags_repository_test.dart` — precedencia
  finca > cuenta > global > `defaultValue` (fail-open), fila borrada
  (soft delete) ignorada, scope de otra finca no aplica, `observarFlags()`
  excluye borradas.
- Read-only table (D-15): no push/pending-guard tests needed, only the pull
  mapper in `SyncService._bajarFeatureFlags()`.

Run the feature flags evaluator set:

```bash
flutter test test/repositories/feature_flags_repository_test.dart
```

## Demo dataset + visible tour

Offline mock finca with realistic data (pesajes, dietas, sanidad, venta/rentabilidad):

| Command | What it does |
|---------|----------------|
| `./scripts/run_demo.sh macos` | Run app with `SEED_DEMO=1` → **Hacienda Demo HatoControl** |
| `./scripts/run_demo_tour.sh macos` | Automated slow tour (integration test) |

Demo animals: **1001** (corral + pesajes), **1002** (economía), **3001** (vendido).

```bash
flutter test test/demo/demo_seed_test.dart
flutter test -d macos integration_test/demo_tour_test.dart \
  --dart-define=SEED_DEMO=1 --dart-define=HATO_E2E_SLOW_MS=900
```

## CI
`.github/workflows/ci.yml` runs on macOS: format, analyze, unit tests, and
**macOS integration tests** (app smoke + offline flows). Reference:

```yaml
- run: flutter test
- run: flutter test -d macos integration_test/app_smoke_test.dart
```

## Integration test tiers

| Tier | Files | Needs device | Runs in CI |
|------|-------|--------------|------------|
| **Offline flows** | `test/integration/offline_*.dart` | No (VM / `flutter test`) | Yes (via `flutter test`) |
| **Device smoke** | `integration_test/app_smoke_test.dart` | Yes (macOS) | Yes |
| **Supabase e2e** | `integration_test/supabase_e2e_test.dart` | Yes + credentials | Manual / staging |

Offline multi-module flows run in the normal test suite (no simulator required):

```bash
flutter test test/integration
```

Device verification (macOS build + simulator smoke):

```bash
./scripts/verify_platforms.sh
```

Run Supabase e2e (visible steps on simulator):

```bash
flutter test -d "iPhone 17" integration_test/supabase_e2e_test.dart \
  --dart-define=HATO_E2E_EMAIL=... \
  --dart-define=HATO_E2E_PASSWORD=... \
  --dart-define=HATO_E2E_SLOW_MS=650
```

Shared device helpers: `integration_test/helpers/integration_helpers.dart`.
Offline seed data: `test/support/local_db_seed.dart`.

## Offline flow tests (`test/integration/`)

- `offline_local_flow_test.dart` — finca, lote, animal, pesajes; all `pendiente=true`.
- `offline_login_cached_session_test.dart` — sesión offline verificada + datos locales.
- `offline_modules_flow_test.dart` — dietas, movimientos_lote, sanidad individual y batch.

Run the offline flow set:

```bash
flutter test test/integration
```

## Local QA commands

```bash
./scripts/test.sh
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
```

After Drift schema edits:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Manual test checklist for Mac/iPhone

### Account/auth
- Sign up / log in / log out.
- App handles no connection on startup.
- Account suspended screen works if server marks account suspended.

### Offline login evaluators
- `test/auth/login_screen_offline_action_test.dart` must keep passing. It is
  the regression test for the iPhone case where `connectivity_plus` reports a
  connection but Supabase cannot be reached: a cached user must still see
  `Entrar sin conexión`.
- `test/auth/mensajes_auth_test.dart` must keep passing. Supabase auth errors
  caused by network failures must be treated as offline-capable failures, not
  as incorrect credentials.
- `test/repositories/sesion_local_repository_test.dart` must keep passing. It
  protects the local verified-user state machine: save after online login,
  activate offline entry, and clear local access on explicit sign-out.
- `integration_test/offline_login_cached_session_test.dart` must keep passing
  as `test/integration/offline_login_cached_session_test.dart` (VM suite).

Run the offline-login evaluator set:

```bash
flutter test test/auth test/repositories/sesion_local_repository_test.dart
flutter test test/integration/offline_login_cached_session_test.dart
```

Keyboard `TUIKeyboardContentView` unsatisfiable-constraint logs are iOS system
keyboard noise unless paired with a Flutter exception or app process crash.

### Offline-first
- Turn off network.
- Confirm a previously logged-in user can see and tap `Entrar sin conexión`
  from the login screen.
- Create finca, lote, animal, and pesaje.
- Reopen app: data still appears.
- Turn network on: sync uploads pending rows.
- Log into another device: synced data appears.

### Photos
- Add finca photo offline.
- Reconnect: photo uploads.
- Confirm `fotoUrl` displays on another device.

### Permissions
- Admin can invite/remove member.
- Operario can operate but not administer members.
- Removed member loses access after sync.

### Data correctness
- Duplicate animal identifier in same finca is rejected.
- Same identifier in another finca is allowed.
- Delete pesaje: current weight recalculates.
- Move animal to another lote: animal disappears from old lote and appears in new lote.
