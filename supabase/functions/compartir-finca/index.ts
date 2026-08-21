import { createClient } from "jsr:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(obj: unknown, status: number) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { "Content-Type": "application/json", ...cors },
  });
}

// Comparte una finca con otra persona (por correo), agregandola como miembro.
// El rol por defecto es 'lector' (solo lectura); la app siempre manda ese.
// Valida que quien llama sea admin de la finca.
//  - Si el correo ya tiene cuenta -> lo agrega como miembro (o lo reactiva).
//  - Si NO tiene cuenta -> le crea una cuenta de invitado (plan 'invitado' via
//    el trigger, por la metadata es_invitado) y la agrega a la finca. La
//    persona pone su contrasena despues con un codigo (OTP) desde la app.
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const jwt = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
    const admin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: u, error: uErr } = await admin.auth.getUser(jwt);
    if (uErr || !u?.user) return json({ error: "no_autenticado" }, 401);
    const callerId = u.user.id;

    const body = await req.json();
    const fincaId = body?.finca_id as string | undefined;
    // Compartir da SOLO LECTURA por defecto: el invitado ve la finca pero no
    // la puede cambiar (la RLS lo impone con private.puede_escribir).
    const rol = (body?.rol as string | undefined) ?? "lector";
    const email = ((body?.email as string | undefined) ?? "").trim()
      .toLowerCase();
    if (!fincaId || !email) return json({ error: "datos_incompletos" }, 400);
    if (rol !== "admin" && rol !== "operario" && rol !== "lector") {
      return json({ error: "rol_invalido" }, 400);
    }

    // Quien comparte debe ser admin de la finca.
    const { data: adminMiembro } = await admin
      .from("finca_miembros").select("id")
      .eq("finca_id", fincaId).eq("usuario_id", callerId).eq("rol", "admin")
      .is("deleted_at", null).maybeSingle();
    if (!adminMiembro) return json({ error: "sin_permiso" }, 403);

    // Buscar al invitado por correo (case-insensitive).
    const { data: invitado } = await admin
      .from("usuarios").select("id, nombre")
      .ilike("email", email).maybeSingle();

    const ahora = new Date().toISOString();

    // CASO 1: el correo no tiene cuenta -> crear invitado + agregar a la finca.
    if (!invitado) {
      const { data: created, error: cErr } = await admin.auth.admin.createUser({
        email,
        email_confirm: true,
        user_metadata: { es_invitado: true },
      });
      if (cErr || !created?.user) {
        return json({ error: "fallo_crear", detalle: cErr?.message }, 500);
      }
      const { error: insErr } = await admin.from("finca_miembros")
        .insert({ finca_id: fincaId, usuario_id: created.user.id, rol,
          created_at: ahora, updated_at: ahora });
      if (insErr) return json({ error: "fallo", detalle: insErr.message }, 500);
      return json({ status: "invitado_nuevo", email }, 200);
    }

    if (invitado.id === callerId) {
      return json({ status: "ya_es_miembro", email }, 200);
    }

    // CASO 2: ya tiene cuenta. Existe la membresia (activa o quitada)?
    const { data: existente } = await admin
      .from("finca_miembros").select("id, deleted_at")
      .eq("finca_id", fincaId).eq("usuario_id", invitado.id).maybeSingle();

    if (existente && existente.deleted_at === null) {
      return json({ status: "ya_es_miembro", email, nombre: invitado.nombre }, 200);
    }

    if (existente) {
      const { error: upErr } = await admin.from("finca_miembros")
        .update({ rol, deleted_at: null, updated_at: ahora })
        .eq("id", existente.id);
      if (upErr) return json({ error: "fallo", detalle: upErr.message }, 500);
    } else {
      const { error: insErr } = await admin.from("finca_miembros")
        .insert({ finca_id: fincaId, usuario_id: invitado.id, rol,
          created_at: ahora, updated_at: ahora });
      if (insErr) return json({ error: "fallo", detalle: insErr.message }, 500);
    }

    return json({ status: "agregado", email, nombre: invitado.nombre }, 200);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
