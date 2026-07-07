#!/usr/bin/env bash
# Automated visible tour on simulator (slow steps for watching).
set -euo pipefail
cd "$(dirname "$0")/.."

DEVICE="${1:-macos}"
SLOW_MS="${HATO_E2E_SLOW_MS:-900}"

echo "== Demo tour integration test on $DEVICE (slow=${SLOW_MS}ms) =="
flutter test -d "$DEVICE" integration_test/demo_tour_test.dart \
  --dart-define=SEED_DEMO=1 \
  --dart-define=HATO_E2E_SLOW_MS="$SLOW_MS"
