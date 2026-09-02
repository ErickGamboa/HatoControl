import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/local/database.dart';
import '../data/repositories/medicamentos_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../services.dart';

/// Modal de Trabajo: medicamentos del catálogo con dosis ya calculada.
Future<void> mostrarSanidadAplicarSheet({
  required BuildContext context,
  required FincaRow finca,
  required AnimalRow animal,
  required double pesoKg,
  required String usuarioId,
  SanidadRepository? sanidadRepository,
  MedicamentosRepository? medicamentosRepository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _SanidadAplicarSheet(
      finca: finca,
      animal: animal,
      pesoKg: pesoKg,
      usuarioId: usuarioId,
      sanidadRepository: sanidadRepository ?? sanidadRepo,
      medicamentosRepository: medicamentosRepository ?? medicamentosRepo,
    ),
  );
}

class _SanidadAplicarSheet extends StatefulWidget {
  const _SanidadAplicarSheet({
    required this.finca,
    required this.animal,
    required this.pesoKg,
    required this.usuarioId,
    required this.sanidadRepository,
    required this.medicamentosRepository,
  });

  final FincaRow finca;
  final AnimalRow animal;
  final double pesoKg;
  final String usuarioId;
  final SanidadRepository sanidadRepository;
  final MedicamentosRepository medicamentosRepository;

  @override
  State<_SanidadAplicarSheet> createState() => _SanidadAplicarSheetState();
}

class _SanidadAplicarSheetState extends State<_SanidadAplicarSheet> {
  final _seleccion = <String>{};
  List<MedicamentoRow> _meds = const [];
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await widget.medicamentosRepository.listarMedicamentos(
      widget.finca.id,
    );
    if (!mounted) return;
    setState(() {
      _meds = lista;
      _cargando = false;
    });
  }

  String _pesoFmt() {
    final p = widget.pesoKg;
    return p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);
  }

  Future<void> _aplicar() async {
    if (_seleccion.isEmpty) return;
    setState(() => _guardando = true);
    try {
      for (final id in _seleccion) {
        await widget.sanidadRepository.aplicarMedicamento(
          animalId: widget.animal.id,
          medicamentoId: id,
          pesoKg: widget.pesoKg,
          responsableId: widget.usuarioId,
        );
      }
      sincronizarSiSePuede();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_seleccion.length} medicamento(s) en '
            '${widget.animal.identificador}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final altura = MediaQuery.sizeOf(context).height * 0.75;

    return SizedBox(
      height: altura,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sanidad · ${widget.animal.identificador}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Peso ${_pesoFmt()} kg · tocá los que vas a aplicar',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: HatoSpacing.lg),
            if (_cargando)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_meds.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No hay medicamentos en el catálogo.\n'
                    'Agregálos en el módulo Sanidad.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _meds.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = _meds[i];
                    final on = _seleccion.contains(m.id);
                    final dosis = widget.medicamentosRepository.dosisParaPeso(
                      m,
                      widget.pesoKg,
                    );
                    return Material(
                      color: on
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() {
                            if (on) {
                              _seleccion.remove(m.id);
                            } else {
                              _seleccion.add(m.id);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                on ? Icons.check_circle : Icons.circle_outlined,
                                color: on
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.nombre,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${dosis.etiquetaDosis}'
                                      ' · ₡${dosis.costoUso.toStringAsFixed(0)}'
                                      '${m.diasRetiro > 0 ? ' · retiro ${m.diasRetiro}d' : ''}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: HatoSpacing.md),
            FilledButton(
              onPressed: _seleccion.isEmpty || _guardando ? null : _aplicar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _guardando
                    ? 'Aplicando…'
                    : _seleccion.isEmpty
                    ? 'Elegí medicamentos'
                    : 'Aplicar ${_seleccion.length}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
