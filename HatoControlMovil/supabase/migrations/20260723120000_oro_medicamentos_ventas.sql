-- Documento oro: medicamentos, dieta_ingredientes, lotes_venta, columnas de retiro/dosis.
-- Idempotent-ish: CREATE IF NOT EXISTS + ADD COLUMN IF NOT EXISTS.

CREATE TABLE IF NOT EXISTS public.medicamentos (
  id uuid PRIMARY KEY,
  finca_id uuid NOT NULL REFERENCES public.fincas(id),
  nombre text NOT NULL,
  costo_envase numeric NOT NULL CHECK (costo_envase >= 0),
  tipo_aplicacion text NOT NULL CHECK (tipo_aplicacion IN ('por_peso','dosis_fija','por_aplicacion')),
  ml_envase numeric,
  aplicaciones_por_envase numeric,
  dosis_cantidad numeric,
  dosis_por_cada_kg numeric,
  dias_retiro integer NOT NULL DEFAULT 0 CHECK (dias_retiro >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.dieta_ingredientes (
  id uuid PRIMARY KEY,
  dieta_id uuid NOT NULL REFERENCES public.dietas(id),
  nombre text NOT NULL,
  costo_animal_dia numeric NOT NULL CHECK (costo_animal_dia >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE TABLE IF NOT EXISTS public.lotes_venta (
  id uuid PRIMARY KEY,
  finca_id uuid NOT NULL REFERENCES public.fincas(id),
  fecha timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

ALTER TABLE public.eventos_sanitarios
  ADD COLUMN IF NOT EXISTS medicamento_id uuid REFERENCES public.medicamentos(id),
  ADD COLUMN IF NOT EXISTS ml_aplicados numeric,
  ADD COLUMN IF NOT EXISTS aplicaciones integer,
  ADD COLUMN IF NOT EXISTS dias_retiro integer,
  ADD COLUMN IF NOT EXISTS retiro_hasta timestamptz;

ALTER TABLE public.ventas
  ADD COLUMN IF NOT EXISTS lote_venta_id uuid REFERENCES public.lotes_venta(id),
  ADD COLUMN IF NOT EXISTS peso numeric CHECK (peso IS NULL OR peso > 0);

-- RLS: mismos patrones de membresía de finca.
ALTER TABLE public.medicamentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dieta_ingredientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lotes_venta ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS medicamentos_select ON public.medicamentos;
CREATE POLICY medicamentos_select ON public.medicamentos
  FOR SELECT TO authenticated
  USING (private.es_miembro(finca_id) AND deleted_at IS NULL);

DROP POLICY IF EXISTS medicamentos_write ON public.medicamentos;
CREATE POLICY medicamentos_write ON public.medicamentos
  FOR ALL TO authenticated
  USING (private.es_miembro(finca_id))
  WITH CHECK (private.es_miembro(finca_id));

DROP POLICY IF EXISTS dieta_ingredientes_select ON public.dieta_ingredientes;
CREATE POLICY dieta_ingredientes_select ON public.dieta_ingredientes
  FOR SELECT TO authenticated
  USING (
    deleted_at IS NULL AND EXISTS (
      SELECT 1 FROM public.dietas d
      WHERE d.id = dieta_id AND private.es_miembro(d.finca_id) AND d.deleted_at IS NULL
    )
  );

DROP POLICY IF EXISTS dieta_ingredientes_write ON public.dieta_ingredientes;
CREATE POLICY dieta_ingredientes_write ON public.dieta_ingredientes
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.dietas d
      WHERE d.id = dieta_id AND private.es_miembro(d.finca_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.dietas d
      WHERE d.id = dieta_id AND private.es_miembro(d.finca_id)
    )
  );

DROP POLICY IF EXISTS lotes_venta_select ON public.lotes_venta;
CREATE POLICY lotes_venta_select ON public.lotes_venta
  FOR SELECT TO authenticated
  USING (private.es_miembro(finca_id) AND deleted_at IS NULL);

DROP POLICY IF EXISTS lotes_venta_write ON public.lotes_venta;
CREATE POLICY lotes_venta_write ON public.lotes_venta
  FOR ALL TO authenticated
  USING (private.es_miembro(finca_id))
  WITH CHECK (private.es_miembro(finca_id));
