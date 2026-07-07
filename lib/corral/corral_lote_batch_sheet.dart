import 'package:flutter/material.dart';

import '../data/repositories/lotes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../lotes/animal_sanidad_tab.dart';
import '../services.dart';

/// Elige un lote y aplica sanidad batch (modo corral).
Future<void> mostrarBatchSanidadCorral(
  BuildContext context, {
  required String fincaId,
  required String? responsableId,
  LotesRepository? lotesRepository,
  SanidadRepository? sanidadRepository,
}) async {
  final lotes = lotesRepository ?? lotesRepo;
  final lista = await lotes.lotesActivos(fincaId);
  if (!context.mounted) return;
  if (lista.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay lotes en esta finca.')),
    );
    return;
  }

  final lote = await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Tratamiento al lote'),
          ),
          for (final l in lista)
            ListTile(title: Text(l.nombre), onTap: () => Navigator.pop(ctx, l)),
        ],
      ),
    ),
  );
  if (lote == null || !context.mounted) return;

  final n = await aplicarSanidadAlLote(
    context,
    lote: lote,
    responsableId: responsableId,
    repo: sanidadRepository,
  );
  if (n != null && n > 0 && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tratamiento aplicado a $n animal(es).')),
    );
  }
}
