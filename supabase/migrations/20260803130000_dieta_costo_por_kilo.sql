-- Dieta digitada como ₡ por kilo × kilos por animal al día.
-- costo_animal_dia y costo_animal_semana quedan como derivados:
--   costo_animal_dia   = costo_kg * kg_animal_dia
--   costo_animal_semana = costo_animal_dia * 7

ALTER TABLE public.dietas
  ADD COLUMN IF NOT EXISTS costo_kg numeric NOT NULL DEFAULT 0
    CHECK (costo_kg >= 0),
  ADD COLUMN IF NOT EXISTS kg_animal_dia numeric NOT NULL DEFAULT 0
    CHECK (kg_animal_dia >= 0);

-- Dietas viejas se digitaron por animal (semanal ÷ 7). Tomarlas como 1 kg al
-- precio del día deja costo_animal_dia idéntico, así el historial de utilidad
-- y los snapshots en lote_dietas no cambian.
UPDATE public.dietas
SET costo_kg = costo_animal_dia,
    kg_animal_dia = 1
WHERE costo_kg = 0 AND costo_animal_dia > 0;
