import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/deudas_repository.dart';
import '../data/repositories/gastos_fijos_repository.dart';
import 'deudas_tab.dart';
import 'gastos_fijos_tab.dart';

/// Módulo **Gastos** de la finca, con dos pestañas que no se mezclan:
///
/// - **Gastos**: lo que se reparte entre los animales (peón, luz, agua) y por
///   lo tanto SÍ baja la utilidad de cada uno.
/// - **Deudas**: a quién se le debe y cuánto. Es una lista de control y no
///   toca ningún cálculo: ni utilidad, ni dieta, ni sanidad.
///
/// Están juntas porque el ganadero las piensa juntas ("la plata que sale"),
/// pero separadas en pestañas para que nunca se confunda una con la otra.
class GastosScreen extends StatefulWidget {
  const GastosScreen({
    super.key,
    required this.finca,
    this.gastosFijosRepository,
    this.deudasRepository,
  });

  final FincaRow finca;

  /// Solo para los tests: en la app cada pestaña usa el repositorio global.
  final GastosFijosRepository? gastosFijosRepository;
  final DeudasRepository? deudasRepository;

  @override
  State<GastosScreen> createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(_alCambiarDePestana);

  /// Para pedirle el PDF a la pestaña de Deudas desde el botón de arriba: el
  /// filtro y la búsqueda viven en la pestaña, no acá.
  final _deudas = GlobalKey<DeudasTabState>();

  bool _exportando = false;

  bool get _enDeudas => _tabs.index == 1;

  @override
  void dispose() {
    _tabs.removeListener(_alCambiarDePestana);
    _tabs.dispose();
    super.dispose();
  }

  /// El botón de PDF solo existe en Deudas, así que la barra se repinta al
  /// cambiar de pestaña.
  void _alCambiarDePestana() {
    if (mounted) setState(() {});
  }

  Future<void> _exportarPdf() async {
    setState(() => _exportando = true);
    try {
      await _deudas.currentState?.exportarPdf();
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          if (_enDeudas)
            IconButton(
              key: const ValueKey('deudas.exportar'),
              tooltip: 'Ver en PDF lo que se está viendo',
              onPressed: _exportando ? null : _exportarPdf,
              icon: _exportando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(key: ValueKey('gastos.tab.gastos'), text: 'Gastos'),
            Tab(key: ValueKey('gastos.tab.deudas'), text: 'Deudas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          GastosFijosTab(
            finca: widget.finca,
            gastosFijosRepository: widget.gastosFijosRepository,
          ),
          DeudasTab(
            key: _deudas,
            finca: widget.finca,
            deudasRepository: widget.deudasRepository,
          ),
        ],
      ),
    );
  }
}
