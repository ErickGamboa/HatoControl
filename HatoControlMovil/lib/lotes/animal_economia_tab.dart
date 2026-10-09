import 'package:flutter/material.dart';

import '../app/widgets/campo_fecha.dart';
import '../app/widgets/quick_number_field.dart';
import '../data/estadisticas/estadisticas_economicas.dart';
import '../data/local/database.dart';
import '../data/repositories/reglas_de_fechas.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';

/// Pestaña Venta / costos / utilidad.
class AnimalEconomiaTab extends StatefulWidget {
  AnimalEconomiaTab({
    super.key,
    required this.animal,
    VentasRepository? ventasRepository,
  }) : ventasRepository = ventasRepository ?? ventasRepo;

  final AnimalRow animal;
  final VentasRepository ventasRepository;

  @override
  State<AnimalEconomiaTab> createState() => _AnimalEconomiaTabState();
}

class _AnimalEconomiaTabState extends State<AnimalEconomiaTab> {
  ResumenEconomicoAnimal? _resumen;

  @override
  void initState() {
    super.initState();
    _recargar();
  }

  Future<void> _recargar() async {
    final r = await widget.ventasRepository.resumenDe(widget.animal.id);
    if (mounted) setState(() => _resumen = r);
  }

  String _fmt(double? v) {
    if (v == null) return '—';
    return '₡${v.round()}';
  }

  String _detalleCompra(ResumenEconomicoAnimal r) {
    if (r.precioKgCompra == 0) return 'Nació en la finca';
    if (r.pesoCompra != null && r.precioKgCompra != null) {
      return '${r.pesoCompra!.round()} kg × ₡${r.precioKgCompra!.round()}/kg';
    }
    if (r.precioCompra != null && r.pesoCompra == null) {
      return 'monto total · el ₡/kg sale con el primer pesaje';
    }
    return '';
  }

  /// Detalle de la venta: lo que devolvió la planta (D-19). Si todavía no hay
  /// liquidación, se dice qué falta en vez de dejar el renglón mudo.
  String _detalleVenta(ResumenEconomicoAnimal r) {
    if (r.precioVenta == null) {
      if (r.pesoVenta == null) return '';
      return 'salió con ${r.pesoVenta!.round()} kg · '
          'falta registrar el dinero recibido';
    }
    final partes = <String>[
      if (r.pesoPie != null) 'pie ${r.pesoPie!.round()} kg',
      if (r.pesoCanal != null) 'canal ${r.pesoCanal!.round()} kg',
      if (r.rendimiento != null) '${r.rendimiento!.toStringAsFixed(1)} %',
      if (r.precioKgVenta != null) '₡${r.precioKgVenta!.round()}/kg canal',
    ];
    return partes.join(' · ');
  }

  /// Corrige la compra y la fecha de ingreso. Antes guardaba la compra con
  /// fecha de HOY: eso corría el ingreso del animal y le borraba los días de
  /// gastos fijos que ya llevaba. Ahora la fecha se respeta, y si de verdad
  /// estaba mal se corrige a mano.
  Future<void> _editarCompra() async {
    // La fila fresca: la que trae la pantalla puede ser de antes de editar.
    final animal = await (db.select(
      db.animales,
    )..where((t) => t.id.equals(widget.animal.id))).getSingle();
    final ingreso = await pesajesRepo.fechaIngreso(animal);
    if (!mounted) return;

    final r = await showModalBottomSheet<_CompraEditada>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _EditarCompraSheet(animal: animal, ingreso: ingreso),
    );
    if (r == null) return;

    try {
      if (!mismoDia(r.ingreso, ingreso)) {
        await pesajesRepo.cambiarFechaIngreso(
          animalId: animal.id,
          fecha: r.ingreso,
        );
      }
      final actualizado = await (db.select(
        db.animales,
      )..where((t) => t.id.equals(animal.id))).getSingle();
      // La fecha de compra es la de ingreso: la que ya tenía (o la recién
      // corregida). Nunca hoy por guardar.
      final fechaCompra = actualizado.fechaCompra ?? momentoDe(r.ingreso);
      await widget.ventasRepository.actualizarCompra(
        animalId: animal.id,
        pesoCompra: r.pesoCompra,
        precioKgCompra: r.precioKgCompra,
        precioCompra: r.precioCompra,
        fechaCompra: fechaCompra,
      );
    } on FechaInvalidaException catch (e) {
      if (mounted) await avisarFechaInvalida(context, e.mensaje);
      return;
    }
    sincronizarSiSePuede();
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = _resumen;
    if (r == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Widget fila(
      String etiqueta,
      String valor, {
      String? detalle,
      TextStyle? style,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etiqueta,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (detalle != null && detalle.isNotEmpty)
                    Text(
                      detalle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                valor,
                textAlign: TextAlign.end,
                style: style ?? theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      );
    }

    final utilidadStyle = r.utilidad != null && r.utilidad! >= 0
        ? theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          )
        : theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFFC62828),
            fontWeight: FontWeight.bold,
          );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          key: const ValueKey('economia.titulo'),
          'Utilidad',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Venta − (compra + dietas + sanidad + gastos fijos)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        if (!r.compraConfiable) ...[
          const SizedBox(height: 12),
          Material(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Falta el precio por kilo de compra. '
                'La utilidad no es confiable hasta completarlo.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        KeyedSubtree(
          key: const ValueKey('economia.compra'),
          child: fila(
            'Compra',
            _fmt(r.precioCompra),
            detalle: _detalleCompra(r),
          ),
        ),
        KeyedSubtree(
          key: const ValueKey('economia.dietas'),
          child: fila('Dietas', _fmt(r.costoAlimentacion)),
        ),
        KeyedSubtree(
          key: const ValueKey('economia.sanidad'),
          child: fila('Sanidad', _fmt(r.costoSanitario)),
        ),
        KeyedSubtree(
          key: const ValueKey('economia.gastosFijos'),
          child: fila(
            'Gastos fijos',
            _fmt(r.costoGastosFijos),
            detalle: 'parte del peón, luz, agua… por sus días en la finca',
          ),
        ),
        const Divider(height: 24),
        KeyedSubtree(
          key: const ValueKey('economia.costoTotal'),
          child: fila('Costo total', _fmt(r.costoTotal)),
        ),
        KeyedSubtree(
          key: const ValueKey('economia.venta'),
          child: fila('Venta', _fmt(r.precioVenta), detalle: _detalleVenta(r)),
        ),
        KeyedSubtree(
          key: const ValueKey('economia.utilidad'),
          child: fila(
            'Utilidad',
            r.precioVenta == null ? '—' : _fmt(r.utilidad),
            style: r.precioVenta == null ? null : utilidadStyle,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Para vender varios animales usá el módulo Venta en la finca '
          '(valida retiro y arma el lote de venta).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 12),
        if (!permisosFinca.esSoloLectura)
          OutlinedButton.icon(
            onPressed: _editarCompra,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Editar compra'),
          ),
      ],
    );
  }
}

/// Lo que se corrigió de la compra. Igual que al dar de alta en Trabajo:
/// por kilo, monto total o nació en la finca.
class _CompraEditada {
  const _CompraEditada({
    required this.ingreso,
    this.pesoCompra,
    this.precioKgCompra,
    this.precioCompra,
  });

  final DateTime ingreso;
  final double? pesoCompra;
  final double? precioKgCompra; // 0 = nació en la finca
  final double? precioCompra;
}

enum _Modo { porKilo, montoTotal, nacio }

class _EditarCompraSheet extends StatefulWidget {
  const _EditarCompraSheet({required this.animal, required this.ingreso});

  final AnimalRow animal;
  final DateTime ingreso;

  @override
  State<_EditarCompraSheet> createState() => _EditarCompraSheetState();
}

class _EditarCompraSheetState extends State<_EditarCompraSheet> {
  late _Modo _modo = widget.animal.precioKgCompra == 0
      ? _Modo.nacio
      : (widget.animal.precioKgCompra == null &&
            widget.animal.precioCompra != null)
      ? _Modo.montoTotal
      : _Modo.porKilo;
  late final _peso = TextEditingController(
    text: _num(widget.animal.pesoCompra),
  );
  late final _precioKg = TextEditingController(
    text: widget.animal.precioKgCompra == 0
        ? ''
        : _num(widget.animal.precioKgCompra),
  );
  late final _monto = TextEditingController(
    text: widget.animal.precioKgCompra == 0
        ? ''
        : _num(widget.animal.precioCompra),
  );
  late DateTime _ingreso = widget.ingreso;

  static String _num(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _peso.dispose();
    _precioKg.dispose();
    _monto.dispose();
    super.dispose();
  }

  double? _leer(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _guardar() {
    FocusScope.of(context).unfocus();
    final peso = _peso.text.trim().isEmpty ? null : _leer(_peso);
    if (_peso.text.trim().isNotEmpty && (peso == null || peso <= 0)) {
      _avisar('Peso de compra inválido');
      return;
    }
    switch (_modo) {
      case _Modo.nacio:
        Navigator.pop(
          context,
          _CompraEditada(ingreso: _ingreso, precioKgCompra: 0, precioCompra: 0),
        );
      case _Modo.porKilo:
        final kg = _leer(_precioKg);
        if (peso == null) {
          _avisar('Por kilo hace falta el peso de compra');
          return;
        }
        if (kg == null || kg < 0) {
          _avisar('Digitá el precio por kilo');
          return;
        }
        Navigator.pop(
          context,
          _CompraEditada(
            ingreso: _ingreso,
            pesoCompra: peso,
            precioKgCompra: kg,
            precioCompra: peso * kg,
          ),
        );
      case _Modo.montoTotal:
        final monto = _leer(_monto);
        if (monto == null || monto <= 0) {
          _avisar('Digitá cuánto costó el animal');
          return;
        }
        Navigator.pop(
          context,
          _CompraEditada(
            ingreso: _ingreso,
            pesoCompra: peso,
            precioCompra: monto,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Compra · ${widget.animal.identificador}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CampoFecha(
              key: const ValueKey('compra.ingreso'),
              etiqueta: 'Fecha de ingreso',
              fecha: _ingreso,
              ultima: DateTime.now(),
              alCambiar: (f) => setState(() => _ingreso = f),
            ),
            const SizedBox(height: 4),
            Text(
              'Desde ese día se le cobran la dieta y los gastos fijos.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<_Modo>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: _Modo.porKilo, label: Text('Por kilo')),
                ButtonSegment(
                  value: _Modo.montoTotal,
                  label: Text('Monto total'),
                ),
                ButtonSegment(value: _Modo.nacio, label: Text('Nació')),
              ],
              selected: {_modo},
              onSelectionChanged: (s) => setState(() => _modo = s.first),
            ),
            if (_modo != _Modo.nacio) ...[
              const SizedBox(height: 16),
              QuickNumberField(
                key: const ValueKey('compra.peso'),
                controller: _peso,
                labelText: 'Peso de compra',
                suffixText: 'kg',
              ),
            ],
            if (_modo == _Modo.porKilo) ...[
              const SizedBox(height: 12),
              QuickNumberField(
                key: const ValueKey('compra.precioKg'),
                controller: _precioKg,
                labelText: 'Precio por kilo',
                suffixText: '₡/kg',
              ),
            ],
            if (_modo == _Modo.montoTotal) ...[
              const SizedBox(height: 12),
              QuickNumberField(
                key: const ValueKey('compra.monto'),
                controller: _monto,
                labelText: 'Cuánto costó el animal',
                suffixText: '₡',
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              key: const ValueKey('compra.guardar'),
              onPressed: _guardar,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
