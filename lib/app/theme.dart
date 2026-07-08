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

/// Tema visual de HatoControl: mismo esquema de color en claro y oscuro,
/// generado a partir de los colores de marca.
abstract final class HatoTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: kVerdeHato,
      primary: kVerdeHato,
      secondary: kAzulHato,
      tertiary: kAzulHato,
      brightness: brightness,
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
