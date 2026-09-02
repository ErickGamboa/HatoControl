#!/usr/bin/env bash
# Local quality gate: format, analyze, unit tests.
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== pub get =="
flutter pub get

echo "== format =="
dart format lib test integration_test

echo "== analyze =="
flutter analyze

echo "== unit + widget tests =="
flutter test

echo "OK — unit suite passed."
