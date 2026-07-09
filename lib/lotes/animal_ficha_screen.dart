import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../data/repositories/feature_flags_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';
import 'animal_dietas_tab.dart';
import 'animal_economia_tab.dart';
import 'animal_info_tab.dart';
import 'animal_pesajes_tab.dart';
import 'animal_sanidad_tab.dart';

/// Hoja de vida del animal con pestañas: general, pesajes, sanidad, dietas,
/// economía. Sanidad y Economía se ocultan si su feature flag está
/// deshabilitado para la finca/cuenta (D-15, módulo 5).
class AnimalFichaScreen extends StatelessWidget {
  AnimalFichaScreen({
    super.key,
    required this.animal,
    required this.usuarioId,
    PesajesRepository? pesajesRepository,
    SanidadRepository? sanidadRepository,
    DietasRepository? dietasRepository,
    VentasRepository? ventasRepository,
    FeatureFlagsRepository? featureFlagsRepository,
  }) : pesajesRepository = pesajesRepository ?? pesajesRepo,
       sanidadRepository = sanidadRepository ?? sanidadRepo,
       dietasRepository = dietasRepository ?? dietasRepo,
       ventasRepository = ventasRepository ?? ventasRepo,
       featureFlagsRepository = featureFlagsRepository ?? featureFlagsRepo;

  final AnimalRow animal;
  final String? usuarioId;
  final PesajesRepository pesajesRepository;
  final SanidadRepository sanidadRepository;
  final DietasRepository dietasRepository;
  final VentasRepository ventasRepository;
  final FeatureFlagsRepository featureFlagsRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: featureFlagsRepository.observarHabilitado(
        'sanidad',
        fincaId: animal.fincaId,
      ),
      initialData: true,
      builder: (context, sanidadSnap) {
        final sanidadHabilitado = sanidadSnap.data ?? true;
        return StreamBuilder<bool>(
          stream: featureFlagsRepository.observarHabilitado(
            'ventas',
            fincaId: animal.fincaId,
          ),
          initialData: true,
          builder: (context, ventasSnap) {
            final ventasHabilitado = ventasSnap.data ?? true;
            final tabs = [
              const Tab(text: 'General'),
              const Tab(text: 'Pesajes'),
              if (sanidadHabilitado) const Tab(text: 'Sanidad'),
              const Tab(text: 'Dietas'),
              if (ventasHabilitado) const Tab(text: 'Economía'),
            ];
            final vistas = [
              AnimalInfoTab(animal: animal),
              AnimalPesajesTab(animal: animal, repo: pesajesRepository),
              if (sanidadHabilitado)
                AnimalSanidadTab(
                  animal: animal,
                  fincaId: animal.fincaId,
                  responsableId: usuarioId,
                  repo: sanidadRepository,
                ),
              AnimalDietasTab(
                animal: animal,
                dietasRepository: dietasRepository,
              ),
              if (ventasHabilitado)
                AnimalEconomiaTab(
                  animal: animal,
                  ventasRepository: ventasRepository,
                ),
            ];
            return DefaultTabController(
              length: tabs.length,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Animal ${animal.identificador}'),
                  bottom: TabBar(isScrollable: true, tabs: tabs),
                ),
                body: TabBarView(children: vistas),
              ),
            );
          },
        );
      },
    );
  }
}
