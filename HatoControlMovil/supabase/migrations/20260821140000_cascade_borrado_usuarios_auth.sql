-- HatoControl — Permitir borrar usuarios desde el dashboard de Auth
-- Project: geocoundyilwxrnbhcqu
--
-- Síntoma: en Authentication → Users, borrar un usuario falla con
-- "Failed to delete user: Database error deleting user".
--
-- Causa: tablas de `public` referencian `auth.users` con llaves foráneas SIN
-- `ON DELETE CASCADE` (típicamente `usuarios.id` y `cuentas.dueno_id`). Al
-- borrar el usuario quedarían filas huérfanas, así que Postgres rechaza el
-- DELETE y GoTrue devuelve ese error genérico.
--
-- Esto reconstruye cada una de esas FK con `ON DELETE CASCADE`. Recorre
-- `pg_constraint` en vez de nombrarlas a mano porque las tablas del núcleo se
-- crearon fuera de `supabase/migrations/`. Reusa `pg_get_constraintdef` para no
-- rearmar la lista de columnas: le quita la cláusula ON DELETE que tuviera y le
-- pone CASCADE.
--
-- OJO: después de esto, borrar un usuario desde el dashboard borra SUS DATOS en
-- cascada. Es lo que se quiere para limpiar pruebas; tenelo presente cuando
-- haya clientes de verdad.

DO $$
DECLARE
  r record;
  v_def text;
  v_arregladas int := 0;
BEGIN
  FOR r IN
    SELECT con.oid,
           con.conname,
           nsp.nspname AS esquema,
           rel.relname AS tabla
    FROM pg_constraint con
    JOIN pg_class rel      ON rel.oid  = con.conrelid
    JOIN pg_namespace nsp  ON nsp.oid  = rel.relnamespace
    JOIN pg_class frel     ON frel.oid = con.confrelid
    JOIN pg_namespace fnsp ON fnsp.oid = frel.relnamespace
    WHERE con.contype = 'f'
      AND fnsp.nspname = 'auth'
      AND frel.relname = 'users'
      AND nsp.nspname = 'public'
      AND con.confdeltype <> 'c'   -- 'c' = ya tiene CASCADE
  LOOP
    -- Ej.: 'FOREIGN KEY (id) REFERENCES auth.users(id)'
    v_def := pg_get_constraintdef(r.oid);
    v_def := regexp_replace(
      v_def,
      '\s+ON DELETE\s+(NO ACTION|RESTRICT|CASCADE|SET NULL|SET DEFAULT)',
      '',
      'gi'
    );

    EXECUTE format(
      'ALTER TABLE %I.%I DROP CONSTRAINT %I',
      r.esquema, r.tabla, r.conname
    );
    EXECUTE format(
      'ALTER TABLE %I.%I ADD CONSTRAINT %I %s ON DELETE CASCADE',
      r.esquema, r.tabla, r.conname, v_def
    );

    RAISE NOTICE 'FK con CASCADE: %.% (%)', r.esquema, r.tabla, r.conname;
    v_arregladas := v_arregladas + 1;
  END LOOP;

  RAISE NOTICE 'FK hacia auth.users arregladas: %', v_arregladas;
END $$;

-- ------------------------------------------------------------------ verificar
-- Todas deberían salir con al_borrar = 'c':
--   SELECT rel.relname AS tabla, con.conname, con.confdeltype AS al_borrar
--   FROM pg_constraint con
--   JOIN pg_class rel      ON rel.oid  = con.conrelid
--   JOIN pg_namespace nsp  ON nsp.oid  = rel.relnamespace
--   JOIN pg_class frel     ON frel.oid = con.confrelid
--   JOIN pg_namespace fnsp ON fnsp.oid = frel.relnamespace
--   WHERE con.contype='f' AND fnsp.nspname='auth' AND frel.relname='users'
--     AND nsp.nspname='public';
