import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../app/widgets/campo_fecha.dart';
import '../app/widgets/quick_number_field.dart';
import '../data/local/database.dart';
import '../data/repositories/deudas_repository.dart';
import 'gastos_fijos_tab.dart' show fmtColones;

/// Abre el formulario de una deuda (nueva o existente) y devuelve el aviso
/// que hay que mostrar, o null si no se hizo nada.
Future<String?> mostrarFormularioDeuda(
  BuildContext context, {
  required String fincaId,
  required DeudasRepository repositorio,
  DeudaConSaldo? existente,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => DeudaFormSheet(
      fincaId: fincaId,
      repositorio: repositorio,
      existente: existente,
    ),
  );
}

/// Formulario de deuda: a quién, cuánto, desde cuándo y (si ya existe) sus
/// abonos.
///
/// En la misma hoja se ve el saldo y se abona, porque es lo que el ganadero
/// viene a hacer: abrirla para ver cuánto falta y anotar lo que acaba de
/// pagar.
class DeudaFormSheet extends StatefulWidget {
  const DeudaFormSheet({
    super.key,
    required this.fincaId,
    required this.repositorio,
    this.existente,
  });

  final String fincaId;
  final DeudasRepository repositorio;
  final DeudaConSaldo? existente;

  @override
  State<DeudaFormSheet> createState() => _DeudaFormSheetState();
}

class _DeudaFormSheetState extends State<DeudaFormSheet> {
  late final _acreedor = TextEditingController(
    text: widget.existente?.deuda.acreedor ?? '',
  );
  late final _monto = TextEditingController(
    text: widget.existente == null
        ? ''
        : _sinDecimalesSobrantes(widget.existente!.deuda.monto),
  );
  late final _nota = TextEditingController(
    text: widget.existente?.deuda.nota ?? '',
  );
  late DateTime _fecha = widget.existente?.deuda.fecha ?? DateTime.now();
  late DateTime? _vence = widget.existente?.deuda.vence;
  bool _guardando = false;

  DeudaConSaldo? get _existente => widget.existente;

  static String _sinDecimalesSobrantes(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(2);

  @override
  void dispose() {
    _acreedor.dispose();
    _monto.dispose();
    _nota.dispose();
    super.dispose();
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _guardar() async {
    final acreedor = _acreedor.text.trim();
    final monto = double.tryParse(_monto.text.trim().replaceAll(',', '.'));
    if (acreedor.isEmpty || monto == null || monto <= 0) {
      _avisar('Escribí a quién le debés y cuánto.');
      return;
    }

    setState(() => _guardando = true);
    try {
      final existente = _existente;
      if (existente == null) {
        await widget.repositorio.crearDeuda(
          fincaId: widget.fincaId,
          acreedor: acreedor,
          monto: monto,
          fecha: _fecha,
          vence: _vence,
          nota: _nota.text,
        );
      } else {
        await widget.repositorio.editarDeuda(
          deudaId: existente.deuda.id,
          acreedor: acreedor,
          monto: monto,
          fecha: _fecha,
          vence: _vence,
          nota: _nota.text,
        );
      }
      if (mounted) {
        Navigator.pop(
          context,
          existente == null ? 'Deuda guardada' : 'Deuda actualizada',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _accion(Future<void> Function() accion, String aviso) async {
    setState(() => _guardando = true);
    try {
      await accion();
      if (mounted) Navigator.pop(context, aviso);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _abonar() async {
    final existente = _existente;
    if (existente == null) return;

    final datos = await showDialog<({double monto, DateTime fecha})>(
      context: context,
      builder: (ctx) => _AbonoDialog(saldo: existente.saldo),
    );
    if (datos == null) return;

    await _accion(
      () => widget.repositorio.registrarAbono(
        deudaId: existente.deuda.id,
        monto: datos.monto,
        fecha: datos.fecha,
      ),
      'Abono de ${fmtColones(datos.monto)} registrado',
    );
  }

  Future<void> _eliminar() async {
    final existente = _existente;
    if (existente == null) return;
    final seguro = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar la deuda?'),
        content: Text(
          'Se quita de la lista "${existente.deuda.acreedor}" con sus '
          'abonos. No se puede recuperar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, borrar'),
          ),
        ],
      ),
    );
    if (seguro != true) return;
    await _accion(
      () => widget.repositorio.eliminarDeuda(existente.deuda.id),
      'Deuda borrada',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final existente = _existente;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existente == null ? 'Nueva deuda' : 'Editar deuda',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HatoSpacing.lg),
            TextField(
              key: const ValueKey('deudas.acreedor'),
              controller: _acreedor,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: '¿A quién se le debe?',
                hintText: 'Cooperativa, veterinario, banco…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            QuickNumberField(
              key: const ValueKey('deudas.monto'),
              controller: _monto,
              labelText: 'Monto de la deuda',
              suffixText: '₡',
            ),
            const SizedBox(height: HatoSpacing.md),
            CampoFecha(
              etiqueta: 'Fecha de la deuda',
              fecha: _fecha,
              alCambiar: (f) => setState(() => _fecha = f),
            ),
            const SizedBox(height: HatoSpacing.md),
            CampoFecha(
              etiqueta: '¿Cuándo hay que pagarla? (opcional)',
              fecha: _vence,
              alCambiar: (f) => setState(() => _vence = f),
              alLimpiar: () => setState(() => _vence = null),
            ),
            const SizedBox(height: HatoSpacing.md),
            TextField(
              key: const ValueKey('deudas.nota'),
              controller: _nota,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Nota (opcional)',
                hintText: 'De qué es la deuda, cómo se va a pagar…',
                border: OutlineInputBorder(),
              ),
            ),
            if (existente != null) ...[
              const SizedBox(height: HatoSpacing.lg),
              _ResumenSaldo(item: existente),
              const SizedBox(height: HatoSpacing.sm),
              _Abonos(
                repositorio: widget.repositorio,
                deudaId: existente.deuda.id,
                alBorrar: _guardando
                    ? null
                    : (id) => _accion(
                        () => widget.repositorio.eliminarAbono(id),
                        'Abono borrado',
                      ),
              ),
              const SizedBox(height: HatoSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('deudas.abonar'),
                      onPressed: _guardando || existente.anulada
                          ? null
                          : _abonar,
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Abonar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('deudas.marcarPagada'),
                      onPressed:
                          _guardando ||
                              existente.pagada ||
                              existente.anulada
                          ? null
                          : () => _accion(
                              () => widget.repositorio.marcarPagada(
                                existente.deuda.id,
                              ),
                              'Deuda marcada como pagada',
                            ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Pagada'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: existente.anulada
                        ? OutlinedButton.icon(
                            key: const ValueKey('deudas.reabrir'),
                            onPressed: _guardando
                                ? null
                                : () => _accion(
                                    () => widget.repositorio.reabrir(
                                      existente.deuda.id,
                                    ),
                                    'Deuda reabierta',
                                  ),
                            icon: const Icon(Icons.undo),
                            label: const Text('Reabrir'),
                          )
                        : OutlinedButton.icon(
                            key: const ValueKey('deudas.anular'),
                            onPressed: _guardando
                                ? null
                                : () => _accion(
                                    () => widget.repositorio.anular(
                                      existente.deuda.id,
                                    ),
                                    'Deuda anulada',
                                  ),
                            icon: const Icon(Icons.block_outlined),
                            label: const Text('Anular'),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('deudas.eliminar'),
                      onPressed: _guardando ? null : _eliminar,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Borrar'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: HatoSpacing.lg),
            FilledButton(
              key: const ValueKey('deudas.guardar'),
              onPressed: _guardando ? null : _guardar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(_guardando ? 'Guardando…' : 'Guardar'),
            ),
            const SizedBox(height: HatoSpacing.sm),
            Text(
              'Las deudas no entran en la utilidad de los animales: esta '
              'lista es solo para llevar el control.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenSaldo extends StatelessWidget {
  const _ResumenSaldo({required this.item});

  final DeudaConSaldo item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(HatoSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saldo',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  fmtColones(item.saldo),
                  key: const ValueKey('deudas.saldo'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Abonado ${fmtColones(item.abonado)}\n'
            'de ${fmtColones(item.deuda.monto)}',
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Abonos extends StatelessWidget {
  const _Abonos({
    required this.repositorio,
    required this.deudaId,
    required this.alBorrar,
  });

  final DeudasRepository repositorio;
  final String deudaId;
  final ValueChanged<String>? alBorrar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<DeudaAbonoRow>>(
      stream: repositorio.observarAbonos(deudaId),
      builder: (context, snap) {
        final abonos = snap.data ?? const <DeudaAbonoRow>[];
        if (abonos.isEmpty) {
          return Text(
            'Todavía no tiene abonos.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final a in abonos)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(fmtFecha(a.fecha))),
                    Text(
                      fmtColones(a.monto),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (alBorrar != null)
                      IconButton(
                        tooltip: 'Borrar el abono',
                        icon: const Icon(Icons.close, size: 18),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => alBorrar!(a.id),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Cuánto se abona y en qué fecha. El monto viene propuesto con el saldo,
/// que es el caso normal: se paga todo lo que falta.
class _AbonoDialog extends StatefulWidget {
  const _AbonoDialog({required this.saldo});

  final double saldo;

  @override
  State<_AbonoDialog> createState() => _AbonoDialogState();
}

class _AbonoDialogState extends State<_AbonoDialog> {
  late final _monto = TextEditingController(
    text: widget.saldo == widget.saldo.roundToDouble()
        ? widget.saldo.round().toString()
        : widget.saldo.toStringAsFixed(2),
  );
  DateTime _fecha = DateTime.now();

  @override
  void dispose() {
    _monto.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar abono'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuickNumberField(
            key: const ValueKey('deudas.abono.monto'),
            controller: _monto,
            labelText: 'Monto del abono',
            suffixText: '₡',
          ),
          const SizedBox(height: HatoSpacing.md),
          CampoFecha(
            etiqueta: '¿Qué día se pagó?',
            fecha: _fecha,
            alCambiar: (f) => setState(() => _fecha = f),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const ValueKey('deudas.abono.guardar'),
          onPressed: () {
            final monto = double.tryParse(
              _monto.text.trim().replaceAll(',', '.'),
            );
            if (monto == null || monto <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Digitá el monto del abono.')),
              );
              return;
            }
            Navigator.pop(context, (monto: monto, fecha: _fecha));
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
