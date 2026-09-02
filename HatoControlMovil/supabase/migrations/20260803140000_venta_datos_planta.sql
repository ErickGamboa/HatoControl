-- Datos de planta por animal vendido (D-19).
-- El grupo de venta se crea solo con identificador + kilos de salida de finca
-- (ventas.peso). Después, por animal, se registran los datos de la planta:
--   peso_pie, peso_canal, dinero_recibido
-- y el rendimiento queda derivado: peso_canal / peso_pie * 100.
-- `dinero_recibido` es la fuente de la utilidad; mientras sea NULL la utilidad
-- se muestra como “—”, nunca ₡0.

ALTER TABLE public.ventas
  ADD COLUMN IF NOT EXISTS peso_pie numeric
    CHECK (peso_pie IS NULL OR peso_pie > 0),
  ADD COLUMN IF NOT EXISTS peso_canal numeric
    CHECK (peso_canal IS NULL OR peso_canal > 0),
  ADD COLUMN IF NOT EXISTS rendimiento numeric
    CHECK (rendimiento IS NULL OR (rendimiento > 0 AND rendimiento <= 100)),
  ADD COLUMN IF NOT EXISTS dinero_recibido numeric
    CHECK (dinero_recibido IS NULL OR dinero_recibido >= 0);

-- Ventas ya registradas: el total cobrado pasa a ser el dinero recibido, así
-- su utilidad no se vuelve “—” de un día para otro.
UPDATE public.ventas
SET dinero_recibido = precio
WHERE dinero_recibido IS NULL AND precio > 0;
