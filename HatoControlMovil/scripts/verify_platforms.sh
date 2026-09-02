#!/usr/bin/env bash
# Build macOS app and run device integration smoke on macOS + iOS simulator.
set -euo pipefail
cd "$(dirname "$0")/.."

IOS_DEVICE="${IOS_DEVICE:-iPhone 17}"
SMOKE=integration_test/app_smoke_test.dart

echo "== pub get =="
flutter pub get

echo "== unit + integration tests (VM) =="
flutter test

echo "== macOS debug build =="
flutter build macos --debug

echo "== macOS device smoke =="
flutter test -d macos "$SMOKE"

echo "== iOS simulator device smoke ($IOS_DEVICE) =="
flutter test -d "$IOS_DEVICE" "$SMOKE"

echo "OK — build and device smoke passed."
