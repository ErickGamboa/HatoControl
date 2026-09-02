import 'dart:io';
import 'dart:typed_data';

/// Bytes de la foto guardada en el dispositivo, o null si el archivo ya no está.
Future<Uint8List?> leerFotoLocal(String ruta) async {
  final archivo = File(ruta);
  if (!await archivo.exists()) return null;
  return archivo.readAsBytes();
}
