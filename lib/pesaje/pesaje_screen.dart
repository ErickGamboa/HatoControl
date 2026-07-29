import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../app/widgets/quick_number_field.dart';
import '../app/widgets/scan_field.dart';
import '../data/local/database.dart';
import '../data/repositories/lotes_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../sanidad/sanidad_aplicar_sheet.dart';
import '../services.dart';

/// Pantalla de Trabajo (documento oro): pesaje en la manga.
/// Identificador (RFID o manual) + peso → lista del día con GMD + FAB sanidad.
class PesajeScreen extends StatefulWidget {
  PesajeScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
    PesajesRepository? pesajesRepository,
    LotesRepository? lotesRepository,
    SanidadRepository? sanidadRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       lotesRepository = lotesRepository ?? lotesRepo,
       sanidadRepository = sanidadRepository ?? sanidadRepo;

  final FincaRow finca;
  final String usuarioId;
  final PesajesRepository pesajesRepository;
  final LotesRepository lotesRepository;
  final SanidadRepository sanidadRepository;

  @override
  State<PesajeScreen> createState() => _PesajeScreenState();
}

class _PesajeScreenState extends State<PesajeScreen> {
  final _identCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _identFocus = FocusNode();
  final _pesoFocus = FocusNode();
  bool _guardando = false;

  /// Último animal pesado en esta sesión → habilita FAB de sanidad.
  AnimalRow? _ultimoAnimal;
  double? _ultimoPeso;

  DateTime get _inicioDeHoy {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    _identCtrl.dispose();
    _pesoCtrl.dispose();
    _identFocus.dispose();
    _pesoFocus.dispose();
    super.dispose();
  }

  void _mostrar(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  double? _parsePeso([TextEditingController? ctrl]) {
    final raw = (ctrl ?? _pesoCtrl).text.trim().replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return null;
    return v;
  }

  String _pesoFmt(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toString();

  Future<void> _registrar() async {
    final ident = _identCtrl.text.trim();
    final peso = _parsePeso();
    if (ident.isEmpty) {
      _mostrar('Escaneá o escribí el identificador.');
      _identFocus.requestFocus();
      return;
    }
    if (peso == null) {
      _mostrar('Ingresá el peso (kg).');
      _pesoFocus.requestFocus();
      return;
    }

    setState(() => _guardando = true);
    try {
      final animal = await widget.pesajesRepository.buscarAnimalActivo(
        widget.finca.id,
        ident,
      );
      if (animal != null) {
        await _pesarExistente(animal, peso);
      } else {
        await _animalNuevo(ident, peso);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _pesarExistente(AnimalRow animal, double peso) async {
    final hoy = await widget.pesajesRepository.pesajeDeHoy(animal.id);
    if (hoy != null) {
      if (!mounted) return;
      final corregir = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ya se pesó hoy'),
          content: Text(
            'El animal "${animal.identificador}" ya tiene '
            '${_pesoFmt(hoy.peso)} kg registrados hoy.\n\n'
            '¿Querés corregir el peso a ${_pesoFmt(peso)} kg?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Corregir'),
            ),
          ],
        ),
      );
      if (corregir != true) return;
      await widget.pesajesRepository.actualizarPesaje(
        pesajeId: hoy.id,
        peso: peso,
      );
      sincronizarSiSePuede();
      // Corregir no reabre el flujo de sanidad (pesaje ya cerrado).
      _mostrar(
        'Pesaje corregido: ${animal.identificador} — ${_pesoFmt(peso)} kg',
      );
      _identCtrl.clear();
      _pesoCtrl.clear();
      _identFocus.requestFocus();
      return;
    }

    await widget.pesajesRepository.agregarPesaje(
      animalId: animal.id,
      peso: peso,
      registradoPor: widget.usuarioId,
    );
    sincronizarSiSePuede();
    _exito(
      animal,
      peso,
      'Pesaje: ${animal.identificador} — ${_pesoFmt(peso)} kg',
    );
  }

  Future<void> _animalNuevo(String ident, double peso) async {
    final lotes = await widget.lotesRepository.lotesActivos(widget.finca.id);
    if (!mounted) return;

    if (lotes.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Animal nuevo'),
          content: Text(
            'El animal "$ident" no existe y esta finca no tiene lotes. '
            'Creá un lote primero en Lotes.',
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

    final alta = await showModalBottomSheet<_AltaAnimal>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _AltaAnimalSheet(
        identificador: ident,
        pesoInicial: peso,
        lotes: lotes,
      ),
    );
    if (alta == null) return;

    await widget.pesajesRepository.crearAnimalConPesaje(
      fincaId: widget.finca.id,
      loteId: alta.loteId,
      identificador: ident,
      peso: alta.pesoCompra,
      registradoPor: widget.usuarioId,
      pesoCompra: alta.nacioEnFinca ? null : alta.pesoCompra,
      precioKgCompra: alta.nacioEnFinca ? 0 : alta.precioKgCompra,
      precioCompra: alta.nacioEnFinca
          ? 0
          : alta.pesoCompra * (alta.precioKgCompra ?? 0),
    );
    sincronizarSiSePuede();

    final animal = await widget.pesajesRepository.buscarAnimalActivo(
      widget.finca.id,
      ident,
    );
    if (animal == null) return;
    _exito(
      animal,
      alta.pesoCompra,
      'Animal "$ident" registrado · ${_pesoFmt(alta.pesoCompra)} kg',
    );
  }

  void _exito(AnimalRow animal, double peso, String mensaje) {
    _mostrar(mensaje);
    setState(() {
      _ultimoAnimal = animal;
      _ultimoPeso = peso;
    });
    _identCtrl.clear();
    _pesoCtrl.clear();
    _identFocus.requestFocus();
  }

  Future<void> _abrirSanidad() async {
    final animal = _ultimoAnimal;
    final peso = _ultimoPeso;
    if (animal == null || peso == null) return;
    await mostrarSanidadAplicarSheet(
      context: context,
      finca: widget.finca,
      animal: animal,
      pesoKg: peso,
      usuarioId: widget.usuarioId,
      sanidadRepository: widget.sanidadRepository,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fabActivo = _ultimoAnimal != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trabajo'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Pesaje · identificador + peso',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('pesaje.sanidadFab'),
        onPressed: fabActivo ? _abrirSanidad : null,
        backgroundColor: fabActivo
            ? theme.colorScheme.secondary
            : theme.colorScheme.surfaceContainerHighest,
        foregroundColor: fabActivo
            ? theme.colorScheme.onSecondary
            : theme.colorScheme.outline,
        icon: const Icon(Icons.add_box_outlined),
        label: const Text('Sanidad'),
        tooltip: fabActivo
            ? 'Aplicar medicamentos a ${_ultimoAnimal!.identificador}'
            : 'Registrá un pesaje primero',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            HatoSpacing.lg,
            HatoSpacing.md,
            HatoSpacing.lg,
            HatoSpacing.lg,
          ),
          child: Column(
            children: [
              ScanField(
                key: const ValueKey('pesaje.animalId'),
                controller: _identCtrl,
                focusNode: _identFocus,
                labelText: 'Identificador (RFID o manual)',
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _pesoFocus.requestFocus(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/iconos/arete.png',
                    width: 24,
                    height: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: HatoSpacing.md),
              QuickNumberField(
                key: const ValueKey('pesaje.weight'),
                controller: _pesoCtrl,
                focusNode: _pesoFocus,
                labelText: 'Peso',
                suffixText: 'kg',
                onSubmitted: (_) => _registrar(),
              ),
              const SizedBox(height: HatoSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('pesaje.submit'),
                  onPressed: _guardando ? null : _registrar,
                  icon: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_guardando ? 'Guardando…' : 'Registrar pesaje'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: HatoSpacing.lg),
              Expanded(
                child: StreamBuilder<List<PesajeHoy>>(
                  stream: widget.pesajesRepository.observarPesajesDelDia(
                    widget.finca.id,
                    _inicioDeHoy,
                  ),
                  builder: (context, snapshot) {
                    final pesajes = snapshot.data ?? const [];
                    return _PesajesDeHoy(pesajes: pesajes);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AltaAnimal {
  const _AltaAnimal({
    required this.loteId,
    required this.pesoCompra,
    required this.nacioEnFinca,
    this.precioKgCompra,
  });

  final String loteId;
  final double pesoCompra;
  final bool nacioEnFinca;
  final double? precioKgCompra;
}

class _AltaAnimalSheet extends StatefulWidget {
  const _AltaAnimalSheet({
    required this.identificador,
    required this.pesoInicial,
    required this.lotes,
  });

  final String identificador;
  final double pesoInicial;
  final List<LoteRow> lotes;

  @override
  State<_AltaAnimalSheet> createState() => _AltaAnimalSheetState();
}

class _AltaAnimalSheetState extends State<_AltaAnimalSheet> {
  late final _pesoCtrl = TextEditingController(
    text: widget.pesoInicial == widget.pesoInicial.roundToDouble()
        ? widget.pesoInicial.toInt().toString()
        : widget.pesoInicial.toString(),
  );
  final _precioKgCtrl = TextEditingController();
  bool _nacioEnFinca = false;
  String? _loteId;

  @override
  void initState() {
    super.initState();
    _pesoCtrl.addListener(() => setState(() {}));
    _precioKgCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pesoCtrl.dispose();
    _precioKgCtrl.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    if (v == null || v < 0) return null;
    return v;
  }

  double? get _peso => _parse(_pesoCtrl);
  double? get _precioKg => _parse(_precioKgCtrl);
  double? get _totalCompra {
    if (_nacioEnFinca) return 0;
    final p = _peso;
    final kg = _precioKg;
    if (p == null || kg == null) return null;
    return p * kg;
  }

  void _continuar() {
    FocusScope.of(context).unfocus();
    final loteId = _loteId;
    if (loteId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Elegí el lote')));
      return;
    }
    final peso = _nacioEnFinca ? widget.pesoInicial : _peso;
    if (peso == null || peso <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Peso de compra inválido')));
      return;
    }
    double? precioKg;
    if (!_nacioEnFinca) {
      precioKg = _precioKg;
      if (precioKg == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Precio por kilo o marcá “nació”')),
        );
        return;
      }
    }
    Navigator.pop(
      context,
      _AltaAnimal(
        loteId: loteId,
        pesoCompra: peso,
        nacioEnFinca: _nacioEnFinca,
        precioKgCompra: precioKg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final total = _totalCompra;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Animal nuevo · ${widget.identificador}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Solo lo mínimo para registrarlo',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: HatoSpacing.lg),
              Text('Lote', style: theme.textTheme.titleSmall),
              const SizedBox(height: HatoSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final l in widget.lotes)
                    ChoiceChip(
                      key: ValueKey('pesaje.loteNombre.${l.nombre}'),
                      selected: _loteId == l.id,
                      label: Text(
                        l.numero == null
                            ? l.nombre
                            : '${l.numero} · ${l.nombre}',
                      ),
                      onSelected: (_) => setState(() => _loteId = l.id),
                    ),
                ],
              ),
              const SizedBox(height: HatoSpacing.lg),
              SwitchListTile(
                key: const ValueKey('pesaje.alta.nacio'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Nació en la finca'),
                subtitle: const Text('Compra ₡0'),
                value: _nacioEnFinca,
                onChanged: (v) => setState(() => _nacioEnFinca = v),
              ),
              if (!_nacioEnFinca) ...[
                const SizedBox(height: HatoSpacing.sm),
                QuickNumberField(
                  key: const ValueKey('pesaje.alta.pesoCompra'),
                  controller: _pesoCtrl,
                  labelText: 'Peso de compra',
                  suffixText: 'kg',
                ),
                const SizedBox(height: HatoSpacing.md),
                QuickNumberField(
                  key: const ValueKey('pesaje.alta.precioKg'),
                  controller: _precioKgCtrl,
                  labelText: 'Precio por kilo',
                  suffixText: '₡/kg',
                ),
              ],
              if (total != null) ...[
                const SizedBox(height: HatoSpacing.md),
                Text(
                  key: const ValueKey('pesaje.alta.costoTotal'),
                  'Costo del animal: ₡${total == total.roundToDouble() ? total.toInt() : total.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: HatoSpacing.xl),
              FilledButton(
                key: const ValueKey('pesaje.alta.guardar'),
                onPressed: _continuar,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Registrar animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PesajesDeHoy extends StatelessWidget {
  const _PesajesDeHoy({required this.pesajes});

  final List<PesajeHoy> pesajes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAnimales = pesajes.map((p) => p.identificador).toSet().length;

    if (pesajes.isEmpty) {
      return Center(
        child: Text(
          'Acá aparecen los animales que peses hoy.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    final lotesOrden = <String>[];
    final nombres = <String, String>{};
    final porLote = <String, List<PesajeHoy>>{};
    for (final p in pesajes) {
      if (!porLote.containsKey(p.loteId)) {
        porLote[p.loteId] = [];
        lotesOrden.add(p.loteId);
        nombres[p.loteId] = p.loteNombre;
      }
      porLote[p.loteId]!.add(p);
    }

    return DefaultTabController(
      key: ValueKey(lotesOrden.join(',')),
      length: lotesOrden.length,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hoy',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                key: const ValueKey('pesaje.contador'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalAnimales pesados',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: HatoSpacing.sm),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [for (final id in lotesOrden) Tab(text: nombres[id])],
          ),
          const SizedBox(height: HatoSpacing.sm),
          Expanded(
            child: TabBarView(
              children: [
                for (final id in lotesOrden) _TablaLote(filas: porLote[id]!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TablaLote extends StatelessWidget {
  const _TablaLote({required this.filas});

  final List<PesajeHoy> filas;

  String _fmt(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);

  String _fmtGmd(double? g) {
    if (g == null) return '—';
    return g.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget celdaEncabezado(String t, {TextAlign align = TextAlign.start}) =>
        Text(
          t,
          textAlign: align,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: celdaEncabezado('Animal')),
              Expanded(
                flex: 2,
                child: celdaEncabezado('Peso', align: TextAlign.end),
              ),
              Expanded(
                flex: 2,
                child: celdaEncabezado('Gan.', align: TextAlign.end),
              ),
              Expanded(
                flex: 2,
                child: celdaEncabezado('GMD', align: TextAlign.end),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final f = filas[i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        f.identificador,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _fmt(f.peso),
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _ValorGanancia(
                        valor: f.ganancia,
                        esEntrada: f.ganancia == null,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _fmtGmd(f.gananciaDiaria),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ValorGanancia extends StatelessWidget {
  const _ValorGanancia({required this.valor, required this.esEntrada});

  final double? valor;
  final bool esEntrada;

  String _fmt(double p) {
    final abs = p.abs();
    return abs == abs.roundToDouble()
        ? abs.toInt().toString()
        : abs.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (esEntrada) {
      return Text(
        'Entrada',
        textAlign: TextAlign.end,
        style: TextStyle(fontSize: 13, color: theme.colorScheme.outline),
      );
    }
    if (valor == null) {
      return Text(
        '—',
        textAlign: TextAlign.end,
        style: TextStyle(fontSize: 14, color: theme.colorScheme.outline),
      );
    }

    const verde = Color(0xFF2E7D32);
    const rojo = Color(0xFFC62828);
    final v = valor!;
    final color = v > 0
        ? verde
        : v < 0
        ? rojo
        : theme.colorScheme.outline;
    final signo = v > 0
        ? '+'
        : v < 0
        ? '-'
        : '';

    return Text(
      '$signo${_fmt(v)}',
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
    );
  }
}
