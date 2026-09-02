import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/theme.dart';
import 'auth/auth_gate.dart';
import 'config/supabase_config.dart';
import 'demo/demo_env.dart';
import 'demo/demo_seed.dart';
import 'demo/seed_prueba.dart';
import 'services.dart';

export 'app/theme.dart' show kAzulHato, kVerdeHato;

/// Cada cuánto se reintenta solo la sincronización si quedó algo pendiente.
const kReintentoSyncCada = Duration(minutes: 2);

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
  // Datos de prueba con números redondos, sobre la sesión real del usuario.
  await maybeSeedPruebaOnStartup();
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

  // Red de seguridad: si algo quedó sin subir (la red se cayó a mitad, el
  // servidor no respondió), se reintenta solo cada dos minutos. El usuario no
  // tiene que acordarse de apretar el botón de sincronizar.
  Timer.periodic(kReintentoSyncCada, (_) async {
    if (await syncService.hayPendientes()) await sincronizarSiSePuede();
  });

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

/// El [home] existe para que la versión web pueda meter su adaptador de
/// pantalla sin duplicar el tema, el título ni el comportamiento del teclado:
/// el marco de la app es uno solo para las tres versiones.
class HatoControlApp extends StatelessWidget {
  const HatoControlApp({super.key, this.home = const AuthGate()});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HatoControl',
      debugShowCheckedModeBanner: false,
      theme: HatoTheme.light,
      darkTheme: HatoTheme.dark,
      themeMode: ThemeMode.system,
      // Flutter no cierra el teclado al tocar fuera del campo. Los
      // formularios se llenan a una mano en la manga, asi que tocar
      // cualquier espacio vacio debe ocultarlo, en toda la app.
      builder: (context, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
      home: home,
    );
  }
}

void runHatoControlApp() {
  runApp(const HatoControlApp());
}
