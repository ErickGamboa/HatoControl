import 'package:flutter/material.dart';

import '../../data/sync/sync_service.dart';
import '../../services.dart';

/// El botón de sincronizar, igual en TODAS las pantallas.
///
/// Va en la barra de arriba de cada pantalla a propósito: el ganadero no tiene
/// por qué acordarse de volver a "Mis fincas" para traer lo que anotó el
/// mayordomo. Donde esté, toca ↻ y baja lo nuevo.
///
/// Mientras sincroniza muestra la ruedita con cuánto lleva subido ("12/210"):
/// una ruedita sin números parece trabada y hace que uno apriete de más. Al
/// terminar avisa, porque si no, en una pantalla que no cambió nada, no hay
/// manera de saber si el toque sirvió.
///
/// Las pantallas se refrescan solas: leen de la base local y esta cambia
/// cuando la sincronización guarda lo que bajó. Las que calculan con un
/// `Future` (Análisis financiero) escuchan a [SyncService.sincronizando] para
/// volver a calcular al terminar.
class BotonSincronizar extends StatelessWidget {
  const BotonSincronizar({super.key});

  Future<void> _sincronizar(BuildContext context) async {
    final mensajero = ScaffoldMessenger.maybeOf(context);
    final pendientesAntes = await syncService.contarPendientes();

    await sincronizarSiSePuede();
    if (!context.mounted) return;

    final pendientesDespues = await syncService.contarPendientes();
    final subidas = pendientesAntes - pendientesDespues;
    mensajero?.hideCurrentSnackBar();
    mensajero?.showSnackBar(
      SnackBar(
        content: Text(
          pendientesDespues > 0
              ? 'Faltan $pendientesDespues por subir. Se reintenta solo.'
              : subidas > 0
              ? 'Listo: se subieron $subidas y se bajó lo nuevo.'
              : 'Datos al día.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: estadoConexion.hayConexion,
      builder: (context, hayConexion, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: syncService.sincronizando,
          builder: (context, sincronizando, _) {
            if (sincronizando) {
              return ValueListenableBuilder<SyncProgreso>(
                valueListenable: syncService.progreso,
                builder: (context, avance, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      if (avance.activo) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${avance.hechas}/${avance.total}',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            final puedeSincronizar = hayConexion && haySesionSupabase;
            return IconButton(
              key: const ValueKey('app.sincronizar'),
              tooltip: puedeSincronizar
                  ? 'Traer datos nuevos'
                  : 'Sin conexión para sincronizar',
              icon: const Icon(Icons.sync),
              onPressed: puedeSincronizar ? () => _sincronizar(context) : null,
            );
          },
        );
      },
    );
  }
}
