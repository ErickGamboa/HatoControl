import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Abre la galería, guarda una copia local permanente y devuelve la ruta.
/// Devuelve null si el usuario cancela.
Future<String?> elegirFotoFinca(BuildContext context) async {
  final XFile? imagen = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 1280,
    imageQuality: 70,
  );
  if (imagen == null) return null;

  final dir = await getApplicationDocumentsDirectory();
  final fotosDir = Directory('${dir.path}/fincas_fotos');
  if (!await fotosDir.exists()) {
    await fotosDir.create(recursive: true);
  }
  final destino = '${fotosDir.path}/${const Uuid().v4()}.jpg';
  await File(imagen.path).copy(destino);
  return destino;
}
