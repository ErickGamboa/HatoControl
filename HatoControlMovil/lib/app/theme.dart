import 'package:flutter/material.dart';

/// Colores de marca de HatoControl, tomados del logo.
const Color kAzulHato = Color(0xFF1B3A5B);
const Color kVerdeHato = Color(0xFF3C8C56);

/// Espaciados estándar de la app (múltiplos de 4).
abstract final class HatoSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Tema visual de HatoControl, generado a partir de los colores de marca.
///
/// Hay **un solo tema y es claro**, aunque el telefono este en modo oscuro: se
/// trabaja al sol, en la manga, y las pantallas estan pensadas para eso. No
/// agregues un tema oscuro sin revisar antes las pantallas que pintan su fondo
/// a mano (el login pinta blanco): con el esquema oscuro les tocaban letras
/// claras sobre fondo claro y no se leia lo que se escribia.
abstract final class HatoTheme {
  static ThemeData get light => _build();

  static ThemeData _build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: kVerdeHato,
      primary: kVerdeHato,
      secondary: kAzulHato,
      tertiary: kAzulHato,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kAzulHato,
        foregroundColor: Colors.white,
      ),
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(HatoSpacing.xs),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
