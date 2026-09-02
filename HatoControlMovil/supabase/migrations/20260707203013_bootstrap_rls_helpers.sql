-- HatoControl — Bootstrap: RLS helpers (run BEFORE module 2/3/4 SQL)
-- Project: geocoundyilwxrnbhcqu
--
-- Module scripts call private.es_miembro(finca_id, auth.uid()).
-- If you see "function private.es_miembro(uuid, uuid) does not exist",
-- run THIS FILE FIRST in Supabase → SQL Editor.
--
-- Prerequisites (must already exist from your base HatoControl schema):
--   public.finca_miembros (finca_id, usuario_id, rol, deleted_at)
--   public.fincas, public.lotes, public.animales, etc.

-- ---------------------------------------------------------------- schema
CREATE SCHEMA IF NOT EXISTS private;

-- ---------------------------------------------------------------- updated_at trigger (used by module 2–4)
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- ---------------------------------------------------------------- membership helper
-- True when user_id has an active row in finca_miembros for that finca.
CREATE OR REPLACE FUNCTION private.es_miembro(p_finca_id uuid, p_user_id uuid)
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
  );
$$;

-- Optional helpers referenced in MODELO_DATOS (safe to create; module SQL does not require them)
CREATE OR REPLACE FUNCTION private.es_admin(p_finca_id uuid, p_user_id uuid)
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
      AND fm.rol = 'admin'
      AND fm.deleted_at IS NULL
  );
$$;

CREATE OR REPLACE FUNCTION private.es_creador(p_finca_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, private
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.fincas f
    WHERE f.id = p_finca_id
      AND f.creada_por = p_user_id
      AND f.deleted_at IS NULL
  );
$$;

-- ---------------------------------------------------------------- permissions (Supabase roles)
REVOKE ALL ON SCHEMA private FROM PUBLIC;
GRANT USAGE ON SCHEMA private TO postgres, authenticated, service_role;

REVOKE ALL ON FUNCTION private.es_miembro(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.es_miembro(uuid, uuid) TO authenticated, service_role;

REVOKE ALL ON FUNCTION private.es_admin(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.es_admin(uuid, uuid) TO authenticated, service_role;

REVOKE ALL ON FUNCTION private.es_creador(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.es_creador(uuid, uuid) TO authenticated, service_role;

-- ---------------------------------------------------------------- verify (should return one row each)
-- SELECT private.es_miembro('00000000-0000-0000-0000-000000000000'::uuid, auth.uid());
-- SELECT proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
--   WHERE n.nspname = 'private' AND proname = 'es_miembro';
