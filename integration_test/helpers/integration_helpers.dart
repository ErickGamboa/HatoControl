import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared wait/pause helpers for device integration tests.
///
/// Use [slowMs] via `--dart-define=HATO_E2E_SLOW_MS=650` on Supabase e2e runs
/// so steps are visible when demoing on a simulator.
const integrationSlowMs = int.fromEnvironment(
  'HATO_E2E_SLOW_MS',
  defaultValue: 0,
);

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  int timeoutSeconds = 15,
}) async {
  final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets);
}

Future<bool> tryTapAndWaitFor(
  WidgetTester tester, {
  required Finder tapTarget,
  required Finder waitFor,
  int timeoutSeconds = 8,
}) async {
  await tester.ensureVisible(tapTarget);
  await tester.tap(tapTarget);
  final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (waitFor.evaluate().isNotEmpty) return true;
  }
  return false;
}

Future<void> scrollUntilVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  await tester.scrollUntilVisible(
    finder,
    240,
    scrollable: find.byType(Scrollable).last,
    maxScrolls: 20,
  );
}

Future<void> pauseIntegration(WidgetTester tester, {int multiplier = 1}) async {
  if (integrationSlowMs <= 0) return;
  await tester.pump(Duration(milliseconds: integrationSlowMs * multiplier));
}

String visibleTextOnScreen(WidgetTester tester) {
  return tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data)
      .whereType<String>()
      .where((t) => t.trim().isNotEmpty)
      .toSet()
      .join(' | ');
}
