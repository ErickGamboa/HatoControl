-- Alias del animal: un nombre corto ("Pinta", "23") para buscarlo sin digitar
-- el arete largo. Opcional; '' = se le quitó el alias.
ALTER TABLE public.animales ADD COLUMN IF NOT EXISTS alias text;
