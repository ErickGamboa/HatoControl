import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:hato_control/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app arranca y muestra pantalla de login', (tester) async {
    await app.main();
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byKey(const ValueKey('login.email')), findsOneWidget);
    expect(find.byKey(const ValueKey('login.password')), findsOneWidget);
    expect(find.byKey(const ValueKey('login.submit')), findsOneWidget);
  });
}
