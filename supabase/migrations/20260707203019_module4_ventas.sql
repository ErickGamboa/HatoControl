-- HatoControl — Module 4: ventas, costos, animal economics
-- Run in Supabase SQL Editor after Module 3 script.

ALTER TABLE public.animales
  ADD COLUMN IF NOT EXISTS estado text NOT NULL DEFAULT 'activo'
    CHECK (estado IN ('activo', 'vendido', 'muerto')),
  ADD COLUMN IF NOT EXISTS precio_compra numeric CHECK (
    precio_compra IS NULL OR precio_compra >= 0
  ),
  ADD COLUMN IF NOT EXISTS fecha_compra timestamptz;

CREATE TABLE IF NOT EXISTS public.ventas (
  id uuid PRIMARY KEY,
  animal_id uuid NOT NULL REFERENCES public.animales (id),
  fecha timestamptz NOT NULL,
  precio numeric NOT NULL CHECK (precio >= 0),
  comprador text,
  observaciones text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.costos_otros (
  id uuid PRIMARY KEY,
  animal_id uuid NOT NULL REFERENCES public.animales (id),
  concepto text NOT NULL,
  monto numeric NOT NULL CHECK (monto >= 0),
  fecha timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_ventas_animal ON public.ventas (animal_id)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_costos_otros_animal ON public.costos_otros (animal_id)
  WHERE deleted_at IS NULL;

ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.costos_otros ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ventas_select ON public.ventas;
CREATE POLICY ventas_select ON public.ventas FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.animales a
    WHERE a.id = ventas.animal_id
      AND private.es_miembro(a.finca_id, auth.uid())
  )
);

DROP POLICY IF EXISTS ventas_insert ON public.ventas;
CREATE POLICY ventas_insert ON public.ventas FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.animales a
    WHERE a.id = ventas.animal_id
      AND private.es_miembro(a.finca_id, auth.uid())
  )
);

DROP POLICY IF EXISTS ventas_update ON public.ventas;
CREATE POLICY ventas_update ON public.ventas FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.animales a
    WHERE a.id = ventas.animal_id
      AND private.es_miembro(a.finca_id, auth.uid())
  )
);

DROP POLICY IF EXISTS costos_otros_select ON public.costos_otros;
CREATE POLICY costos_otros_select ON public.costos_otros FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.animales a
    WHERE a.id = costos_otros.animal_id
      AND private.es_miembro(a.finca_id, auth.uid())
  )
);

DROP POLICY IF EXISTS costos_otros_insert ON public.costos_otros;
CREATE POLICY costos_otros_insert ON public.costos_otros FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.animales a
    WHERE a.id = costos_otros.animal_id
      AND private.es_miembro(a.finca_id, auth.uid())
  )
);

DROP POLICY IF EXISTS costos_otros_update ON public.costos_otros;
CREATE POLICY costos_otros_update ON public.costos_otros FOR UPDATE USING (
  EXISTS (
    SELECT 1 FROM public.animales a
    WHERE a.id = costos_otros.animal_id
      AND private.es_miembro(a.finca_id, auth.uid())
  )
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_ventas_updated_at'
  ) THEN
    CREATE TRIGGER trg_ventas_updated_at
      BEFORE UPDATE ON public.ventas
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_costos_otros_updated_at'
  ) THEN
    CREATE TRIGGER trg_costos_otros_updated_at
      BEFORE UPDATE ON public.costos_otros
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
