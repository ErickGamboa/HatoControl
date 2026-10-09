-- Muerte del animal con su fecha: corta dieta y gastos fijos ese día aunque
-- se registre después. La app solo manda la columna cuando el animal murió.

ALTER TABLE public.animales
  ADD COLUMN IF NOT EXISTS fecha_muerte timestamptz;
