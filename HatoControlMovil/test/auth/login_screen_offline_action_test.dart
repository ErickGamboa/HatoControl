import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/auth/login_screen.dart';
import 'package:hato_control/data/local/database.dart';

void main() {
  SesionLocalRow cachedSession() {
    return SesionLocalRow(
      id: 'actual',
      usuarioId: 'user-1',
      email: 'offline@example.com',
      nombre: 'Usuario Offline',
      ultimoLoginOnline: DateTime(2026, 1, 1),
      offlineActiva: false,
    );
  }

  testWidgets(
    'evaluator: muestra Entrar sin conexión aunque connectivity diga online',
    (tester) async {
      var entroOffline = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineLoginAction(
              sesionLocal: cachedSession(),
              hayConexion: true,
              falloRedReciente: false,
              cargando: false,
              onEntrarSinConexion: () => entroOffline = true,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('login.offline')), findsOneWidget);
      expect(
        find.text('Entrar sin conexión como offline@example.com'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('login.offline')));
      expect(entroOffline, isTrue);
    },
  );

  testWidgets('evaluator: oculta acceso offline sin usuario cacheado', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfflineLoginAction(
            sesionLocal: null,
            hayConexion: false,
            falloRedReciente: true,
            cargando: false,
            onEntrarSinConexion: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('login.offline')), findsNothing);
    expect(find.textContaining('Entrar sin conexión'), findsNothing);
  });
}
