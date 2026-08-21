import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../app/widgets/quick_number_field.dart';
import '../app/widgets/scan_field.dart';
import '../data/estadisticas/estadisticas_economicas.dart';
import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';

class _ItemVenta {
  _ItemVenta({required this.animal, required this.peso});

  final AnimalRow animal;
  double peso;
}

/// Módulo Venta (D-19): retiro bloquea · el grupo se arma con identificador y
/// kilos de salida de finca · el dinero y los datos de planta se registran
/// después, animal por animal, desde el historial.
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
  final _identFocus = FocusNode();
  final _pesoFocus = FocusNode();

  final _enCurso = <_ItemVenta>[];
  bool _guardando = false;

  @override
  void dispose() {
    _tabs.dispose();
    _identCtrl.dispose();
    _pesoCtrl.dispose();
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

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _agregarALista() async {
    final ident = _identCtrl.text.trim();
    final peso = _parse(_pesoCtrl);
    if (ident.isEmpty) {
      _snack('Escaneá o escribí el identificador.');
      _identFocus.requestFocus();
      return;
    }
    if (peso == null) {
      _snack('Ingresá los kilos de salida.');
      _pesoFocus.requestFocus();
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
      _enCurso.add(_ItemVenta(animal: animal, peso: peso));
    });
    _identCtrl.clear();
    _pesoCtrl.clear();
    _identFocus.requestFocus();
    _snack('${animal.identificador} agregado');
  }

  Future<void> _editarPesoAnimal(_ItemVenta item) async {
    final ctrl = TextEditingController(text: _fmt(item.peso));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Kilos · ${item.animal.identificador}'),
        content: QuickNumberField(
          controller: ctrl,
          labelText: 'Kilos de salida',
          suffixText: 'kg',
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
    setState(() => item.peso = v);
  }

  Future<void> _confirmar() async {
    if (_enCurso.isEmpty) return;
    final totalKg = _enCurso.fold<double>(0, (s, i) => s + i.peso);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar venta'),
        content: Text(
          'Se venden ${_enCurso.length} animal(es).\n'
          '${_fmt(totalKg)} kg de salida.\n\n'
          'Salen del lote de manejo y quedan en el historial.\n'
          'Ahí registrás, por animal, el peso en pie, el peso en canal y el '
          'dinero recibido.',
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
          for (final i in _enCurso) (animalId: i.animal.id, peso: i.peso),
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
    if (permisosFinca.esSoloLectura) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(HatoSpacing.xl),
          child: Text(
            'Te compartieron esta finca solo para verla: podés revisar el '
            'historial de ventas, pero no registrar una venta nueva.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }
    final totalKg = _enCurso.fold<double>(0, (s, i) => s + i.peso);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(HatoSpacing.lg),
        child: Column(
          children: [
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
              labelText: 'Kilos de salida',
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
                    : '${_enCurso.length} animal(es) · ${_fmt(totalKg)} kg',
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
                        'Escaneá el animal y digitá los kilos de salida.\n'
                        'El dinero recibido y los datos de planta se registran\n'
                        'después, en el historial.\n'
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
                          subtitle: Text('${_fmt(item.peso)} kg de salida'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Corregir kilos',
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _editarPesoAnimal(item),
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

const _verde = Color(0xFF2E7D32);
const _rojo = Color(0xFFC62828);

String _fechaCorta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _colones(double v) => '₡${v.round()}';

String _kg(double? v) => v == null
    ? '—'
    : '${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(1)} kg';

String _pct(double? v) => v == null ? '—' : '${v.toStringAsFixed(1)} %';

class _HistorialVentas extends StatelessWidget {
  const _HistorialVentas({
    required this.fincaId,
    required this.ventasRepository,
  });

  final String fincaId;
  final VentasRepository ventasRepository;

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
              'Acá queda el historial de grupos de venta.\n'
              'Tocá un animal para registrar el peso en pie,\n'
              'el peso en canal y el dinero recibido.',
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
          itemBuilder: (context, i) => _GrupoVentaCard(
            resumen: lotes[i],
            ventasRepository: ventasRepository,
          ),
        );
      },
    );
  }
}

/// Un grupo de venta: encabezado con el análisis y la lista de animales, cada
/// uno tocable para registrar sus datos de planta.
class _GrupoVentaCard extends StatelessWidget {
  const _GrupoVentaCard({
    required this.resumen,
    required this.ventasRepository,
  });

  final ResumenLoteVenta resumen;
  final VentasRepository ventasRepository;

  Future<void> _registrarDatos(BuildContext context, VentaConAnimal v) async {
    final guardado = await showDialog<bool>(
      context: context,
      // Tocar fuera NO descarta lo digitado: son tres datos que cuestan
      // conseguir y perderlos en silencio se lee como “no guardó”.
      barrierDismissible: false,
      builder: (_) =>
          _DatosPlantaDialog(item: v, ventasRepository: ventasRepository),
    );
    if (guardado != true) return;
    sincronizarSiSePuede();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos guardados · ${v.animal.identificador}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = resumen;
    final hayDatos = r.conDatosPlanta > 0;
    final u = r.utilidadTotal;

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        key: ValueKey('venta.grupo.${r.lote.id}'),
        leading: Icon(Icons.sell_outlined, color: theme.colorScheme.primary),
        title: Text(
          'Grupo · ${_fechaCorta(r.lote.fecha)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          hayDatos
              ? '${r.total} animales · utilidad ${_colones(u)}'
              : '${r.total} animales · faltan datos de planta',
          style: TextStyle(
            color: hayDatos
                ? (u >= 0 ? _verde : _rojo)
                : theme.colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          _AnalisisGrupo(resumen: r),
          const Divider(height: 1),
          for (final v in r.ventas)
            ListTile(
              key: ValueKey('venta.animal.${v.venta.id}'),
              dense: true,
              onTap: permisosFinca.esSoloLectura
                  ? null
                  : () => _registrarDatos(context, v),
              title: Text(v.animal.identificador),
              subtitle: Text(
                v.tieneDatosPlanta
                    ? 'Pie ${_kg(v.venta.pesoPie)} · Canal '
                          '${_kg(v.venta.pesoCanal)} · '
                          '${_pct(v.venta.rendimiento)} · '
                          '${_colones(v.venta.dineroRecibido!)}'
                    : permisosFinca.esSoloLectura
                    ? 'Salida ${_kg(v.venta.peso)} · '
                          'faltan los datos de planta'
                    : 'Salida ${_kg(v.venta.peso)} · '
                          'tocá para registrar los datos de planta',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    v.utilidad == null ? '—' : _colones(v.utilidad!),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: v.utilidad == null
                          ? theme.colorScheme.outline
                          : (v.utilidad! >= 0 ? _verde : _rojo),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    v.tieneDatosPlanta
                        ? Icons.edit_outlined
                        : Icons.add_circle_outline,
                    size: 20,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Análisis del grupo de venta: utilidad total, rendimiento promedio y totales.
class _AnalisisGrupo extends StatelessWidget {
  const _AnalisisGrupo({required this.resumen});

  final ResumenLoteVenta resumen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = resumen;
    final kgCanal = r.precioKgCanal;

    Widget dato(String etiqueta, String valor, {Color? color}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          valor,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(HatoSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis del grupo',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: HatoSpacing.sm),
          Wrap(
            spacing: HatoSpacing.lg,
            runSpacing: HatoSpacing.md,
            children: [
              dato(
                'Utilidad total',
                r.conDatosPlanta == 0 ? '—' : _colones(r.utilidadTotal),
                color: r.conDatosPlanta == 0
                    ? theme.colorScheme.outline
                    : (r.utilidadTotal >= 0 ? _verde : _rojo),
              ),
              dato('Rendimiento promedio', _pct(r.rendimientoPromedio)),
              dato(
                'Dinero recibido',
                r.conDatosPlanta == 0 ? '—' : _colones(r.dineroRecibidoTotal),
              ),
              dato('Kilos de salida', _kg(r.pesoFincaTotal)),
              if (r.pesoPieTotal > 0) dato('Kilos en pie', _kg(r.pesoPieTotal)),
              if (r.pesoCanalTotal > 0)
                dato('Kilos de canal', _kg(r.pesoCanalTotal)),
              if (kgCanal != null)
                dato('₡ por kilo de canal', '${_colones(kgCanal)}/kg'),
            ],
          ),
          if (r.pendientesDeDatos > 0) ...[
            const SizedBox(height: HatoSpacing.sm),
            Text(
              r.conDatosPlanta == 0
                  ? 'Ningún animal tiene datos de planta todavía.'
                  : 'Faltan ${r.pendientesDeDatos} de ${r.total} animales.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Registra, por animal, lo que devuelve la planta. El rendimiento se calcula
/// en vivo desde los dos pesos (D-19): no se digita.
class _DatosPlantaDialog extends StatefulWidget {
  const _DatosPlantaDialog({
    required this.item,
    required this.ventasRepository,
  });

  final VentaConAnimal item;
  final VentasRepository ventasRepository;

  @override
  State<_DatosPlantaDialog> createState() => _DatosPlantaDialogState();
}

class _DatosPlantaDialogState extends State<_DatosPlantaDialog> {
  late final TextEditingController _pieCtrl;
  late final TextEditingController _canalCtrl;
  late final TextEditingController _dineroCtrl;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final v = widget.item.venta;
    _pieCtrl = TextEditingController(text: _inicial(v.pesoPie));
    _canalCtrl = TextEditingController(text: _inicial(v.pesoCanal));
    _dineroCtrl = TextEditingController(text: _inicial(v.dineroRecibido));
    for (final c in [_pieCtrl, _canalCtrl, _dineroCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  static String _inicial(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  @override
  void dispose() {
    _pieCtrl.dispose();
    _canalCtrl.dispose();
    _dineroCtrl.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    if (v == null || v <= 0) return null;
    return v;
  }

  Future<void> _guardar() async {
    final pie = _num(_pieCtrl);
    final canal = _num(_canalCtrl);
    final dinero = _num(_dineroCtrl);

    if (canal != null && pie != null && canal > pie) {
      _aviso('El peso en canal no puede ser mayor que el peso en pie.');
      return;
    }
    if (pie == null && canal == null && dinero == null) {
      _aviso('Digitá al menos un dato antes de guardar.');
      return;
    }

    setState(() => _guardando = true);
    try {
      await widget.ventasRepository.registrarDatosPlanta(
        ventaId: widget.item.venta.id,
        pesoPie: pie,
        pesoCanal: canal,
        dineroRecibido: dinero,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      // Sin esto el botón se quedaba en “Guardando…” para siempre y parecía
      // que la app había guardado.
      if (!mounted) return;
      setState(() => _guardando = false);
      _aviso('No se pudo guardar: $e');
    }
  }

  void _aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pie = _num(_pieCtrl);
    final canal = _num(_canalCtrl);
    final dinero = _num(_dineroCtrl);
    final rendimiento = rendimientoCanal(pesoPie: pie, pesoCanal: canal);

    return AlertDialog(
      title: Text('Datos de planta · ${widget.item.animal.identificador}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Salió de la finca con ${_kg(widget.item.venta.peso)}.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            QuickNumberField(
              key: const ValueKey('planta.pesoPie'),
              controller: _pieCtrl,
              labelText: 'Peso en pie',
              suffixText: 'kg',
            ),
            const SizedBox(height: HatoSpacing.md),
            QuickNumberField(
              key: const ValueKey('planta.pesoCanal'),
              controller: _canalCtrl,
              labelText: 'Peso en canal',
              suffixText: 'kg',
            ),
            const SizedBox(height: HatoSpacing.sm),
            Container(
              padding: const EdgeInsets.all(HatoSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                key: const ValueKey('planta.rendimiento'),
                rendimiento == null
                    ? 'Rendimiento: digitá los dos pesos'
                    : 'Rendimiento: ${_pct(rendimiento)}  '
                          '(${_kg(canal)} ÷ ${_kg(pie)})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            QuickNumberField(
              key: const ValueKey('planta.dinero'),
              controller: _dineroCtrl,
              labelText: 'Dinero recibido',
              suffixText: '₡',
            ),
            if (dinero != null && canal != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${_colones(dinero / canal)} por kilo de canal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            const SizedBox(height: HatoSpacing.sm),
            Text(
              'La utilidad de este animal sale del dinero recibido.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const ValueKey('planta.guardar'),
          onPressed: _guardando ? null : _guardar,
          child: Text(_guardando ? 'Guardando…' : 'Guardar'),
        ),
      ],
    );
  }
}
