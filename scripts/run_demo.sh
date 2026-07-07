#!/usr/bin/env bash
# Launch app with demo dataset (offline). Use on macOS or iOS simulator.
set -euo pipefail
cd "$(dirname "$0")/.."

DEVICE="${1:-macos}"

echo "== Demo mode: seeding Hacienda Demo HatoControl =="
flutter run -d "$DEVICE" \
  --dart-define=SEED_DEMO=1 \
  --dart-define=DEMO_USER_ID=00000000-0000-4000-8000-000000000001
