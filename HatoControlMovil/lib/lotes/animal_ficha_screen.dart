import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';
import 'animal_dietas_tab.dart';
import 'animal_economia_tab.dart';
import 'animal_info_tab.dart';
import 'animal_pesajes_tab.dart';
import 'animal_sanidad_tab.dart';

/// Hoja de vida del animal (documento oro, Módulo 5).
class AnimalFichaScreen extends StatelessWidget {
  AnimalFichaScreen({
    super.key,
    required this.animal,
    required this.usuarioId,
    PesajesRepository? pesajesRepository,
    SanidadRepository? sanidadRepository,
    DietasRepository? dietasRepository,
    VentasRepository? ventasRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       sanidadRepository = sanidadRepository ?? sanidadRepo,
       dietasRepository = dietasRepository ?? dietasRepo,
       ventasRepository = ventasRepository ?? ventasRepo;

  final AnimalRow animal;
  final String? usuarioId;
  final PesajesRepository pesajesRepository;
  final SanidadRepository sanidadRepository;
  final DietasRepository dietasRepository;
  final VentasRepository ventasRepository;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hoja de vida · ${animal.identificador}'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(key: ValueKey('ficha.tab.general'), text: 'General'),
              Tab(key: ValueKey('ficha.tab.pesajes'), text: 'Pesajes'),
              Tab(key: ValueKey('ficha.tab.sanidad'), text: 'Sanidad'),
              Tab(key: ValueKey('ficha.tab.dietas'), text: 'Dietas'),
              Tab(key: ValueKey('ficha.tab.venta'), text: 'Venta'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AnimalInfoTab(animal: animal),
            AnimalPesajesTab(animal: animal, repo: pesajesRepository),
            AnimalSanidadTab(
              animal: animal,
              fincaId: animal.fincaId,
              responsableId: usuarioId,
              repo: sanidadRepository,
            ),
            AnimalDietasTab(animal: animal, dietasRepository: dietasRepository),
            AnimalEconomiaTab(
              animal: animal,
              ventasRepository: ventasRepository,
            ),
          ],
        ),
      ),
    );
  }
}
