import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../app/widgets/campo_fecha.dart';
import '../data/local/database.dart';
import '../data/repositories/deudas_repository.dart';
import '../services.dart';
import 'deuda_form_sheet.dart';
import 'deudas_pdf_screen.dart';
import 'gastos_fijos_tab.dart' show fmtColones;

/// Pestaña "Deudas" del módulo Gastos.
///
/// Es una LISTA, no contabilidad: lo que se anota acá no toca la utilidad del
/// animal ni se prorratea como los gastos fijos. Sirve para saber a quién se
/// le debe, cuánto falta y qué ya se pagó. Por eso tiene filtros, buscador,
/// totales de lo que se está viendo y un PDF con exactamente eso.
class DeudasTab extends StatefulWidget {
  DeudasTab({super.key, required this.finca, DeudasRepository? deudasRepository})
    : deudasRepository = deudasRepository ?? deudasRepo;

  final FincaRow finca;
  final DeudasRepository deudasRepository;

  @override
  DeudasTabState createState() => DeudasTabState();
}

/// El estado es público porque `GastosScreen` le pide el PDF desde el botón
/// de la barra de arriba: el filtro y la búsqueda viven acá, no allá.
class DeudasTabState extends State<DeudasTab> {
  final _buscarCtrl = TextEditingController();

  late final Stream<List<DeudaConSaldo>> _stream = widget.deudasRepository
      .observarDeudas(widget.finca.id);

  FiltroDeuda _filtro = FiltroDeuda.todas;
  String _busqueda = '';
  DateTime? _desde;
  DateTime? _hasta;

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  bool get _hayFiltroDeFecha => _desde != null || _hasta != null;

  Future<void> _formulario({DeudaConSaldo? existente}) async {
    final aviso = await mostrarFormularioDeuda(
      context,
      fincaId: widget.finca.id,
      repositorio: widget.deudasRepository,
      existente: existente,
    );
    if (aviso == null) return;
    sincronizarSiSePuede();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(aviso)));
    }
  }

  Future<void> _elegirRango() async {
    final hoy = DateTime.now();
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(hoy.year - 10),
      lastDate: DateTime(hoy.year + 5, 12, 31),
      initialDateRange: _desde != null && _hasta != null
          ? DateTimeRange(start: _desde!, end: _hasta!)
          : null,
      helpText: 'Fechas de la deuda',
      saveText: 'Filtrar',
    );
    if (rango == null) return;
    setState(() {
      _desde = rango.start;
      _hasta = rango.end;
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _filtro = FiltroDeuda.todas;
      _busqueda = '';
      _desde = null;
      _hasta = null;
      _buscarCtrl.clear();
    });
  }

  /// Abre el PDF con EXACTAMENTE lo que se está viendo.
  ///
  /// Lo llama el botón de la barra de arriba (`GastosScreen`). La lista se
  /// vuelve a armar con los mismos filtros en vez de guardarla al pintar, para
  /// que el PDF no pueda salir con algo viejo.
  Future<void> exportarPdf() async {
    final visibles = filtrarDeudas(
      await widget.deudasRepository.deudasDe(widget.finca.id),
      filtro: _filtro,
      busqueda: _busqueda,
      desde: _desde,
      hasta: _hasta,
    );
    if (!mounted) return;

    if (visibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay deudas que exportar.')),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeudasPdfScreen(
          nombreFinca: widget.finca.nombre,
          descripcionFiltro: _descripcionFiltro(),
          deudas: visibles,
          totales: TotalesDeudas.de(visibles),
          generadoEl: DateTime.now(),
        ),
      ),
    );
  }

  /// Qué se está viendo, en una línea. Va en el PDF: una hoja impresa tiene
  /// que decir sola de qué es, o al rato nadie sabe qué muestra.
  String _descripcionFiltro() {
    final partes = <String>[
      switch (_filtro) {
        FiltroDeuda.todas => 'Todas las deudas',
        FiltroDeuda.pendientes => 'Deudas pendientes',
        FiltroDeuda.pagadas => 'Deudas pagadas',
        FiltroDeuda.anuladas => 'Deudas anuladas',
        FiltroDeuda.vencidas => 'Deudas vencidas',
      },
      if (_desde != null && _hasta != null)
        'del ${fmtFecha(_desde!)} al ${fmtFecha(_hasta!)}',
      if (_busqueda.trim().isNotEmpty) 'que dicen "${_busqueda.trim()}"',
    ];
    return partes.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final soloLectura = permisosFinca.esSoloLectura;

    return StreamBuilder<List<DeudaConSaldo>>(
      stream: _stream,
      builder: (context, snap) {
        final todas = snap.data ?? const <DeudaConSaldo>[];
        final visibles = filtrarDeudas(
          todas,
          filtro: _filtro,
          busqueda: _busqueda,
          desde: _desde,
          hasta: _hasta,
        );
        final totales = TotalesDeudas.de(visibles);

        return Scaffold(
          floatingActionButton: soloLectura
              ? null
              : FloatingActionButton.extended(
                  key: const ValueKey('deudas.agregar'),
                  onPressed: () => _formulario(),
                  icon: const Icon(Icons.add),
                  label: const Text('Deuda'),
                ),
          body: Column(
            children: [
              _Filtros(
                buscarCtrl: _buscarCtrl,
                filtro: _filtro,
                hayFiltroDeFecha: _hayFiltroDeFecha,
                textoRango: _desde == null || _hasta == null
                    ? 'Fechas'
                    : '${fmtFecha(_desde!)} – ${fmtFecha(_hasta!)}',
                alBuscar: (v) => setState(() => _busqueda = v),
                alFiltrar: (f) => setState(() => _filtro = f),
                alElegirRango: _elegirRango,
                alLimpiar:
                    _filtro == FiltroDeuda.todas &&
                        _busqueda.isEmpty &&
                        !_hayFiltroDeFecha
                    ? null
                    : _limpiarFiltros,
              ),
              Expanded(
                child: snap.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : todas.isEmpty
                    ? const _VacioDeudas()
                    : visibles.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(HatoSpacing.xl),
                          child: Text(
                            'Ninguna deuda coincide con lo que buscás.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        key: const ValueKey('deudas.lista'),
                        padding: const EdgeInsets.fromLTRB(
                          HatoSpacing.lg,
                          HatoSpacing.md,
                          HatoSpacing.lg,
                          96,
                        ),
                        itemCount: visibles.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _DeudaCard(
                          item: visibles[i],
                          soloLectura: soloLectura,
                          onTap: () => _formulario(existente: visibles[i]),
                        ),
                      ),
              ),
              _BarraTotales(totales: totales),
            ],
          ),
        );
      },
    );
  }
}

/// Buscador + filtros. Se dejan siempre a la vista (y no escondidos en un
/// menú) porque con la lista larga son la única forma de encontrar algo.
class _Filtros extends StatelessWidget {
  const _Filtros({
    required this.buscarCtrl,
    required this.filtro,
    required this.hayFiltroDeFecha,
    required this.textoRango,
    required this.alBuscar,
    required this.alFiltrar,
    required this.alElegirRango,
    required this.alLimpiar,
  });

  final TextEditingController buscarCtrl;
  final FiltroDeuda filtro;
  final bool hayFiltroDeFecha;
  final String textoRango;
  final ValueChanged<String> alBuscar;
  final ValueChanged<FiltroDeuda> alFiltrar;
  final VoidCallback alElegirRango;

  /// null cuando no hay nada que limpiar.
  final VoidCallback? alLimpiar;

  static const _etiquetas = {
    FiltroDeuda.todas: 'Todas',
    FiltroDeuda.pendientes: 'Pendientes',
    FiltroDeuda.vencidas: 'Vencidas',
    FiltroDeuda.pagadas: 'Pagadas',
    FiltroDeuda.anuladas: 'Anuladas',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            HatoSpacing.lg,
            HatoSpacing.md,
            HatoSpacing.lg,
            0,
          ),
          child: TextField(
            key: const ValueKey('deudas.buscar'),
            controller: buscarCtrl,
            onChanged: alBuscar,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: '¿A quién le debo?',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: buscarCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        buscarCtrl.clear();
                        alBuscar('');
                      },
                    ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: HatoSpacing.lg),
            children: [
              for (final entrada in _etiquetas.entries)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: ChoiceChip(
                    key: ValueKey('deudas.filtro.${entrada.key.name}'),
                    selected: filtro == entrada.key,
                    label: Text(entrada.value),
                    onSelected: (_) => alFiltrar(entrada.key),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                child: FilterChip(
                  key: const ValueKey('deudas.filtro.fechas'),
                  selected: hayFiltroDeFecha,
                  avatar: const Icon(Icons.event_outlined, size: 18),
                  label: Text(textoRango),
                  onSelected: (_) => alElegirRango(),
                ),
              ),
              if (alLimpiar != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: ActionChip(
                    key: const ValueKey('deudas.filtro.limpiar'),
                    avatar: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpiar'),
                    onPressed: alLimpiar,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeudaCard extends StatelessWidget {
  const _DeudaCard({
    required this.item,
    required this.soloLectura,
    required this.onTap,
  });

  final DeudaConSaldo item;
  final bool soloLectura;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = item.deuda;
    final vencida = item.vencida();

    final (color, etiqueta) = item.anulada
        ? (theme.colorScheme.outline, 'Anulada')
        : item.pagada
        ? (const Color(0xFF2E7D32), 'Pagada')
        : vencida
        ? (theme.colorScheme.error, 'Vencida')
        : (theme.colorScheme.primary, 'Pendiente');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        key: ValueKey('deudas.card.${d.id}'),
        onTap: soloLectura ? null : onTap,
        leading: Icon(
          item.pagada
              ? Icons.check_circle_outline
              : item.anulada
              ? Icons.block_outlined
              : Icons.account_balance_wallet_outlined,
          color: color,
        ),
        title: Text(
          d.acreedor,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${fmtColones(d.monto)} · ${fmtFecha(d.fecha)}'
              '${d.vence == null ? '' : ' · vence ${fmtFecha(d.vence!)}'}',
            ),
            if (item.abonado > 0 && !item.anulada)
              Text(
                'Abonado ${fmtColones(item.abonado)} · '
                'saldo ${fmtColones(item.saldo)}',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            if (d.nota != null)
              Text(
                d.nota!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
          ],
        ),
        isThreeLine: item.abonado > 0 || d.nota != null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              etiqueta,
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            if (!item.anulada && !item.pagada)
              Text(
                fmtColones(item.saldo),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Totales de lo que se está viendo. Fijos abajo: son la respuesta a
/// "¿cuánto debo?", y no deberían quedar al final de un scroll.
class _BarraTotales extends StatelessWidget {
  const _BarraTotales({required this.totales});

  final TotalesDeudas totales;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(HatoSpacing.lg, 10, HatoSpacing.lg, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo: ${fmtColones(totales.saldo)}',
                      key: const ValueKey('deudas.totalSaldo'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '${totales.cantidad} deuda(s) · '
                      'total ${fmtColones(totales.total)} · '
                      'abonado ${fmtColones(totales.abonado)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              // Hueco del botón flotante, para que el texto no quede debajo.
              const SizedBox(width: 150),
            ],
          ),
        ),
      ),
    );
  }
}

class _VacioDeudas extends StatelessWidget {
  const _VacioDeudas();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(HatoSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: HatoSpacing.lg),
            Text(
              'Deudas de la finca',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: HatoSpacing.sm),
            Text(
              'Anotá a quién le debés, cuánto y desde cuándo. Se puede ir '
              'abonando hasta pagarla.\n\n'
              'Esta lista es solo para llevar el control: no entra en la '
              'utilidad de los animales.',
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
}
