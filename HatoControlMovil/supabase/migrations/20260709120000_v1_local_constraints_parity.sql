-- HatoControl — CHECK constraints on the v1 base tables (Fase 3, ver
-- docs/ARCHITECTURE_REVIEW.md #3 y docs/DECISIONES.md).
--
-- cuentas, finca_miembros, animales y pesajes predate this repo (created
-- directly on the Supabase dashboard — see the "known gap" in
-- docs/SUPABASE_SQL_ORDER.md), so unlike modules 2-5 there is no earlier
-- migration file to edit. `animales` already got its `estado`/
-- `precio_compra` checks from module 4
-- (20260707203019_module4_ventas.sql); this migration adds the two that
-- were still missing: finca_miembros.rol and cuentas.plan/estado. It also
-- adds pesajes.peso > 0, matching the local Drift constraint added in the
-- same change.
--
-- ADD CONSTRAINT (not CREATE TABLE) so this is safe to push independently
-- of the base-schema-capture gap above.
--
-- NOT VALID + separate VALIDATE CONSTRAINT: this table already has live
-- rows (unlike modules 2-5, which are brand new). NOT VALID adds the
-- constraint for all future writes immediately without an error if some
-- existing row doesn't already conform; VALIDATE CONSTRAINT then checks
-- the backlog and reports exactly which constraint (if any) has
-- pre-existing violations, instead of the whole migration aborting
-- opaquely mid-push.

ALTER TABLE public.finca_miembros DROP CONSTRAINT IF EXISTS finca_miembros_rol_check;
ALTER TABLE public.finca_miembros
  ADD CONSTRAINT finca_miembros_rol_check
  CHECK (rol IN ('admin', 'operario')) NOT VALID;

ALTER TABLE public.cuentas DROP CONSTRAINT IF EXISTS cuentas_plan_check;
ALTER TABLE public.cuentas DROP CONSTRAINT IF EXISTS cuentas_estado_check;
ALTER TABLE public.cuentas
  ADD CONSTRAINT cuentas_plan_check
  CHECK (plan IN ('invitado', 'light', 'medium', 'pro')) NOT VALID,
  ADD CONSTRAINT cuentas_estado_check
  CHECK (estado IN ('activa', 'suspendida')) NOT VALID;

ALTER TABLE public.pesajes DROP CONSTRAINT IF EXISTS pesajes_peso_check;
ALTER TABLE public.pesajes
  ADD CONSTRAINT pesajes_peso_check
  CHECK (peso > 0) NOT VALID;

ALTER TABLE public.finca_miembros VALIDATE CONSTRAINT finca_miembros_rol_check;
ALTER TABLE public.cuentas VALIDATE CONSTRAINT cuentas_plan_check;
ALTER TABLE public.cuentas VALIDATE CONSTRAINT cuentas_estado_check;
ALTER TABLE public.pesajes VALIDATE CONSTRAINT pesajes_peso_check;
