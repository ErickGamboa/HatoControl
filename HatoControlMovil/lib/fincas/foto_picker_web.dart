import 'package:flutter/material.dart';

/// En web no hay sistema de archivos del dispositivo: la foto de la finca se
/// muestra desde `fincas.fotoUrl` y la captura queda deshabilitada (D-09).
const bool soportaFotoLocal = false;

Future<String?> elegirFotoFinca(BuildContext context) async => null;

bool existeFotoLocal(String ruta) => false;

Widget imagenFotoLocal(String ruta, {BoxFit fit = BoxFit.cover}) =>
    const SizedBox.shrink();
