import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/estadisticas/estadisticas_pesajes.dart';
import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';
import '../services.dart';

/// Historial agregado de un lote por jornadas de pesaje (D-01): para cada
/// período muestra cantidad de animales, peso promedio/mínimo/máximo,
/// ganancia promedio y kg/día promedio, más la evolución del peso promedio.
class LoteHistorialScreen extends StatelessWidget {
  LoteHistorialScreen({super.key, required this.lote, PesajesRepository? repo})
    : repo = repo ?? pesajesRepo;

  final LoteRow lote;

  /// Inyectable en tests (D-10); por defecto usa el repositorio global.
  final PesajesRepository repo;

  static const _verde = Color(0xFF2E7D32);
  static const _rojo = Color(0xFFC62828);

  static const _meses = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Oct',
    'Nov',
    'Dic',
  ];

  String _fechaCorta(DateTime d) => '${d.day} ${_meses[d.month - 1]}';

  String _fmt(double p) {
    final abs = p.abs();
    return abs == abs.roundToDouble()
        ? abs.toInt().toString()
        : abs.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Historial · ${lote.nombre}')),
      body: StreamBuilder<List<PeriodoLote>>(
        stream: repo.observarResumenLote(lote.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final periodos = snapshot.data ?? const [];
          if (periodos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Este lote no tiene pesajes todavía.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            );
          }

          // Más reciente arriba en la tabla.
          final filas = periodos.reversed.toList();

          return Column(
            children: [
              if (periodos.length >= 2)
                _GraficoPromedio(periodos: periodos, fechaCorta: _fechaCorta),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    _Encabezado('Período', flex: 4, align: TextAlign.start),
                    _Encabezado('Animales', flex: 2),
                    _Encabezado('Promedio', flex: 3),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.desde == null
                                      ? _fechaCorta(p.hasta)
                                      : '${_fechaCorta(p.desde!)} → '
                                            '${_fechaCorta(p.hasta)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'mín ${_fmt(p.pesoMinimo)} · '
                                  'máx ${_fmt(p.pesoMaximo)} kg',
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
                              '${p.animales}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${_fmt(p.pesoPromedio)} kg',
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: _Valor(
                              valor: p.gananciaPromedio,
                              sufijo: ' kg',
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: _Valor(
                              valor: p.gananciaDiariaPromedio,
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
      ),
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

/// Evolución del peso promedio del lote por jornada (D-11: fl_chart).
class _GraficoPromedio extends StatelessWidget {
  const _GraficoPromedio({required this.periodos, required this.fechaCorta});

  final List<PeriodoLote> periodos;
  final String Function(DateTime) fechaCorta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primero = periodos.first.hasta;
    final spots = [
      for (final p in periodos)
        FlSpot(diasCalendario(primero, p.hasta).toDouble(), p.pesoPromedio),
    ];

    return Container(
      height: 160,
      margin: const EdgeInsets.all(16),
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
                    '${fechaCorta(periodos[t.spotIndex].hasta)}\n'
                    '${t.y.toStringAsFixed(1)} kg promedio',
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

/// Valor coloreado: verde si sube, rojo si baja, "—" si no aplica.
class _Valor extends StatelessWidget {
  const _Valor({required this.valor, this.decimales, this.sufijo = ''});

  final double? valor;
  final int? decimales;
  final String sufijo;

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
        '—',
        textAlign: TextAlign.end,
        style: TextStyle(fontSize: 14, color: theme.colorScheme.outline),
      );
    }
    const verde = LoteHistorialScreen._verde;
    const rojo = LoteHistorialScreen._rojo;
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
      '$signo${_fmt(v)}$sufijo',
      textAlign: TextAlign.end,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
    );
  }
}
