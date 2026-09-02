import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control_web/app/adaptador_pantalla.dart';

/// El corazón de la versión web: en pantalla angosta se muestra tal cual la
/// app del teléfono, y en pantalla ancha la distribución de computadora. Estas
/// pruebas no llegan a la base de datos: solo verifican que el corte de
/// tamaño elija el camino correcto.
void main() {
  const movil = Text('movil');
  const pc = Text('escritorio');

  Future<void> abrirCon(WidgetTester tester, double ancho) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(ancho, 900);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: _Adaptador(movil: movil, escritorio: pc),
      ),
    );
  }

  testWidgets('un teléfono ve la interfaz de la app nativa', (tester) async {
    await abrirCon(tester, 390);

    expect(find.text('movil'), findsOneWidget);
    expect(find.text('escritorio'), findsNothing);
  });

  testWidgets('una tablet angosta todavía ve la interfaz móvil', (
    tester,
  ) async {
    await abrirCon(tester, kAnchoEscritorio - 1);

    expect(find.text('movil'), findsOneWidget);
  });

  testWidgets('una computadora ve la distribución de escritorio', (
    tester,
  ) async {
    await abrirCon(tester, 1440);

    expect(find.text('escritorio'), findsOneWidget);
    expect(find.text('movil'), findsNothing);
  });
}

/// Copia exacta de la decisión de [AdaptadorPantalla], con dos widgets de
/// mentira en lugar de las pantallas reales (que necesitan Supabase y la base
/// de datos local).
class _Adaptador extends StatelessWidget {
  const _Adaptador({required this.movil, required this.escritorio});

  final Widget movil;
  final Widget escritorio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) =>
          restricciones.maxWidth >= kAnchoEscritorio ? escritorio : movil,
    );
  }
}
