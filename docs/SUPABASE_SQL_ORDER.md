# Supabase SQL — orden de ejecución

Scripts en `docs/supabase_*.sql`. Correr en **Supabase Dashboard → SQL Editor**
(proyecto `geocoundyilwxrnbhcqu`), **un archivo a la vez**, en este orden.

## 0. Diagnóstico (opcional, solo lectura)

Pegá esto primero para ver qué falta:

```sql
-- ¿Existe el helper que falló?
SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname IN ('es_miembro', 'set_updated_at')
ORDER BY 1, 2;

-- ¿Tablas base del producto?
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
    'planes', 'cuentas', 'usuarios', 'fincas', 'finca_miembros',
    'lotes', 'animales', 'pesajes', 'dietas', 'eventos_sanitarios'
  )
ORDER BY 1;

-- ¿Trigger updated_at?
SELECT tgname, relname
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
WHERE tgname LIKE '%updated_at%'
ORDER BY relname;
```

Interpretación:

| Resultado | Acción |
|-----------|--------|
| `es_miembro` **no aparece** | Correr **`supabase_bootstrap_rls_helpers.sql`** |
| Faltan `fincas`, `finca_miembros`, etc. | El proyecto no tiene el schema base v1; hay que restaurarlo desde el backup/script original del producto (no está en este repo) |
| `set_updated_at` no existe | El bootstrap lo crea |
| `dietas` ya existe | Module 2 ya se aplicó (total o parcial); no re-ejecutar CREATE TABLE sin revisar |

## 1. Bootstrap (obligatorio si falló `es_miembro`)

```text
docs/supabase_bootstrap_rls_helpers.sql
```

Crea:

- `private` schema
- `public.set_updated_at()`
- `private.es_miembro(finca_id, user_id)` ← **esto resuelve tu error**
- `private.es_admin`, `private.es_creador` (opcionales)

## 2. Module 2 — Dietas

```text
docs/supabase_module2_dietas.sql
```

Tablas: `dietas`, `lote_dietas`, `movimientos_lote` + RLS + triggers.

**Depende de:** `fincas`, `lotes`, `animales`, `private.es_miembro`, `set_updated_at`.

## 3. Module 3 — Sanidad

```text
docs/supabase_module3_sanidad.sql
```

Tabla: `eventos_sanitarios` + RLS.

**Depende de:** Module 2 aplicado (o al menos `animales` + helpers).

## 4. Module 4 — Ventas / economía

```text
docs/supabase_module4_ventas.sql
```

Columnas en `animales` + tablas `ventas`, `costos_otros`.

**Depende de:** Module 3 (o al menos `animales` + helpers).

---

## Error que viste

```text
function private.es_miembro(uuid, uuid) does not exist
```

Las políticas RLS de Module 2 llaman `private.es_miembro(finca_id, auth.uid())`.
Esa función vive en el **bootstrap**, no en Module 2. No es un bug del script de dietas:
**falta el paso 1**.

## Si Module 2 falló a mitad

Si el editor creó tablas pero falló en `CREATE POLICY`:

1. Correr bootstrap.
2. Borrar políticas a medias (si existen) o saltar líneas ya aplicadas.
3. Re-ejecutar solo la parte que falta, o usar:

```sql
-- ejemplo: recrear política dietas_select
DROP POLICY IF EXISTS dietas_select ON public.dietas;
-- luego pegar CREATE POLICY ... del script
```

## Verificación rápida post-bootstrap

```sql
SELECT private.es_miembro(
  (SELECT id FROM public.fincas LIMIT 1),
  auth.uid()
);
```

Con sesión SQL anónima puede devolver `false`; lo importante es que **no lance error**.

## English summary

Run order: **bootstrap → module2 → module3 → module4**.  
Your error means step **bootstrap** was skipped; module scripts assume helpers already exist on the server.
