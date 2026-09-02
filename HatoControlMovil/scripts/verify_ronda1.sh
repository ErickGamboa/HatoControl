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

if [[ -n "${HATO_E2E_EMAIL:-}" && -n "${HATO_E2E_PASSWORD:-}" ]]; then
  DEVICE="${HATO_E2E_DEVICE:-macos}"
  echo "== ronda1 Supabase e2e on $DEVICE =="
  flutter test -d "$DEVICE" integration_test/ronda1_utilidad_e2e_test.dart \
    --dart-define=HATO_E2E_EMAIL="$HATO_E2E_EMAIL" \
    --dart-define=HATO_E2E_PASSWORD="$HATO_E2E_PASSWORD" \
    --dart-define=HATO_E2E_SLOW_MS="${HATO_E2E_SLOW_MS:-0}"
else
  echo "Skip cloud e2e (set HATO_E2E_EMAIL / HATO_E2E_PASSWORD to run)."
fi

echo "OK — ronda 1 automated checks passed."
echo "Manual leftovers: #1 launch iOS, #8/#9 UI sanidad — see test/QA_CORRECCIONES_R1.md"
