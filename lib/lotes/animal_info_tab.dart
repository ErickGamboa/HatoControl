import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';

/// Estado actual del animal (oro Módulo 5): lote, peso, retiro, venta.
class AnimalInfoTab extends StatelessWidget {
  AnimalInfoTab({
    super.key,
    required this.animal,
    PesajesRepository? pesajesRepository,
    SanidadRepository? sanidadRepository,
    VentasRepository? ventasRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       sanidadRepository = sanidadRepository ?? sanidadRepo,
       ventasRepository = ventasRepository ?? ventasRepo;

  final AnimalRow animal;
  final PesajesRepository pesajesRepository;
  final SanidadRepository sanidadRepository;
  final VentasRepository ventasRepository;

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  /// El lote actual y la fecha real de ingreso a la finca, en una sola pasada.
  Future<({LoteRow? lote, DateTime ingreso})> _loteEIngreso() async {
    final lote = await (db.select(
      db.lotes,
    )..where((t) => t.id.equals(animal.loteId))).getSingleOrNull();
    final ingreso = await pesajesRepository.fechaIngreso(animal);
    return (lote: lote, ingreso: ingreso);
  }

  String _peso(double? p) {
    if (p == null) return '—';
    return p == p.roundToDouble()
        ? '${p.toInt()} kg'
        : '${p.toStringAsFixed(1)} kg';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<({LoteRow? lote, DateTime ingreso})>(
      future: _loteEIngreso(),
      builder: (context, datosSnap) {
        final lote = datosSnap.data?.lote;
        final ingreso = datosSnap.data?.ingreso;
        return StreamBuilder<List<AnimalConPeso>>(
          stream: pesajesRepository.observarAnimalesDeLote(animal.loteId),
          builder: (context, pesoSnap) {
            final conPeso = pesoSnap.data?.where(
              (a) => a.animal.id == animal.id,
            );
            final peso = conPeso == null || conPeso.isEmpty
                ? null
                : conPeso.first.pesoActual;
            return StreamBuilder<DateTime?>(
              stream: sanidadRepository.observarRetiroHasta(animal.id),
              builder: (context, retiroSnap) {
                final retiro = retiroSnap.data;
                return StreamBuilder<VentaRow?>(
                  stream: ventasRepository.observarVenta(animal.id),
                  builder: (context, ventaSnap) {
                    final venta = ventaSnap.data;
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _FilaInfo('Identificador', animal.identificador),
                        _FilaInfo(
                          'Estado',
                          animal.estado == EstadoAnimal.vendido
                              ? 'Vendido'
                              : animal.estado == EstadoAnimal.muerto
                              ? 'Muerto'
                              : 'Activo',
                        ),
                        _FilaInfo(
                          'Lote actual',
                          animal.estado == EstadoAnimal.vendido
                              ? '— (vendido)'
                              : (lote?.nombre ?? '—'),
                        ),
                        _FilaInfo('Peso actual', _peso(peso)),
                        _FilaInfo(
                          'En retiro',
                          retiro == null
                              ? 'No'
                              : 'Sí · hasta ${_fecha(retiro)}',
                        ),
                        _FilaInfo(
                          'Fecha de ingreso',
                          ingreso == null ? '—' : _fecha(ingreso),
                        ),
                        if (animal.precioCompra != null)
                          _FilaInfo(
                            'Precio compra',
                            '₡${animal.precioCompra!.toStringAsFixed(0)}',
                          ),
                        if (venta != null) ...[
                          const Divider(height: 32),
                          Text(
                            'Venta',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _FilaInfo('Fecha venta', _fecha(venta.fecha)),
                          _FilaInfo('Peso venta', _peso(venta.peso)),
                          _FilaInfo(
                            'Precio venta',
                            '₡${venta.precio.toStringAsFixed(0)}',
                          ),
                        ],
                        StreamBuilder<List<MovimientoLoteRow>>(
                          stream:
                              (db.select(db.movimientosLote)
                                    ..where(
                                      (t) =>
                                          t.animalId.equals(animal.id) &
                                          t.deletedAt.isNull(),
                                    )
                                    ..orderBy([
                                      (t) => OrderingTerm.desc(t.fecha),
                                    ]))
                                  .watch(),
                          builder: (context, movSnap) {
                            final movs = movSnap.data ?? const [];
                            if (movs.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(height: 32),
                                Text(
                                  'Cambios de lote',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                for (final m in movs)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      _fecha(m.fecha),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        if (animal.pendiente)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              'Cambios pendientes de sincronizar',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              etiqueta,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
