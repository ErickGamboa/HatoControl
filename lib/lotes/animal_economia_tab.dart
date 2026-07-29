import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/estadisticas/estadisticas_economicas.dart';
import '../data/local/database.dart';
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
    return '';
  }

  String _detalleVenta(ResumenEconomicoAnimal r) {
    if (r.pesoVenta != null && r.precioKgVenta != null) {
      return '${r.pesoVenta!.round()} kg × ₡${r.precioKgVenta!.round()}/kg';
    }
    return '';
  }

  Future<void> _editarCompra() async {
    final pesoCtrl = TextEditingController(
      text: widget.animal.pesoCompra?.round().toString() ?? '',
    );
    final precioKgCtrl = TextEditingController(
      text: widget.animal.precioKgCompra?.round().toString() ?? '',
    );
    var nacio = widget.animal.precioKgCompra == 0;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Compra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Nació en la finca'),
                value: nacio,
                onChanged: (v) => setLocal(() => nacio = v),
              ),
              if (!nacio) ...[
                TextField(
                  controller: pesoCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Peso de compra',
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: precioKgCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Precio por kilo',
                    suffixText: '₡/kg',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
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
      ),
    );
    if (ok != true) return;

    if (nacio) {
      await widget.ventasRepository.actualizarCompra(
        animalId: widget.animal.id,
        pesoCompra: null,
        precioKgCompra: 0,
        precioCompra: 0,
        fechaCompra: null,
      );
    } else {
      final peso = double.tryParse(pesoCtrl.text.trim().replaceAll(',', '.'));
      final kg = double.tryParse(precioKgCtrl.text.trim().replaceAll(',', '.'));
      if (peso == null || kg == null || peso <= 0 || kg < 0) return;
      await widget.ventasRepository.actualizarCompra(
        animalId: widget.animal.id,
        pesoCompra: peso,
        precioKgCompra: kg,
        precioCompra: peso * kg,
        fechaCompra: DateTime.now(),
      );
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
        Text('Utilidad', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Venta − (compra + dietas + sanidad)',
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
        fila('Compra', _fmt(r.precioCompra), detalle: _detalleCompra(r)),
        fila('Dietas', _fmt(r.costoAlimentacion)),
        fila('Sanidad', _fmt(r.costoSanitario)),
        const Divider(height: 24),
        fila('Costo total', _fmt(r.costoTotal)),
        fila('Venta', _fmt(r.precioVenta), detalle: _detalleVenta(r)),
        fila(
          'Utilidad',
          r.precioVenta == null ? '—' : _fmt(r.utilidad),
          style: r.precioVenta == null ? null : utilidadStyle,
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
        OutlinedButton.icon(
          onPressed: _editarCompra,
          icon: const Icon(Icons.shopping_cart_outlined),
          label: const Text('Editar compra'),
        ),
      ],
    );
  }
}
