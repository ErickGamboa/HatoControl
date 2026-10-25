import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../app/widgets/campo_fecha.dart';
import '../data/estadisticas/estadisticas_sanidad.dart';
import '../data/local/database.dart';
import '../data/repositories/medicamentos_repository.dart';
import '../data/repositories/reglas_de_fechas.dart';
import '../data/repositories/sanidad_repository.dart';
import '../services.dart';

/// Hoja para aplicar uno o varios medicamentos a TODOS los animales activos
/// de un lote, de un solo tiro. La fecha es hoy, pero se puede cambiar.
///
/// Si ese día algunos animales ya tienen ese mismo medicamento, solo se le
/// aplica a los que faltan. Devuelve el resultado, o null si se canceló.
Future<ResultadoAplicacionLote?> mostrarSanidadLoteSheet({
  required BuildContext context,
  required LoteRow lote,
  String? usuarioId,
  SanidadRepository? sanidadRepository,
  MedicamentosRepository? medicamentosRepository,
}) {
  return showModalBottomSheet<ResultadoAplicacionLote>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _SanidadLoteSheet(
      lote: lote,
      usuarioId: usuarioId,
      sanidadRepository: sanidadRepository ?? sanidadRepo,
      medicamentosRepository: medicamentosRepository ?? medicamentosRepo,
    ),
  );
}

class _SanidadLoteSheet extends StatefulWidget {
  const _SanidadLoteSheet({
    required this.lote,
    required this.usuarioId,
    required this.sanidadRepository,
    required this.medicamentosRepository,
  });

  final LoteRow lote;
  final String? usuarioId;
  final SanidadRepository sanidadRepository;
  final MedicamentosRepository medicamentosRepository;

  @override
  State<_SanidadLoteSheet> createState() => _SanidadLoteSheetState();
}

class _SanidadLoteSheetState extends State<_SanidadLoteSheet> {
  final _seleccion = <String>{};
  List<MedicamentoRow> _meds = const [];
  bool _cargando = true;
  bool _guardando = false;
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final lista = await widget.medicamentosRepository.listarMedicamentos(
      widget.lote.fincaId,
    );
    if (!mounted) return;
    setState(() {
      _meds = lista;
      _cargando = false;
    });
  }

  Future<void> _aplicar() async {
    if (_seleccion.isEmpty) return;
    setState(() => _guardando = true);
    try {
      final r = await widget.sanidadRepository.aplicarMedicamentoALote(
        loteId: widget.lote.id,
        medicamentoIds: _seleccion.toList(),
        fecha: _fecha,
        responsableId: widget.usuarioId,
      );
      if (r.aplicadas > 0) sincronizarSiSePuede();
      if (mounted) Navigator.pop(context, r);
    } on FechaInvalidaException catch (e) {
      if (mounted) await avisarFechaInvalida(context, e.mensaje);
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
              'Medicar todo el lote',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '"${widget.lote.nombre}" · tocá los que vas a aplicar',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            CampoFecha(
              key: const ValueKey('sanidadLote.fecha'),
              etiqueta: '¿Qué día se aplicó?',
              fecha: _fecha,
              ultima: DateTime.now(),
              alCambiar: (f) => setState(() => _fecha = f),
            ),
            const SizedBox(height: HatoSpacing.md),
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
                    return Material(
                      color: on
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        key: ValueKey('sanidadLote.med.${m.id}'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() {
                          if (on) {
                            _seleccion.remove(m.id);
                          } else {
                            _seleccion.add(m.id);
                          }
                        }),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
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
                                      '${TipoAplicacionMedicamento.etiqueta(m.tipoAplicacion)}'
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
            const SizedBox(height: HatoSpacing.sm),
            Text(
              'La dosis de cada animal sale de su último peso. Si ese día ya '
              'tiene ese medicamento, no se le vuelve a poner.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            FilledButton(
              key: const ValueKey('sanidadLote.aplicar'),
              onPressed: _seleccion.isEmpty || _guardando ? null : _aplicar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _guardando
                    ? 'Aplicando…'
                    : _seleccion.isEmpty
                    ? 'Elegí medicamentos'
                    : 'Aplicar a todo el lote',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Le cuenta al ganadero, en palabras, qué pasó al medicar el lote.
Future<void> avisarResultadoSanidadLote(
  BuildContext context,
  ResultadoAplicacionLote r,
) {
  final lineas = <String>[
    if (r.animales == 0) 'El lote no tiene animales activos.',
    if (r.aplicadas > 0)
      'Se registraron ${r.aplicadas} aplicación(es).'
    else if (r.animales > 0)
      'No se registró ninguna aplicación nueva.',
    if (r.yaLoTenian > 0)
      '${r.yaLoTenian} ya lo tenían ese día: no se repitieron.',
    if (r.entraronDespues.isNotEmpty)
      'No se aplicó a ${r.entraronDespues.join(', ')}: entraron a la finca '
          'después de esa fecha.',
    if (r.sinPeso.isNotEmpty)
      'No se aplicó a ${r.sinPeso.join(', ')}: no tienen peso para '
          'calcular la dosis.',
  ];
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Medicar el lote'),
      content: Text(lineas.join('\n\n')),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
