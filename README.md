# HatoControl

Flutter app for cattle farm management. The app is designed as **offline-first**: data is written to a local Drift/SQLite database first and later synchronized with Supabase.

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
- `docs/MODELO_DATOS.md` — domain model and Supabase assumptions
- `docs/ARCHITECTURE_REVIEW.md` — architecture review and roadmap
- `docs/QA_AUTOMATION.md` — test plan, invariants, and manual QA checklist

## Local setup / Configuración local

Install Flutter, then run:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Quality checks / comandos de calidad:

```bash
dart format lib test integration_test
flutter analyze
flutter test
```

## Platform notes / Notas de plataforma

### macOS / iPhone

```bash
flutter devices
flutter run -d <device-id>
```

For iPhone you also need Xcode installed, an Apple Development Team selected for the iOS Runner target, and a trusted developer profile on the iPhone.

The repository currently includes generated Flutter platform folders for iOS, Android, web, and macOS.

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
