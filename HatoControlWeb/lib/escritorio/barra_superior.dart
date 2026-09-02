import 'package:flutter/material.dart';
import 'package:hato_control/app/theme.dart';
import 'package:hato_control/fincas/sync_status_sheet.dart';
import 'package:hato_control/services.dart';

/// Barra de arriba: dónde estoy, si hay internet, y el botón de sincronizar.
///
/// En el teléfono el estado de la sincronización vive dentro de la lista de
/// fincas; en la computadora conviene tenerlo siempre a la vista, porque el
/// usuario se queda horas en la misma pantalla.
class BarraSuperior extends StatelessWidget {
  const BarraSuperior({
    super.key,
    required this.migaDePan,
    required this.sinConexion,
  });

  final List<String> migaDePan;
  final bool sinConexion;

  static const double alto = 60;

  Future<void> _sincronizar(BuildContext context) async {
    if (syncService.sincronizando.value) return;
    await sincronizarSiSePuede();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          estadoConexion.hayConexion.value
              ? 'Sincronizado'
              : 'Sin internet: los cambios se suben cuando vuelva',
        ),
      ),
    );
  }

  Future<void> _verDetalleSync(BuildContext context) async {
    final pendientes = await syncService.pendientesPorTabla();
    final estados = await syncService.estadoPorTabla();
    if (!context.mounted) return;
    await mostrarSyncStatusSheet(
      context,
      pendientes: pendientes,
      estados: estados,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: alto,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: HatoSpacing.xl),
        child: Row(
          children: [
            Expanded(child: _MigaDePan(partes: migaDePan)),
            if (sinConexion) ...[
              Tooltip(
                message: 'Trabajando sin internet',
                child: Icon(
                  Icons.cloud_off,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: HatoSpacing.md),
            ],
            IconButton(
              tooltip: 'Detalle de sincronización',
              icon: const Icon(Icons.fact_check_outlined, size: 20),
              onPressed: () => _verDetalleSync(context),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: syncService.sincronizando,
              builder: (context, sincronizando, _) {
                if (sincronizando) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: HatoSpacing.md),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                return TextButton.icon(
                  onPressed: () => _sincronizar(context),
                  icon: const Icon(Icons.sync, size: 18),
                  label: const Text('Sincronizar'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MigaDePan extends StatelessWidget {
  const _MigaDePan({required this.partes});

  final List<String> partes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hijos = <Widget>[];
    for (var i = 0; i < partes.length; i++) {
      final ultima = i == partes.length - 1;
      hijos.add(
        Flexible(
          child: Text(
            partes[i],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ultima
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
          ),
        ),
      );
      if (!ultima) {
        hijos.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: HatoSpacing.sm),
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: theme.colorScheme.outline,
            ),
          ),
        );
      }
    }
    return Row(children: hijos);
  }
}
