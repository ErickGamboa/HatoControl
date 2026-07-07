import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth/auth_gate.dart';
import 'config/supabase_config.dart';
import 'demo/demo_env.dart';
import 'demo/demo_seed.dart';
import 'services.dart';

/// Colores de marca de HatoControl, tomados del logo.
const Color kAzulHato = Color(0xFF1B3A5B);
const Color kVerdeHato = Color(0xFF3C8C56);

/// Initializes Supabase, local session, connectivity, and optional demo seed.
Future<void> bootstrapHatoControl() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    // ignore: deprecated_member_use
    anonKey: SupabaseConfig.anonKey,
  );

  await sesionLocalRepo.cargar();
  await maybeSeedDemoOnStartup();
  await estadoConexion.iniciar(alRecuperarConexion: syncService.sincronizar);

  if (!kSeedDemoEnabled) {
    final usuarioInicial = supabase.auth.currentUser;
    if (usuarioInicial != null) {
      await sesionLocalRepo.guardarUsuarioVerificado(
        usuarioId: usuarioInicial.id,
        email: usuarioInicial.email,
        nombre: usuarioInicial.userMetadata?['nombre'] as String?,
      );
    }
  }

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
}

class HatoControlApp extends StatelessWidget {
  const HatoControlApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kAzulHato,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

void runHatoControlApp() {
  runApp(const HatoControlApp());
}
