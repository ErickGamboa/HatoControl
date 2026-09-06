import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/app/teclado/teclado_del_app.dart';
import 'package:hato_control/app/teclado/teclado_en_pantalla.dart';
import 'package:hato_control/app/teclado/teclado_fisico.dart';

/// Los dibujitos de las teclas de borrar y ocultar, tal como se pintan.
const teclaBorrar = '⌫';
const teclaOcultar = '⌄';

void main() {
  /// Un detector que se puede prender y apagar a mano: en los tests no hay
  /// lector Bluetooth ni canal nativo.
  TecladoFisico detectorEn(bool conectado) => TecladoFisico.fijo(conectado);

  Future<void> montar(
    WidgetTester tester, {
    required TecladoFisico detector,
    required Widget cuerpo,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            TecladoDelApp(detector: detector, child: child!),
        home: Scaffold(body: cuerpo),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sin lector conectado no se mete: manda el teclado del sistema', (
    tester,
  ) async {
    final controlador = TextEditingController();
    await montar(
      tester,
      detector: detectorEn(false),
      cuerpo: TextField(controller: controlador),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.byType(TecladoEnPantalla), findsNothing);
  });

  testWidgets('con lector conectado sale el teclado de la app al enfocar', (
    tester,
  ) async {
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(controller: TextEditingController()),
    );

    expect(find.byType(TecladoEnPantalla), findsNothing);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.byType(TecladoEnPantalla), findsOneWidget);
  });

  testWidgets('un campo de aretes saca el pad numerico y escribe digitos', (
    tester,
  ) async {
    final controlador = TextEditingController();
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(
        controller: controlador,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    // El pad numerico no trae letras.
    expect(find.text('q'), findsNothing);
    expect(find.text('7'), findsOneWidget);
    // Sin decimales el campo de arete no muestra la coma.
    expect(find.text(','), findsNothing);

    await tester.tap(find.text('7'));
    await tester.tap(find.text('3'));
    await tester.pumpAndSettle();

    expect(controlador.text, '73');
  });

  testWidgets('un campo de peso trae la coma decimal', (tester) async {
    final controlador = TextEditingController();
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(
        controller: controlador,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    await tester.tap(find.text('4'));
    await tester.tap(find.text(','));
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();

    expect(controlador.text, '4,5');
  });

  testWidgets('el borrar quita el ultimo caracter', (tester) async {
    final controlador = TextEditingController(text: '123');
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(
        controller: controlador,
        keyboardType: TextInputType.number,
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    await tester.tap(find.text(teclaBorrar));
    await tester.pumpAndSettle();

    expect(controlador.text, '12');
  });

  testWidgets('un campo de correo saca las letras y respeta las mayusculas', (
    tester,
  ) async {
    final controlador = TextEditingController();
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(
        controller: controlador,
        keyboardType: TextInputType.emailAddress,
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.text('q'), findsOneWidget);

    await tester.tap(find.text('h'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mayus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    // La mayuscula se apaga sola despues de una letra.
    await tester.tap(find.text('t'));
    await tester.pumpAndSettle();

    expect(controlador.text, 'hAt');
  });

  testWidgets('la capa 123 del teclado de letras trae arroba y acentos', (
    tester,
  ) async {
    final controlador = TextEditingController();
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(
        controller: controlador,
        keyboardType: TextInputType.emailAddress,
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('123'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('@'));
    await tester.tap(find.text('é'));
    await tester.pumpAndSettle();

    expect(controlador.text, '@é');
  });

  testWidgets('la tecla grande dispara onSubmitted, no un salto de linea', (
    tester,
  ) async {
    String? enviado;
    final controlador = TextEditingController(text: '99');
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(
        controller: controlador,
        keyboardType: TextInputType.number,
        onSubmitted: (valor) => enviado = valor,
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.text('Listo'), findsOneWidget);
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();

    expect(enviado, '99');
  });

  testWidgets('con textInputAction next la tecla grande dice Siguiente', (
    tester,
  ) async {
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(
        controller: TextEditingController(),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.text('Siguiente'), findsOneWidget);
  });

  testWidgets('ocultar lo cierra, y vuelve al cambiar de campo', (
    tester,
  ) async {
    final primero = FocusNode();
    final segundo = FocusNode();
    addTearDown(primero.dispose);
    addTearDown(segundo.dispose);

    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: Column(
        children: [
          TextField(focusNode: primero, controller: TextEditingController()),
          TextField(focusNode: segundo, controller: TextEditingController()),
        ],
      ),
    );

    primero.requestFocus();
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsOneWidget);

    await tester.tap(find.text(teclaOcultar));
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsNothing);

    segundo.requestFocus();
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsOneWidget);
  });

  testWidgets('al soltar el foco el teclado se va', (tester) async {
    final foco = FocusNode();
    addTearDown(foco.dispose);

    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(focusNode: foco, controller: TextEditingController()),
    );

    foco.requestFocus();
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsOneWidget);

    foco.unfocus();
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsNothing);
  });

  testWidgets('desconectar el lector devuelve el teclado del sistema', (
    tester,
  ) async {
    final detector = detectorEn(true);
    final foco = FocusNode();
    addTearDown(foco.dispose);

    await montar(
      tester,
      detector: detector,
      cuerpo: TextField(focusNode: foco, controller: TextEditingController()),
    );

    foco.requestFocus();
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsOneWidget);

    detector.conectado.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsNothing);
  });

  testWidgets('si el sistema igual muestra su teclado, el propio se quita', (
    tester,
  ) async {
    final foco = FocusNode();
    addTearDown(foco.dispose);

    // En Android se puede prender «mostrar teclado en pantalla» aunque haya
    // teclado fisico: ahi el sistema tapa media pantalla desde abajo.
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(viewInsets: EdgeInsets.only(bottom: 300)),
        child: MaterialApp(
          builder: (context, child) =>
              TecladoDelApp(detector: detectorEn(true), child: child!),
          home: Scaffold(
            body: TextField(
              focusNode: foco,
              controller: TextEditingController(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    foco.requestFocus();
    await tester.pumpAndSettle();

    expect(find.byType(TecladoEnPantalla), findsNothing);
  });

  testWidgets('el teclado deja lugar abajo para que el campo no quede tapado', (
    tester,
  ) async {
    late double insetAdentro;
    final foco = FocusNode();
    addTearDown(foco.dispose);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            TecladoDelApp(detector: detectorEn(true), child: child!),
        home: Builder(
          builder: (context) {
            insetAdentro = MediaQuery.viewInsetsOf(context).bottom;
            return Scaffold(
              body: TextField(
                focusNode: foco,
                controller: TextEditingController(),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(insetAdentro, 0);

    foco.requestFocus();
    await tester.pumpAndSettle();

    final alto = tester.getSize(find.byType(TecladoEnPantalla)).height;
    expect(insetAdentro, greaterThan(0));
    expect(insetAdentro, alto);
  });
}
