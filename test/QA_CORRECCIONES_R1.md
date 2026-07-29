# QA — Correcciones ronda 1 / Round-1 corrections

Bilingual checklist of what automated tests cover vs what still needs device/cloud verification.

## Coverage matrix / Matriz de cobertura

| # | Change | Automated today | Gap / how to verify |
|---|---|---|---|
| **14** | Utilidad ₡/kg + dieta semanal + corte venta | `test/repositories/utilidad_oro_test.dart`, `test/integration/correcciones_ronda1_flow_test.dart` | Create **new** animals in UI; old demo animals keep legacy totals |
| **11** | Sync automático + columnas nuevas | Fake gateway push asserts in `correcciones_ronda1_flow_test`; engine tests exist | Real cloud: offline write → connect → row in Supabase table |
| **6** | Ingredientes solo nombres | Repo + ronda1 flow | UI: create dieta `Pasto`/`Concentrado`/`Melaza`, reopen |
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

Visible Supabase e2e (login + finca + lote + pesaje; **does not yet assert utilidad/kg**):

```bash
flutter test -d macos integration_test/supabase_e2e_test.dart \
  --dart-define=HATO_E2E_EMAIL=... \
  --dart-define=HATO_E2E_PASSWORD=...
```

## Recommended next e2e tools / Próximas herramientas

1. **Extend `supabase_e2e_test.dart`** (or add `integration_test/ronda1_utilidad_e2e_test.dart`) to:
   - Register animal with peso + ₡/kg and assert on-screen “Costo del animal”
   - Create dieta semanal + ingredients
   - Sell with lote ₡/kg and open hoja de vida → Venta breakdown
   - Optional: query Supabase REST for `peso_compra` / `precio_kg` / `costo_animal_semana` after sync
2. **Widget tests** with fake repos for: `#8` pesaje FAB, `#9` sanidad `+`, `#2/#5` copy keys
3. **Keep cloud check in Mainor’s loop** (punto 11): for each module, write offline → sync → confirm in Supabase dashboard/SQL

## Offline evaluator set (AGENTS.md)

Still required for login work:

- `test/auth/login_screen_offline_action_test.dart`
- `test/integration/offline_login_cached_session_test.dart`
