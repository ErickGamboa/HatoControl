import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/estadisticas/estadisticas_financieras.dart';
import '../data/local/database.dart';
import '../data/repositories/lotes_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../lotes/animal_ficha_screen.dart';
import '../services.dart';

/// Análisis financiero: distribución de costos, costo por kilo ganado y
/// utilidad por animal.
///
/// La utilidad aparece SOLO de los animales vendidos y liquidados. Los que
/// siguen en pie suman costo: de esos todavía no se sabe cuánto van a dejar y
/// no se inventa una estimación.
class AnalisisFinancieroScreen extends StatefulWidget {
  AnalisisFinancieroScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
    VentasRepository? ventasRepository,
    LotesRepository? lotesRepository,
  }) : ventasRepository = ventasRepository ?? ventasRepo,
       lotesRepository = lotesRepository ?? lotesRepo;

  final FincaRow finca;
  final String usuarioId;
  final VentasRepository ventasRepository;
  final LotesRepository lotesRepository;

  @override
  State<AnalisisFinancieroScreen> createState() =>
      _AnalisisFinancieroScreenState();
}

class _AnalisisFinancieroScreenState extends State<AnalisisFinancieroScreen> {
  /// null = toda la finca.
  String? _loteId;

  late Future<_Datos> _datos = _cargar();

  Future<_Datos> _cargar() async {
    final animales = await widget.ventasRepository.financieroDeFinca(
      widget.finca.id,
    );
    final lotes = await widget.lotesRepository.lotesActivos(widget.finca.id);
    return _Datos(animales: animales, lotes: lotes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis financiero'),
        actions: [
          IconButton(
            key: const ValueKey('financiero.recargar'),
            tooltip: 'Volver a calcular',
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _datos = _cargar()),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<_Datos>(
          future: _datos,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _Vacio('No se pudo calcular: ${snapshot.error}');
            }
            final datos = snapshot.data!;
            if (datos.animales.isEmpty) {
              return const _Vacio(
                'Esta finca todavía no tiene animales registrados. '
                'Registralos en Trabajo para ver el análisis de costos.',
              );
            }

            final lote = datos.lotes.where((l) => l.id == _loteId).firstOrNull;
            final delGrupo = lote == null
                ? datos.animales
                : datos.animales
                      .where((a) => a.animal.loteId == lote.id)
                      .toList();
            final resumen = sumarFinanciero(delGrupo.map((a) => a.aporte));

            return Column(
              children: [
                _SelectorLote(
                  lotes: datos.lotes,
                  loteId: lote?.id,
                  onElegir: (id) => setState(() => _loteId = id),
                ),
                Expanded(
                  child: ListView(
                    key: const ValueKey('financiero.lista'),
                    padding: const EdgeInsets.only(top: HatoSpacing.md),
                    children: [
                      _DistribucionCostos(resumen: resumen),
                      _CostoPorKilo(resumen: resumen),
                      _Utilidad(resumen: resumen),
                      _RankingUtilidad(
                        animales: delGrupo,
                        usuarioId: widget.usuarioId,
                      ),
                    ],
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

class _Datos {
  const _Datos({required this.animales, required this.lotes});

  final List<AnimalFinanciero> animales;
  final List<LoteRow> lotes;
}

// ---------------------------------------------------------------- utilidades

/// ₡ con separador de miles y sin decimales: en la finca no se llevan céntimos.
String _colones(double v) {
  final negativo = v < 0;
  final entero = v.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    if (i > 0 && (entero.length - i) % 3 == 0) buffer.write('.');
    buffer.write(entero[i]);
  }
  return '${negativo ? '-' : ''}₡$buffer';
}

String _kg(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// Frase de la tarjeta de utilidad, con la concordancia bien puesta: quedaba
/// feo leer "De 1 animal vendidos y liquidados".
String _lecturaUtilidad(int conUtilidad, int enPie) {
  if (conUtilidad == 0) {
    final enPieTexto = enPie == 1
        ? 'El animal en pie solo acumula costo'
        : 'Los $enPie animales en pie solo acumulan costo';
    return 'Todavía no hay animales vendidos y liquidados, por lo que no hay '
        'utilidad que reportar. $enPieTexto por ahora.';
  }
  final vendidos = conUtilidad == 1
      ? 'Corresponde a 1 animal vendido y liquidado'
      : 'Corresponde a $conUtilidad animales vendidos y liquidados';
  if (enPie == 0) return '$vendidos.';
  final pie = enPie == 1
      ? '1 animal que sigue en pie queda excluido'
      : '$enPie animales que siguen en pie quedan excluidos';
  return '$vendidos. $pie: su utilidad se conoce hasta la venta.';
}

const _verde = Color(0xFF2E7D32);
const _rojo = Color(0xFFC62828);

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

class _SelectorLote extends StatelessWidget {
  const _SelectorLote({
    required this.lotes,
    required this.loteId,
    required this.onElegir,
  });

  final List<LoteRow> lotes;
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
              key: const ValueKey('financiero.lote.todos'),
              selected: loteId == null,
              label: const Text('Toda la finca'),
              onSelected: (_) => onElegir(null),
            ),
          ),
          for (final l in lotes)
            Padding(
              padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
              child: ChoiceChip(
                key: ValueKey('financiero.lote.${l.nombre}'),
                selected: loteId == l.id,
                label: Text(
                  l.numero == null ? l.nombre : '${l.numero} · ${l.nombre}',
                ),
                onSelected: (_) => onElegir(l.id),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ tarjetas

/// Desglose del costo por rubro, de mayor a menor, con barra proporcional.
class _DistribucionCostos extends StatelessWidget {
  const _DistribucionCostos({required this.resumen});

  final ResumenFinanciero resumen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final partes = resumen.desglose;

    if (partes.isEmpty) {
      return const _Tarjeta(
        key: ValueKey('financiero.desglose'),
        titulo: 'Distribución de costos',
        hijo: Text(
          'Todavía no hay costos registrados: compra, dietas, sanidad ni '
          'gastos fijos.',
        ),
      );
    }

    final mayor = partes.first;
    return _Tarjeta(
      key: const ValueKey('financiero.desglose'),
      titulo: 'Distribución de costos',
      lectura:
          'Del costo total de ${_colones(resumen.costoTotal)}, el rubro de mayor '
          'peso es ${mayor.tipo.toLowerCase()}, con el '
          '${mayor.porcentaje.round()} %.',
      hijo: Column(
        children: [
          for (final p in partes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.tipo,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${_colones(p.monto)} · ${p.porcentaje.round()} %',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.porcentaje / 100,
                      minHeight: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
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

/// El número del engorde: lo que cuesta ponerle un kilo encima al ganado.
class _CostoPorKilo extends StatelessWidget {
  const _CostoPorKilo({required this.resumen});

  final ResumenFinanciero resumen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final costo = resumen.costoPorKiloGanado;

    if (costo == null) {
      return const _Tarjeta(
        key: ValueKey('financiero.costoKilo'),
        titulo: 'Costo por kilo ganado',
        hijo: Text(
          'Se requiere un segundo pesaje para determinar los kilos ganados, '
          'que son el divisor de este indicador.',
        ),
      );
    }

    return _Tarjeta(
      key: const ValueKey('financiero.costoKilo'),
      titulo: 'Costo por kilo ganado',
      lectura:
          'Corresponde a ${_colones(resumen.costoDeEngorde)} de dietas, sanidad '
          'y gastos fijos, dividido entre los ${_kg(resumen.kilosGanados)} kg '
          'ganados. La compra queda excluida: esos kilos se adquirieron, no se '
          'produjeron. Si este costo supera el precio de venta por kilo, cada '
          'kilo producido genera pérdida.',
      hijo: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _colones(costo),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 6),
          Text('por kilo', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Utilidad realizada (solo vendidos) y costo de lo que sigue en pie.
class _Utilidad extends StatelessWidget {
  const _Utilidad({required this.resumen});

  final ResumenFinanciero resumen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enPie = resumen.animales - resumen.conUtilidad;

    Widget linea(String etiqueta, String valor, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(etiqueta)),
          Text(
            valor,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );

    return _Tarjeta(
      key: const ValueKey('financiero.utilidad'),
      titulo: 'Utilidad',
      lectura: _lecturaUtilidad(resumen.conUtilidad, enPie),
      hijo: Column(
        children: [
          if (resumen.conUtilidad > 0) ...[
            linea('Dinero recibido', _colones(resumen.ventaRecibida)),
            linea(
              'Utilidad',
              _colones(resumen.utilidad),
              color: resumen.utilidad >= 0 ? _verde : _rojo,
            ),
            const Divider(),
          ],
          linea('Costo acumulado', _colones(resumen.costoTotal)),
        ],
      ),
    );
  }
}

/// Los animales que más y menos dejaron. Solo entran los ya liquidados: de los
/// que están en pie no hay utilidad que ordenar.
class _RankingUtilidad extends StatelessWidget {
  const _RankingUtilidad({required this.animales, required this.usuarioId});

  final List<AnimalFinanciero> animales;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    final conUtilidad =
        animales.where((a) => a.resumen.utilidad != null).toList()
          ..sort((a, b) => b.resumen.utilidad!.compareTo(a.resumen.utilidad!));
    if (conUtilidad.isEmpty) return const SizedBox.shrink();

    final mejores = conUtilidad.take(3).toList();
    final peores = conUtilidad.reversed.take(3).toList().reversed.toList();

    return _Tarjeta(
      key: const ValueKey('financiero.ranking'),
      titulo: 'Mayor y menor utilidad',
      lectura: 'Utilidad por animal vendido. Tocá uno para ver su ficha.',
      hijo: Column(
        children: [
          for (final a in mejores) _FilaAnimal(animal: a, usuarioId: usuarioId),
          if (conUtilidad.length > 3) ...[
            const Divider(),
            for (final a in peores)
              _FilaAnimal(animal: a, usuarioId: usuarioId),
          ],
        ],
      ),
    );
  }
}

class _FilaAnimal extends StatelessWidget {
  const _FilaAnimal({required this.animal, required this.usuarioId});

  final AnimalFinanciero animal;
  final String usuarioId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final utilidad = animal.resumen.utilidad!;
    return InkWell(
      key: ValueKey('financiero.animal.${animal.animal.identificador}'),
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
                _colones(animal.resumen.costoTotal),
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                _colones(utilidad),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: utilidad >= 0 ? _verde : _rojo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
