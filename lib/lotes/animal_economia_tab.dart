import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/estadisticas/estadisticas_economicas.dart';
import '../data/local/database.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';

/// Pestaña Venta / costos / rentabilidad (Module 4).
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

  Future<void> _editarCompra() async {
    final precioCtrl = TextEditingController(
      text: widget.animal.precioCompra?.round().toString() ?? '',
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Precio de compra'),
        content: TextField(
          controller: precioCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Monto ₡',
            border: OutlineInputBorder(),
          ),
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
    final raw = precioCtrl.text.trim().replaceAll(',', '.');
    final precio = raw.isEmpty ? null : double.tryParse(raw);
    await widget.ventasRepository.actualizarCompra(
      animalId: widget.animal.id,
      precioCompra: precio,
      fechaCompra: precio != null ? DateTime.now() : null,
    );
    sincronizarSiSePuede();
    await _recargar();
  }

  Future<void> _registrarVenta() async {
    if (widget.animal.estado == EstadoAnimal.vendido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este animal ya está vendido.')),
      );
      return;
    }
    final precioCtrl = TextEditingController();
    final compradorCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio de venta ₡',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: compradorCtrl,
              decoration: const InputDecoration(
                labelText: 'Comprador (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vender'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final precio = double.tryParse(precioCtrl.text.trim().replaceAll(',', '.'));
    if (precio == null || precio <= 0) return;
    await widget.ventasRepository.registrarVenta(
      animalId: widget.animal.id,
      precio: precio,
      comprador: compradorCtrl.text.trim().isEmpty
          ? null
          : compradorCtrl.text.trim(),
    );
    sincronizarSiSePuede();
    await _recargar();
  }

  Future<void> _agregarOtroCosto() async {
    final conceptoCtrl = TextEditingController();
    final montoCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Otro costo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: conceptoCtrl,
              decoration: const InputDecoration(
                labelText: 'Concepto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: montoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto ₡',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final concepto = conceptoCtrl.text.trim();
    final monto = double.tryParse(montoCtrl.text.trim().replaceAll(',', '.'));
    if (concepto.isEmpty || monto == null || monto <= 0) return;
    await widget.ventasRepository.registrarCostoOtro(
      animalId: widget.animal.id,
      concepto: concepto,
      monto: monto,
    );
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

    Widget fila(String etiqueta, String valor, {TextStyle? style}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                etiqueta,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
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
        Text('Resumen económico', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        fila('Compra', _fmt(r.precioCompra)),
        fila('Alimentación', _fmt(r.costoAlimentacion)),
        fila('Sanidad', _fmt(r.costoSanitario)),
        fila('Otros costos', _fmt(r.costoOtros)),
        const Divider(height: 24),
        fila('Costo total', _fmt(r.costoTotal)),
        fila('Venta', _fmt(r.precioVenta)),
        fila('Utilidad', _fmt(r.utilidad), style: utilidadStyle),
        if (r.margenPorcentaje != null)
          fila('Margen', '${r.margenPorcentaje!.toStringAsFixed(1)} %'),
        if (r.rentabilidadPorcentaje != null)
          fila(
            'Rentabilidad',
            '${r.rentabilidadPorcentaje!.toStringAsFixed(1)} %',
          ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _editarCompra,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Compra'),
            ),
            FilledButton.tonalIcon(
              onPressed: _registrarVenta,
              icon: const Icon(Icons.sell_outlined),
              label: const Text('Vender'),
            ),
            OutlinedButton.icon(
              onPressed: _agregarOtroCosto,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Otro costo'),
            ),
          ],
        ),
      ],
    );
  }
}
