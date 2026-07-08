-- HatoControl — admin_audit_log: every hatoctl write is recorded here.
-- service_role only: no RLS policies for `authenticated` at all (neither
-- read nor write). The app never touches this table.

CREATE TABLE IF NOT EXISTS public.admin_audit_log (
  id uuid PRIMARY KEY,
  actor text NOT NULL,
  accion text NOT NULL,
  detalle jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_admin_audit_log_created_at
  ON public.admin_audit_log (created_at DESC);

ALTER TABLE public.admin_audit_log ENABLE ROW LEVEL SECURITY;
-- Intentionally no policies: service_role bypasses RLS; authenticated has
-- no access at all.
