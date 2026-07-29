import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../app/widgets/quick_number_field.dart';
import '../app/widgets/scan_field.dart';
import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';

class _ItemVenta {
  _ItemVenta({
    required this.animal,
    required this.peso,
    required this.precioKg,
  });

  final AnimalRow animal;
  double peso;
  double precioKg;

  double get total => peso * precioKg;
}

/// Módulo Venta: retiro bloquea · lote de venta · ₡/kg del lote editable por animal.
class VentaScreen extends StatefulWidget {
  VentaScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
    PesajesRepository? pesajesRepository,
    VentasRepository? ventasRepository,
    SanidadRepository? sanidadRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       ventasRepository = ventasRepository ?? ventasRepo,
       sanidadRepository = sanidadRepository ?? sanidadRepo;

  final FincaRow finca;
  final String usuarioId;
  final PesajesRepository pesajesRepository;
  final VentasRepository ventasRepository;
  final SanidadRepository sanidadRepository;

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  final _identCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _precioLoteCtrl = TextEditingController();
  final _identFocus = FocusNode();
  final _pesoFocus = FocusNode();

  final _enCurso = <_ItemVenta>[];
  bool _guardando = false;

  @override
  void dispose() {
    _tabs.dispose();
    _identCtrl.dispose();
    _pesoCtrl.dispose();
    _precioLoteCtrl.dispose();
    _identFocus.dispose();
    _pesoFocus.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  double? _parse(TextEditingController c) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    if (v == null || v <= 0) return null;
    return v;
  }

  String _fmt(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);

  String _fmtColon(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(0);

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _agregarALista() async {
    final ident = _identCtrl.text.trim();
    final peso = _parse(_pesoCtrl);
    final precioLote = _parse(_precioLoteCtrl);
    if (ident.isEmpty) {
      _snack('Escaneá o escribí el identificador.');
      _identFocus.requestFocus();
      return;
    }
    if (peso == null) {
      _snack('Ingresá el peso de venta.');
      _pesoFocus.requestFocus();
      return;
    }
    if (precioLote == null) {
      _snack('Ingresá el precio del lote (₡/kg).');
      return;
    }

    final animal = await widget.pesajesRepository.buscarAnimalActivo(
      widget.finca.id,
      ident,
    );
    if (animal == null) {
      _snack('No hay un animal activo con ese identificador.');
      return;
    }

    final retiro = await widget.sanidadRepository.retiroHasta(animal.id);
    if (retiro != null) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Animal en retiro'),
          content: Text(
            'No se puede vender "${animal.identificador}".\n'
            'Retiro hasta ${_fecha(retiro)}.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    if (_enCurso.any((e) => e.animal.id == animal.id)) {
      _snack('Ese animal ya está en la venta en curso.');
      return;
    }

    setState(() {
      _enCurso.add(
        _ItemVenta(animal: animal, peso: peso, precioKg: precioLote),
      );
    });
    _identCtrl.clear();
    _pesoCtrl.clear();
    _identFocus.requestFocus();
    _snack('${animal.identificador} agregado');
  }

  Future<void> _editarPrecioAnimal(_ItemVenta item) async {
    final ctrl = TextEditingController(text: _fmt(item.precioKg));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('₡/kg · ${item.animal.identificador}'),
        content: QuickNumberField(
          controller: ctrl,
          labelText: 'Precio por kilo',
          suffixText: '₡/kg',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final v = double.tryParse(ctrl.text.trim().replaceAll(',', '.'));
    if (v == null || v <= 0) return;
    setState(() => item.precioKg = v);
  }

  Future<void> _confirmar() async {
    if (_enCurso.isEmpty) return;
    final totalKg = _enCurso.fold<double>(0, (s, i) => s + i.peso);
    final totalColon = _enCurso.fold<double>(0, (s, i) => s + i.total);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar venta'),
        content: Text(
          'Se venden ${_enCurso.length} animal(es).\n'
          '${_fmt(totalKg)} kg · ₡${_fmtColon(totalColon)}\n\n'
          'Salen del lote de manejo y quedan en el historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _guardando = true);
    try {
      await widget.ventasRepository.confirmarLoteVenta(
        fincaId: widget.finca.id,
        items: [
          for (final i in _enCurso)
            (animalId: i.animal.id, peso: i.peso, precioKg: i.precioKg),
        ],
      );
      sincronizarSiSePuede();
      if (!mounted) return;
      setState(() => _enCurso.clear());
      _snack('Venta confirmada');
      _tabs.animateTo(1);
    } on AnimalEnRetiroException catch (e) {
      _snack('Retiro activo hasta ${_fecha(e.retiroHasta)}');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'En curso'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _tabEnCurso(theme),
          _HistorialVentas(
            fincaId: widget.finca.id,
            ventasRepository: widget.ventasRepository,
          ),
        ],
      ),
    );
  }

  Widget _tabEnCurso(ThemeData theme) {
    final totalKg = _enCurso.fold<double>(0, (s, i) => s + i.peso);
    final totalColon = _enCurso.fold<double>(0, (s, i) => s + i.total);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(HatoSpacing.lg),
        child: Column(
          children: [
            QuickNumberField(
              key: const ValueKey('venta.precioLote'),
              controller: _precioLoteCtrl,
              labelText: 'Precio del lote',
              suffixText: '₡/kg',
            ),
            const SizedBox(height: HatoSpacing.md),
            ScanField(
              key: const ValueKey('venta.animalId'),
              controller: _identCtrl,
              focusNode: _identFocus,
              labelText: 'Identificador (RFID o manual)',
              onSubmitted: (_) => _pesoFocus.requestFocus(),
            ),
            const SizedBox(height: HatoSpacing.md),
            QuickNumberField(
              key: const ValueKey('venta.peso'),
              controller: _pesoCtrl,
              focusNode: _pesoFocus,
              labelText: 'Peso',
              suffixText: 'kg',
              onSubmitted: (_) => _agregarALista(),
            ),
            const SizedBox(height: HatoSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                key: const ValueKey('venta.agregar'),
                onPressed: _agregarALista,
                icon: const Icon(Icons.add),
                label: const Text('Agregar a la venta'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: HatoSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _enCurso.isEmpty
                    ? 'Lista vacía'
                    : '${_enCurso.length} · ${_fmt(totalKg)} kg · ₡${_fmtColon(totalColon)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: HatoSpacing.sm),
            Expanded(
              child: _enCurso.isEmpty
                  ? Center(
                      child: Text(
                        'Precio del lote (₡/kg) · escaneá · peso.\n'
                        'Podés corregir el ₡/kg de cada animal.\n'
                        'Si hay retiro activo, la app no deja vender.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _enCurso.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final item = _enCurso[i];
                        return ListTile(
                          title: Text(
                            item.animal.identificador,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${_fmt(item.peso)} kg · ₡${_fmt(item.precioKg)}/kg',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₡${_fmtColon(item.total)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Corregir ₡/kg',
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _editarPrecioAnimal(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _enCurso.removeAt(i)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const ValueKey('venta.confirmar'),
                onPressed: _enCurso.isEmpty || _guardando ? null : _confirmar,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _guardando
                      ? 'Confirmando…'
                      : 'Confirmar venta (${_enCurso.length})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorialVentas extends StatelessWidget {
  const _HistorialVentas({
    required this.fincaId,
    required this.ventasRepository,
  });

  final String fincaId;
  final VentasRepository ventasRepository;

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<ResumenLoteVenta>>(
      stream: ventasRepository.observarLotesVenta(fincaId),
      builder: (context, snap) {
        final lotes = snap.data ?? const [];
        if (lotes.isEmpty) {
          return Center(
            child: Text(
              'Acá queda el historial de lotes de venta\ncon su utilidad.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(HatoSpacing.lg),
          itemCount: lotes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final r = lotes[i];
            final u = r.utilidadTotal;
            final color = u >= 0
                ? const Color(0xFF2E7D32)
                : const Color(0xFFC62828);
            return Card(
              margin: EdgeInsets.zero,
              child: ExpansionTile(
                leading: Icon(
                  Icons.sell_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Lote · ${_fecha(r.lote.fecha)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${r.ventas.length} animales · utilidad ₡${u.toStringAsFixed(0)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
                children: [
                  for (final v in r.ventas)
                    ListTile(
                      dense: true,
                      title: Text(v.animal.identificador),
                      subtitle: Text(
                        '${v.venta.peso?.toStringAsFixed(0) ?? '—'} kg'
                        '${v.venta.precioKg != null ? ' · ₡${v.venta.precioKg!.toStringAsFixed(0)}/kg' : ''}'
                        ' · ₡${v.venta.precio.toStringAsFixed(0)}',
                      ),
                      trailing: Text(
                        v.utilidad == null
                            ? '—'
                            : '₡${v.utilidad!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: (v.utilidad ?? 0) >= 0
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
