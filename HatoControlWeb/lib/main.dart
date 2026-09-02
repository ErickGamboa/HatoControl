import 'package:flutter/material.dart';
import 'package:hato_control/app_bootstrap.dart' as movil;

import 'app/adaptador_pantalla.dart';

/// Punto de entrada de HatoControl Web.
///
/// El arranque y el marco de la app son los mismos de la versión nativa
/// (Supabase, sesión local, conectividad, sincronización, tema y título): así
/// la web y el teléfono se comportan igual y comparten la misma base de
/// datos. Lo único propio de la web es qué se pinta adentro, que lo decide
/// [AdaptadorPantalla] según el tamaño de la pantalla.
Future<void> main() async {
  await movil.bootstrapHatoControl();
  runApp(const movil.HatoControlApp(home: AdaptadorPantalla()));
}
