import 'dart:async';

import 'package:flutter/material.dart';

import '../app/widgets/boton_sincronizar.dart';
import 'package:flutter/services.dart';

import '../app/teclado/lector_de_aretes.dart';
import '../app/theme.dart';
import '../app/widgets/campo_fecha.dart';
import '../app/widgets/quick_number_field.dart';
import '../app/widgets/campo_animal.dart';
import '../data/local/database.dart';
import '../data/repositories/lotes_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/reglas_de_fechas.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
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
    VentasRepository? ventasRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       lotesRepository = lotesRepository ?? lotesRepo,
       sanidadRepository = sanidadRepository ?? sanidadRepo,
       ventasRepository = ventasRepository ?? ventasRepo;

  final FincaRow finca;
  final String usuarioId;
  final PesajesRepository pesajesRepository;
  final LotesRepository lotesRepository;
  final SanidadRepository sanidadRepository;

  /// Para corregir la compra (₡/kg) desde la mesa de trabajo.
  final VentasRepository ventasRepository;

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

  /// Fecha de la jornada: el día en que de verdad se pesó. Hoy por defecto;
  /// el patrón la cambia una vez para pasar la hoja que le dejó el peón, y
  /// todo lo que digite queda con ese día. Al volver a entrar es hoy otra vez.
  DateTime _fecha = DateTime.now();

  bool get _esHoy => mismoDia(_fecha, DateTime.now());

  DateTime get _inicioDeHoy {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<void> _cambiarFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(hoy.year - 5),
      lastDate: hoy,
      helpText: '¿Qué día se pesó?',
    );
    _soltarElFoco();
    if (elegida == null || !mounted) return;
    setState(() => _fecha = mismoDia(elegida, hoy) ? hoy : elegida);
  }

  /// Stream de la lista del día, creado UNA sola vez. Si se armara dentro de
  /// `build` el StreamBuilder se resuscribiría en cada frame y la pantalla
  /// entraría en un ciclo de reconstrucciones sin fin.
  late final Stream<List<PesajeHoy>> _pesajesDelDia = widget.pesajesRepository
      .observarPesajesDelDia(widget.finca.id, _inicioDeHoy);

  /// Los animales para el buscador del campo del arete.
  late final Stream<List<AnimalBuscable>> _buscables = widget.pesajesRepository
      .observarBuscables(widget.finca.id)
      .asBroadcastStream();

  /// El lector escribe en el campo del arete sin necesidad de que ese campo
  /// tenga el foco: ningún campo de la app toma el foco solo.
  late final _lector = LectorDeAretes(
    campo: _identCtrl,
    // El campo del arete recibe solo cuando lo tiene; el del peso es del
    // ganadero. Con una hoja o un diálogo abierto manda lo que esté arriba.
    puedeLeer: () =>
        mounted &&
        !_identFocus.hasFocus &&
        !_pesoFocus.hasFocus &&
        ModalRoute.of(context)?.isCurrent == true,
    alTerminarLaLectura: () {
      if (mounted) _pesoFocus.requestFocus();
    },
  );

  @override
  void initState() {
    super.initState();
    _lector.escuchar();
  }

  @override
  void dispose() {
    _lector.soltar();
    _identCtrl.dispose();
    _pesoCtrl.dispose();
    _identFocus.dispose();
    _pesoFocus.dispose();
    super.dispose();
  }

  /// Confirmación que se siente: en un corral con ruido la vibración es lo que
  /// se nota, y si no vibró es que no quedó registrado.
  void _avisarRegistrado() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Suelta el foco: ni el arete ni el peso quedan activos, así que no sale
  /// ningún teclado y el lector vuelve a entrar por la pantalla entera. Se
  /// llama al volver de cualquier hoja o diálogo y después de registrar.
  void _soltarElFoco() {
    if (mounted) FocusScope.of(context).unfocus();
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
      return;
    }
    if (peso == null && _pesoCtrl.text.trim().isNotEmpty) {
      _mostrar('Ese peso no es válido.');
      return;
    }

    setState(() => _guardando = true);
    try {
      var animal = await widget.pesajesRepository.buscarActivoPorIdOAlias(
        widget.finca.id,
        ident,
      );
      if (animal == null) {
        // Unos dígitos del final o un pedazo del alias: que escoja cuál, o
        // que confirme que de verdad es uno nuevo.
        final eleccion = await _escogerEntreParecidos(ident);
        if (eleccion == null) return;
        if (eleccion.animalId != null) {
          animal = await widget.pesajesRepository.buscarAnimalActivo(
            widget.finca.id,
            eleccion.identificador!,
          );
        }
      }
      if (animal == null && !RegExp(r'^\d+$').hasMatch(ident)) {
        _mostrar('No hay un animal con el arete o alias "$ident".');
        return;
      }
      if (animal != null) {
        // Un animal que ya existe solo se registra para pesarlo.
        if (peso == null) {
          _mostrar('Ingresá el peso (kg).');
          return;
        }
        await _pesarExistente(animal, peso);
      } else {
        // Uno nuevo puede entrar sin pesar: el peso se le pone después.
        await _animalNuevo(ident, peso);
      }
    } on FechaInvalidaException catch (e) {
      if (mounted) await avisarFechaInvalida(context, e.mensaje);
    } on AliasEnUsoException catch (e) {
      _mostrar('${e.mensaje} No se registró el animal.');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  /// Lo digitado no es el arete ni el alias de ningún animal. Si hay animales
  /// que se le parecen, se pregunta cuál es (o si es uno nuevo). Devuelve
  /// null si canceló, `_Eleccion.nuevo` si no hay parecidos o dijo que es
  /// nuevo, o el animal escogido.
  Future<_Eleccion?> _escogerEntreParecidos(String ident) async {
    final parecidos = sugerencias(
      await widget.pesajesRepository.buscables(widget.finca.id),
      ident,
    );
    if (parecidos.isEmpty || !mounted) return const _Eleccion.nuevo();
    final esNumero = RegExp(r'^\d+$').hasMatch(ident);
    setState(() => _guardando = false);
    final r = await showDialog<_Eleccion>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Cuál es "$ident"?'),
        contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final a in parecidos)
                ListTile(
                  key: ValueKey('pesaje.parecido.${a.identificador}'),
                  title: Text(
                    a.identificador,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    [if (a.alias != null) a.alias!, a.loteNombre].join(' · '),
                  ),
                  onTap: () => Navigator.pop(
                    ctx,
                    _Eleccion(animalId: a.id, identificador: a.identificador),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          if (esNumero)
            TextButton(
              key: const ValueKey('pesaje.parecido.nuevo'),
              onPressed: () => Navigator.pop(ctx, const _Eleccion.nuevo()),
              child: Text('Es nuevo: $ident'),
            ),
        ],
      ),
    );
    _soltarElFoco();
    if (mounted) setState(() => _guardando = true);
    return r;
  }

  Future<void> _pesarExistente(AnimalRow animal, double peso) async {
    final hoy = await widget.pesajesRepository.pesajeDeHoy(
      animal.id,
      dia: _fecha,
    );
    if (hoy != null) {
      if (!mounted) return;
      final cuando = _esHoy ? 'hoy' : 'el ${fmtFecha(_fecha)}';
      final corregir = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_esHoy ? 'Ya se pesó hoy' : 'Ya se pesó ese día'),
          content: Text(
            'El animal "${animal.identificador}" ya tiene '
            '${_pesoFmt(hoy.peso)} kg registrados $cuando.\n\n'
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
      _soltarElFoco();
      return;
    }

    await widget.pesajesRepository.agregarPesaje(
      animalId: animal.id,
      peso: peso,
      registradoPor: widget.usuarioId,
      fecha: _fecha,
    );
    sincronizarSiSePuede();
    _exito(
      animal,
      peso,
      'Pesaje: ${animal.identificador} — ${_pesoFmt(peso)} kg'
      '${_esHoy ? '' : ' (${fmtFecha(_fecha)})'}',
    );
  }

  Future<void> _animalNuevo(String ident, double? peso) async {
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

    // Mientras el ganadero llena la hoja no se está guardando nada: el botón
    // no debe quedar dando vueltas detrás.
    setState(() => _guardando = false);
    final alta = await showModalBottomSheet<_AltaAnimal>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _AltaAnimalSheet(
        identificador: ident,
        pesoInicial: peso,
        lotes: lotes,
        fecha: _fecha,
      ),
    );
    _soltarElFoco();
    if (alta == null || !mounted) return;
    setState(() => _guardando = true);

    final nacio = alta.modo == _ModoCompra.nacio;
    await widget.pesajesRepository.crearAnimalConPesaje(
      fincaId: widget.finca.id,
      loteId: alta.loteId,
      identificador: ident,
      peso: alta.peso,
      registradoPor: widget.usuarioId,
      fecha: _fecha,
      alias: alta.alias,
      pesoCompra: nacio ? null : alta.peso,
      precioKgCompra: switch (alta.modo) {
        _ModoCompra.nacio => 0,
        _ModoCompra.porKilo => alta.precioKgCompra,
        _ModoCompra.montoTotal => null,
      },
      precioCompra: switch (alta.modo) {
        _ModoCompra.nacio => 0,
        _ModoCompra.porKilo => alta.peso! * alta.precioKgCompra!,
        _ModoCompra.montoTotal => alta.montoTotal,
      },
    );
    sincronizarSiSePuede();

    final animal = await widget.pesajesRepository.buscarAnimalActivo(
      widget.finca.id,
      ident,
    );
    if (animal == null) return;
    final pesoAlta = alta.peso;
    if (pesoAlta == null) {
      // Sin pesar: no hay peso para la sanidad, el FAB sigue como estaba.
      _avisarRegistrado();
      _mostrar('Animal "$ident" registrado sin peso');
      _identCtrl.clear();
      _pesoCtrl.clear();
      _soltarElFoco();
      return;
    }
    _exito(
      animal,
      pesoAlta,
      'Animal "$ident" registrado · ${_pesoFmt(pesoAlta)} kg',
    );
  }

  void _exito(AnimalRow animal, double peso, String mensaje) {
    _avisarRegistrado();
    _mostrar(mensaje);
    setState(() {
      _ultimoAnimal = animal;
      _ultimoPeso = peso;
    });
    _identCtrl.clear();
    _pesoCtrl.clear();
    _soltarElFoco();
  }

  /// Toca una fila de la lista del día → corregir lote, peso y precio por kilo,
  /// o borrar el pesaje.
  Future<void> _accionesPesaje(PesajeHoy p) async {
    final lotes = await widget.lotesRepository.lotesActivos(widget.finca.id);
    if (!mounted) return;
    final r = await showModalBottomSheet<_CorreccionPesaje>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _CorregirPesajeSheet(
        pesaje: p,
        lotes: lotes,
        pesoInicial: p.peso == null ? '' : _pesoFmt(p.peso!),
      ),
    );
    _soltarElFoco();
    if (r == null) return;
    if (r.eliminar) {
      await _eliminarPesaje(p);
      return;
    }
    try {
      await _guardarCorreccion(p, r);
    } on FechaInvalidaException catch (e) {
      if (mounted) await avisarFechaInvalida(context, e.mensaje);
    }
  }

  /// Aplica solo lo que de verdad cambió: mover de lote, corregir el peso del
  /// día y/o corregir la compra (₡/kg → total). Cada cosa queda pendiente de
  /// sincronizar por su cuenta.
  Future<void> _guardarCorreccion(PesajeHoy p, _CorreccionPesaje r) async {
    final cambios = <String>[];

    if (r.loteId != p.loteId) {
      // Si recién se dio de alta, se corrige el lote de entrada; si ya se
      // había movido antes, es un cambio de lote el día de este pesaje.
      await widget.pesajesRepository.corregirLote(
        animalId: p.animalId,
        nuevoLoteId: r.loteId,
        fecha: p.fecha,
      );
      cambios.add('lote');
    }

    final peso = r.peso;
    if (p.sinPeso && peso != null) {
      // Entró sin peso: este es su primer pesaje, el día que entró. Si se
      // compró por monto total, de acá sale el ₡/kg.
      await widget.pesajesRepository.registrarPesajeEnFecha(
        animalId: p.animalId,
        peso: peso,
        fecha: p.fecha,
        registradoPor: widget.usuarioId,
      );
      cambios.add('peso ${_pesoFmt(peso)} kg');
    } else if (peso != null && peso != p.peso) {
      await widget.pesajesRepository.actualizarPesaje(
        pesajeId: p.id,
        peso: peso,
      );
      cambios.add('peso ${_pesoFmt(peso)} kg');
    }

    if (r.precioKgCompra != null && r.precioKgCompra != p.precioKgCompra) {
      final precioKg = r.precioKgCompra!;
      // ₡0/kg = nació en la finca: `actualizarCompra` limpia peso, total y
      // fecha. Si tiene precio pero nunca tuvo peso de compra, el peso de
      // entrada (primer pesaje) es el que corresponde.
      final pesoCompra = precioKg == 0
          ? null
          : p.pesoCompra ??
                await widget.pesajesRepository.primerPeso(p.animalId);
      await widget.ventasRepository.actualizarCompra(
        animalId: p.animalId,
        pesoCompra: pesoCompra,
        precioKgCompra: precioKg,
        precioCompra: pesoCompra == null ? null : pesoCompra * precioKg,
        // Se respeta la fecha de compra original: cambiarla movería la fecha
        // de ingreso y con ella el prorrateo de gastos fijos.
        fechaCompra: precioKg == 0 ? null : (p.fechaCompra ?? p.fecha),
      );
      cambios.add(
        precioKg == 0 ? 'nació en la finca' : '₡${_pesoFmt(precioKg)}/kg',
      );
    }

    if (cambios.isEmpty) return;
    sincronizarSiSePuede();
    _mostrar('${p.identificador}: ${cambios.join(' · ')}');
  }

  Future<void> _eliminarPesaje(PesajeHoy p) async {
    final esEntrada = p.ganancia == null;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar el pesaje?'),
        content: Text(
          esEntrada
              ? 'Es el pesaje de entrada de "${p.identificador}": si lo '
                    'borrás, el animal queda sin peso registrado.'
              : 'Se borra el pesaje del ${fmtFecha(p.fecha)} de '
                    '"${p.identificador}" (${_pesoFmt(p.peso!)} kg). El animal '
                    'sigue en el lote.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const ValueKey('pesaje.eliminar.confirmar'),
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await widget.pesajesRepository.eliminarPesaje(p.id);
    sincronizarSiSePuede();
    // El FAB de sanidad apunta al último animal pesado: si era este, se apaga.
    if (mounted && _ultimoAnimal?.identificador == p.identificador) {
      setState(() {
        _ultimoAnimal = null;
        _ultimoPeso = null;
      });
    }
    _mostrar('Pesaje de ${p.identificador} eliminado');
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
      fecha: _fecha,
    );
    _soltarElFoco();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fabActivo = _ultimoAnimal != null;

    // Red de seguridad: la finca esconde este módulo a los invitados, pero si
    // alguno llega acá (por historial de navegación) no ve la manga.
    if (permisosFinca.esSoloLectura) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Trabajo'),
          actions: const [BotonSincronizar()],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(HatoSpacing.xl),
            child: Text(
              'Te compartieron esta finca solo para verla: no podés registrar '
              'pesajes ni sanidad.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trabajo'),
        actions: const [BotonSincronizar()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _FechaJornada(
            fecha: _fecha,
            esHoy: _esHoy,
            alTocar: _cambiarFecha,
            alVolverAHoy: () => setState(() => _fecha = DateTime.now()),
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
              CampoAnimal(
                key: const ValueKey('pesaje.animalId'),
                controller: _identCtrl,
                focusNode: _identFocus,
                animales: _buscables,
                labelText: 'Arete o alias',
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _pesoFocus.requestFocus(),
                onSeleccionado: (_) => _pesoFocus.requestFocus(),
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
                  stream: _pesajesDelDia,
                  builder: (context, snapshot) {
                    final pesajes = snapshot.data ?? const [];
                    return _PesajesDeHoy(
                      pesajes: pesajes,
                      onTocarFila: _accionesPesaje,
                    );
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

/// Lo que el ganadero corrigió en la mesa de trabajo. `eliminar` manda: si es
/// true se borra el pesaje y el resto no se mira.
class _CorreccionPesaje {
  const _CorreccionPesaje({
    required this.loteId,
    required this.peso,
    required this.precioKgCompra,
  }) : eliminar = false;

  const _CorreccionPesaje.eliminar()
    : loteId = '',
      peso = 0,
      precioKgCompra = null,
      eliminar = true;

  final String loteId;

  /// null = sigue sin peso (solo para un animal que entró sin pesar).
  final double? peso;

  /// null = el campo quedó vacío, no se toca la compra. 0 = nació en la finca.
  final double? precioKgCompra;
  final bool eliminar;
}

/// Hoja para corregir de un solo golpe lo que se pudo digitar mal en la manga:
/// el lote, el peso del día y el precio por kilo de compra. Dueña de sus
/// controladores (liberarlos desde afuera revienta: el campo todavía los usa).
class _CorregirPesajeSheet extends StatefulWidget {
  const _CorregirPesajeSheet({
    required this.pesaje,
    required this.lotes,
    required this.pesoInicial,
  });

  final PesajeHoy pesaje;
  final List<LoteRow> lotes;
  final String pesoInicial;

  @override
  State<_CorregirPesajeSheet> createState() => _CorregirPesajeSheetState();
}

class _CorregirPesajeSheetState extends State<_CorregirPesajeSheet> {
  late final _pesoCtrl = TextEditingController(text: widget.pesoInicial);
  late final _precioKgCtrl = TextEditingController(
    text: widget.pesaje.precioKgCompra == null
        ? ''
        : _fmt(widget.pesaje.precioKgCompra!),
  );
  late String _loteId = widget.pesaje.loteId;

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  @override
  void initState() {
    super.initState();
    // El total de compra se recalcula mientras escriben el precio.
    _pesoCtrl.addListener(() => setState(() {}));
    _precioKgCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pesoCtrl.dispose();
    _precioKgCtrl.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  /// Kilos con que se compró el animal: los que ya tenía o, si nunca tuvo,
  /// el peso de entrada (que para un animal recién dado de alta es este mismo).
  double? get _pesoCompra => widget.pesaje.pesoCompra ?? _parse(_pesoCtrl);

  double? get _totalCompra {
    final kg = _parse(_precioKgCtrl);
    if (kg == null) return null;
    if (kg == 0) return 0;
    final peso = _pesoCompra;
    return peso == null ? null : peso * kg;
  }

  void _guardar() {
    FocusScope.of(context).unfocus();
    final peso = _parse(_pesoCtrl);
    // Un animal que entró sin peso puede seguir sin peso.
    final sigueSinPeso = widget.pesaje.sinPeso && _pesoCtrl.text.trim().isEmpty;
    if (!sigueSinPeso && (peso == null || peso <= 0)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Peso inválido')));
      return;
    }
    final precioKg = _precioKgCtrl.text.trim().isEmpty
        ? null
        : _parse(_precioKgCtrl);
    if (_precioKgCtrl.text.trim().isNotEmpty &&
        (precioKg == null || precioKg < 0)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Precio por kilo inválido')));
      return;
    }
    Navigator.pop(
      context,
      _CorreccionPesaje(loteId: _loteId, peso: peso, precioKgCompra: precioKg),
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
                widget.pesaje.identificador,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Corregí lo que quedó mal',
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
                      key: ValueKey('pesaje.corregir.lote.${l.nombre}'),
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
              QuickNumberField(
                key: const ValueKey('pesaje.corregir.peso'),
                controller: _pesoCtrl,
                labelText: widget.pesaje.sinPeso
                    ? 'Peso (entró sin pesar)'
                    : 'Peso',
                suffixText: 'kg',
              ),
              const SizedBox(height: HatoSpacing.md),
              QuickNumberField(
                key: const ValueKey('pesaje.corregir.precioKg'),
                controller: _precioKgCtrl,
                labelText: 'Precio por kilo',
                suffixText: '₡/kg',
              ),
              const SizedBox(height: 6),
              Text(
                total == null
                    ? 'Dejalo vacío para no tocar la compra · 0 = nació en la finca'
                    : 'Compra: ₡${_fmt(total)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: HatoSpacing.lg),
              FilledButton.icon(
                key: const ValueKey('pesaje.corregir.guardar'),
                onPressed: _guardar,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Guardar'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!widget.pesaje.sinPeso) ...[
                const SizedBox(height: HatoSpacing.sm),
                TextButton.icon(
                  key: const ValueKey('pesaje.corregir.eliminar'),
                  onPressed: () => Navigator.pop(
                    context,
                    const _CorreccionPesaje.eliminar(),
                  ),
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'Eliminar pesaje',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// La fecha de la jornada, siempre a la vista arriba de la manga. En hoy se
/// ve tranquila; en otro día se pinta de otro color para que no se olvide
/// que se está digitando con fecha atrás, y trae el botón para volver a hoy.
class _FechaJornada extends StatelessWidget {
  const _FechaJornada({
    required this.fecha,
    required this.esHoy,
    required this.alTocar,
    required this.alVolverAHoy,
  });

  final DateTime fecha;
  final bool esHoy;
  final VoidCallback alTocar;
  final VoidCallback alVolverAHoy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fondo = esHoy
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.tertiaryContainer;
    final texto = esHoy
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.onTertiaryContainer;
    return Material(
      color: fondo,
      child: InkWell(
        key: const ValueKey('pesaje.fecha'),
        onTap: alTocar,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: HatoSpacing.lg),
            child: Row(
              children: [
                Icon(Icons.event_outlined, color: texto, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    esHoy
                        ? 'Fecha: hoy, ${fmtFecha(fecha)}'
                        : 'Digitando el ${fmtFecha(fecha)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: texto,
                      fontWeight: esHoy ? FontWeight.w600 : FontWeight.w800,
                    ),
                  ),
                ),
                if (esHoy)
                  Text(
                    'Cambiar',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  TextButton(
                    key: const ValueKey('pesaje.fecha.hoy'),
                    onPressed: alVolverAHoy,
                    child: const Text('Volver a hoy'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Respuesta a "¿cuál es?": un animal que ya existe, o uno nuevo.
class _Eleccion {
  const _Eleccion({required this.animalId, required this.identificador});
  const _Eleccion.nuevo() : animalId = null, identificador = null;

  final String? animalId;
  final String? identificador;
}

/// Cómo se compró el animal que entra.
enum _ModoCompra { porKilo, montoTotal, nacio }

class _AltaAnimal {
  const _AltaAnimal({
    required this.loteId,
    required this.peso,
    required this.modo,
    this.precioKgCompra,
    this.montoTotal,
    this.alias,
  });

  final String loteId;

  /// Peso de entrada. null = entró sin pesar.
  final double? peso;
  final _ModoCompra modo;
  final double? precioKgCompra; // solo por kilo
  final double? montoTotal; // solo monto total

  /// Nombre corto opcional ("Pinta", "23").
  final String? alias;
}

class _AltaAnimalSheet extends StatefulWidget {
  const _AltaAnimalSheet({
    required this.identificador,
    required this.pesoInicial,
    required this.lotes,
    required this.fecha,
  });

  final String identificador;

  /// Lo que marcó la romana. null = se registra sin pesar.
  final double? pesoInicial;
  final List<LoteRow> lotes;

  /// Fecha de la jornada: el día en que entra.
  final DateTime fecha;

  @override
  State<_AltaAnimalSheet> createState() => _AltaAnimalSheetState();
}

class _AltaAnimalSheetState extends State<_AltaAnimalSheet> {
  late final _pesoCtrl = TextEditingController(
    text: switch (widget.pesoInicial) {
      null => '',
      final p => p == p.roundToDouble() ? p.toInt().toString() : p.toString(),
    },
  );
  final _precioKgCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  _ModoCompra _modo = _ModoCompra.porKilo;
  String? _loteId;

  @override
  void initState() {
    super.initState();
    _pesoCtrl.addListener(() => setState(() {}));
    _precioKgCtrl.addListener(() => setState(() {}));
    _montoCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pesoCtrl.dispose();
    _precioKgCtrl.dispose();
    _montoCtrl.dispose();
    _aliasCtrl.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final v = double.tryParse(c.text.trim().replaceAll(',', '.'));
    if (v == null || v < 0) return null;
    return v;
  }

  double? get _peso => _parse(_pesoCtrl);
  double? get _precioKg => _parse(_precioKgCtrl);
  double? get _monto => _parse(_montoCtrl);

  static String _colones(double v) =>
      '₡${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(0)}';

  /// Lo que se le muestra debajo de los campos: el total cuando se compra
  /// por kilo y el ₡/kg cuando se compra por monto.
  String? get _resumen {
    switch (_modo) {
      case _ModoCompra.nacio:
        return 'Compra ₡0';
      case _ModoCompra.porKilo:
        final p = _peso;
        final kg = _precioKg;
        if (p == null || kg == null) return null;
        return 'Costo del animal: ${_colones(p * kg)}';
      case _ModoCompra.montoTotal:
        final m = _monto;
        if (m == null) return null;
        final p = _peso;
        if (p == null || p == 0) {
          return 'El ₡/kg sale cuando se pese por primera vez';
        }
        return '${_colones(m / p)} por kilo';
    }
  }

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _continuar() {
    FocusScope.of(context).unfocus();
    final loteId = _loteId;
    if (loteId == null) {
      _avisar('Elegí el lote');
      return;
    }
    final textoPeso = _pesoCtrl.text.trim();
    final peso = textoPeso.isEmpty ? null : _peso;
    if (textoPeso.isNotEmpty && (peso == null || peso <= 0)) {
      _avisar('Peso de entrada inválido');
      return;
    }
    switch (_modo) {
      case _ModoCompra.porKilo:
        if (peso == null) {
          _avisar(
            'Por kilo hace falta el peso. Si no se ha pesado, usá '
            '"Monto total".',
          );
          return;
        }
        final precioKg = _precioKg;
        if (precioKg == null) {
          _avisar('Digitá el precio por kilo');
          return;
        }
        Navigator.pop(
          context,
          _AltaAnimal(
            loteId: loteId,
            peso: peso,
            modo: _modo,
            precioKgCompra: precioKg,
            alias: _aliasCtrl.text,
          ),
        );
      case _ModoCompra.montoTotal:
        final monto = _monto;
        if (monto == null || monto <= 0) {
          _avisar('Digitá cuánto costó el animal');
          return;
        }
        Navigator.pop(
          context,
          _AltaAnimal(
            loteId: loteId,
            peso: peso,
            modo: _modo,
            montoTotal: monto,
            alias: _aliasCtrl.text,
          ),
        );
      case _ModoCompra.nacio:
        Navigator.pop(
          context,
          _AltaAnimal(
            loteId: loteId,
            peso: peso,
            modo: _modo,
            alias: _aliasCtrl.text,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final resumen = _resumen;
    final esHoy = mismoDia(widget.fecha, DateTime.now());

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
                esHoy
                    ? 'Entra hoy · solo lo mínimo para registrarlo'
                    : 'Entra el ${fmtFecha(widget.fecha)}',
                key: const ValueKey('pesaje.alta.fecha'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: esHoy
                      ? theme.colorScheme.outline
                      : theme.colorScheme.tertiary,
                  fontWeight: esHoy ? null : FontWeight.w700,
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
              QuickNumberField(
                key: const ValueKey('pesaje.alta.pesoCompra'),
                controller: _pesoCtrl,
                labelText: 'Peso de entrada',
                suffixText: 'kg',
              ),
              const SizedBox(height: 4),
              Text(
                'Vacío = todavía no se ha pesado',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: HatoSpacing.lg),
              Text('Compra', style: theme.textTheme.titleSmall),
              const SizedBox(height: HatoSpacing.sm),
              SegmentedButton<_ModoCompra>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: _ModoCompra.porKilo,
                    label: Text(
                      'Por kilo',
                      key: ValueKey('pesaje.alta.porKilo'),
                    ),
                  ),
                  ButtonSegment(
                    value: _ModoCompra.montoTotal,
                    label: Text(
                      'Monto total',
                      key: ValueKey('pesaje.alta.montoTotal'),
                    ),
                  ),
                  ButtonSegment(
                    value: _ModoCompra.nacio,
                    label: Text('Nació', key: ValueKey('pesaje.alta.nacio')),
                  ),
                ],
                selected: {_modo},
                onSelectionChanged: (s) => setState(() => _modo = s.first),
              ),
              if (_modo == _ModoCompra.porKilo) ...[
                const SizedBox(height: HatoSpacing.md),
                QuickNumberField(
                  key: const ValueKey('pesaje.alta.precioKg'),
                  controller: _precioKgCtrl,
                  labelText: 'Precio por kilo',
                  suffixText: '₡/kg',
                ),
              ],
              if (_modo == _ModoCompra.montoTotal) ...[
                const SizedBox(height: HatoSpacing.md),
                QuickNumberField(
                  key: const ValueKey('pesaje.alta.monto'),
                  controller: _montoCtrl,
                  labelText: 'Cuánto costó el animal',
                  suffixText: '₡',
                ),
              ],
              if (resumen != null) ...[
                const SizedBox(height: HatoSpacing.md),
                Text(
                  key: const ValueKey('pesaje.alta.costoTotal'),
                  resumen,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: HatoSpacing.lg),
              TextField(
                key: const ValueKey('pesaje.alta.alias'),
                controller: _aliasCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Alias (opcional)',
                  helperText: 'Un nombre corto para buscarlo: "Pinta", "23"',
                  border: OutlineInputBorder(),
                ),
              ),
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
  const _PesajesDeHoy({required this.pesajes, required this.onTocarFila});

  final List<PesajeHoy> pesajes;
  final ValueChanged<PesajeHoy> onTocarFila;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalAnimales = pesajes
        .where((p) => !p.sinPeso)
        .map((p) => p.identificador)
        .toSet()
        .length;

    if (pesajes.isEmpty) {
      return Center(
        child: Text(
          'Acá aparecen los animales que digités hoy.',
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
                  'Digitado hoy',
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
          // Una pestaña por lote pesado hoy — incluso si hay uno solo, para
          // que el contador de ese lote siempre esté a la vista.
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final id in lotesOrden)
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(nombres[id]!),
                      const SizedBox(width: 6),
                      // Contador discreto: cuántos animales distintos van
                      // pesados en este lote hoy.
                      Text(
                        '${porLote[id]!.where((p) => !p.sinPeso).map((p) => p.identificador).toSet().length}',
                        key: ValueKey('pesaje.contadorLote.${nombres[id]}'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: HatoSpacing.sm),
          Expanded(
            child: TabBarView(
              children: [
                for (final id in lotesOrden)
                  _TablaLote(filas: porLote[id]!, onTocarFila: onTocarFila),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TablaLote extends StatelessWidget {
  const _TablaLote({required this.filas, required this.onTocarFila});

  final List<PesajeHoy> filas;
  final ValueChanged<PesajeHoy> onTocarFila;

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
              return InkWell(
                key: ValueKey(
                  f.sinPeso
                      ? 'pesaje.fila.sinPeso.${f.animalId}'
                      : 'pesaje.fila.${f.id}',
                ),
                onTap: () => onTocarFila(f),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.identificador,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (f.alias != null)
                              Text(
                                f.alias!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            // Digitado hoy pero pesado otro día: que se vea.
                            if (!mismoDia(f.fecha, DateTime.now()))
                              Text(
                                'del ${fmtFecha(f.fecha)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.tertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          f.peso == null ? '—' : _fmt(f.peso!),
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: f.sinPeso
                            ? Text(
                                'Sin peso',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.outline,
                                ),
                              )
                            : _ValorGanancia(
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
