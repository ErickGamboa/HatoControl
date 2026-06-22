import 'package:connectivity_plus/connectivity_plus.dart';
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

  // Sincronizar: al arrancar, cuando VUELVA la conexión y al iniciar sesión.
  syncService.sincronizar();
  Connectivity().onConnectivityChanged.listen((resultados) {
    final hayConexion =
        resultados.any((r) => r != ConnectivityResult.none);
    if (hayConexion) syncService.sincronizar();
  });
  supabase.auth.onAuthStateChange.listen((estado) {
    if (estado.event == AuthChangeEvent.signedIn) {
      syncService.sincronizar();
    }
  });

  runApp(const HatoControlApp());
}

class HatoControlApp extends StatelessWidget {
  const HatoControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HatoControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
