-- HatoControl — Module 5: feature_flags (module on/off, admin-managed)
-- Read-only to the app; written only by the admin CLI via the service_role
-- key, which bypasses RLS. There are intentionally no INSERT/UPDATE/DELETE
-- policies for `authenticated` — that is the enforcement mechanism, not an
-- oversight. See docs/DECISIONES.md D-15.

CREATE TABLE IF NOT EXISTS public.feature_flags (
  id uuid PRIMARY KEY,
  scope text NOT NULL CHECK (scope IN ('global', 'cuenta', 'finca')),
  scope_id uuid,
  clave text NOT NULL,
  habilitado boolean NOT NULL DEFAULT true,
  nota text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz,
  CONSTRAINT feature_flags_scope_id_shape CHECK (
    (scope = 'global') = (scope_id IS NULL)
  )
);

-- One active row per (scope, scope_id, clave). COALESCE folds the NULL
-- scope_id for 'global' rows into a fixed sentinel so the partial unique
-- index still applies uniformly.
CREATE UNIQUE INDEX IF NOT EXISTS idx_feature_flags_scope_clave
  ON public.feature_flags (
    scope,
    COALESCE(scope_id, '00000000-0000-0000-0000-000000000000'::uuid),
    clave
  )
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_feature_flags_clave ON public.feature_flags (clave)
  WHERE deleted_at IS NULL;

ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;

-- Cuenta-membership helper (dueño OR member of any finca under that cuenta),
-- mirroring private.es_miembro's role for the 'finca' scope.
CREATE OR REPLACE FUNCTION private.es_miembro_cuenta(p_cuenta_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, private
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.cuentas c
    WHERE c.id = p_cuenta_id AND c.dueno_id = p_user_id
  ) OR EXISTS (
    SELECT 1 FROM public.fincas f
    JOIN public.finca_miembros fm ON fm.finca_id = f.id
    WHERE f.cuenta_id = p_cuenta_id
      AND fm.usuario_id = p_user_id
      AND fm.deleted_at IS NULL
      AND f.deleted_at IS NULL
  );
$$;

REVOKE ALL ON FUNCTION private.es_miembro_cuenta(uuid, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.es_miembro_cuenta(uuid, uuid) TO authenticated, service_role;

CREATE POLICY feature_flags_select ON public.feature_flags
  FOR SELECT USING (
    scope = 'global'
    OR (scope = 'finca' AND private.es_miembro(scope_id, auth.uid()))
    OR (scope = 'cuenta' AND private.es_miembro_cuenta(scope_id, auth.uid()))
  );

-- No INSERT/UPDATE/DELETE policy for `authenticated`: the admin CLI writes
-- with the service_role key, which bypasses RLS entirely.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_feature_flags_updated_at'
  ) THEN
    CREATE TRIGGER trg_feature_flags_updated_at
      BEFORE UPDATE ON public.feature_flags
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
