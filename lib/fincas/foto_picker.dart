import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Deja elegir una foto (cámara o galería), la guarda en una copia local
/// permanente de la app y devuelve la ruta del archivo. Devuelve null si el
/// usuario cancela.
Future<String?> elegirFotoFinca(BuildContext context) async {
  final fuente = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Tomar foto'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Elegir de la galería'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (fuente == null) return null;

  final XFile? imagen = await ImagePicker().pickImage(
    source: fuente,
    maxWidth: 1280,
    imageQuality: 70, // comprime para no subir archivos enormes
  );
  if (imagen == null) return null;

  // Copiar a una carpeta permanente de la app (la ruta temporal se borra).
  final dir = await getApplicationDocumentsDirectory();
  final fotosDir = Directory('${dir.path}/fincas_fotos');
  if (!await fotosDir.exists()) {
    await fotosDir.create(recursive: true);
  }
  final destino = '${fotosDir.path}/${const Uuid().v4()}.jpg';
  await File(imagen.path).copy(destino);
  return destino;
}
