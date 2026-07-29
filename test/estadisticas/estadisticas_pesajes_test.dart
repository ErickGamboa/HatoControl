import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/estadisticas/estadisticas_pesajes.dart';

void main() {
  group('diasCalendario', () {
    test('cuenta días de calendario, no bloques de 24 horas', () {
      expect(
        diasCalendario(DateTime(2026, 1, 10, 18), DateTime(2026, 1, 11, 8)),
        1,
      );
      expect(diasCalendario(DateTime(2026, 1, 10), DateTime(2026, 2, 15)), 36);
    });
  });

  group('gananciaDiariaGlobal', () {
    test('null con menos de dos pesajes', () {
      expect(gananciaDiariaGlobal([]), isNull);
      expect(
        gananciaDiariaGlobal([(fecha: DateTime(2026, 1, 10), peso: 210.0)]),
        isNull,
      );
    });

    test('null si primer y último pesaje caen el mismo día', () {
      expect(
        gananciaDiariaGlobal([
          (fecha: DateTime(2026, 1, 10, 8), peso: 210.0),
          (fecha: DateTime(2026, 1, 10, 17), peso: 212.0),
        ]),
        isNull,
      );
    });

    test('promedio global = (último - primero) / días de calendario', () {
      // Ejemplo de la especificación: 210 (10 Ene) → 248 (20 Mar) en 69 días.
      final promedio = gananciaDiariaGlobal([
        (fecha: DateTime(2026, 1, 10), peso: 210.0),
        (fecha: DateTime(2026, 2, 15), peso: 232.0),
        (fecha: DateTime(2026, 3, 20), peso: 248.0),
      ]);
      expect(promedio, closeTo(38 / 69, 0.0001));
    });

    test('pérdida de peso produce promedio negativo', () {
      final promedio = gananciaDiariaGlobal([
        (fecha: DateTime(2026, 1, 1), peso: 200.0),
        (fecha: DateTime(2026, 1, 6), peso: 190.0),
      ]);
      expect(promedio, closeTo(-2, 0.0001));
    });

    test('acepta el historial en cualquier orden', () {
      final promedio = gananciaDiariaGlobal([
        (fecha: DateTime(2026, 3, 20), peso: 248.0),
        (fecha: DateTime(2026, 1, 10), peso: 210.0),
      ]);
      expect(promedio, closeTo(38 / 69, 0.0001));
    });
  });

  group('resumenPorPeriodos', () {
    test('lista vacía produce resumen vacío', () {
      expect(resumenPorPeriodos([]), isEmpty);
    });

    test('una sola jornada: conteo y pesos, sin ganancias', () {
      final periodos = resumenPorPeriodos([
        (animalId: 'a', fecha: DateTime(2026, 1, 10), peso: 210.0),
        (animalId: 'b', fecha: DateTime(2026, 1, 10), peso: 190.0),
      ]);

      expect(periodos, hasLength(1));
      final p = periodos.single;
      expect(p.desde, isNull);
      expect(p.hasta, DateTime(2026, 1, 10));
      expect(p.animales, 2);
      expect(p.pesoPromedio, 200);
      expect(p.pesoMinimo, 190);
      expect(p.pesoMaximo, 210);
      expect(p.gananciaPromedio, isNull);
      expect(p.gananciaDiariaPromedio, isNull);
      expect(p.animalesConGanancia, 0);
    });

    test('ejemplo de la especificación: períodos con animal que entra y '
        'animal que se sale', () {
      // Jornadas: 10 Ene, 15 Feb (36 días), 20 Mar (33 días).
      // A pesa siempre; B falta en marzo; C entra en febrero.
      final periodos = resumenPorPeriodos([
        (animalId: 'A', fecha: DateTime(2026, 1, 10), peso: 210.0),
        (animalId: 'B', fecha: DateTime(2026, 1, 10), peso: 190.0),
        (animalId: 'A', fecha: DateTime(2026, 2, 15), peso: 232.0),
        (animalId: 'B', fecha: DateTime(2026, 2, 15), peso: 210.0),
        (animalId: 'C', fecha: DateTime(2026, 2, 15), peso: 200.0),
        (animalId: 'A', fecha: DateTime(2026, 3, 20), peso: 248.0),
        (animalId: 'C', fecha: DateTime(2026, 3, 20), peso: 215.0),
      ]);

      expect(periodos, hasLength(3));

      final enero = periodos[0];
      expect(enero.animales, 2);
      expect(enero.gananciaPromedio, isNull);

      final febrero = periodos[1];
      expect(febrero.desde, DateTime(2026, 1, 10));
      expect(febrero.hasta, DateTime(2026, 2, 15));
      expect(febrero.animales, 3); // C entra, cuenta en el conteo
      expect(febrero.pesoPromedio, closeTo(214, 0.0001));
      expect(febrero.pesoMinimo, 200);
      expect(febrero.pesoMaximo, 232);
      // Solo A (+22) y B (+20) tienen pesaje previo; C no distorsiona.
      expect(febrero.animalesConGanancia, 2);
      expect(febrero.gananciaPromedio, closeTo(21, 0.0001));
      expect(
        febrero.gananciaDiariaPromedio,
        closeTo((22 / 36 + 20 / 36) / 2, 0.0001),
      );

      final marzo = periodos[2];
      expect(marzo.desde, DateTime(2026, 2, 15));
      expect(marzo.animales, 2); // B faltó a la jornada
      expect(marzo.pesoPromedio, closeTo(231.5, 0.0001));
      expect(marzo.gananciaPromedio, closeTo(15.5, 0.0001)); // A +16, C +15
      expect(
        marzo.gananciaDiariaPromedio,
        closeTo((16 / 33 + 15 / 33) / 2, 0.0001),
      );
    });

    test('solo animales con peso en ambas jornadas consecutivas del lote', () {
      final periodos = resumenPorPeriodos([
        (animalId: 'D', fecha: DateTime(2026, 1, 10), peso: 100.0),
        (animalId: 'E', fecha: DateTime(2026, 1, 10), peso: 150.0),
        (animalId: 'E', fecha: DateTime(2026, 2, 15), peso: 160.0),
        // D falta el 15 Feb y reaparece el 20 Mar: no entra al promedio Feb→Mar.
        (animalId: 'D', fecha: DateTime(2026, 3, 20), peso: 130.0),
        (animalId: 'E', fecha: DateTime(2026, 3, 20), peso: 175.0),
      ]);

      final marzo = periodos.last;
      expect(marzo.animales, 2);
      expect(marzo.animalesConGanancia, 1);
      // Solo E (+15 en 33 días) estuvo en ambas fechas del período.
      expect(marzo.gananciaPromedio, closeTo(15, 0.0001));
      expect(marzo.gananciaDiariaPromedio, closeTo(15 / 33, 0.0001));
    });

    test('dos pesajes del mismo animal el mismo día: se usa el último', () {
      final periodos = resumenPorPeriodos([
        (animalId: 'a', fecha: DateTime(2026, 1, 10, 8), peso: 210.0),
        (animalId: 'a', fecha: DateTime(2026, 1, 10, 16), peso: 213.0),
      ]);

      expect(periodos, hasLength(1));
      expect(periodos.single.animales, 1);
      expect(periodos.single.pesoPromedio, 213);
    });

    test('pérdida de peso produce ganancia promedio negativa', () {
      final periodos = resumenPorPeriodos([
        (animalId: 'a', fecha: DateTime(2026, 1, 1), peso: 200.0),
        (animalId: 'a', fecha: DateTime(2026, 1, 11), peso: 195.0),
      ]);

      final ultimo = periodos.last;
      expect(ultimo.gananciaPromedio, closeTo(-5, 0.0001));
      expect(ultimo.gananciaDiariaPromedio, closeTo(-0.5, 0.0001));
    });
  });
}
