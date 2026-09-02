import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/estadisticas/estadisticas_economicas.dart';

void main() {
  test('ejemplo roadmap: utilidad ₡147 000 sobre venta ₡780 000', () {
    final r = calcularResumenEconomico(
      precioCompra: 520000,
      periodosAlimentacion: [
        PeriodoAlimentacion(
          desde: DateTime(2026, 1, 1),
          hasta: DateTime(2026, 1, 10),
          costoAnimalDia: 10555.5555555556,
        ),
      ],
      costosSanitarios: const [18000],
      costosOtros: const [],
      precioVenta: 780000,
      hasta: DateTime(2026, 1, 10),
    );

    expect(r.costoAlimentacion, closeTo(95000, 1));
    expect(r.costoSanitario, 18000);
    expect(r.costoTotal, closeTo(633000, 1));
    expect(r.utilidad, closeTo(147000, 1));
    expect(r.margenPorcentaje, closeTo(18.85, 0.1));
    expect(r.rentabilidadPorcentaje, closeTo(23.22, 0.1));
  });

  test('sin venta utilidad y márgenes son null', () {
    final r = calcularResumenEconomico(
      precioCompra: null,
      periodosAlimentacion: const [],
      costosSanitarios: const [null, 5000],
      costosOtros: const [1000],
      precioVenta: null,
    );
    expect(r.costoSanitario, 5000);
    expect(r.costoOtros, 1000);
    expect(r.costoTotal, 6000);
    expect(r.utilidad, isNull);
    expect(r.margenPorcentaje, isNull);
  });

  test('costo alimentación suma días por período', () {
    final total = costoAlimentacionDesdePeriodos([
      PeriodoAlimentacion(
        desde: DateTime(2026, 1, 1),
        hasta: DateTime(2026, 1, 4),
        costoAnimalDia: 100,
      ),
    ], hasta: DateTime(2026, 1, 4));
    expect(total, 300);
  });
}
