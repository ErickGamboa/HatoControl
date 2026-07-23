# HatoControl — Product roadmap / Hoja de ruta

Living implementation plan. **Product behavior is defined only by**
[`docs/ESPECIFICACION_FUNCIONAL.md`](ESPECIFICACION_FUNCIONAL.md) (documento oro,
Erick → Mainor). If a feature is not in that doc, it is out of scope: do not
build it; remove or align existing code that contradicts it.

Companion docs:
- `docs/ESPECIFICACION_FUNCIONAL.md` — **fuente de verdad del producto**.
- `docs/DECISIONES.md` — technical/product decisions (must not contradict the oro).
- `docs/MODELO_DATOS.md` — data model (extend only for oro modules).
- `docs/ARCHITECTURE_REVIEW.md` — technical hardening (globals, sync, CI).
- `docs/QA_AUTOMATION.md` — test pyramid and evaluator sets.

## Vision (from the oro)

App for a field cattleman: **touch-first**, **offline-first**, centered on the
**Pantalla de Trabajo (Pesaje)**. Cycle:

```text
Pesaje (trabajo) ──► Sanidad (FAB) ──► Hoja de Vida
       │                  │
     Lotes ◄── Dietas     └── medicamentos / dosis / retiro
       │
     Venta (lote de venta + utilidad)
```

Infrastructure kept (not “field modules” but not deleted): auth, fincas,
cuenta/licencia, sync.

## Quality bar / Barra de calidad

Every oro module ships only when ALL of these hold:

1. Behavior matches `ESPECIFICACION_FUNCIONAL.md` (acceptance = that text).
2. Data model updated in `MODELO_DATOS.md` + Drift + Sync in the same change.
3. Offline-first invariants (`AGENTS.md`): UUID, `pendiente`, soft delete, txs.
4. Business math in pure/testable repository (or estadisticas) functions.
5. Named evaluator set in `QA_AUTOMATION.md`; `dart format` / `analyze` / `test` green.

## Current state vs oro (jul 2026)

Gold behavior: `docs/ESPECIFICACION_FUNCIONAL.md`. Local Drift **v12** adds
medicamentos, dieta_ingredientes, lotes_venta, retiro/dosis on eventos,
peso/lote_venta_id on ventas. Push Supabase migration
`20260723120000_oro_medicamentos_ventas.sql` before syncing new tables.

### Keep and align

| Oro module | Status |
|---|---|
| **1 Trabajo (Pesaje)** | Day board + GMD + same-day correct + FAB sanidad con dosis |
| **2 Sanidad catalog** | CRUD medicamentos + apply from Trabajo |
| **3 Lotes** | Nombre/número; lista; cambiar lote; hoja de vida |
| **4 Dietas** | Ingredientes opcionales; rangos en ficha |
| **5 Hoja de Vida** | General (retiro/peso/venta) + tabs oro |
| **6 Venta** | Retiro block + lote de venta + utilidad oro |

### Still to retire

- [x] Corral removed from finca home
- [x] Deleted `CorralScreen` + batch sheet + tests
- [x] Deleted `LoteHistorialScreen` charts module + nav entry
- [ ] Feature-flag gating leftovers in non-oro paths (if any)
- [ ] Optional: standalone `AnimalHistorialScreen` if fully covered by Hoja de Vida


## Platforms

iOS, Android, macOS first-class. Web scaffold exists but not ready (`dart:io`
photos). Windows optional/documented-only. Cross-cutting sync robustness stays
always-on (see `ARCHITECTURE_REVIEW.md`).
