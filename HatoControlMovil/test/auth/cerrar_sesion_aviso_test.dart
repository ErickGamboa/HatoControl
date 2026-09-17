import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/auth/cerrar_sesion_ui.dart';

/// Al cerrar sesión la copia local se borra entera (ver `cerrarSesionEn`), así
/// que nadie puede salir con trabajo sin subir sin enterarse. Estos tests
/// cuidan el aviso: qué dice y qué salidas ofrece.
void main() {
  Future<void> mostrar(
    WidgetTester tester,
    Future<void> Function(BuildContext) abrir,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => abrir(context),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('el aviso dice cuántos registros faltan y ofrece tres salidas', (
    tester,
  ) async {
    DecisionCierre? elegida;
    await mostrar(tester, (context) async {
      elegida = await preguntarQueHacerConPendientes(context, 12);
    });

    expect(find.text('Falta subir tu trabajo'), findsOneWidget);
    expect(find.textContaining('12 registros'), findsOneWidget);
    expect(find.text('Subir ahora'), findsOneWidget);
    expect(find.text('Seguir en la app'), findsOneWidget);
    expect(find.text('Salir y borrarlo'), findsOneWidget);

    await tester.tap(find.text('Seguir en la app'));
    await tester.pumpAndSettle();
    expect(elegida, DecisionCierre.quedarse);
  });

  testWidgets('con un solo registro pendiente no dice "1 registros"', (
    tester,
  ) async {
    await mostrar(tester, (context) async {
      await preguntarQueHacerConPendientes(context, 1);
    });

    expect(find.textContaining('1 registro '), findsOneWidget);
    expect(find.textContaining('1 registros'), findsNothing);
  });

  testWidgets('"Salir y borrarlo" devuelve descartar, no cierra por su cuenta', (
    tester,
  ) async {
    DecisionCierre? elegida;
    await mostrar(tester, (context) async {
      elegida = await preguntarQueHacerConPendientes(context, 3);
    });

    await tester.tap(find.text('Salir y borrarlo'));
    await tester.pumpAndSettle();
    expect(elegida, DecisionCierre.descartar);
  });

  testWidgets('perder el trabajo pide una segunda confirmación', (
    tester,
  ) async {
    bool? confirmo;
    await mostrar(tester, (context) async {
      confirmo = await confirmarDescartePendientes(context, 3);
    });

    expect(find.text('¿Borrar lo que falta?'), findsOneWidget);
    expect(find.textContaining('No se pueden recuperar'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(confirmo, isFalse);

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sí, borrar y salir'));
    await tester.pumpAndSettle();
    expect(confirmo, isTrue);
  });
}
