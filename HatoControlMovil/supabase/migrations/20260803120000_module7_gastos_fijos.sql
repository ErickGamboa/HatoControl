-- HatoControl — Module 7: gastos fijos de la finca y sus cargos congelados (D-17)
-- Run in Supabase SQL Editor (project geocoundyilwxrnbhcqu).
--
-- PREREQUISITE (run first if you get "private.es_miembro does not exist"):
--   docs/supabase_bootstrap_rls_helpers.sql
-- See docs/SUPABASE_SQL_ORDER.md for full order and diagnostics.
--
-- gastos_fijos: gasto indirecto de la finca (peón, luz, agua). `monto` es
--   mensual cuando periodicidad = 'mensual'. `hasta` null = vigente.
-- gasto_fijo_cargos: la parte que absorbió un animal en un mes, congelada al
--   vender para que su utilidad no cambie si después se digita un gasto viejo.

-- ---------------------------------------------------------------- gastos_fijos
CREATE TABLE IF NOT EXISTS public.gastos_fijos (
  id uuid PRIMARY KEY,
  finca_id uuid NOT NULL REFERENCES public.fincas (id),
  concepto text NOT NULL,
  monto numeric NOT NULL CHECK (monto >= 0),
  periodicidad text NOT NULL CHECK (periodicidad IN ('mensual', 'unico')),
  desde timestamptz NOT NULL,
  hasta timestamptz,
  moneda text NOT NULL DEFAULT 'CRC',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_gastos_fijos_finca ON public.gastos_fijos (finca_id)
  WHERE deleted_at IS NULL;

ALTER TABLE public.gastos_fijos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS gastos_fijos_select ON public.gastos_fijos;
CREATE POLICY gastos_fijos_select ON public.gastos_fijos
  FOR SELECT USING (private.es_miembro(finca_id, auth.uid()));

DROP POLICY IF EXISTS gastos_fijos_insert ON public.gastos_fijos;
CREATE POLICY gastos_fijos_insert ON public.gastos_fijos
  FOR INSERT WITH CHECK (private.es_miembro(finca_id, auth.uid()));

DROP POLICY IF EXISTS gastos_fijos_update ON public.gastos_fijos;
CREATE POLICY gastos_fijos_update ON public.gastos_fijos
  FOR UPDATE USING (private.es_miembro(finca_id, auth.uid()))
  WITH CHECK (private.es_miembro(finca_id, auth.uid()));

-- ------------------------------------------------------------ gasto_fijo_cargos
CREATE TABLE IF NOT EXISTS public.gasto_fijo_cargos (
  id uuid PRIMARY KEY,
  gasto_fijo_id uuid NOT NULL REFERENCES public.gastos_fijos (id),
  animal_id uuid NOT NULL REFERENCES public.animales (id),
  mes timestamptz NOT NULL,
  dias integer NOT NULL CHECK (dias >= 0),
  monto numeric NOT NULL CHECK (monto >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_gasto_fijo_cargos_animal
  ON public.gasto_fijo_cargos (animal_id)
  WHERE deleted_at IS NULL;

-- Un solo cargo por gasto × animal × mes (espejo del índice local).
CREATE UNIQUE INDEX IF NOT EXISTS idx_gasto_fijo_cargos_gasto_animal_mes_activos
  ON public.gasto_fijo_cargos (gasto_fijo_id, animal_id, mes)
  WHERE deleted_at IS NULL;

ALTER TABLE public.gasto_fijo_cargos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS gasto_fijo_cargos_select ON public.gasto_fijo_cargos;
CREATE POLICY gasto_fijo_cargos_select ON public.gasto_fijo_cargos
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = gasto_fijo_cargos.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

DROP POLICY IF EXISTS gasto_fijo_cargos_insert ON public.gasto_fijo_cargos;
CREATE POLICY gasto_fijo_cargos_insert ON public.gasto_fijo_cargos
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = gasto_fijo_cargos.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

DROP POLICY IF EXISTS gasto_fijo_cargos_update ON public.gasto_fijo_cargos;
CREATE POLICY gasto_fijo_cargos_update ON public.gasto_fijo_cargos
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = gasto_fijo_cargos.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.animales a
      WHERE a.id = gasto_fijo_cargos.animal_id
        AND private.es_miembro(a.finca_id, auth.uid())
    )
  );

-- ---------------------------------------------------------------- updated_at triggers
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_gastos_fijos_updated_at'
  ) THEN
    CREATE TRIGGER trg_gastos_fijos_updated_at
      BEFORE UPDATE ON public.gastos_fijos
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_gasto_fijo_cargos_updated_at'
  ) THEN
    CREATE TRIGGER trg_gasto_fijo_cargos_updated_at
      BEFORE UPDATE ON public.gasto_fijo_cargos
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
