import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../sanidad/sanidad_aplicar_sheet.dart';
import '../services.dart';

/// Pestaña de historial sanitario de un animal.
class AnimalSanidadTab extends StatelessWidget {
  AnimalSanidadTab({
    super.key,
    required this.animal,
    required this.fincaId,
    required this.responsableId,
    SanidadRepository? repo,
    PesajesRepository? pesajesRepository,
  }) : repo = repo ?? sanidadRepo,
       pesajesRepository = pesajesRepository ?? pesajesRepo;

  final AnimalRow animal;
  final String fincaId;
  final String? responsableId;
  final SanidadRepository repo;
  final PesajesRepository pesajesRepository;

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _abrirMedicamentos(BuildContext context) async {
    final historial = await pesajesRepository
        .observarHistorial(animal.id)
        .first;
    if (!context.mounted) return;
    if (historial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesá el animal primero para calcular la dosis.'),
        ),
      );
      return;
    }
    final pesoKg = historial.last.peso;
    final finca =
        await (db.select(db.fincas)
              ..where((t) => t.id.equals(fincaId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    if (!context.mounted) return;
    if (finca == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se encontró la finca.')));
      return;
    }
    await mostrarSanidadAplicarSheet(
      context: context,
      finca: finca,
      animal: animal,
      pesoKg: pesoKg,
      usuarioId: responsableId ?? '',
      sanidadRepository: repo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        StreamBuilder<List<EventoSanitarioRow>>(
          stream: repo.observarHistorial(animal.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final eventos = snapshot.data ?? const [];
            if (eventos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Sin registros sanitarios.\nUsá + para aplicar medicamentos.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: eventos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = eventos[i];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_iconoTipo(e.tipo), size: 20),
                    ),
                    title: Text(e.producto),
                    subtitle: Text(
                      '${TipoEventoSanitario.etiqueta(e.tipo)} · ${_fecha(e.fecha)}'
                      '${e.dosis != null ? ' · ${e.dosis}' : ''}'
                      '${e.costo != null ? ' · ₡${e.costo!.toStringAsFixed(0)}' : ''}'
                      '${e.retiroHasta != null ? ' · retiro hasta ${_fecha(e.retiroHasta!)}' : ''}',
                    ),
                    isThreeLine: e.observaciones != null,
                    trailing: e.pendiente
                        ? Icon(
                            Icons.cloud_upload_outlined,
                            color: theme.colorScheme.outline,
                          )
                        : null,
                  ),
                );
              },
            );
          },
        ),
        if (!permisosFinca.esSoloLectura)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () => _abrirMedicamentos(context),
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  IconData _iconoTipo(String tipo) => switch (tipo) {
    TipoEventoSanitario.vacuna => Icons.vaccines_outlined,
    TipoEventoSanitario.desparasitacion => Icons.pest_control_outlined,
    TipoEventoSanitario.medicamento => Icons.medication_outlined,
    _ => Icons.medical_services_outlined,
  };
}
