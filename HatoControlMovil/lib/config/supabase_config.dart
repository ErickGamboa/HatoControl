/// Configuración de conexión a Supabase.
///
/// La clave `anon` es PÚBLICA por diseño: está pensada para ir embebida en
/// apps cliente. La seguridad real la dan las políticas RLS de la base de
/// datos, no esta clave. (Nunca pongas aquí la "service_role key".)
///
/// Usamos la clave `anon` (formato JWT) en lugar de la "publishable" nueva
/// porque es la que adjunta correctamente el token del usuario en las
/// escrituras y hace que `auth.uid()` funcione en las políticas RLS.
class SupabaseConfig {
  static const String url = 'https://geocoundyilwxrnbhcqu.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdlb2NvdW5keWlsd3hybmJoY3F1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2MzAyMTgsImV4cCI6MjA5NjIwNjIxOH0.JZAL5N3Px0EQloqkq-pTh-EJkO7Lgvr49VupWiXnlK0';
  // Llave "publishable" moderna (no-JWT). El servicio de Storage la usa para
  // resolver el rol correctamente junto con el token del usuario.
  static const String publishableKey =
      'sb_publishable_rEfan_ESEHvHsu7xy7rh7g_AQkaP_A4';
}
