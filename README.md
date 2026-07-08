# HatoControl

Flutter app for cattle farm management. The app is designed as **offline-first**: data is written to a local Drift/SQLite database first and later synchronized with Supabase.

**Canonical repo:** `/Users/mainor/Developer/HatoControlRun` (this folder). An older Desktop experiments clone was archived on 2026-07-07 under `~/Developer/_archive/`; do not use it for development.

## Main modules
- Auth and account/licensing
- Fincas and shared finca members
- Lotes
- Animals and weight history (`pesajes`)
- Finca photos

## Architecture

```text
Flutter UI → Repositories → Drift/SQLite
                         ↕
                    SyncService
                         ↕
                   Supabase/Postgres
```

Useful docs:
- `AGENTS.md` — guide and guardrails for coding agents
- `docs/ROADMAP.md` — product roadmap: módulos (historial, dietas, sanidad, corral, ventas), order, and quality bar
- `docs/DECISIONES.md` — decision log: decisions made and decisions still open per module
- `docs/MODELO_DATOS.md` — domain model and Supabase assumptions
- `docs/ARCHITECTURE_REVIEW.md` — technical architecture review and hardening roadmap
- `supabase/migrations/` — versioned schema (Supabase CLI); see
  `docs/SUPABASE_SQL_ORDER.md` for the migration workflow

## Local setup / Configuración local

Install Flutter, then run:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Quality checks / comandos de calidad:

```bash
./scripts/test.sh
```

Or manually:

```bash
dart format lib test integration_test
flutter analyze
flutter test
```

Platform build + integration (macOS + iOS simulator):

```bash
chmod +x scripts/*.sh   # once
./scripts/verify_platforms.sh
```

Optional Supabase e2e (requires seeded test user):

```bash
flutter test -d macos integration_test/supabase_e2e_test.dart \
  --dart-define=HATO_E2E_EMAIL=... \
  --dart-define=HATO_E2E_PASSWORD=...
```

Demo mode (mock finca with all modules, offline):

```bash
./scripts/run_demo.sh macos          # explore manually
./scripts/run_demo_tour.sh macos     # automated visible tour
```

## Platform notes / Notas de plataforma

### macOS / iPhone

```bash
flutter devices
flutter run -d <device-id>
```

For iPhone you also need Xcode installed, an Apple Development Team selected for the iOS Runner target, and a trusted developer profile on the iPhone.

The repository currently includes generated Flutter platform folders for iOS, Android, web, and macOS.

### App Store / TestFlight (iOS)

Prerequisites: Apple Developer Program membership, App Store Connect app record for bundle ID `cr.co.hatoControl`.

1. Regenerate launcher icons if the logo changed:
   ```bash
   dart run flutter_launcher_icons
   ```
2. Build a release IPA:
   ```bash
   flutter build ipa --release
   ```
3. Upload from Xcode (**Product → Archive → Distribute App**) or with `xcrun altool`.
4. Start with **TestFlight** internal testing, then external beta, before submitting for App Store review.

Store listing still needed outside the repo: screenshots, privacy policy URL, support URL, and App Privacy answers in App Store Connect. Support contact email is configured in `lib/config/support_config.dart`.

### Windows / Android from Windows

This app was originally developed from Windows targeting Android. That workflow does not require a committed `windows/` desktop folder.

Windows desktop support is not generated in this checkout yet. On a Windows machine with Flutter desktop support enabled, add it only if the product should ship as a Windows desktop app:

```powershell
flutter config --enable-windows-desktop
flutter create --platforms=windows .
flutter run -d windows
```

After adding Windows, commit the generated `windows/` folder and update this section with any Windows-specific setup or QA notes.

## Agent-friendly repo notes / Notas para agentes
- Spanish domain terms are intentional: `finca`, `lote`, `pesaje`, `cuenta`.
- Keep business rules in repositories/sync services, not directly in widgets.
- If data shape changes, update Drift schema/migrations, sync, tests, and `docs/MODELO_DATOS.md`.
- Keep docs bilingual where it helps future agents and developers.

## Notes
- Supabase anon/publishable keys are public client keys. Never commit `service_role` secrets.
- After editing Drift schema, regenerate `lib/data/local/database.g.dart`.
