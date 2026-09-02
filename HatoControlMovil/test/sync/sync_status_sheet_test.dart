import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/fincas/sync_status_sheet.dart';

void main() {
  Widget envolver(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('sin pendientes ni errores muestra el mensaje de todo al día', (
    tester,
  ) async {
    await tester.pumpWidget(
      envolver(const SyncStatusSheet(pendientes: {}, estados: [])),
    );

    expect(
      find.text('Todo sincronizado, sin errores pendientes.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('syncStatus.list')), findsNothing);
  });

  testWidgets('lista tablas con pendientes y con error, cada una con su dato', (
    tester,
  ) async {
    await tester.pumpWidget(
      envolver(
        SyncStatusSheet(
          pendientes: const {'pesajes': 3, 'lotes': 0},
          estados: [
            SyncEstadoRow(
              tabla: 'dietas',
              ultimoError: 'fallo remoto simulado',
              ultimoErrorEn: DateTime(2026, 1, 1),
            ),
          ],
        ),
      ),
    );

    expect(find.byKey(const ValueKey('syncStatus.list')), findsOneWidget);
    // 'lotes' con 0 pendientes y sin error no aparece.
    expect(find.text('lotes'), findsNothing);
    expect(find.text('pesajes'), findsOneWidget);
    expect(find.text('3 pendiente(s)'), findsOneWidget);
    expect(find.text('dietas'), findsOneWidget);
    expect(find.text('fallo remoto simulado'), findsOneWidget);
  });
}
