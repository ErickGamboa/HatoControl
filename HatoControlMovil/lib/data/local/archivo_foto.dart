/// Lectura de la foto local que `SyncService` sube al servidor. En web no hay
/// archivos locales, así que la implementación devuelve null y el sync se
/// salta ese paso.
library;

export 'archivo_foto_web.dart' if (dart.library.io) 'archivo_foto_io.dart';
