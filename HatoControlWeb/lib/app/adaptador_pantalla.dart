import 'package:flutter/material.dart';
import 'package:hato_control/auth/auth_gate.dart';

import '../escritorio/escritorio_gate.dart';

/// A partir de este ancho (en píxeles lógicos) se considera que el usuario
/// está en una computadora y se muestra la distribución de escritorio.
///
/// Por debajo se muestra, sin tocar ni un pixel, la misma interfaz de la app
/// nativa: un teléfono en el navegador ve exactamente lo mismo que en el APK.
const double kAnchoEscritorio = 1000;

/// Decide entre la interfaz móvil (idéntica a la app nativa) y la de
/// escritorio. Reacciona al tamaño de la ventana en vivo.
class AdaptadorPantalla extends StatelessWidget {
  const AdaptadorPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        if (restricciones.maxWidth >= kAnchoEscritorio) {
          return const EscritorioGate();
        }
        return const AuthGate();
      },
    );
  }
}
