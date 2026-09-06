import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/app_bootstrap.dart';

void main() {
  testWidgets('la app es clara aunque el telefono este en modo oscuro', (
    tester,
  ) async {
    // El login pinta su fondo blanco a mano. Cuando la app seguia el modo del
    // telefono, con el telefono en oscuro le tocaban letras claras sobre ese
    // blanco y no se leia lo que se escribia. HatoControl es siempre clara.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(
      const HatoControlApp(home: Scaffold(body: Text('adentro'))),
    );
    await tester.pumpAndSettle();

    final tema = Theme.of(tester.element(find.text('adentro')));
    expect(tema.brightness, Brightness.light);
    expect(tema.colorScheme.brightness, Brightness.light);
  });
}
