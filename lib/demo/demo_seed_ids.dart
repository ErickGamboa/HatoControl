/// IDs and labels for the local demo dataset (offline / simulator tour).
abstract final class DemoSeedIds {
  static const userId = '00000000-0000-4000-8000-000000000001';
  static const cuentaId = '00000000-0000-4000-8000-000000000010';
  static const fincaNombre = 'Hacienda Demo HatoControl';
  static const loteDestete = 'Destete';
  static const loteLevante = 'Levante';
  static const loteEngorde = 'Engorde';

  /// Animal with pesaje history + sanidad (corral / ficha).
  static const animalCorral = '1001';

  /// Animal with compra + costos for Economía tab (not sold).
  static const animalEconomia = '1002';

  /// Animal sold — full rentabilidad example (roadmap golden numbers).
  static const animalVendido = '3001';
}

/// Summary returned after seeding (for tests and demo tour).
class DemoSeedSnapshot {
  const DemoSeedSnapshot({
    required this.fincaId,
    required this.fincaNombre,
    required this.loteDesteteId,
    required this.loteEngordeId,
  });

  final String fincaId;
  final String fincaNombre;
  final String loteDesteteId;
  final String loteEngordeId;
}
