import 'package:flutter/material.dart';

import '../services.dart';

/// Qué eligió el ganadero cuando se le avisa que falta subir trabajo.
enum DecisionCierre { subir, quedarse, descartar }

/// Cierra la sesión avisando si queda trabajo sin subir.
///
/// Al salir, la copia local se borra ENTERA (ver [cerrarSesion]): es lo que
/// evita que la siguiente cuenta herede los marcadores de bajada de esta y no
/// vea sus propias fincas. Como borrar cuesta caro si algo no se subió, aquí
/// no se sale en silencio: se avisa cuántos registros faltan, se ofrece
/// subirlos, y perderlos requiere un sí explícito.
Future<void> cerrarSesionConAviso(BuildContext context) async {
  var pendientes = await cerrarSesion();
  if (pendientes == 0) return;

  while (true) {
    if (!context.mounted) return;
    final decision = await preguntarQueHacerConPendientes(context, pendientes);

    switch (decision) {
      case null:
      case DecisionCierre.quedarse:
        return;

      case DecisionCierre.subir:
        await sincronizarSiSePuede();
        pendientes = await syncService.contarPendientes();
        if (pendientes == 0) {
          await cerrarSesion();
          return;
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Todavía faltan $pendientes. Revisá que tengás internet.',
            ),
          ),
        );

      case DecisionCierre.descartar:
        if (!context.mounted) return;
        final seguro = await confirmarDescartePendientes(context, pendientes);
        if (seguro != true) continue;
        await cerrarSesion(descartarPendientes: true);
        return;
    }
  }
}

/// Aviso de "falta subir tu trabajo". Público para poder probar el texto y
/// las salidas sin depender de los singletons de la app.
Future<DecisionCierre?> preguntarQueHacerConPendientes(
  BuildContext context,
  int pendientes,
) {
  final registros = pendientes == 1 ? '1 registro' : '$pendientes registros';
  return showDialog<DecisionCierre>(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('cerrarSesion.falta'),
      title: const Text('Falta subir tu trabajo'),
      content: Text(
        'Hay $registros guardados en este aparato que todavía no llegaron al '
        'servidor. Al salir, la copia de este aparato se borra: eso se '
        'perdería.\n\n'
        'Conectate a internet y subilos antes de salir.',
      ),
      actions: [
        TextButton(
          key: const ValueKey('cerrarSesion.descartar'),
          onPressed: () => Navigator.of(context).pop(DecisionCierre.descartar),
          child: const Text('Salir y borrarlo'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(DecisionCierre.subir),
          child: const Text('Subir ahora'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(DecisionCierre.quedarse),
          child: const Text('Seguir en la app'),
        ),
      ],
    ),
  );
}

/// Segunda confirmación antes de perder trabajo sin subir.
Future<bool?> confirmarDescartePendientes(
  BuildContext context,
  int pendientes,
) {
  final registros = pendientes == 1 ? '1 registro' : '$pendientes registros';
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      key: const ValueKey('cerrarSesion.confirmarDescarte'),
      title: const Text('¿Borrar lo que falta?'),
      content: Text(
        'Se van a borrar $registros que nunca llegaron al servidor. '
        'No se pueden recuperar.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const ValueKey('cerrarSesion.confirmarDescarte.si'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sí, borrar y salir'),
        ),
      ],
    ),
  );
}
