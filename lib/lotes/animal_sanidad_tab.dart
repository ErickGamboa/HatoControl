import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/sanidad_repository.dart';
import '../sanidad/sanidad_form_dialog.dart';
import '../services.dart';

/// Pestaña de historial sanitario de un animal.
class AnimalSanidadTab extends StatelessWidget {
  AnimalSanidadTab({
    super.key,
    required this.animal,
    required this.fincaId,
    required this.responsableId,
    SanidadRepository? repo,
  }) : repo = repo ?? sanidadRepo;

  final AnimalRow animal;
  final String fincaId;
  final String? responsableId;
  final SanidadRepository repo;

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _registrar(BuildContext context) async {
    final sugerencias = await repo.sugerenciasProducto(fincaId);
    if (!context.mounted) return;
    final datos = await mostrarFormularioSanidad(
      context,
      titulo: 'Registrar sanidad · ${animal.identificador}',
      sugerenciasProducto: sugerencias,
    );
    if (datos == null) return;
    await repo.registrarEvento(
      animalId: animal.id,
      tipo: datos.tipo,
      producto: datos.producto,
      dosis: datos.dosis,
      observaciones: datos.observaciones,
      costo: datos.costo,
      responsableId: responsableId,
    );
    sincronizarSiSePuede();
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
                    'Sin registros sanitarios.\nUsá + para agregar uno.',
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
                      '${e.costo != null ? ' · ₡${e.costo!.toStringAsFixed(0)}' : ''}',
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
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _registrar(context),
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

/// Aplica un evento sanitario a todos los animales del lote.
Future<int?> aplicarSanidadAlLote(
  BuildContext context, {
  required LoteRow lote,
  required String? responsableId,
  SanidadRepository? repo,
}) async {
  final r = repo ?? sanidadRepo;
  final sugerencias = await r.sugerenciasProducto(lote.fincaId);
  if (!context.mounted) return null;
  final datos = await mostrarFormularioSanidad(
    context,
    titulo: 'Tratamiento al lote · ${lote.nombre}',
    sugerenciasProducto: sugerencias,
  );
  if (datos == null) return null;
  final count = await r.registrarEventoEnLote(
    loteId: lote.id,
    tipo: datos.tipo,
    producto: datos.producto,
    dosis: datos.dosis,
    observaciones: datos.observaciones,
    costo: datos.costo,
    responsableId: responsableId,
  );
  sincronizarSiSePuede();
  return count;
}
