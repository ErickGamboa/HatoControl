# HatoControl — agent working guide

## Product context
Flutter offline-first app for cattle farm management: fincas, lotes, animals, weights, account/licensing. Local state is Drift/SQLite; Supabase is remote sync/auth/storage backend.

## Language and documentation policy
- The product domain is Spanish-first (`finca`, `lote`, `animal`, `pesaje`, `cuenta`). Preserve domain names in code and UI unless a product decision changes them.
- Agent/developer docs should be understandable in English. When adding user-facing setup or QA instructions, prefer bilingual headings or short Spanish/English notes.
- Keep README, `AGENTS.md`, and `docs/` updated when workflows, supported platforms, data rules, or test commands change.
- When adding a new platform or setup requirement, document both macOS and Windows implications when applicable.

## Architecture map
- `lib/main.dart`: app bootstrap, Supabase init, connectivity/auth-triggered sync, theme.
- `lib/services.dart`: global singleton service/repository instances. Keep this thin; prefer injectable dependencies in new code/tests.
- `lib/data/local/database.dart`: Drift schema and migrations.
- `lib/data/repositories/`: local-first business operations. UI should call repositories, not Supabase directly.
- `lib/data/sync/sync_service.dart`: bidirectional sync between local Drift tables and Supabase.
- Feature UI folders: `auth/`, `cuenta/`, `fincas/`, `lotes/`, `pesaje/`, `home/`.
- `docs/MODELO_DATOS.md`: domain model and Supabase/RLS expectations.

## Non-negotiable invariants
1. App is offline-first: writes go to Drift first and set `pendiente=true`.
2. Server writes happen in `SyncService`, not directly from UI screens.
3. Every domain row uses a client-generated UUID primary key.
4. Soft deletes use `deletedAt`; do not hard-delete domain data unless explicitly requested.
5. Local writes that change syncable data must update `updatedAt` and mark `pendiente=true`.
6. New finca creation must create the finca and admin membership in one local transaction.
7. New animal creation must create the animal and its first pesaje in one local transaction.
8. Animal identifiers must be unique per finca; enforce in UI/repository and rely on server constraint.
9. Never commit Supabase `service_role` secrets. The anon/publishable keys are public, but keep service credentials out of the repo.
10. Generated Drift files (`database.g.dart`) must be regenerated after schema changes.

## Before changing code
- Read the relevant repository and screen file.
- If changing data shape, update `lib/data/local/database.dart`, Drift migration, `SyncService`, `docs/MODELO_DATOS.md`, and tests.
- Prefer small PRs: one domain behavior or one screen at a time.

## Quality commands
Run these before handing work back:

```bash
dart format lib test
flutter analyze
flutter test
```

If Drift schema changed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing expectations
- Repository/domain logic: unit tests with an in-memory Drift database.
- Sync logic: tests with a fake Supabase boundary or extracted remote gateway.
- Screens: widget tests with injected fake repositories, not real Supabase.
- Important flows: integration tests for login, create finca, create lote, create animal + pesaje, offline write then sync.
- Offline login changes must keep the evaluator set documented in `docs/QA_AUTOMATION.md` passing, especially `test/auth/login_screen_offline_action_test.dart` and `integration_test/offline_login_cached_session_test.dart`.

## Guardrails for agents
- Do not add network calls in widgets unless they are auth-only or explicitly approved.
- Do not bypass RLS assumptions; client checks are UX only, server constraints/RLS are source of truth.
- Do not clear `pendiente` until a server upload succeeds.
- Do not advance sync cursors beyond rows that were successfully applied locally.
- Avoid globals in new code; introduce constructors/interfaces to make code testable.
