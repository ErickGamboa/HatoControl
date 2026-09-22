-- HatoControl — terreno del lote + módulo Gastos · pestaña Deudas
--
-- 1) lotes.area_m2 / area_unidad: en cuánto terreno se maneja el lote. Se
--    guarda SIEMPRE en metros cuadrados y `area_unidad` recuerda en qué
--    unidad lo digitó el ganadero (ha | mz | m2), para poder sumar lotes
--    medidos en unidades distintas en el análisis de pesos.
--
-- 2) deudas / deuda_abonos: lista de a quién se le debe y cuánto, con sus
--    abonos. NO entra en la contabilidad del animal (ni utilidad, ni dietas,
--    ni sanidad): es solo control. Lo que sí pesa en la utilidad son los
--    gastos fijos, que van en su propia tabla.

-- ------------------------------------------------------------------- lotes
ALTER TABLE public.lotes
  ADD COLUMN IF NOT EXISTS area_m2 numeric,
  ADD COLUMN IF NOT EXISTS area_unidad text;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'lotes_area_m2_positiva'
  ) THEN
    ALTER TABLE public.lotes
      ADD CONSTRAINT lotes_area_m2_positiva
      CHECK (area_m2 IS NULL OR area_m2 > 0);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'lotes_area_unidad_valida'
  ) THEN
    ALTER TABLE public.lotes
      ADD CONSTRAINT lotes_area_unidad_valida
      CHECK (area_unidad IS NULL OR area_unidad IN ('ha', 'mz', 'm2'));
  END IF;
END $$;

-- ------------------------------------------------------------------ deudas
CREATE TABLE IF NOT EXISTS public.deudas (
  id uuid PRIMARY KEY,
  finca_id uuid NOT NULL REFERENCES public.fincas (id),
  acreedor text NOT NULL,
  monto numeric NOT NULL CHECK (monto >= 0),
  fecha timestamptz NOT NULL,
  vence timestamptz,
  estado text NOT NULL DEFAULT 'pendiente'
    CHECK (estado IN ('pendiente', 'pagada', 'anulada')),
  nota text,
  moneda text NOT NULL DEFAULT 'CRC',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_deudas_finca ON public.deudas (finca_id)
  WHERE deleted_at IS NULL;

ALTER TABLE public.deudas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS deudas_select ON public.deudas;
CREATE POLICY deudas_select ON public.deudas
  FOR SELECT USING (private.es_miembro(finca_id, auth.uid()));

DROP POLICY IF EXISTS deudas_insert ON public.deudas;
CREATE POLICY deudas_insert ON public.deudas
  FOR INSERT WITH CHECK (private.puede_escribir(finca_id, auth.uid()));

DROP POLICY IF EXISTS deudas_update ON public.deudas;
CREATE POLICY deudas_update ON public.deudas
  FOR UPDATE USING (private.puede_escribir(finca_id, auth.uid()))
  WITH CHECK (private.puede_escribir(finca_id, auth.uid()));

-- ------------------------------------------------------------ deuda_abonos
CREATE TABLE IF NOT EXISTS public.deuda_abonos (
  id uuid PRIMARY KEY,
  deuda_id uuid NOT NULL REFERENCES public.deudas (id),
  monto numeric NOT NULL CHECK (monto > 0),
  fecha timestamptz NOT NULL,
  nota text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE INDEX IF NOT EXISTS idx_deuda_abonos_deuda
  ON public.deuda_abonos (deuda_id)
  WHERE deleted_at IS NULL;

ALTER TABLE public.deuda_abonos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS deuda_abonos_select ON public.deuda_abonos;
CREATE POLICY deuda_abonos_select ON public.deuda_abonos
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.deudas d
      WHERE d.id = deuda_abonos.deuda_id
        AND private.es_miembro(d.finca_id, auth.uid())
    )
  );

DROP POLICY IF EXISTS deuda_abonos_insert ON public.deuda_abonos;
CREATE POLICY deuda_abonos_insert ON public.deuda_abonos
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.deudas d
      WHERE d.id = deuda_abonos.deuda_id
        AND private.puede_escribir(d.finca_id, auth.uid())
    )
  );

DROP POLICY IF EXISTS deuda_abonos_update ON public.deuda_abonos;
CREATE POLICY deuda_abonos_update ON public.deuda_abonos
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.deudas d
      WHERE d.id = deuda_abonos.deuda_id
        AND private.puede_escribir(d.finca_id, auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.deudas d
      WHERE d.id = deuda_abonos.deuda_id
        AND private.puede_escribir(d.finca_id, auth.uid())
    )
  );

-- ------------------------------------------------------ updated_at triggers
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_deudas_updated_at'
  ) THEN
    CREATE TRIGGER trg_deudas_updated_at
      BEFORE UPDATE ON public.deudas
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_deuda_abonos_updated_at'
  ) THEN
    CREATE TRIGGER trg_deuda_abonos_updated_at
      BEFORE UPDATE ON public.deuda_abonos
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;
