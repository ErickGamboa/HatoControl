import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/local/database.dart';
import '../services.dart';

/// Registro de pesajes. Se ingresa el identificador (arete) y el peso.
/// Si el animal no existe, se pide elegir el lote y se crea con ese peso.
/// El identificador se puede escribir a mano o lo "teclea" el lector RFID
/// (modo HID) cuando este campo está enfocado.
class PesajeScreen extends StatefulWidget {
  const PesajeScreen({super.key, required this.finca});

  final FincaRow finca;

  @override
  State<PesajeScreen> createState() => _PesajeScreenState();
}

/// Una fila de la tabla de la sesión de pesaje.
class _FilaPesaje {
  _FilaPesaje({required this.ident, required this.peso, required this.ganancia});
  final String ident;
  final double peso;
  final double? ganancia; // null = animal nuevo (peso de entrada)
}

class _PesajeScreenState extends State<PesajeScreen> {
  final _identCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _identFocus = FocusNode();
  final _pesoFocus = FocusNode();
  bool _guardando = false;

  // Pesajes registrados en esta sesión (el más reciente arriba).
  final List<_FilaPesaje> _sesion = [];

  String get _usuarioId => supabase.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    // Al enfocar el campo de ID, seleccionar todo: así un nuevo escaneo del
    // lector reemplaza el valor anterior completo (no se pega al final).
    _identFocus.addListener(_seleccionarTodoId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _identFocus.requestFocus();
    });
  }

  void _seleccionarTodoId() {
    if (_identFocus.hasFocus && _identCtrl.text.isNotEmpty) {
      _identCtrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _identCtrl.text.length,
      );
    }
  }

  @override
  void dispose() {
    _identFocus.removeListener(_seleccionarTodoId);
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

  double? _parsePeso() {
    final raw = _pesoCtrl.text.trim().replaceAll(',', '.');
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
      _mostrar('Ingresá el identificador del animal.');
      _identFocus.requestFocus();
      return;
    }
    if (peso == null) {
      _mostrar('Ingresá un peso válido (kg).');
      _pesoFocus.requestFocus();
      return;
    }

    setState(() => _guardando = true);
    try {
      final animal = await pesajesRepo.buscarAnimal(widget.finca.id, ident);
      if (animal != null) {
        final anterior = await pesajesRepo.ultimoPeso(animal.id);
        await pesajesRepo.agregarPesaje(
          animalId: animal.id,
          peso: peso,
          registradoPor: _usuarioId,
        );
        syncService.sincronizar();
        _agregarFila(_FilaPesaje(
          ident: ident,
          peso: peso,
          ganancia: anterior == null ? null : peso - anterior,
        ));
        _exito('Pesaje registrado: $ident — ${_pesoFmt(peso)} kg');
      } else {
        await _animalNuevo(ident, peso);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _agregarFila(_FilaPesaje fila) {
    setState(() => _sesion.insert(0, fila));
  }

  Future<void> _animalNuevo(String ident, double peso) async {
    final lotes = await lotesRepo.lotesActivos(widget.finca.id);
    if (!mounted) return;

    if (lotes.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Animal nuevo'),
          content: Text(
            'El animal "$ident" no existe y esta finca no tiene lotes. '
            'Creá un lote primero en la sección Lotes.',
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

    final loteId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'El animal "$ident" es nuevo. ¿En qué lote lo ponés?',
                style: Theme.of(ctx).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final l in lotes)
                    ListTile(
                      leading: CircleAvatar(
                        child: Text(l.numero?.toString() ?? '–'),
                      ),
                      title: Text(l.nombre),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(ctx, l.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (loteId == null) return; // canceló
    await pesajesRepo.crearAnimalConPesaje(
      fincaId: widget.finca.id,
      loteId: loteId,
      identificador: ident,
      peso: peso,
      registradoPor: _usuarioId,
    );
    syncService.sincronizar();
    // Animal nuevo: su primer pesaje es el de entrada (sin ganancia previa).
    _agregarFila(_FilaPesaje(ident: ident, peso: peso, ganancia: null));
    _exito('Animal "$ident" creado y pesado: ${_pesoFmt(peso)} kg');
  }

  void _exito(String mensaje) {
    _mostrar(mensaje);
    _identCtrl.clear();
    _pesoCtrl.clear();
    _identFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesaje')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _identCtrl,
                focusNode: _identFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _pesoFocus.requestFocus(),
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'Identificador del animal (arete)',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/iconos/arete.png',
                        width: 24,
                        height: 24,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pesoCtrl,
                focusNode: _pesoFocus,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _registrar(),
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'Peso',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset('assets/iconos/peso.png',
                        width: 24,
                        height: 24,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  suffixText: 'kg',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _guardando ? null : _registrar,
                  icon: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Registrar pesaje'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: _TablaSesion(filas: _sesion)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tabla de la sesión de pesaje: ID, peso y ganancia (vs. peso anterior).
/// Abajo muestra la cantidad de animales pesados.
class _TablaSesion extends StatelessWidget {
  const _TablaSesion({required this.filas});

  final List<_FilaPesaje> filas;

  String _fmt(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (filas.isEmpty) {
      return Center(
        child: Text(
          'Acá aparecerán los animales que vayas pesando.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.outline),
        ),
      );
    }

    // Cantidad de animales (distintos) pesados en la sesión.
    final cantidad = filas.map((f) => f.ident).toSet().length;

    Widget celdaEncabezado(String t, {TextAlign align = TextAlign.start}) =>
        Text(t,
            textAlign: align,
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.bold));

    return Column(
      children: [
        // Encabezado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Row(
            children: [
              Expanded(flex: 4, child: celdaEncabezado('Animal')),
              Expanded(
                  flex: 3,
                  child:
                      celdaEncabezado('Peso (kg)', align: TextAlign.end)),
              Expanded(
                  flex: 3,
                  child:
                      celdaEncabezado('Ganancia', align: TextAlign.end)),
            ],
          ),
        ),
        // Filas
        Expanded(
          child: ListView.separated(
            itemCount: filas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final f = filas[i];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(f.ident,
                          style: const TextStyle(fontSize: 16)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(_fmt(f.peso),
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 16)),
                    ),
                    Expanded(flex: 3, child: _Ganancia(valor: f.ganancia)),
                  ],
                ),
              );
            },
          ),
        ),
        // Total
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(10)),
          ),
          child: Text(
            'Animales pesados: $cantidad',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

/// Muestra la ganancia: verde si subió, rojo si bajó, gris "Entrada" si es nuevo.
class _Ganancia extends StatelessWidget {
  const _Ganancia({required this.valor});

  final double? valor;

  String _fmt(double p) {
    final abs = p.abs();
    final s = abs == abs.roundToDouble()
        ? abs.toInt().toString()
        : abs.toStringAsFixed(1);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (valor == null) {
      return Text('Entrada',
          textAlign: TextAlign.end,
          style: TextStyle(fontSize: 15, color: theme.colorScheme.outline));
    }
    const verde = Color(0xFF2E7D32);
    const rojo = Color(0xFFC62828);
    final v = valor!;
    if (v == 0) {
      return Text('0 kg',
          textAlign: TextAlign.end,
          style: TextStyle(fontSize: 16, color: theme.colorScheme.outline));
    }
    final positivo = v > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(positivo ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16, color: positivo ? verde : rojo),
        const SizedBox(width: 2),
        Text(
          '${_fmt(v)} kg',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: positivo ? verde : rojo,
          ),
        ),
      ],
    );
  }
}
