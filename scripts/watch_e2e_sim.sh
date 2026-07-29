#!/usr/bin/env bash
# Watch the booted iOS Simulator while an e2e run is in progress.
# Takes a PNG every N seconds so a stuck screen (keyboard, dialog, etc.)
# is visible without staring at the Simulator the whole time.
#
# Usage:
#   ./scripts/watch_e2e_sim.sh [/tmp/hato_e2e_watch] [interval_seconds]
#
# Tip: start this in another terminal before `flutter test -d <sim> ...`
set -euo pipefail

OUT_DIR="${1:-/tmp/hato_e2e_watch}"
INTERVAL="${2:-4}"
mkdir -p "$OUT_DIR"
# Fresh run folder with timestamp
RUN_DIR="$OUT_DIR/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RUN_DIR"

echo "Watching booted simulator → $RUN_DIR (every ${INTERVAL}s)"
echo "Stop with Ctrl-C"
i=0
while true; do
  i=$((i + 1))
  file="$RUN_DIR/$(printf '%04d' "$i").png"
  if xcrun simctl io booted screenshot "$file" >/dev/null 2>&1; then
    # Keep a stable "latest" alias for quick glance
    cp "$file" "$OUT_DIR/latest.png"
    echo "$(date +%H:%M:%S) wrote $file"
  else
    echo "$(date +%H:%M:%S) screenshot failed (is a simulator booted?)"
  fi
  sleep "$INTERVAL"
done
