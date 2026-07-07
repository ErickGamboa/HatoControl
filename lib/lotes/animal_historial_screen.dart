import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/pesajes_repository.dart';
import '../services.dart';
import 'animal_pesajes_tab.dart';

/// Historial de pesajes de un animal (pantalla completa; ver también
/// [AnimalFichaScreen] con pestañas).
class AnimalHistorialScreen extends StatelessWidget {
  AnimalHistorialScreen({
    super.key,
    required this.animal,
    PesajesRepository? repo,
  }) : repo = repo ?? pesajesRepo;

  final AnimalRow animal;
  final PesajesRepository repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Animal ${animal.identificador}')),
      body: AnimalPesajesTab(animal: animal, repo: repo),
    );
  }
}
