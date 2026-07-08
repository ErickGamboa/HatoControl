import 'package:flutter/material.dart';

import '../app/widgets/quick_number_field.dart';
import '../app/widgets/scan_field.dart';
import '../data/local/database.dart';
import '../data/repositories/lotes_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../lotes/animal_ficha_screen.dart';
import '../sanidad/sanidad_form_dialog.dart';
import '../services.dart';
import 'corral_lote_batch_sheet.dart';

/// Pantalla de trabajo unificada: escanear arete → pesaje, sanidad, mover (3c).
class CorralScreen extends StatefulWidget {
  CorralScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
    PesajesRepository? pesajesRepository,
    SanidadRepository? sanidadRepository,
    LotesRepository? lotesRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       sanidadRepository = sanidadRepository ?? sanidadRepo,
       lotesRepository = lotesRepository ?? lotesRepo;

  final FincaRow finca;
  final String usuarioId;
  final PesajesRepository pesajesRepository;
  final SanidadRepository sanidadRepository;
  final LotesRepository lotesRepository;

  @override
  State<CorralScreen> createState() => _CorralScreenState();
}

class _CorralScreenState extends State<CorralScreen> {
  final _identCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _identFocus = FocusNode();
  final _pesoFocus = FocusNode();

  AnimalRow? _animal;
  String? _loteNombre;
  double? _pesoActual;
  EventoSanitarioRow? _ultimoEvento;
  bool _guardando = false;
  int _buscarSeq = 0;

  @override
  void dispose() {
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

  double? _parsePeso() {
    final raw = _pesoCtrl.text.trim().replaceAll(',', '.');
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return null;
    return v;
  }

  String _fmt(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toString();

  Future<void> _buscarAnimal() async {
    final ident = _identCtrl.text.trim();
    final seq = ++_buscarSeq;
    if (ident.isEmpty) {
      setState(() {
        _animal = null;
        _loteNombre = null;
        _pesoActual = null;
        _ultimoEvento = null;
      });
      return;
    }

    final animal = await widget.pesajesRepository.buscarAnimal(
      widget.finca.id,
      ident,
    );
    if (!mounted || seq != _buscarSeq) return;

    if (animal == null) {
      setState(() {
        _animal = null;
        _loteNombre = null;
        _pesoActual = null;
        _ultimoEvento = null;
      });
      return;
    }

    final lotes = await widget.lotesRepository.lotesActivos(widget.finca.id);
    final lote = lotes.where((l) => l.id == animal.loteId).firstOrNull;
    final peso = await widget.pesajesRepository.ultimoPeso(animal.id);
    final ultimo = await widget.sanidadRepository.ultimoEvento(animal.id);
    if (!mounted || seq != _buscarSeq) return;

    setState(() {
      _animal = animal;
      _loteNombre = lote?.nombre;
      _pesoActual = peso;
      _ultimoEvento = ultimo;
    });
  }

  Future<void> _registrarPesaje() async {
    final ident = _identCtrl.text.trim();
    final peso = _parsePeso();
    if (ident.isEmpty) {
      _snack('Ingresá el identificador del animal.');
      _identFocus.requestFocus();
      return;
    }
    if (peso == null) {
      _snack('Ingresá un peso válido (kg).');
      _pesoFocus.requestFocus();
      return;
    }

    setState(() => _guardando = true);
    try {
      var animal = _animal;
      if (animal == null || animal.identificador != ident) {
        animal = await widget.pesajesRepository.buscarAnimalActivo(
          widget.finca.id,
          ident,
        );
      }

      if (animal != null) {
        await widget.pesajesRepository.agregarPesaje(
          animalId: animal.id,
          peso: peso,
          registradoPor: widget.usuarioId,
        );
        sincronizarSiSePuede();
        _exito('Pesaje: $ident — ${_fmt(peso)} kg');
        await _buscarAnimal();
      } else {
        await _animalNuevo(ident, peso);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _animalNuevo(String ident, double peso) async {
    final lotes = await widget.lotesRepository.lotesActivos(widget.finca.id);
    if (!mounted) return;
    if (lotes.isEmpty) {
      _snack('Creá un lote antes de registrar animales nuevos.');
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
                'Animal "$ident" es nuevo. ¿En qué lote?',
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
                      title: Text(l.nombre),
                      onTap: () => Navigator.pop(ctx, l.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (loteId == null) return;

    await widget.pesajesRepository.crearAnimalConPesaje(
      fincaId: widget.finca.id,
      loteId: loteId,
      identificador: ident,
      peso: peso,
      registradoPor: widget.usuarioId,
    );
    sincronizarSiSePuede();
    _exito('Animal "$ident" creado — ${_fmt(peso)} kg');
    await _buscarAnimal();
  }

  void _exito(String msg) {
    _snack(msg);
    _pesoCtrl.clear();
    _identFocus.requestFocus();
  }

  Future<void> _sanidad() async {
    final animal = _animal;
    if (animal == null || animal.estado != EstadoAnimal.activo) {
      _snack('Buscá un animal activo primero.');
      return;
    }
    final sugerencias = await widget.sanidadRepository.sugerenciasProducto(
      widget.finca.id,
    );
    if (!mounted) return;
    final datos = await mostrarFormularioSanidad(
      context,
      titulo: 'Sanidad · ${animal.identificador}',
      sugerenciasProducto: sugerencias,
    );
    if (datos == null) return;
    await widget.sanidadRepository.registrarEvento(
      animalId: animal.id,
      tipo: datos.tipo,
      producto: datos.producto,
      dosis: datos.dosis,
      observaciones: datos.observaciones,
      costo: datos.costo,
      responsableId: widget.usuarioId,
    );
    sincronizarSiSePuede();
    _snack('Sanidad registrada.');
    await _buscarAnimal();
  }

  Future<void> _repetirUltimo() async {
    final animal = _animal;
    if (animal == null || animal.estado != EstadoAnimal.activo) {
      _snack('Buscá un animal activo primero.');
      return;
    }
    final ok = await widget.sanidadRepository.repetirUltimoEvento(
      animalId: animal.id,
      responsableId: widget.usuarioId,
    );
    if (!ok) {
      _snack('Este animal no tiene tratamientos previos.');
      return;
    }
    sincronizarSiSePuede();
    _snack('Tratamiento repetido.');
    await _buscarAnimal();
  }

  Future<void> _moverLote() async {
    final animal = _animal;
    if (animal == null || animal.estado != EstadoAnimal.activo) {
      _snack('Buscá un animal activo primero.');
      return;
    }
    final lotes = await widget.lotesRepository.lotesActivos(widget.finca.id);
    if (!mounted) return;
    final destino = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Mover a lote'),
            ),
            for (final l in lotes)
              if (l.id != animal.loteId)
                ListTile(
                  title: Text(l.nombre),
                  onTap: () => Navigator.pop(ctx, l.id),
                ),
          ],
        ),
      ),
    );
    if (destino == null) return;
    await widget.pesajesRepository.moverAnimalDeLote(
      animalId: animal.id,
      nuevoLoteId: destino,
    );
    sincronizarSiSePuede();
    _snack('Animal movido de lote.');
    await _buscarAnimal();
  }

  Future<void> _batchLote() async {
    await mostrarBatchSanidadCorral(
      context,
      fincaId: widget.finca.id,
      lotesRepository: widget.lotesRepository,
      sanidadRepository: widget.sanidadRepository,
      responsableId: widget.usuarioId,
    );
  }

  void _abrirFicha() {
    final animal = _animal;
    if (animal == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AnimalFichaScreen(animal: animal, usuarioId: widget.usuarioId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animal = _animal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Corral'),
        actions: [
          IconButton(
            key: const ValueKey('corral.batchLote'),
            tooltip: 'Tratamiento al lote',
            icon: const Icon(Icons.vaccines_outlined),
            onPressed: _batchLote,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScanField(
                key: const ValueKey('corral.animalId'),
                controller: _identCtrl,
                focusNode: _identFocus,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _buscarAnimal(),
                onSubmitted: (_) => _pesoFocus.requestFocus(),
                labelText: 'Arete / identificador',
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
              const SizedBox(height: 12),
              QuickNumberField(
                key: const ValueKey('corral.weight'),
                controller: _pesoCtrl,
                focusNode: _pesoFocus,
                labelText: 'Peso (kg)',
                suffixText: 'kg',
                onSubmitted: (_) => _registrarPesaje(),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const ValueKey('corral.submitPeso'),
                onPressed: _guardando ? null : _registrarPesaje,
                icon: const Icon(Icons.check),
                label: const Text('Registrar peso'),
              ),
              const SizedBox(height: 16),
              if (animal != null)
                Card(
                  key: const ValueKey('corral.animalCard'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                animal.identificador,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (animal.estado != EstadoAnimal.activo)
                              Chip(
                                label: Text(animal.estado),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                        Text(
                          'Lote: ${_loteNombre ?? '—'} · '
                          'Peso: ${_pesoActual != null ? '${_fmt(_pesoActual!)} kg' : '—'}',
                        ),
                        if (_ultimoEvento != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Último: ${_ultimoEvento!.producto} '
                              '(${TipoEventoSanitario.etiqueta(_ultimoEvento!.tipo)})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (animal.estado == EstadoAnimal.activo) ...[
                              FilledButton.tonalIcon(
                                key: const ValueKey('corral.sanidad'),
                                onPressed: _sanidad,
                                icon: const Icon(
                                  Icons.medical_services_outlined,
                                ),
                                label: const Text('Sanidad'),
                              ),
                              if (_ultimoEvento != null)
                                FilledButton.tonalIcon(
                                  key: const ValueKey('corral.repetir'),
                                  onPressed: _repetirUltimo,
                                  icon: const Icon(Icons.replay),
                                  label: const Text('Repetir último'),
                                ),
                              OutlinedButton.icon(
                                key: const ValueKey('corral.mover'),
                                onPressed: _moverLote,
                                icon: const Icon(Icons.swap_horiz),
                                label: const Text('Mover lote'),
                              ),
                            ],
                            TextButton.icon(
                              onPressed: _abrirFicha,
                              icon: const Icon(Icons.pets_outlined),
                              label: const Text('Hoja de vida'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else if (_identCtrl.text.trim().isNotEmpty)
                Text(
                  'Animal no encontrado — al registrar peso se creará si elegís lote.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
