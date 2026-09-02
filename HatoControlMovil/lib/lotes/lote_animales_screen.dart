import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../services.dart';
import 'animal_ficha_screen.dart';

/// Lista los animales de un lote (con su peso actual) y permite buscarlos.
/// Al tocar un animal se abre su historial de pesajes.
class LoteAnimalesScreen extends StatefulWidget {
  const LoteAnimalesScreen({super.key, required this.lote, this.usuarioId});

  final LoteRow lote;
  final String? usuarioId;

  @override
  State<LoteAnimalesScreen> createState() => _LoteAnimalesScreenState();
}

class _LoteAnimalesScreenState extends State<LoteAnimalesScreen> {
  final _buscarCtrl = TextEditingController();
  final _buscarFocus = FocusNode();
  String _filtro = '';

  // Stream estable: se crea UNA sola vez. Si se recreara en cada build (al
  // teclear en el buscador), el StreamBuilder volvería a "cargando" y borraría
  // el campo de búsqueda (perdiendo foco y las lecturas del lector).
  late final Stream<List<AnimalConPeso>> _stream = pesajesRepo
      .observarAnimalesDeLote(widget.lote.id);
  late final Stream<DietaVigenteLote?> _dietaStream = dietasRepo
      .observarDietaVigente(widget.lote.id);

  @override
  void initState() {
    super.initState();
    // Al enfocar el buscador, seleccionar todo: así el lector RFID (modo
    // teclado) reemplaza la búsqueda anterior al escanear.
    _buscarFocus.addListener(_seleccionarTodo);
  }

  void _seleccionarTodo() {
    if (_buscarFocus.hasFocus && _buscarCtrl.text.isNotEmpty) {
      _buscarCtrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _buscarCtrl.text.length,
      );
    }
  }

  @override
  void dispose() {
    _buscarFocus.removeListener(_seleccionarTodo);
    _buscarFocus.dispose();
    _buscarCtrl.dispose();
    super.dispose();
  }

  String _fmt(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);

  /// Selector de dieta para este lote (incluye opción Sin dieta).
  Future<void> _asignarDieta() async {
    final dietas = await dietasRepo.observarDietas(widget.lote.fincaId).first;
    if (!mounted) return;

    final dietaId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Dieta de "${widget.lote.nombre}"',
                style: Theme.of(ctx).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(Icons.block_outlined),
                    title: const Text('Sin dieta'),
                    subtitle: const Text('Costo de dieta ₡0'),
                    onTap: () => Navigator.pop(ctx, ''),
                  ),
                  if (dietas.isEmpty)
                    const ListTile(
                      title: Text('No hay dietas en el catálogo'),
                      subtitle: Text('Creálas en la sección Dietas'),
                    )
                  else
                    for (final d in dietas)
                      ListTile(
                        title: Text(d.nombre),
                        subtitle: Text(
                          '₡${d.costoAnimalDia.toStringAsFixed(0)} / animal / día'
                          '  ·  ₡${d.costoKg.toStringAsFixed(0)} / kg × '
                          '${d.kgAnimalDia == d.kgAnimalDia.roundToDouble() ? d.kgAnimalDia.toInt() : d.kgAnimalDia} kg',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pop(ctx, d.id),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (dietaId == null) return;
    if (dietaId.isEmpty) {
      await _quitarDieta();
      return;
    }
    await dietasRepo.asignarDietaALote(
      loteId: widget.lote.id,
      dietaId: dietaId,
    );
    sincronizarSiSePuede();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dieta asignada al lote.')));
    }
  }

  Future<void> _quitarDieta() async {
    await dietasRepo.quitarDietaDeLote(widget.lote.id);
    sincronizarSiSePuede();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dieta quitada del lote.')));
    }
  }

  /// Abre un selector con los otros lotes y mueve el animal al elegido.
  Future<void> _moverAnimal(AnimalRow animal) async {
    final lotes = await lotesRepo.lotesActivos(widget.lote.fincaId);
    final otros = lotes.where((l) => l.id != widget.lote.id).toList();
    if (!mounted) return;

    if (otros.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay otros lotes en esta finca para mover el animal.',
          ),
        ),
      );
      return;
    }

    final destino = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Mover "${animal.identificador}" a:',
                style: Theme.of(ctx).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final l in otros)
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

    if (destino == null) return;
    await pesajesRepo.moverAnimalDeLote(
      animalId: animal.id,
      nuevoLoteId: destino,
    );
    sincronizarSiSePuede();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Animal "${animal.identificador}" movido de lote.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soloLectura = permisosFinca.esSoloLectura;

    Widget encabezado(
      String t,
      int flex, {
      TextAlign align = TextAlign.start,
    }) => Expanded(
      flex: flex,
      child: Text(
        t,
        textAlign: align,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.lote.nombre)),
      body: Column(
        children: [
          _TarjetaDietaLote(
            dietaStream: _dietaStream,
            onAsignar: _asignarDieta,
            onQuitar: _quitarDieta,
            soloLectura: soloLectura,
          ),
          // Buscador (fuera del StreamBuilder: nunca pierde el foco)
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _buscarCtrl,
              focusNode: _buscarFocus,
              autofocus: true,
              onChanged: (v) => setState(() => _filtro = v.trim()),
              decoration: InputDecoration(
                hintText: 'Buscar o escanear arete',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _filtro.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _buscarCtrl.clear();
                          setState(() => _filtro = '');
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          // Encabezado de la tabla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                encabezado('Animal', 4),
                encabezado('Peso actual', 3, align: TextAlign.end),
                if (!soloLectura)
                  encabezado('Cambiar lote', 3, align: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AnimalConPeso>>(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final todos = snapshot.data ?? const <AnimalConPeso>[];

                if (todos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/iconos/lotes.png',
                              width: 72,
                              height: 72,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Este lote no tiene animales',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Los animales se agregan al registrar un pesaje '
                              'en la sección Pesaje.',
                              textAlign: TextAlign.center,
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

                final animales = _filtro.isEmpty
                    ? todos
                    : todos
                          .where(
                            (a) => a.animal.identificador
                                .toLowerCase()
                                .contains(_filtro.toLowerCase()),
                          )
                          .toList();

                if (animales.isEmpty) {
                  return Center(
                    child: Text(
                      'Sin resultados para "$_filtro"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        itemCount: animales.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final a = animales[i];
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AnimalFichaScreen(
                                  animal: a.animal,
                                  usuarioId: widget.usuarioId,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      a.animal.identificador,
                                      style: const TextStyle(fontSize: 17),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      a.pesoActual != null
                                          ? '${_fmt(a.pesoActual!)} kg'
                                          : '—',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: a.pesoActual != null
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline,
                                      ),
                                    ),
                                  ),
                                  if (!soloLectura)
                                    Expanded(
                                      flex: 3,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          tooltip: 'Cambiar de lote',
                                          icon: const Icon(Icons.swap_horiz),
                                          color: theme.colorScheme.primary,
                                          onPressed: () =>
                                              _moverAnimal(a.animal),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: theme.colorScheme.primaryContainer,
                      child: Text(
                        'Total de animales: ${todos.length}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta con la dieta vigente del lote. La ganancia de peso vive ahora en el
/// módulo Análisis, donde se puede comparar entre lotes y en el tiempo.
class _TarjetaDietaLote extends StatelessWidget {
  const _TarjetaDietaLote({
    required this.dietaStream,
    required this.onAsignar,
    required this.onQuitar,
    required this.soloLectura,
  });

  final Stream<DietaVigenteLote?> dietaStream;
  final VoidCallback onAsignar;
  final VoidCallback onQuitar;
  final bool soloLectura;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<DietaVigenteLote?>(
      stream: dietaStream,
      builder: (context, dietaSnap) {
        final vigente = dietaSnap.data;
        return Material(
          color: theme.colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vigente == null ? 'Sin dieta' : vigente.dieta.nombre,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      if (vigente != null)
                        Text(
                          '₡${vigente.asignacion.costoAnimalDiaSnapshot.toStringAsFixed(0)} / animal / día',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        )
                      else
                        Text(
                          soloLectura
                              ? 'Este lote no tiene dieta asignada'
                              : 'Tocá para asignar una dieta',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!soloLectura) ...[
                  IconButton(
                    key: const ValueKey('lote.asignarDieta'),
                    tooltip: vigente == null
                        ? 'Asignar dieta'
                        : 'Cambiar dieta',
                    icon: const Icon(Icons.edit),
                    onPressed: onAsignar,
                  ),
                  if (vigente != null)
                    IconButton(
                      key: const ValueKey('lote.quitarDieta'),
                      tooltip: 'Quitar dieta',
                      icon: const Icon(Icons.link_off),
                      onPressed: onQuitar,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
