/// Fachada de la foto de finca. Elige la implementación según la plataforma:
/// en móvil/escritorio se usa el archivo local (`dart:io`), en web no hay
/// sistema de archivos, así que la captura queda deshabilitada y la foto se
/// muestra desde `fincas.fotoUrl` (ver D-09).
library;

export 'foto_picker_web.dart' if (dart.library.io) 'foto_picker_io.dart';
