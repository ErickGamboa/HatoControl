import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/estadisticas/estadisticas_pesajes.dart';
import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';

/// Pestaña de historial de pesajes (reutilizable en ficha del animal).
class AnimalPesajesTab extends StatelessWidget {
  const AnimalPesajesTab({super.key, required this.animal, required this.repo});

  final AnimalRow animal;
  final PesajesRepository repo;

  static const _verde = Color(0xFF2E7D32);
  static const _rojo = Color(0xFFC62828);

  String _fmt(double p) {
    final abs = p.abs();
    return abs == abs.roundToDouble()
        ? abs.toInt().toString()
        : abs.toStringAsFixed(1);
  }

  String _fecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<PesajeHistorial>>(
      stream: repo.observarHistorial(animal.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final historial = snapshot.data ?? const [];
        if (historial.isEmpty) {
          return Center(
            child: Text(
              'Este animal no tiene pesajes.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          );
        }

        final total = historial.last.peso - historial.first.peso;
        final promedioGlobal = gananciaDiariaGlobal([
          for (final p in historial) (fecha: p.fecha, peso: p.peso),
        ]);
        final filas = historial.reversed.toList();

        return Column(
          children: [
            _ResumenCard(
              total: total,
              promedioGlobal: promedioGlobal,
              pesoActual: historial.last.peso,
              cantidad: historial.length,
              fmt: _fmt,
            ),
            if (historial.length >= 2)
              _GraficoPeso(historial: historial, fecha: _fecha),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Row(
                children: [
                  _Encabezado('Fecha', flex: 4, align: TextAlign.start),
                  _Encabezado('Peso', flex: 3),
                  _Encabezado('Días', flex: 2),
                  _Encabezado('Ganancia', flex: 3),
                  _Encabezado('kg/día', flex: 3),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: filas.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = filas[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            _fecha(p.fecha),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${_fmt(p.peso)} kg',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            p.dias?.toString() ?? '—',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _Valor(valor: p.ganancia, entrada: true),
                        ),
                        Expanded(
                          flex: 3,
                          child: _Valor(
                            valor: p.gananciaDiaria,
                            entrada: false,
                            decimales: 2,
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
      },
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(
    this.texto, {
    required this.flex,
    this.align = TextAlign.end,
  });

  final String texto;
  final int flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        texto,
        textAlign: align,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  const _ResumenCard({
    required this.total,
    required this.promedioGlobal,
    required this.pesoActual,
    required this.cantidad,
    required this.fmt,
  });

  final double total;
  final double? promedioGlobal;
  final double pesoActual;
  final int cantidad;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const verde = AnimalPesajesTab._verde;
    const rojo = AnimalPesajesTab._rojo;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aumento total',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${total >= 0 ? '+' : '-'}${fmt(total)} kg',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: total >= 0 ? verde : rojo,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Peso actual: ${fmt(pesoActual)} kg · $cantidad pesaje(s)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Promedio',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                promedioGlobal == null
                    ? '—'
                    : '${promedioGlobal! >= 0 ? '+' : '-'}'
                          '${promedioGlobal!.abs().toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: promedioGlobal == null
                      ? theme.colorScheme.outline
                      : promedioGlobal! >= 0
                      ? verde
                      : rojo,
                ),
              ),
              Text(
                'kg/día',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GraficoPeso extends StatelessWidget {
  const _GraficoPeso({required this.historial, required this.fecha});

  final List<PesajeHistorial> historial;
  final String Function(DateTime) fecha;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primero = historial.first.fecha;
    final spots = [
      for (final p in historial)
        FlSpot(diasCalendario(primero, p.fecha).toDouble(), p.peso),
    ];

    return Container(
      height: 160,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: theme.colorScheme.outlineVariant,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => [
                for (final t in touched)
                  LineTooltipItem(
                    '${fecha(historial[t.spotIndex].fecha)}\n'
                    '${t.y == t.y.roundToDouble() ? t.y.toInt() : t.y.toStringAsFixed(1)} kg',
                    TextStyle(
                      color: theme.colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Valor extends StatelessWidget {
  const _Valor({required this.valor, required this.entrada, this.decimales});

  final double? valor;
  final bool entrada;
  final int? decimales;

  String _fmt(double p) {
    final abs = p.abs();
    if (decimales != null) return abs.toStringAsFixed(decimales!);
    return abs == abs.roundToDouble()
        ? abs.toInt().toString()
        : abs.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (valor == null) {
      return Text(
        entrada ? 'Entrada' : '—',
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
      '$signo${_fmt(v)}${decimales == null ? ' kg' : ''}',
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
    );
  }
}
