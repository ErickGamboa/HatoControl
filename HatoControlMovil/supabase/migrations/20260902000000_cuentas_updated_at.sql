-- ---------------------------------------------------------------------------
-- updated_at automático en cuentas (y usuarios / planes)
--
-- Por qué: la bajada del sync pide filas con `(updated_at, id) > cursor`. Si
-- el admin edita una cuenta a mano (asignar plan pagado, suspender, reactivar)
-- y `updated_at` no se mueve, esa fila queda por detrás del cursor de cada
-- dispositivo y NO baja nunca — el cliente sigue viendo su estado viejo por
-- más que apriete "Ya pagué, actualizar".
--
-- Estas tres tablas se administran a mano desde el dashboard y no tenían el
-- trigger que sí traen las tablas de los módulos 2-4.
--
-- Idempotente: se puede correr varias veces sin romper nada. No modifica ni
-- una fila de datos, solo agrega los triggers.
-- ---------------------------------------------------------------------------

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_cuentas_updated_at'
  ) THEN
    CREATE TRIGGER trg_cuentas_updated_at
      BEFORE UPDATE ON public.cuentas
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_usuarios_updated_at'
  ) THEN
    CREATE TRIGGER trg_usuarios_updated_at
      BEFORE UPDATE ON public.usuarios
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_planes_updated_at'
  ) THEN
    CREATE TRIGGER trg_planes_updated_at
      BEFORE UPDATE ON public.planes
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END $$;

-- Verificación (correr aparte, después):
--   SELECT tgname, relname FROM pg_trigger t
--   JOIN pg_class c ON c.oid = t.tgrelid
--   WHERE tgname IN ('trg_cuentas_updated_at','trg_usuarios_updated_at','trg_planes_updated_at');
