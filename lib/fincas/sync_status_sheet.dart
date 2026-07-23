import 'package:flutter/material.dart';

import '../data/local/database.dart';

/// Bottom sheet con el detalle de sincronización por tabla (D-13): cuántas
/// filas locales quedan `pendiente` de subir, y el último error de bajada si
/// lo hubo. Pensado para diagnóstico, no para uso diario — el ícono que lo
/// abre solo aparece cuando hay algo que mostrar (ver [FincasScreen]).
Future<void> mostrarSyncStatusSheet(
  BuildContext context, {
  required Map<String, int> pendientes,
  required List<SyncEstadoRow> estados,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        SyncStatusSheet(pendientes: pendientes, estados: estados),
  );
}

class SyncStatusSheet extends StatelessWidget {
  const SyncStatusSheet({
    super.key,
    required this.pendientes,
    required this.estados,
  });

  final Map<String, int> pendientes;
  final List<SyncEstadoRow> estados;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final erroresPorTabla = {
      for (final e in estados)
        if (e.ultimoError != null) e.tabla: e,
    };
    final tablas = {
      for (final entry in pendientes.entries)
        if (entry.value > 0) entry.key,
      ...erroresPorTabla.keys,
    }.toList()..sort();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de sincronización',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (tablas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Todo sincronizado, sin errores pendientes.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  key: const ValueKey('syncStatus.list'),
                  shrinkWrap: true,
                  itemCount: tablas.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final tabla = tablas[i];
                    final count = pendientes[tabla] ?? 0;
                    final error = erroresPorTabla[tabla];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        error != null
                            ? Icons.error_outline
                            : Icons.cloud_upload_outlined,
                        color: error != null
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline,
                      ),
                      title: Text(tabla),
                      subtitle: error != null
                          ? Text(
                              error.ultimoError!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: count > 0 ? Text('$count pendiente(s)') : null,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
