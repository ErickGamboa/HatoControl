import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/estadisticas/estadisticas_pesajes.dart';
import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../lotes/animal_ficha_screen.dart';
import '../services.dart';

/// Análisis de pesos: cómo viene ganando cada lote y cada animal.
///
/// Todo esto ya se calculaba (`resumenPorPeriodos`) y solo se veía una línea
/// del último período dentro de Lotes. Acá se ve el historial completo y se
/// pueden comparar los lotes entre sí.
class AnalisisPesosScreen extends StatefulWidget {
  AnalisisPesosScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
    PesajesRepository? pesajesRepository,
    DietasRepository? dietasRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       dietasRepository = dietasRepository ?? dietasRepo;

  final FincaRow finca;
  final String usuarioId;
  final PesajesRepository pesajesRepository;
  final DietasRepository dietasRepository;

  @override
  State<AnalisisPesosScreen> createState() => _AnalisisPesosScreenState();
}

class _AnalisisPesosScreenState extends State<AnalisisPesosScreen> {
  /// null = todos los lotes (vista comparativa).
  String? _loteId;

  late final Stream<List<ResumenPesosLote>> _resumen = widget.pesajesRepository
      .observarResumenPesosFinca(widget.finca.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Análisis de pesos')),
      body: SafeArea(
        child: StreamBuilder<List<ResumenPesosLote>>(
          stream: _resumen,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final lotes = snapshot.data!;
            if (lotes.isEmpty) {
              return const _Vacio(
                'Esta finca todavía no tiene lotes registrados. Creá uno en '
                'Lotes y registrá los pesajes para ver el análisis.',
              );
            }
            // Si el lote elegido se borró, se vuelve a la comparativa.
            final elegido = lotes
                .where((r) => r.lote.id == _loteId)
                .firstOrNull;

            return Column(
              children: [
                _SelectorLote(
                  lotes: lotes,
                  loteId: elegido?.lote.id,
                  onElegir: (id) => setState(() => _loteId = id),
                ),
                Expanded(
                  child: elegido == null
                      ? _ComparativaLotes(lotes: lotes)
                      : _DetalleLote(
                          resumen: elegido,
                          dietaStream: widget.dietasRepository
                              .observarDietaVigente(elegido.lote.id),
                          animalesStream: widget.pesajesRepository
                              .observarAnimalesDeLote(elegido.lote.id),
                          usuarioId: widget.usuarioId,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- utilidades

String _fecha(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().substring(2)}';

String _kg(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

String _conSigno(double v) => '${v >= 0 ? '+' : ''}${_kg(v)}';

String _animales(int n) => n == 1 ? 'a 1 animal' : 'a $n animales';

const _verde = Color(0xFF2E7D32);
const _rojo = Color(0xFFC62828);

Color _colorGanancia(double? v, ColorScheme cs) {
  if (v == null) return cs.outline;
  if (v > 0) return _verde;
  if (v < 0) return _rojo;
  return cs.outline;
}

class _Vacio extends StatelessWidget {
  const _Vacio(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(HatoSpacing.xl),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

/// Tarjeta con título y, opcionalmente, una línea que explica en español qué
/// significa el número. Sin esa línea el ganadero ve datos, no respuestas.
class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    super.key,
    required this.titulo,
    required this.hijo,
    this.lectura,
  });

  final String titulo;
  final Widget hijo;
  final String? lectura;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(
        HatoSpacing.lg,
        0,
        HatoSpacing.lg,
        HatoSpacing.md,
      ),
      child: Padding(
        padding: const EdgeInsets.all(HatoSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: HatoSpacing.md),
            hijo,
            if (lectura != null) ...[
              const SizedBox(height: HatoSpacing.md),
              Text(
                lectura!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ selector

class _SelectorLote extends StatelessWidget {
  const _SelectorLote({
    required this.lotes,
    required this.loteId,
    required this.onElegir,
  });

  final List<ResumenPesosLote> lotes;
  final String? loteId;
  final ValueChanged<String?> onElegir;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: HatoSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            child: ChoiceChip(
              key: const ValueKey('analisis.lote.todos'),
              selected: loteId == null,
              label: const Text('Todos'),
              onSelected: (_) => onElegir(null),
            ),
          ),
          for (final r in lotes)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: ChoiceChip(
                key: ValueKey('analisis.lote.${r.lote.nombre}'),
                selected: loteId == r.lote.id,
                label: Text(
                  r.lote.numero == null
                      ? r.lote.nombre
                      : '${r.lote.numero} · ${r.lote.nombre}',
                ),
                onSelected: (_) => onElegir(r.lote.id),
              ),
            ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- comparativa

/// Lote contra lote: cuál está ganando mejor. Ordenados de mejor a peor GMD.
class _ComparativaLotes extends StatelessWidget {
  const _ComparativaLotes({required this.lotes});

  final List<ResumenPesosLote> lotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conDatos = lotes.where((l) => l.ultimaConGanancia != null).toList()
      ..sort(
        (a, b) => b.ultimaConGanancia!.gananciaDiariaPromedio!.compareTo(
          a.ultimaConGanancia!.gananciaDiariaPromedio!,
        ),
      );
    final sinDatos = lotes.where((l) => l.ultimaConGanancia == null).toList();

    if (conDatos.isEmpty) {
      return const _Vacio(
        'Ningún lote registra dos jornadas de pesaje todavía. Con un segundo '
        'pesaje se puede comparar la ganancia.',
      );
    }

    return ListView(
      key: const ValueKey('analisis.lista'),
      padding: const EdgeInsets.only(top: HatoSpacing.md),
      children: [
        _Tarjeta(
          key: const ValueKey('analisis.comparativa'),
          titulo: 'Comparación entre lotes',
          lectura:
              'Ganancia diaria por animal en la última jornada de pesaje de '
              'cada lote. El primero es el de mejor rendimiento.',
          hijo: Column(
            children: [
              for (final r in conDatos)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          r.lote.nombre,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${_kg(r.ultimaJornada!.pesoPromedio)} kg',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${r.ultimaConGanancia!.gananciaDiariaPromedio!.toStringAsFixed(2)} kg/día',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _colorGanancia(
                              r.ultimaConGanancia!.gananciaDiariaPromedio,
                              theme.colorScheme,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (sinDatos.isNotEmpty)
          _Tarjeta(
            titulo: 'Sin datos suficientes',
            lectura:
                'Estos lotes aún no registran dos jornadas de pesaje, por lo '
                'que no hay ganancia que comparar.',
            hijo: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final r in sinDatos)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${r.lote.nombre} · '
                      '${r.periodos.isEmpty ? 'sin pesajes' : '1 jornada'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------- detalle lote

class _DetalleLote extends StatelessWidget {
  const _DetalleLote({
    required this.resumen,
    required this.dietaStream,
    required this.animalesStream,
    required this.usuarioId,
  });

  final ResumenPesosLote resumen;
  final Stream<DietaVigenteLote?> dietaStream;
  final Stream<List<AnimalConPeso>> animalesStream;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    final periodos = resumen.periodos;
    if (periodos.isEmpty) {
      return const _Vacio(
        'Este lote todavía no registra pesajes. Registralos en Trabajo para '
        'ver el análisis.',
      );
    }

    return ListView(
      key: const ValueKey('analisis.detalle'),
      padding: const EdgeInsets.only(top: HatoSpacing.md),
      children: [
        _ComoViene(resumen: resumen, dietaStream: dietaStream),
        _CadaPesaje(periodos: periodos),
        _QueTanParejo(ultima: periodos.last),
        _Rankings(animalesStream: animalesStream, usuarioId: usuarioId),
      ],
    );
  }
}

/// Curva del peso promedio del lote + la ganancia del último período, con la
/// dieta al lado: es la pregunta real, "¿está sirviendo la dieta que le puse?".
class _ComoViene extends StatelessWidget {
  const _ComoViene({required this.resumen, required this.dietaStream});

  final ResumenPesosLote resumen;
  final Stream<DietaVigenteLote?> dietaStream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ultima = resumen.ultimaConGanancia;
    final periodos = resumen.periodos;

    return _Tarjeta(
      key: const ValueKey('analisis.comoViene'),
      titulo: 'Evolución del peso',
      lectura: ultima == null
          ? 'Se requiere una segunda jornada de pesaje para calcular la '
                'ganancia.'
          : 'Entre el ${_fecha(ultima.desde!)} y el ${_fecha(ultima.hasta)} '
                'la ganancia promedio fue de '
                '${_conSigno(ultima.gananciaPromedio!)} kg por animal. El '
                'cálculo compara ${_animales(ultima.animalesConGanancia)} '
                'contra su propio pesaje anterior.',
      hijo: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ultima != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  ultima.gananciaDiariaPromedio!.toStringAsFixed(2),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _colorGanancia(
                      ultima.gananciaDiariaPromedio,
                      theme.colorScheme,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('kg por día', style: theme.textTheme.titleMedium),
              ],
            ),
          StreamBuilder<DietaVigenteLote?>(
            stream: dietaStream,
            builder: (context, snap) {
              final vigente = snap.data;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  vigente == null
                      ? 'Sin dieta asignada'
                      : 'Dieta ${vigente.dieta.nombre} · '
                            '₡${vigente.asignacion.costoAnimalDiaSnapshot.toStringAsFixed(0)} por animal por día',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              );
            },
          ),
          if (periodos.length >= 2) ...[
            const SizedBox(height: HatoSpacing.md),
            _GraficoPromedios(periodos: periodos),
          ],
        ],
      ),
    );
  }
}

class _GraficoPromedios extends StatelessWidget {
  const _GraficoPromedios({required this.periodos});

  final List<PeriodoLote> periodos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primera = periodos.first.hasta;
    final spots = [
      for (final p in periodos)
        FlSpot(diasCalendario(primera, p.hasta).toDouble(), p.pesoPromedio),
    ];

    return SizedBox(
      height: 160,
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
                    '${_fecha(periodos[t.spotIndex].hasta)}\n'
                    '${_kg(t.y)} kg promedio',
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

/// Jornada por jornada: la fecha, el promedio de kilos y cuántos animales lo
/// componen. La cantidad NO es decoración: el promedio solo se puede comparar
/// contra otra jornada si se pesó a la misma gente.
class _CadaPesaje extends StatelessWidget {
  const _CadaPesaje({required this.periodos});

  final List<PeriodoLote> periodos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final masReciente = periodos.reversed.toList();
    final cantidades = periodos.map((p) => p.animales).toSet();
    final grupoCambio = cantidades.length > 1;

    Widget encabezado(
      String t, {
      TextAlign align = TextAlign.start,
      int f = 3,
    }) => Expanded(
      flex: f,
      child: Text(
        t,
        textAlign: align,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return _Tarjeta(
      key: const ValueKey('analisis.cadaPesaje'),
      titulo: 'Detalle por jornada de pesaje',
      lectura: grupoCambio
          ? 'El peso promedio es el total de kilos dividido entre los animales '
                'pesados ese día. Importante: la cantidad de animales pesados '
                'varía entre jornadas, por lo que el promedio puede subir o '
                'bajar sin que los animales hayan cambiado de peso. La '
                'ganancia sí compara a cada animal contra su propio pesaje '
                'anterior.'
          : 'El peso promedio es el total de kilos dividido entre los animales '
                'pesados ese día. La ganancia compara a cada animal contra su '
                'propio pesaje anterior.',
      hijo: Column(
        children: [
          Row(
            children: [
              encabezado('Fecha'),
              encabezado('Animales', align: TextAlign.end, f: 2),
              encabezado('Promedio', align: TextAlign.end),
              encabezado('Ganancia', align: TextAlign.end),
            ],
          ),
          const Divider(),
          for (final p in masReciente)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _fecha(p.hasta),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${p.animales}',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${_kg(p.pesoPromedio)} kg',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      p.gananciaPromedio == null
                          ? 'Entrada'
                          : '${_conSigno(p.gananciaPromedio!)} kg',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _colorGanancia(
                          p.gananciaPromedio,
                          theme.colorScheme,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Un lote disparejo se vende mal: conviene ver la distancia entre el más
/// liviano y el más pesado.
class _QueTanParejo extends StatelessWidget {
  const _QueTanParejo({required this.ultima});

  final PeriodoLote ultima;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diferencia = ultima.pesoMaximo - ultima.pesoMinimo;

    Widget dato(String etiqueta, String valor) => Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            etiqueta,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );

    return _Tarjeta(
      key: const ValueKey('analisis.parejo'),
      titulo: 'Uniformidad del lote',
      lectura:
          'En la jornada del ${_fecha(ultima.hasta)} la diferencia entre el '
          'animal más liviano y el más pesado es de ${_kg(diferencia)} kg.',
      hijo: Row(
        children: [
          dato('Peso mínimo', '${_kg(ultima.pesoMinimo)} kg'),
          dato('Peso promedio', '${_kg(ultima.pesoPromedio)} kg'),
          dato('Peso máximo', '${_kg(ultima.pesoMaximo)} kg'),
        ],
      ),
    );
  }
}

/// Los que más ganan, los que menos, y los que van para atrás. Tocando uno se
/// abre su ficha: de ver el número a ver el animal en un toque.
class _Rankings extends StatelessWidget {
  const _Rankings({required this.animalesStream, required this.usuarioId});

  final Stream<List<AnimalConPeso>> animalesStream;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AnimalConPeso>>(
      stream: animalesStream,
      builder: (context, snap) {
        final animales = snap.data ?? const <AnimalConPeso>[];
        final conGmd = animales.where((a) => a.gananciaDiaria != null).toList()
          ..sort((a, b) => b.gananciaDiaria!.compareTo(a.gananciaDiaria!));
        if (conGmd.isEmpty) return const SizedBox.shrink();

        final mejores = conGmd.take(3).toList();
        final peores = conGmd.reversed.take(3).toList();
        final enBaja = conGmd.where((a) => a.gananciaDiaria! < 0).toList();

        return Column(
          children: [
            _Tarjeta(
              key: const ValueKey('analisis.ranking'),
              titulo: 'Mejor y menor rendimiento',
              lectura:
                  'Ganancia diaria entre los dos últimos pesajes de cada '
                  'animal. Tocá uno para ver su ficha.',
              hijo: Column(
                children: [
                  for (final a in mejores)
                    _FilaAnimal(animal: a, usuarioId: usuarioId),
                  if (conGmd.length > 3) ...[
                    const Divider(),
                    for (final a in peores.reversed)
                      _FilaAnimal(animal: a, usuarioId: usuarioId),
                  ],
                ],
              ),
            ),
            if (enBaja.isNotEmpty)
              _Tarjeta(
                key: const ValueKey('analisis.enBaja'),
                titulo: 'Animales con pérdida de peso',
                lectura:
                    'Registraron menos peso que en su pesaje anterior. '
                    'Conviene revisarlos.',
                hijo: Column(
                  children: [
                    for (final a in enBaja)
                      _FilaAnimal(animal: a, usuarioId: usuarioId),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FilaAnimal extends StatelessWidget {
  const _FilaAnimal({required this.animal, required this.usuarioId});

  final AnimalConPeso animal;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      key: ValueKey('analisis.animal.${animal.animal.identificador}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              AnimalFichaScreen(animal: animal.animal, usuarioId: usuarioId),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                animal.animal.identificador,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                animal.pesoActual == null
                    ? '—'
                    : '${_kg(animal.pesoActual!)} kg',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${animal.gananciaDiaria!.toStringAsFixed(2)} kg/día',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _colorGanancia(
                    animal.gananciaDiaria,
                    theme.colorScheme,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
