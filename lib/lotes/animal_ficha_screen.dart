import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../services.dart';
import 'animal_dietas_tab.dart';
import 'animal_info_tab.dart';
import 'animal_pesajes_tab.dart';
import 'animal_sanidad_tab.dart';

/// Hoja de vida del animal con pestañas: general, pesajes, sanidad, dietas.
class AnimalFichaScreen extends StatelessWidget {
  AnimalFichaScreen({
    super.key,
    required this.animal,
    required this.usuarioId,
    PesajesRepository? pesajesRepository,
    SanidadRepository? sanidadRepository,
    DietasRepository? dietasRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       sanidadRepository = sanidadRepository ?? sanidadRepo,
       dietasRepository = dietasRepository ?? dietasRepo;

  final AnimalRow animal;
  final String? usuarioId;
  final PesajesRepository pesajesRepository;
  final SanidadRepository sanidadRepository;
  final DietasRepository dietasRepository;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Animal ${animal.identificador}'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Pesajes'),
              Tab(text: 'Sanidad'),
              Tab(text: 'Dietas'),
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
          ],
        ),
      ),
    );
  }
}
