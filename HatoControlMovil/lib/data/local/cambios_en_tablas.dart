import 'package:drift/drift.dart';

import 'database.dart';

/// Aviso de "algo cambió en estas tablas".
///
/// Sirve para las listas que se arman leyendo VARIAS tablas: mirando una sola,
/// la pantalla no se entera de la mitad de las cosas (el inventario no veía
/// llegar un pesaje, la ficha no veía un evento sanitario).
///
/// El nombre NO es decorativo y tiene que ser distinto en cada consulta.
/// Drift guarda estos avisos en un mapa cuya llave es el texto del SQL, así
/// que dos consultas con el mismo texto terminan siendo LA MISMA: la segunda
/// pantalla que se abre se queda escuchando las tablas de la primera y no se
/// mueve nunca. Eso fue exactamente lo que pasó con el inventario cuando
/// antes se había abierto la tarjeta de dieta.
extension CambiosEnTablas on AppDatabase {
  Stream<void> cambiosEn(
    String nombre,
    Set<ResultSetImplementation<dynamic, dynamic>> tablas,
  ) {
    assert(
      RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(nombre),
      'El nombre va directo en el SQL: solo minúsculas, números y _.',
    );
    assert(
      () {
        final suyas = tablas.map((t) => t.aliasedName).toSet();
        final previas = _nombresUsados.putIfAbsent(nombre, () => suyas);
        return previas.difference(suyas).isEmpty &&
            suyas.difference(previas).isEmpty;
      }(),
      'Ya hay otra consulta llamada "$nombre" escuchando otras tablas. '
      'Ponele un nombre propio o las dos pantallas se pisan.',
    );
    return customSelect('SELECT 1 AS $nombre', readsFrom: tablas).watch();
  }
}

/// Solo alimenta el aviso de arriba; en release los `assert` no corren.
final Map<String, Set<String>> _nombresUsados = {};
