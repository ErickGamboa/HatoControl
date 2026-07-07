-- HatoControl — Module 3: eventos_sanitarios
-- Run in Supabase SQL Editor after Module 2 script.
-- Prerequisite: docs/supabase_bootstrap_rls_helpers.sql (private.es_miembro).

CREATE TABLE IF NOT EXISTS public.eventos_sanitarios (
  id uuid PRIMARY KEY,
  animal_id uuid NOT NULL REFERENCES public.animales (id),
  tipo text NOT NULL CHECK (
    tipo IN ('vacuna', 'medicamento', 'desparasitacion', 'otro')
  ),
  producto text NOT NULL,
  dosis text,
  fecha timestamptz NOT NULL,
  responsable_id uuid REFERENCES public.usuarios (id),
  observaciones text,
  costo numeric CHECK (costo IS NULL OR costo >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_eventos_sanitarios_animal
  ON public.eventos_sanitarios (animal_id)
  WHERE deleted_at IS NULL;

ALTER TABLE public.eventos_sanitarios ENABLE ROW LEVEL SECURITY;

CREATE POLICY eventos_sanitarios_select ON public.eventos_sanitarios
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = eventos_sanitarios.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

CREATE POLICY eventos_sanitarios_insert ON public.eventos_sanitarios
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = eventos_sanitarios.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

CREATE POLICY eventos_sanitarios_update ON public.eventos_sanitarios
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = eventos_sanitarios.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = eventos_sanitarios.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_eventos_sanitarios_updated_at'
  ) THEN
    CREATE TRIGGER trg_eventos_sanitarios_updated_at
      BEFORE UPDATE ON public.eventos_sanitarios
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
