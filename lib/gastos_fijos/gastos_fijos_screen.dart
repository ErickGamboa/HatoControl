import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme.dart';
import '../data/local/database.dart';
import '../data/repositories/gastos_fijos_repository.dart';
import '../services.dart';

const _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'setiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// ₡ con punto de miles y sin decimales: 300000 → "₡300.000".
String fmtColones(double monto) {
  final entero = monto.round().abs().toString();
  final partes = <String>[];
  for (var i = entero.length; i > 0; i -= 3) {
    partes.insert(0, entero.substring(i - 3 < 0 ? 0 : i - 3, i));
  }
  final signo = monto < 0 ? '-' : '';
  return '$signo₡${partes.join('.')}';
}

String _mesAno(DateTime f) => '${_meses[f.month - 1]} ${f.year}';

/// Gastos fijos de la finca (Módulo 7): peón, luz, agua. Se reparten entre los
/// animales según los días que estuvo cada uno (prorrateo por días-animal).
class GastosFijosScreen extends StatelessWidget {
  GastosFijosScreen({
    super.key,
    required this.finca,
    GastosFijosRepository? gastosFijosRepository,
  }) : gastosFijosRepository = gastosFijosRepository ?? gastosFijosRepo;

  final FincaRow finca;
  final GastosFijosRepository gastosFijosRepository;

  Future<void> _formulario(
    BuildContext context, {
    GastoFijoRow? existente,
  }) async {
    final resultado = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _GastoFormSheet(
        existente: existente,
        onGuardar: (datos) async {
          if (existente == null) {
            await gastosFijosRepository.crearGasto(
              fincaId: finca.id,
              concepto: datos.concepto,
              monto: datos.monto,
              periodicidad: datos.periodicidad,
              desde: datos.desde,
            );
          } else {
            await gastosFijosRepository.editarGasto(
              gastoId: existente.id,
              concepto: datos.concepto,
              monto: datos.monto,
              periodicidad: datos.periodicidad,
              desde: datos.desde,
              hasta: datos.hasta,
            );
          }
          sincronizarSiSePuede();
        },
        onDarDeBaja: existente == null
            ? null
            : () async {
                await gastosFijosRepository.darDeBaja(existente.id);
                sincronizarSiSePuede();
              },
        onReactivar: existente == null || existente.hasta == null
            ? null
            : () async {
                await gastosFijosRepository.editarGasto(
                  gastoId: existente.id,
                  concepto: existente.concepto,
                  monto: existente.monto,
                  periodicidad: existente.periodicidad,
                  desde: existente.desde,
                  hasta: null,
                );
                sincronizarSiSePuede();
              },
        onEliminar: existente == null
            ? null
            : () async {
                await gastosFijosRepository.eliminarGasto(existente.id);
                sincronizarSiSePuede();
              },
      ),
    );
    if (resultado != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(resultado)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos fijos')),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('gastosFijos.agregar'),
        onPressed: () => _formulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Gasto'),
      ),
      body: StreamBuilder<List<GastoFijoRow>>(
        stream: gastosFijosRepository.observarGastos(finca.id),
        builder: (context, snap) {
          final lista = snap.data ?? const <GastoFijoRow>[];
          if (snap.connectionState == ConnectionState.waiting &&
              lista.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (lista.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(HatoSpacing.xl),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: HatoSpacing.lg),
                    Text(
                      'Gastos de la finca',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: HatoSpacing.sm),
                    Text(
                      'Los que no son de un animal en particular: el peón, la '
                      'luz, el agua. Se reparten entre los animales según los '
                      'días que estuvo cada uno en la finca.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              HatoSpacing.lg,
              HatoSpacing.lg,
              HatoSpacing.lg,
              88,
            ),
            children: [
              _ResumenMesCard(
                key: const ValueKey('gastosFijos.resumen'),
                repositorio: gastosFijosRepository,
                fincaId: finca.id,
                gastos: lista,
              ),
              const SizedBox(height: HatoSpacing.lg),
              for (final g in lista) ...[
                _GastoCard(
                  gasto: g,
                  onTap: () => _formulario(context, existente: g),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: HatoSpacing.md),
              Text(
                'Cada gasto se reparte solo entre los animales que estaban en '
                'la finca ese mes. Al vender un animal su parte queda fija y no '
                'vuelve a cambiar.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GastoCard extends StatelessWidget {
  const _GastoCard({required this.gasto, required this.onTap});

  final GastoFijoRow gasto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mensual = gasto.periodicidad == PeriodicidadGasto.mensual;
    final deBaja = gasto.hasta != null;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          mensual ? Icons.event_repeat_outlined : Icons.receipt_outlined,
          color: deBaja ? theme.colorScheme.outline : theme.colorScheme.primary,
        ),
        title: Text(
          gasto.concepto,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          mensual
              ? '${fmtColones(gasto.monto)} cada mes · desde ${_mesAno(gasto.desde)}'
                    '${deBaja ? ' · dado de baja en ${_mesAno(gasto.hasta!)}' : ''}'
              : '${fmtColones(gasto.monto)} una sola vez · ${_mesAno(gasto.desde)}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// Encabezado con lo devengado del mes en curso y el ₡ por animal-día.
class _ResumenMesCard extends StatefulWidget {
  const _ResumenMesCard({
    super.key,
    required this.repositorio,
    required this.fincaId,
    required this.gastos,
  });

  final GastosFijosRepository repositorio;
  final String fincaId;
  final List<GastoFijoRow> gastos;

  @override
  State<_ResumenMesCard> createState() => _ResumenMesCardState();
}

class _ResumenMesCardState extends State<_ResumenMesCard> {
  ResumenGastosMes? _resumen;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(_ResumenMesCard viejo) {
    super.didUpdateWidget(viejo);
    if (_firma(viejo.gastos) != _firma(widget.gastos)) _cargar();
  }

  String _firma(List<GastoFijoRow> gastos) => gastos
      .map((g) => '${g.id}:${g.monto}:${g.periodicidad}:${g.desde}:${g.hasta}')
      .join('|');

  Future<void> _cargar() async {
    final r = await widget.repositorio.resumenMesActual(widget.fincaId);
    if (mounted) setState(() => _resumen = r);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = _resumen;
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(HatoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r == null ? 'Este mes' : 'Este mes (${_mesAno(r.mes)})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              r == null ? '—' : fmtColones(r.totalDevengado),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              r == null
                  ? ''
                  : r.costoPorAnimalDia == null
                  ? 'Todavía no hay animales a los cuales repartirlo.'
                  : '${fmtColones(r.costoPorAnimalDia!)} por animal por día'
                        ' · ${r.animalesActivos} animales',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatosGasto {
  const _DatosGasto({
    required this.concepto,
    required this.monto,
    required this.periodicidad,
    required this.desde,
    this.hasta,
  });

  final String concepto;
  final double monto;
  final String periodicidad;
  final DateTime desde;
  final DateTime? hasta;
}

class _GastoFormSheet extends StatefulWidget {
  const _GastoFormSheet({
    required this.onGuardar,
    this.existente,
    this.onDarDeBaja,
    this.onReactivar,
    this.onEliminar,
  });

  final GastoFijoRow? existente;
  final Future<void> Function(_DatosGasto datos) onGuardar;
  final Future<void> Function()? onDarDeBaja;
  final Future<void> Function()? onReactivar;
  final Future<void> Function()? onEliminar;

  @override
  State<_GastoFormSheet> createState() => _GastoFormSheetState();
}

class _GastoFormSheetState extends State<_GastoFormSheet> {
  late final _concepto = TextEditingController(
    text: widget.existente?.concepto,
  );
  late final _monto = TextEditingController(
    text: widget.existente == null
        ? ''
        : widget.existente!.monto.round().toString(),
  );
  late bool _mensual =
      (widget.existente?.periodicidad ?? PeriodicidadGasto.mensual) ==
      PeriodicidadGasto.mensual;
  late int _mes = (widget.existente?.desde ?? DateTime.now()).month;
  late int _ano = (widget.existente?.desde ?? DateTime.now()).year;
  bool _guardando = false;

  @override
  void dispose() {
    _concepto.dispose();
    _monto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final concepto = _concepto.text.trim();
    final monto = double.tryParse(_monto.text.trim().replaceAll(',', '.'));
    if (concepto.isEmpty || monto == null || monto < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribí el concepto y el monto')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      await widget.onGuardar(
        _DatosGasto(
          concepto: concepto,
          monto: monto,
          periodicidad: _mensual
              ? PeriodicidadGasto.mensual
              : PeriodicidadGasto.unico,
          desde: DateTime(_ano, _mes, 1),
          hasta: widget.existente?.hasta,
        ),
      );
      if (mounted) {
        Navigator.pop(
          context,
          widget.existente == null ? 'Gasto guardado' : 'Gasto actualizado',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _accion(Future<void> Function() accion, String mensaje) async {
    setState(() => _guardando = true);
    try {
      await accion();
      if (mounted) Navigator.pop(context, mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);
    final ahora = DateTime.now();
    final anos = [
      for (var a = ahora.year - 2; a <= ahora.year + 1; a++) a,
      if (_ano < ahora.year - 2) _ano,
    ]..sort();
    final existente = widget.existente;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existente == null ? 'Nuevo gasto fijo' : 'Editar gasto',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HatoSpacing.lg),
            TextField(
              key: const ValueKey('gastosFijos.concepto'),
              controller: _concepto,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: '¿Qué gasto es?',
                hintText: 'Salario del peón, luz, agua…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            TextField(
              key: const ValueKey('gastosFijos.monto'),
              controller: _monto,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: _mensual ? 'Monto por mes' : 'Monto',
                suffixText: '₡',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            SwitchListTile(
              key: const ValueKey('gastosFijos.mensual'),
              contentPadding: EdgeInsets.zero,
              value: _mensual,
              onChanged: (v) => setState(() => _mensual = v),
              title: const Text('Se repite cada mes'),
              subtitle: Text(
                _mensual
                    ? 'Se aplica solo todos los meses. No hay que digitarlo de nuevo.'
                    : 'Gasto de una sola vez, solo en ese mes.',
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            Text(
              _mensual ? 'Desde qué mes' : 'De qué mes fue',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<int>(
                    key: const ValueKey('gastosFijos.mes'),
                    initialValue: _mes,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (var m = 1; m <= 12; m++)
                        DropdownMenuItem(value: m, child: Text(_meses[m - 1])),
                    ],
                    onChanged: (v) => setState(() => _mes = v ?? _mes),
                  ),
                ),
                const SizedBox(width: HatoSpacing.sm),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    key: const ValueKey('gastosFijos.ano'),
                    initialValue: _ano,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final a in anos)
                        DropdownMenuItem(value: a, child: Text('$a')),
                    ],
                    onChanged: (v) => setState(() => _ano = v ?? _ano),
                  ),
                ),
              ],
            ),
            if (existente?.hasta != null) ...[
              const SizedBox(height: HatoSpacing.md),
              Text(
                'Dado de baja en ${_mesAno(existente!.hasta!)}: dejó de '
                'repartirse desde esa fecha.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: HatoSpacing.xl),
            FilledButton(
              key: const ValueKey('gastosFijos.guardar'),
              onPressed: _guardando ? null : _guardar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_guardando ? 'Guardando…' : 'Guardar'),
            ),
            if (existente != null) ...[
              const SizedBox(height: HatoSpacing.sm),
              if (existente.hasta == null && widget.onDarDeBaja != null)
                OutlinedButton.icon(
                  key: const ValueKey('gastosFijos.darDeBaja'),
                  onPressed: _guardando
                      ? null
                      : () =>
                            _accion(widget.onDarDeBaja!, 'Gasto dado de baja'),
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Dar de baja (dejó de pagarse)'),
                ),
              if (existente.hasta != null && widget.onReactivar != null)
                OutlinedButton.icon(
                  key: const ValueKey('gastosFijos.reactivar'),
                  onPressed: _guardando
                      ? null
                      : () => _accion(widget.onReactivar!, 'Gasto reactivado'),
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Reactivar'),
                ),
              if (widget.onEliminar != null)
                TextButton.icon(
                  key: const ValueKey('gastosFijos.eliminar'),
                  onPressed: _guardando
                      ? null
                      : () => _accion(widget.onEliminar!, 'Gasto eliminado'),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
