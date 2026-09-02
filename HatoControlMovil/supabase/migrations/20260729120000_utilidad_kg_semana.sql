-- Utilidad por kilo / dieta semanal (correcciones ronda 1, punto 14).
-- Columnas nuevas; las existentes quedan como totales derivados.

ALTER TABLE public.animales
  ADD COLUMN IF NOT EXISTS peso_compra numeric CHECK (peso_compra IS NULL OR peso_compra > 0),
  ADD COLUMN IF NOT EXISTS precio_kg_compra numeric CHECK (precio_kg_compra IS NULL OR precio_kg_compra >= 0);

ALTER TABLE public.ventas
  ADD COLUMN IF NOT EXISTS precio_kg numeric CHECK (precio_kg IS NULL OR precio_kg >= 0);

ALTER TABLE public.dietas
  ADD COLUMN IF NOT EXISTS costo_animal_semana numeric NOT NULL DEFAULT 0
    CHECK (costo_animal_semana >= 0);

-- Datos existentes se digitaron como costo/día → semanal = día × 7.
UPDATE public.dietas
SET costo_animal_semana = costo_animal_dia * 7
WHERE costo_animal_semana = 0 AND costo_animal_dia > 0;
