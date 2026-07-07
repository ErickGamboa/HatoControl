-- HatoControl — Module 2: dietas, lote_dietas, movimientos_lote
-- Run in Supabase SQL Editor (project geocoundyilwxrnbhcqu).
-- Requires existing helpers: private.es_miembro(finca_id, user_id).

-- ---------------------------------------------------------------- dietas
CREATE TABLE IF NOT EXISTS public.dietas (
  id uuid PRIMARY KEY,
  finca_id uuid NOT NULL REFERENCES public.fincas (id),
  nombre text NOT NULL,
  descripcion text,
  costo_animal_dia numeric NOT NULL CHECK (costo_animal_dia >= 0),
  moneda text NOT NULL DEFAULT 'CRC',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_dietas_finca ON public.dietas (finca_id)
  WHERE deleted_at IS NULL;

ALTER TABLE public.dietas ENABLE ROW LEVEL SECURITY;

CREATE POLICY dietas_select ON public.dietas
  FOR SELECT USING (private.es_miembro(finca_id, auth.uid()));

CREATE POLICY dietas_insert ON public.dietas
  FOR INSERT WITH CHECK (private.es_miembro(finca_id, auth.uid()));

CREATE POLICY dietas_update ON public.dietas
  FOR UPDATE USING (private.es_miembro(finca_id, auth.uid()))
  WITH CHECK (private.es_miembro(finca_id, auth.uid()));

-- ---------------------------------------------------------------- lote_dietas
CREATE TABLE IF NOT EXISTS public.lote_dietas (
  id uuid PRIMARY KEY,
  lote_id uuid NOT NULL REFERENCES public.lotes (id),
  dieta_id uuid NOT NULL REFERENCES public.dietas (id),
  desde timestamptz NOT NULL,
  hasta timestamptz,
  costo_animal_dia_snapshot numeric NOT NULL CHECK (costo_animal_dia_snapshot >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_lote_dietas_lote ON public.lote_dietas (lote_id)
  WHERE deleted_at IS NULL;

ALTER TABLE public.lote_dietas ENABLE ROW LEVEL SECURITY;

CREATE POLICY lote_dietas_select ON public.lote_dietas
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.lotes l
      WHERE l.id = lote_dietas.lote_id
        AND private.es_miembro(l.finca_id, auth.uid())
    )
  );

CREATE POLICY lote_dietas_insert ON public.lote_dietas
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.lotes l
      WHERE l.id = lote_dietas.lote_id
        AND private.es_miembro(l.finca_id, auth.uid())
    )
  );

CREATE POLICY lote_dietas_update ON public.lote_dietas
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.lotes l
      WHERE l.id = lote_dietas.lote_id
        AND private.es_miembro(l.finca_id, auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.lotes l
      WHERE l.id = lote_dietas.lote_id
        AND private.es_miembro(l.finca_id, auth.uid())
    )
  );

-- ---------------------------------------------------------------- movimientos_lote
CREATE TABLE IF NOT EXISTS public.movimientos_lote (
  id uuid PRIMARY KEY,
  animal_id uuid NOT NULL REFERENCES public.animales (id),
  lote_origen uuid REFERENCES public.lotes (id),
  lote_destino uuid NOT NULL REFERENCES public.lotes (id),
  fecha timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_movimientos_animal ON public.movimientos_lote (animal_id)
  WHERE deleted_at IS NULL;

ALTER TABLE public.movimientos_lote ENABLE ROW LEVEL SECURITY;

CREATE POLICY movimientos_lote_select ON public.movimientos_lote
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = movimientos_lote.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

CREATE POLICY movimientos_lote_insert ON public.movimientos_lote
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = movimientos_lote.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

CREATE POLICY movimientos_lote_update ON public.movimientos_lote
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = movimientos_lote.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = movimientos_lote.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

-- ---------------------------------------------------------------- updated_at triggers
-- Reuse your existing set_updated_at() if present; otherwise:
-- CREATE OR REPLACE FUNCTION public.set_updated_at() ...

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_dietas_updated_at'
  ) THEN
    CREATE TRIGGER trg_dietas_updated_at
      BEFORE UPDATE ON public.dietas
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_lote_dietas_updated_at'
  ) THEN
    CREATE TRIGGER trg_lote_dietas_updated_at
      BEFORE UPDATE ON public.lote_dietas
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_movimientos_lote_updated_at'
  ) THEN
    CREATE TRIGGER trg_movimientos_lote_updated_at
      BEFORE UPDATE ON public.movimientos_lote
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
