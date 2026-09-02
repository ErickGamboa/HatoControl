-- HatoControl — Invitados de solo lectura (rol `lector`) + plan pro sin tope
-- Project: geocoundyilwxrnbhcqu
--
-- Qué hace, en orden:
--   1. `finca_miembros.rol` acepta 'lector' además de 'admin' / 'operario'.
--   2. Nuevo helper `private.puede_escribir(finca, usuario)`: miembro activo
--      cuyo rol NO es 'lector'. Se crea en las DOS aritméticas — con usuario y
--      con solo la finca (tomando `auth.uid()`) — porque en el proyecto vivo
--      hay políticas escritas de las dos formas.
--   3. Reescribe TODAS las políticas de escritura (INSERT/UPDATE/DELETE) que
--      hoy usan `private.es_miembro` para que usen `private.puede_escribir`.
--      Se hace recorriendo `pg_policies` porque las tablas del núcleo (fincas,
--      lotes, animales, pesajes…) se crearon fuera de `supabase/migrations/`.
--      Las políticas de SELECT quedan intactas: el invitado sigue viendo todo.
--   4. Sube `planes.limite_fincas` del plan `pro` para que sea "N fincas".
--
-- Es idempotente: correrlo dos veces no cambia nada la segunda vez (ya no hay
-- políticas de escritura con `es_miembro`).
--
-- Correr en Supabase → SQL Editor (o `supabase db push`). Después de correrlo,
-- revisar el NOTICE final: lista las políticas reescritas.
--
-- Si falla a mitad, el SQL Editor lo corre todo en una transacción: no queda
-- nada aplicado y se puede volver a correr desde arriba. Igual conviene
-- confirmar con las consultas del final que ninguna tabla se quedó sin su
-- política de escritura.

-- ------------------------------------------------------------------ 1. rol
DO $$
DECLARE c record;
BEGIN
  FOR c IN
    SELECT con.conname
    FROM pg_constraint con
    JOIN pg_class rel ON rel.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = rel.relnamespace
    WHERE n.nspname = 'public'
      AND rel.relname = 'finca_miembros'
      AND con.contype = 'c'
      AND pg_get_constraintdef(con.oid) ILIKE '%rol%'
  LOOP
    EXECUTE format(
      'ALTER TABLE public.finca_miembros DROP CONSTRAINT %I', c.conname
    );
    RAISE NOTICE 'CHECK viejo de rol eliminado: %', c.conname;
  END LOOP;
END $$;

ALTER TABLE public.finca_miembros
  ADD CONSTRAINT finca_miembros_rol_check
  CHECK (rol IN ('admin', 'operario', 'lector'));

-- --------------------------------------------------------------- 2. helper
-- Miembro activo que SÍ puede escribir en la finca. Un 'lector' (invitado)
-- devuelve false, así que toda escritura suya choca contra la RLS.
CREATE OR REPLACE FUNCTION private.puede_escribir(p_finca_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, private
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.finca_miembros fm
    WHERE fm.finca_id = p_finca_id
      AND fm.usuario_id = p_user_id
      AND fm.deleted_at IS NULL
      AND fm.rol IN ('admin', 'operario')
  );
$$;

REVOKE ALL ON FUNCTION private.puede_escribir(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.puede_escribir(uuid, uuid)
  TO authenticated, service_role;

-- Sobrecarga de UN argumento. En el proyecto vivo hay políticas escritas como
-- `private.es_miembro(finca_id)` (sin pasar el usuario: lo toma de auth.uid()),
-- así que la reescritura del paso 3 también produce llamadas de un argumento.
-- Sin esta versión, el CREATE POLICY falla con 42883 "function
-- private.puede_escribir(uuid) does not exist".
CREATE OR REPLACE FUNCTION private.puede_escribir(p_finca_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, private
AS $$
  SELECT private.puede_escribir(p_finca_id, auth.uid());
$$;

REVOKE ALL ON FUNCTION private.puede_escribir(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.puede_escribir(uuid)
  TO authenticated, service_role;

-- ------------------------------------------------- 3. políticas de escritura
DO $$
DECLARE
  r record;
  v_qual text;
  v_check text;
  v_roles text;
  v_sql text;
  v_tipo text;
  v_reescritas int := 0;
BEGIN
  FOR r IN
    SELECT schemaname, tablename, policyname, cmd, qual, with_check,
           roles, permissive
    FROM pg_policies
    WHERE schemaname = 'public'
      AND cmd IN ('INSERT', 'UPDATE', 'DELETE', 'ALL')
      AND (
        coalesce(qual, '') LIKE '%es_miembro%'
        OR coalesce(with_check, '') LIKE '%es_miembro%'
      )
  LOOP
    -- Primero la forma calificada y después la desnuda: si una política se
    -- escribió como `es_miembro(...)` (sin `private.`, resuelta por
    -- search_path) igual queda migrada. El orden importa — al revés se
    -- duplicaría el prefijo.
    v_qual := replace(
      replace(
        coalesce(r.qual, ''), 'private.es_miembro(', 'private.puede_escribir('
      ),
      'es_miembro(', 'private.puede_escribir('
    );
    v_check := replace(
      replace(
        coalesce(r.with_check, ''),
        'private.es_miembro(', 'private.puede_escribir('
      ),
      'es_miembro(', 'private.puede_escribir('
    );
    v_roles := array_to_string(r.roles, ', ');
    v_tipo := CASE
      WHEN r.permissive = 'PERMISSIVE' THEN 'PERMISSIVE' ELSE 'RESTRICTIVE'
    END;

    EXECUTE format(
      'DROP POLICY %I ON %I.%I', r.policyname, r.schemaname, r.tablename
    );

    IF r.cmd = 'ALL' THEN
      -- Una política FOR ALL también gobierna el SELECT: si le cambiáramos el
      -- helper, el invitado dejaría de VER la finca. Se parte en cuatro para
      -- que solo las tres de escritura exijan `puede_escribir`.
      IF r.qual IS NOT NULL THEN
        EXECUTE format(
          'CREATE POLICY %I ON %I.%I AS %s FOR SELECT TO %s USING (%s)',
          r.policyname || '_select', r.schemaname, r.tablename, v_tipo,
          v_roles, r.qual
        );
        EXECUTE format(
          'CREATE POLICY %I ON %I.%I AS %s FOR DELETE TO %s USING (%s)',
          r.policyname || '_delete', r.schemaname, r.tablename, v_tipo,
          v_roles, v_qual
        );
      END IF;
      EXECUTE format(
        'CREATE POLICY %I ON %I.%I AS %s FOR INSERT TO %s WITH CHECK (%s)',
        r.policyname || '_insert', r.schemaname, r.tablename, v_tipo, v_roles,
        coalesce(nullif(v_check, ''), v_qual)
      );
      EXECUTE format(
        'CREATE POLICY %I ON %I.%I AS %s FOR UPDATE TO %s '
        'USING (%s) WITH CHECK (%s)',
        r.policyname || '_update', r.schemaname, r.tablename, v_tipo, v_roles,
        coalesce(nullif(v_qual, ''), v_check),
        coalesce(nullif(v_check, ''), v_qual)
      );
      RAISE NOTICE 'FOR ALL partida en 4: %.%', r.tablename, r.policyname;
    ELSE
      v_sql := format(
        'CREATE POLICY %I ON %I.%I AS %s FOR %s TO %s',
        r.policyname, r.schemaname, r.tablename, v_tipo, r.cmd, v_roles
      );
      IF r.qual IS NOT NULL THEN
        v_sql := v_sql || format(' USING (%s)', v_qual);
      END IF;
      IF r.with_check IS NOT NULL THEN
        v_sql := v_sql || format(' WITH CHECK (%s)', v_check);
      END IF;
      EXECUTE v_sql;
      RAISE NOTICE 'reescrita: %.% (%)', r.tablename, r.policyname, r.cmd;
    END IF;

    v_reescritas := v_reescritas + 1;
  END LOOP;

  RAISE NOTICE 'Políticas de escritura migradas a puede_escribir: %',
    v_reescritas;
END $$;

-- --------------------------------------------- 3b. GRANT de los helpers de RLS
-- El log del emulador (2026-08-21) mostró bajadas fallando con
-- `permission denied for function es_miembro` (42501). Encaja con lo que reveló
-- el error 42883 del paso 3: hay una sobrecarga de UN argumento
-- (`es_miembro(uuid)`) que el bootstrap nunca otorgó — solo otorga la de dos.
-- Sin EXECUTE, la política de SELECT rechaza lecturas legítimas. Este bloque
-- recorre `pg_proc`, así que cubre TODAS las sobrecargas y esquemas.
DO $$
DECLARE f record;
BEGIN
  FOR f IN
    SELECT p.oid::regprocedure AS firma, n.nspname
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE p.proname IN (
      'es_miembro', 'es_admin', 'es_creador', 'comparte_finca', 'puede_escribir'
    )
  LOOP
    EXECUTE format(
      'GRANT EXECUTE ON FUNCTION %s TO authenticated, service_role', f.firma
    );
    RAISE NOTICE 'GRANT EXECUTE: %.%', f.nspname, f.firma;
  END LOOP;
END $$;

-- ----------------------------------------------------------- 4. plan pro = N
-- "N fincas" = sin tope práctico. El trigger private.validar_limite_fincas
-- compara contra este número, así que 999 alcanza para cualquier ganadero.
UPDATE public.planes SET limite_fincas = 999, updated_at = now()
WHERE codigo = 'pro' AND limite_fincas < 999;

-- ------------------------------------------------------------------ verificar
-- Ninguna política de escritura debería seguir usando es_miembro:
--   SELECT tablename, policyname, cmd FROM pg_policies
--   WHERE schemaname='public' AND cmd <> 'SELECT'
--     AND (qual LIKE '%es_miembro%' OR with_check LIKE '%es_miembro%');
--
-- Cada tabla con RLS debería conservar sus políticas de escritura (si alguna
-- corrida a medias dejó una tabla sin INSERT/UPDATE, aparece acá):
--   SELECT c.relname AS tabla,
--          count(*) FILTER (WHERE p.cmd = 'INSERT') AS ins,
--          count(*) FILTER (WHERE p.cmd = 'UPDATE') AS upd,
--          count(*) FILTER (WHERE p.cmd = 'SELECT') AS sel
--   FROM pg_class c
--   JOIN pg_namespace n ON n.oid = c.relnamespace
--   LEFT JOIN pg_policies p
--     ON p.schemaname = n.nspname AND p.tablename = c.relname
--   WHERE n.nspname = 'public' AND c.relkind = 'r' AND c.relrowsecurity
--   GROUP BY c.relname ORDER BY c.relname;
--
-- Planes:
--   SELECT codigo, nombre, limite_fincas FROM public.planes ORDER BY limite_fincas;
