import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control_web/escritorio/secciones.dart';

void main() {
  group('SeccionEscritorio.paraFinca', () {
    test('quien puede escribir ve todos los módulos', () {
      final secciones = SeccionEscritorio.paraFinca(soloLectura: false);

      expect(secciones, SeccionEscritorio.values);
      expect(secciones, contains(SeccionEscritorio.pesaje));
    });

    test('un invitado de solo lectura no entra a la manga', () {
      final secciones = SeccionEscritorio.paraFinca(soloLectura: true);

      expect(secciones, isNot(contains(SeccionEscritorio.pesaje)));
      // Pero sí ve todo lo demás: le compartieron la finca para verla.
      expect(secciones, contains(SeccionEscritorio.lotes));
      expect(secciones, contains(SeccionEscritorio.analisis));
      expect(secciones.length, SeccionEscritorio.values.length - 1);
    });
  });

  test('todas las secciones tienen un ícono para la barra lateral', () {
    for (final seccion in SeccionEscritorio.values) {
      expect(
        seccion.icono != null || seccion.asset != null,
        isTrue,
        reason: 'La sección ${seccion.name} se vería sin ícono en el menú',
      );
      expect(seccion.etiqueta, isNotEmpty);
    }
  });
}
