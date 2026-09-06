import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/app/teclado/teclado_del_app.dart';
import 'package:hato_control/app/teclado/teclado_del_sistema.dart';
import 'package:hato_control/app/teclado/teclado_en_pantalla.dart';

/// Los dibujitos de las teclas de borrar y ocultar, tal como se pintan.
const teclaBorrar = '⌫';
const teclaOcultar = '⌄';

void main() {
  /// Un detector que se puede prender y apagar a mano: en los tests no hay
  /// lector Bluetooth ni canal nativo.
  TecladoDelSistema detectorEn(bool escondido) =>
      TecladoDelSistema.fijo(escondido);

  /// El teclado propio se toma un momento antes de dibujarse, para no cruzarse
  /// con el del sistema si este llegara a subir. Los tests tienen que dejar
  /// pasar esa espera igual que el ganadero.
  Future<void> esperarAlTeclado(WidgetTester tester) async {
    await tester.pump(TecladoDelApp.esperaAntesDeMostrar);
    await tester.pumpAndSettle();
  }

  Future<void> montar(
    WidgetTester tester, {
    required TecladoDelSistema detector,
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

  Future<void> enfocar(WidgetTester tester) async {
    await tester.tap(find.byType(TextField).first);
    await esperarAlTeclado(tester);
  }

  testWidgets('sin lector conectado no se mete: manda el teclado del sistema', (
    tester,
  ) async {
    await montar(
      tester,
      detector: detectorEn(false),
      cuerpo: TextField(controller: TextEditingController()),
    );

    await enfocar(tester);

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

    await enfocar(tester);

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

    await enfocar(tester);

    // El pad numerico no trae letras.
    expect(find.text('q'), findsNothing);
    expect(find.text('7'), findsOneWidget);
    // Sin decimales el campo del arete no muestra la coma.
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

    await enfocar(tester);

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

    await enfocar(tester);

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

    await enfocar(tester);

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

    await enfocar(tester);
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
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(
        controller: TextEditingController(text: '99'),
        keyboardType: TextInputType.number,
        onSubmitted: (valor) => enviado = valor,
      ),
    );

    await enfocar(tester);

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

    await enfocar(tester);

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
    await esperarAlTeclado(tester);
    expect(find.byType(TecladoEnPantalla), findsOneWidget);

    await tester.tap(find.text(teclaOcultar));
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsNothing);

    segundo.requestFocus();
    await esperarAlTeclado(tester);
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
    await esperarAlTeclado(tester);
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
    await esperarAlTeclado(tester);
    expect(find.byType(TecladoEnPantalla), findsOneWidget);

    detector.escondido.value = false;
    await tester.pumpAndSettle();
    expect(find.byType(TecladoEnPantalla), findsNothing);
  });

  group('nunca dos teclados', () {
    testWidgets('si el sistema igual muestra el suyo, el propio se quita', (
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
      await esperarAlTeclado(tester);

      expect(find.byType(TecladoEnPantalla), findsNothing);
    });

    testWidgets('mientras sube el del sistema, el propio no se asoma ni un frame', (
      tester,
    ) async {
      final foco = FocusNode();
      addTearDown(foco.dispose);
      final tapado = ValueNotifier<double>(0);
      addTearDown(tapado.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder<double>(
          valueListenable: tapado,
          builder: (context, alto, _) => MediaQuery(
            data: MediaQueryData(viewInsets: EdgeInsets.only(bottom: alto)),
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
        ),
      );
      await tester.pumpAndSettle();

      foco.requestFocus();
      // El teclado del sistema tarda en subir: pasa por alturas chiquitas antes
      // de tapar la pantalla. El propio no debe verse en ningun momento del
      // camino, ni siquiera un parpadeo.
      for (var ms = 0; ms <= 400; ms += 25) {
        tapado.value = (ms * 1.2).clamp(0, 300).toDouble();
        await tester.pump(const Duration(milliseconds: 25));
        expect(
          find.byType(TecladoEnPantalla),
          findsNothing,
          reason: 'se asomo a los $ms ms, con ${tapado.value} tapados',
        );
      }
    });
  });

  testWidgets('nunca sale solo: hace falta que el ganadero toque el campo', (
    tester,
  ) async {
    // Ningun campo de la app pide el foco al aparecer. Si alguien vuelve a
    // poner un autofocus, este test lo caza: al abrirse la pantalla no debe
    // haber teclado tapando nada.
    await montar(
      tester,
      detector: detectorEn(true),
      cuerpo: TextField(controller: TextEditingController()),
    );

    await tester.pump(TecladoDelApp.esperaAntesDeMostrar);
    await tester.pumpAndSettle();

    expect(find.byType(TecladoEnPantalla), findsNothing);
  });

  testWidgets('el teclado propio es mas bajo que el del sistema', (
    tester,
  ) async {
    // Las pantallas estan armadas para el hueco que deja el teclado del
    // sistema (35-40 % en un telefono). Si el propio se pasa, la lista del dia
    // de Trabajo se queda sin espacio y los dialogos dejan botones afuera.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    for (final tipo in [
      TextInputType.number,
      const TextInputType.numberWithOptions(decimal: true),
      TextInputType.emailAddress,
    ]) {
      final foco = FocusNode();
      addTearDown(foco.dispose);
      await montar(
        tester,
        detector: detectorEn(true),
        cuerpo: TextField(
          focusNode: foco,
          controller: TextEditingController(),
          keyboardType: tipo,
        ),
      );
      foco.requestFocus();
      await esperarAlTeclado(tester);

      final alto = tester.getSize(find.byType(TecladoEnPantalla)).height;
      final pantalla = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(
        alto / pantalla,
        lessThan(0.35),
        reason: 'el teclado de $tipo ocupa demasiado',
      );
    }
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
    await esperarAlTeclado(tester);

    final alto = tester.getSize(find.byType(TecladoEnPantalla)).height;
    expect(insetAdentro, greaterThan(0));
    expect(insetAdentro, alto);
  });
}
