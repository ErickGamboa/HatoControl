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

ALTER TABLE public.finca_miembros
  ADD CONSTRAINT finca_miembros_rol_check
  CHECK (rol IN ('admin', 'operario'));

ALTER TABLE public.cuentas
  ADD CONSTRAINT cuentas_plan_check
  CHECK (plan IN ('invitado', 'light', 'medium', 'pro')),
  ADD CONSTRAINT cuentas_estado_check
  CHECK (estado IN ('activa', 'suspendida'));

ALTER TABLE public.pesajes
  ADD CONSTRAINT pesajes_peso_check
  CHECK (peso > 0);
