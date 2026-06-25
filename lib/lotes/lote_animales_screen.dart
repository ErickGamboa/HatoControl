import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';
import '../services.dart';
import 'animal_historial_screen.dart';

/// Lista los animales de un lote (con su peso actual) y permite buscarlos.
/// Al tocar un animal se abre su historial de pesajes.
class LoteAnimalesScreen extends StatefulWidget {
  const LoteAnimalesScreen({super.key, required this.lote});

  final LoteRow lote;

  @override
  State<LoteAnimalesScreen> createState() => _LoteAnimalesScreenState();
}

class _LoteAnimalesScreenState extends State<LoteAnimalesScreen> {
  final _buscarCtrl = TextEditingController();
  String _filtro = '';

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  String _fmt(double p) =>
      p == p.roundToDouble() ? p.toInt().toString() : p.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.lote.nombre)),
      body: StreamBuilder<List<AnimalConPeso>>(
        stream: pesajesRepo.observarAnimalesDeLote(widget.lote.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final todos = snapshot.data ?? const <AnimalConPeso>[];

          if (todos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/iconos/lotes.png',
                        width: 72,
                        height: 72,
                        color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('Este lote no tiene animales',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Los animales se agregan al registrar un pesaje en la '
                      'sección Pesaje.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            );
          }

          // Filtrar por identificador según el buscador.
          final animales = _filtro.isEmpty
              ? todos
              : todos
                  .where((a) => a.animal.identificador
                      .toLowerCase()
                      .contains(_filtro.toLowerCase()))
                  .toList();

          return Column(
            children: [
              // Buscador
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _buscarCtrl,
                  onChanged: (v) => setState(() => _filtro = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Buscar animal por identificador',
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
              // Encabezado
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text('Animal',
                          style: theme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Peso actual',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: animales.isEmpty
                    ? Center(
                        child: Text('Sin resultados para "$_filtro"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline)),
                      )
                    : ListView.separated(
                        itemCount: animales.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final a = animales[i];
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    AnimalHistorialScreen(animal: a.animal),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
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
                                  const SizedBox(width: 8),
                                  Icon(Icons.chevron_right,
                                      color: theme.colorScheme.outline),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
