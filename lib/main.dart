import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'auth/auth_gate.dart';
import 'services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    // ignore: deprecated_member_use
    anonKey: SupabaseConfig.anonKey,
  );

  await sesionLocalRepo.cargar();
  await estadoConexion.iniciar(alRecuperarConexion: syncService.sincronizar);

  final usuarioInicial = supabase.auth.currentUser;
  if (usuarioInicial != null) {
    await sesionLocalRepo.guardarUsuarioVerificado(
      usuarioId: usuarioInicial.id,
      email: usuarioInicial.email,
      nombre: usuarioInicial.userMetadata?['nombre'] as String?,
    );
  }

  // Sincronizar: al arrancar, cuando VUELVA la conexión y al iniciar sesión.
  sincronizarSiSePuede();
  supabase.auth.onAuthStateChange.listen((estado) async {
    if (estado.event == AuthChangeEvent.signedIn) {
      final usuario = estado.session?.user ?? supabase.auth.currentUser;
      if (usuario != null) {
        await sesionLocalRepo.guardarUsuarioVerificado(
          usuarioId: usuario.id,
          email: usuario.email,
          nombre: usuario.userMetadata?['nombre'] as String?,
        );
      }
      sincronizarSiSePuede();
    }
  });

  runApp(const HatoControlApp());
}

/// Colores de marca de HatoControl, tomados del logo.
const Color kAzulHato = Color(0xFF1B3A5B); // azul marino (la "H", los textos)
const Color kVerdeHato = Color(0xFF3C8C56); // verde (la "C", el arete, el arco)

class HatoControlApp extends StatelessWidget {
  const HatoControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Combinación de los dos colores del logo repartida entre los componentes:
    // verde como color principal (botones de acción, íconos) y azul marino como
    // secundario, usado en botones flotantes, chips y acentos. El encabezado
    // queda con el estilo por defecto (no se pinta de azul).
    final scheme = ColorScheme.fromSeed(
      seedColor: kVerdeHato,
      primary: kVerdeHato,
      secondary: kAzulHato,
      tertiary: kAzulHato,
    );
    return MaterialApp(
      title: 'HatoControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        // Botones flotantes ("+") en azul marino: combina con el verde de los
        // botones principales.
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kAzulHato,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
