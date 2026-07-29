# QA — Correcciones ronda 1 / Round-1 corrections

Bilingual checklist of what automated tests cover vs what still needs device/cloud verification.

## Coverage matrix / Matriz de cobertura

| # | Change | Automated today | Gap / how to verify |
|---|---|---|---|
| **14** | Utilidad ₡/kg + dieta semanal + corte venta | `utilidad_oro_test`, `correcciones_ronda1_flow_test`, **`integration_test/ronda1_utilidad_e2e_test.dart`** (UI + Supabase) | Create **new** animals; old demo animals keep legacy totals |
| **11** | Sync automático + columnas nuevas | Fake gateway + **e2e waits for real Supabase rows** | — |
| **6** | Ingredientes solo nombres | Repo + ronda1 flow + **e2e creates Pasto/Concentrado/Melaza** | — |
| **8** | Sanidad FAB no se reactiva al corregir | None (logic change only) | Manual: pesar → salir → reentrar → corregir peso → FAB sigue off |
| **7** | Ganancia promedio lote (ambas fechas) | `test/estadisticas/estadisticas_pesajes_test.dart` | UI lote detalle after 2 jornadas |
| **13** | Lote sin dieta / quitar | `correcciones_ronda1_flow_test`, `utilidad_oro_test` | UI picker “Sin dieta” |
| **9** | `+` sanidad = hoja medicamentos | None | Manual hoja de vida → Sanidad → `+` |
| **3** | Quitar meds al lote | None | Manual: detalle lote sin ícono vacunas |
| **12** | Foto solo galería | None | Manual: tocar foto finca |
| **1** | Launch iOS | None | Cold start iPhone claro/oscuro |
| **2,4,5,10** | Textos | None | Spot-check UI copy |

## Commands / Comandos

Fast evaluator (CI + ronda 1):

```bash
./scripts/verify_ronda1.sh
```

Full unit/widget suite:

```bash
flutter test
```

Device smoke (macOS):

```bash
flutter test -d macos integration_test/app_smoke_test.dart
```

Visible Supabase e2e (legacy smoke: login + finca + lote + pesaje):

```bash
flutter test -d macos integration_test/supabase_e2e_test.dart \
  --dart-define=HATO_E2E_EMAIL=... \
  --dart-define=HATO_E2E_PASSWORD=...
```

Round-1 utilidad e2e (UI + cloud assert of new columns):

```bash
flutter test -d macos integration_test/ronda1_utilidad_e2e_test.dart \
  --dart-define=HATO_E2E_EMAIL=... \
  --dart-define=HATO_E2E_PASSWORD=...
```

`./scripts/verify_ronda1.sh` runs this automatically when `HATO_E2E_EMAIL` / `HATO_E2E_PASSWORD` are set.

## Recommended next / Siguiente

1. Widget tests with fake repos for `#8` pesaje FAB, `#9` sanidad `+`
2. Spot-check manual: `#1` launch iOS, `#12` galería, copy `#2/#4/#5/#10`

## Offline evaluator set (AGENTS.md)

Still required for login work:

- `test/auth/login_screen_offline_action_test.dart`
- `test/integration/offline_login_cached_session_test.dart`
