# Architecture review — HatoControl

## Current state
HatoControl is a Flutter app with an offline-first architecture:

```text
Flutter UI screens
   ↓
Repositories (local-first business actions)
   ↓
Drift / SQLite local database
   ↕
SyncService
   ↕
Supabase Auth + Postgres/RLS + Edge Function for finca photos
```

Implemented domains: accounts/licensing, fincas, finca members, lotes, animals, pesajes, and finca photos.

## What is good already
- Clear offline-first direction: repositories write locally and `SyncService` uploads later.
- Drift schema mirrors the Supabase model and uses client-generated UUIDs.
- Domain transactions exist for important multi-row actions:
  - create finca + admin membership
  - create animal + first pesaje
- Soft delete pattern exists through `deletedAt`.
- Sync avoids one bad row blocking all rows.
- RLS/security model is documented in `docs/MODELO_DATOS.md`.

## Main risks / improvement areas

### 1. Testability is limited by globals
`lib/services.dart` creates global singleton repositories and database. This is convenient, but widget and sync tests become hard because screens depend on real services.

**Improve:** move toward dependency injection. Small first step: introduce an `AppServices` object and pass it down, or later use Riverpod/Provider.

### 2. SyncService does too much directly
`SyncService` owns local DB logic, remote Supabase calls, upload mapping, download mapping, photos, cursors, and retry behavior.

**Improve:** split into:
- `RemoteApi`/`SupabaseGateway` interface
- table-specific sync mappers
- sync orchestration

This enables fake remote sync tests without a real Supabase project.

### 3. Local database lacks explicit constraints
The data model documents uniqueness and relationships, but local Drift tables do not currently declare all unique constraints/foreign keys/checks.

**Improve locally:**
- unique `(fincaId, identificador)` for animals
- unique `(fincaId, usuarioId)` for members
- role check: `admin | operario`
- account status/plan checks where useful
- weight must be positive

Keep server constraints as the final source of truth.

### 4. Conflict policy is simple last-write-wins
This is fine for v1, but can surprise users if two devices edit the same record offline.

**Improve:** document visible conflict behavior and later add conflict logs for important edits.

### 5. Cursors can miss rows in edge cases
Sync uses `updated_at > cursor`. If several rows have identical timestamps and the cursor advances to that timestamp, a row not applied due to partial failure could be skipped.

**Improve:** cursor by `(updated_at, id)` or only advance after a batch is fully applied.

### 6. Generated DB file is committed
`database.g.dart` is present. That is acceptable, but agents must regenerate it after schema changes.

## Recommended target architecture

```text
lib/
  app/                 app bootstrap, dependency wiring, theme, routing
  core/                shared errors, ids, clock, result types, validators
  data/
    local/             Drift schema + DAOs
    remote/            SupabaseGateway interface + implementation
    sync/              sync orchestration + table sync units
    repositories/      local-first use cases
  features/
    auth/
    cuenta/
    fincas/
    lotes/
    pesaje/
  test_support/        fakes/builders only if needed
```

No need for a large rewrite immediately. Refactor only when a feature or test needs it.

## Priority roadmap

### Phase 1 — guardrails and understanding
- Keep `AGENTS.md` updated.
- Replace placeholder README with product + run instructions.
- Add unit tests for repository invariants.
- Add CI for format/analyze/test.

### Phase 2 — QA automation
- In-memory Drift test database.
- Repository tests for finca/lote/animal/pesaje flows.
- Sync tests with fake remote gateway.
- Widget smoke tests for key screens.

### Phase 3 — local constraints and safer sync
- Add local unique/check constraints.
- Add sync status/error table for observability.
- Make cursor advancement safer.
- Extract Supabase gateway.

### Phase 4 — device/hardware validation
- Run on iPhone with a development team configured in Xcode.
- Test offline/online transitions, photo upload, account limits, and multi-device sync.
- Define hardware integration boundary if external farm hardware will connect later: BLE, Wi-Fi, scale files, or manual import.

### Phase 5 — publish readiness
- App name/icons/splash/privacy policy.
- Store screenshots and metadata.
- TestFlight internal beta, then external beta.
- Production Supabase project, backups, logging, RLS review, and migration process.
