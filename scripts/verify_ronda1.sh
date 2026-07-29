#!/usr/bin/env bash
# Verifica regresiones de la ronda 1 (utilidad, dietas, sync columnas).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== format =="
dart format --output=none --set-exit-if-changed lib test integration_test

echo "== analyze =="
flutter analyze

echo "== ronda 1 focused tests =="
flutter test \
  test/repositories/utilidad_oro_test.dart \
  test/integration/correcciones_ronda1_flow_test.dart \
  test/repositories/dietas_repository_test.dart \
  test/estadisticas/estadisticas_pesajes_test.dart \
  test/repositories/ventas_repository_test.dart \
  test/repositories/medicamentos_sanidad_venta_test.dart

echo "== full suite =="
flutter test

echo "OK — ronda 1 automated checks passed."
echo "Still manual/cloud: #1 launch iOS, #8/#9 UI sanidad, #11 rows in Supabase,"
echo "see test/QA_CORRECCIONES_R1.md"
