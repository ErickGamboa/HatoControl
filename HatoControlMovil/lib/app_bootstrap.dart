import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/teclado/teclado_del_app.dart';
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

/// Sincroniza cada vez que la app vuelve del segundo plano.
///
/// En el teléfono la app casi nunca arranca en frío: se retoma. El arranque y
/// el inicio de sesión sí sincronizaban, pero volver a abrirla desde el
/// multitarea no disparaba nada, así que el ganadero se encontraba el hato
/// como lo había dejado el día anterior y no tenía cómo saber que le faltaban
/// datos. Con esto, abrir la app ya trae lo nuevo.
class _SincronizarAlVolver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.resumed) sincronizarSiSePuede();
  }
}

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
  WidgetsBinding.instance.addObserver(_SincronizarAlVolver());

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
      // HatoControl es SIEMPRE clara, tenga el telefono el modo que tenga. Se
      // trabaja al sol y las pantallas y los fondos estan pensados para eso.
      // Antes decia ThemeMode.system: con el telefono en oscuro, el login
      // (que pinta su fondo blanco a mano) quedaba con letras claras sobre
      // blanco y no se leia nada de lo que se escribia.
      themeMode: ThemeMode.light,
      // Español de Costa Rica en todo lo que Flutter pone por su cuenta: el
      // calendario para elegir fechas, los menús de copiar/pegar, el
      // "cancelar"/"aceptar". Sin esto salían en inglés y en la finca nadie
      // tiene por qué entender "Select date".
      locale: const Locale('es'),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('es'), Locale('en')],
      // Flutter no cierra el teclado al tocar fuera del campo. Los
      // formularios se llenan a una mano en la manga, asi que tocar
      // cualquier espacio vacio debe ocultarlo, en toda la app.
      // El teclado propio va por fuera del GestureDetector: si quedara adentro,
      // tocar entre dos teclas apagaria el campo que se esta llenando.
      builder: (context, child) => TecladoDelApp(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: child,
        ),
      ),
      home: home,
    );
  }
}

void runHatoControlApp() {
  runApp(const HatoControlApp());
}
