import 'package:flutter/material.dart';

import '../data/local/database.dart';
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
class GastosScreen extends StatelessWidget {
  const GastosScreen({super.key, required this.finca});

  final FincaRow finca;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gastos'),
          bottom: const TabBar(
            tabs: [
              Tab(key: ValueKey('gastos.tab.gastos'), text: 'Gastos'),
              Tab(key: ValueKey('gastos.tab.deudas'), text: 'Deudas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GastosFijosTab(finca: finca),
            DeudasTab(finca: finca),
          ],
        ),
      ),
    );
  }
}
