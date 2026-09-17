# HatoControl — agent working guide

## Product context
Flutter offline-first app for cattle farm management: fincas, lotes, animals, weights, account/licensing. Local state is Drift/SQLite; Supabase is remote sync/auth/storage backend.

**Product behavior source of truth:** `docs/ESPECIFICACION_FUNCIONAL.md` (documento oro). If a feature is not described there, do not build it; remove or align existing code that contradicts it. Implementation sequencing lives in `docs/ROADMAP.md`.

**This package is also the web app.** `../HatoControlWeb` is a Flutter web
project that depends on this one by path (`hato_control`) and reuses these
screens, repositories, sync and theme as-is — it adds only a desktop layout
for wide screens. So `lib/` is shared product code for three clients (Android,
web on a phone, web on a computer), not just for the APK. Two consequences:

- **Keep `lib/` web-safe.** No bare `dart:io` / `path_provider` imports: put
  platform code behind a conditional import pair (`foto_picker.dart` and
  `data/local/archivo_foto.dart` are the examples). `flutter build web` must
  keep passing from `../HatoControlWeb`.
- **Shared behavior goes in this package, not in the web project.** When a
  rule or a dialog has to exist in both clients, extract it here (see
  `fincas/crear_finca_flujo.dart`, `fincas/editar_finca_flujo.dart`,
  `cuenta/estado_cuenta.dart`, `data/estadisticas/estadisticas_finca.dart`)
  so the phone and the computer can never drift apart.

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
- `lib/app/permisos_finca.dart`: `PermisosFinca` — read-only state for the open finca (invited users). Loaded by `FincaDetalleScreen`, read by the module screens.
- `lib/app/teclado/`: the app's own on-screen keyboard. The ear-tag reader pairs over Bluetooth as an HID keyboard, and the OS then hides its own keyboard app-wide (on iOS with no setting or public API to bring it back), so no field could be typed by hand — not even the login. `TecladoDelApp` wraps the whole app from the `MaterialApp.builder`, watches the `FocusManager`, and draws its own keyboard only while a physical keyboard is connected. With no reader connected it does nothing and the system keyboard behaves as always.
- Feature UI folders: `auth/`, `cuenta/`, `fincas/`, `lotes/`, `pesaje/`, `dietas/`, `sanidad/`, `venta/`, `home/`.
- `docs/ESPECIFICACION_FUNCIONAL.md`: product behavior (oro).
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
11. Invited users are read-only. `finca_miembros.rol = 'lector'` may never write:
    server-side, every `INSERT`/`UPDATE`/`DELETE` policy must go through
    `private.puede_escribir(finca, uid)` (not `es_miembro`, which is read-level);
    client-side, new write UI must be hidden when `permisosFinca.esSoloLectura`
    (`lib/app/permisos_finca.dart`). Sharing a finca always grants `lector`.
12. The app never calls `auth.signUp`. There is no self-service account creation:
    accounts are opened by the admin when a license is bought, or by invitation.
13. The app is always light (`themeMode: ThemeMode.light`), whatever mode the
    phone is in — it is used outdoors. Do not add a dark theme without first
    fixing the screens that paint their own background (the login paints white):
    with a dark scheme they got light text on a light background.
14. No field takes focus on its own. No `autofocus: true`, and no
    `requestFocus()` when a screen, sheet or dialog opens — a keyboard must
    only appear after the user taps where they want to write. The two
    programmatic focus moves that remain are user actions: the reader's Enter
    and the keyboard's own "Siguiente" key. After saving, screens release focus
    (`unfocus`) rather than moving it back to the tag field. The reader does not
    need focus: `LectorDeAretes` (`lib/app/teclado/`) captures it at screen
    level in Trabajo and Venta.
15. The app's own keyboard must be **shorter** than the system keyboard (it
    aims at ~30 % of the screen, always four rows). Screens are laid out for
    the gap the system keyboard leaves; when the app's was taller, Trabajo's
    day list and the Dietas dialog overflowed.
16. The app's own keyboard and the system keyboard must never both be on screen.
    `TecladoDelSistema` answers whether the system will show its keyboard (on
    Android that includes the `show_ime_with_hard_keyboard` setting, not just
    whether a reader is paired), `TecladoDelApp` waits out the system
    keyboard's slide-in before drawing its own, and it steps aside if
    `viewInsets.bottom` says the system keyboard is up anyway.

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

If `lib/` changed, the web client has to stay green too (it consumes this
package):

```bash
cd ../HatoControlWeb && flutter analyze && flutter test && flutter build web
```

## Manual testing account (mandatory)
- Manual testing on a device or emulator happens ONLY in the account `erick.yosue@gmail.com`, inside the finca named **`pruebas`**.
- Every other account and every other finca holds the owner's real production data. Never register, edit, or delete anything there — not even data you plan to undo, because deletes are soft and still sync to Supabase.
- If the emulator is signed into another account, sign out and switch before touching any write flow.
- Merely launching the app counts as testing in whatever account is signed in: it runs migrations on that cache and triggers a sync. Check first (`adb exec-out "run-as cr.co.hato_control cat /data/data/cr.co.hato_control/app_flutter/hatocontrol.sqlite" > tmp.sqlite`, then `sqlite3 tmp.sqlite "select email from sesiones_locales;"`). If it is not `erick.yosue@gmail.com`, do not launch it — verify with `flutter test` and `flutter analyze` instead.

## Testing expectations
- Repository/domain logic: unit tests with an in-memory Drift database.
- Sync logic: tests with a fake Supabase boundary or extracted remote gateway.
- Screens: widget tests with injected fake repositories, not real Supabase.
- Important flows: integration tests for login, create finca, create lote, create animal + pesaje, offline write then sync.
- Offline login changes must keep the evaluator set documented in `test/QA_CORRECCIONES_R1.md` passing, especially `test/auth/login_screen_offline_action_test.dart` and `test/integration/offline_login_cached_session_test.dart`.
- Round-1 money/sync changes: run `./scripts/verify_ronda1.sh` before handing work back.

## Guardrails for agents
- Do not add network calls in widgets unless they are auth-only or explicitly approved.
- Do not bypass RLS assumptions; client checks are UX only, server constraints/RLS are source of truth.
- Do not clear `pendiente` until a server upload succeeds.
- Do not advance sync cursors beyond rows that were successfully applied locally.
- Never let the local cache outlive the session that filled it: sync cursors belong to the device, so a cache left behind makes the next account inherit them and never download its own older rows (its finca exists in the cloud and never shows up). Signing out uploads everything and wipes the cache, or it does not sign out — see `lib/auth/cierre_sesion.dart`.
- Avoid globals in new code; introduce constructors/interfaces to make code testable.
