import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/estadisticas/estadisticas_financieras.dart';

AporteFinanciero aporte({
  double compra = 0,
  double alimentacion = 0,
  double sanidad = 0,
  double gastosFijos = 0,
  double? dineroRecibido,
  double? utilidad,
  double kilosGanados = 0,
}) => (
  compra: compra,
  alimentacion: alimentacion,
  sanidad: sanidad,
  gastosFijos: gastosFijos,
  dineroRecibido: dineroRecibido,
  utilidad: utilidad,
  kilosGanados: kilosGanados,
);

void main() {
  test('suma los costos de todos los animales del grupo', () {
    final r = sumarFinanciero([
      aporte(compra: 100, alimentacion: 20, sanidad: 5, gastosFijos: 3),
      aporte(compra: 200, alimentacion: 30, sanidad: 5, gastosFijos: 7),
    ]);

    expect(r.animales, 2);
    expect(r.compra, 300);
    expect(r.alimentacion, 50);
    expect(r.sanidad, 10);
    expect(r.gastosFijos, 10);
    expect(r.costoTotal, 370);
  });

  test('la utilidad solo cuenta a los vendidos y liquidados', () {
    final r = sumarFinanciero([
      // En pie: suma costo, no utilidad.
      aporte(compra: 100, alimentacion: 20),
      // Vendido y liquidado.
      aporte(compra: 100, alimentacion: 20, dineroRecibido: 200, utilidad: 80),
      // Vendido pero la planta no ha liquidado: utilidad null.
      aporte(compra: 100, alimentacion: 20),
    ]);

    expect(r.animales, 3);
    expect(r.conUtilidad, 1);
    expect(r.utilidad, 80);
    expect(r.ventaRecibida, 200);
    // El costo sí incluye a los tres.
    expect(r.costoTotal, 360);
  });

  test('una utilidad negativa resta, no se ignora', () {
    final r = sumarFinanciero([
      aporte(dineroRecibido: 200, utilidad: 80),
      aporte(dineroRecibido: 100, utilidad: -30),
    ]);

    expect(r.conUtilidad, 2);
    expect(r.utilidad, 50);
  });

  test('el costo por kilo ganado deja la compra afuera', () {
    final r = sumarFinanciero([
      aporte(
        compra: 200000,
        alimentacion: 45000,
        sanidad: 4000,
        gastosFijos: 1000,
        kilosGanados: 100,
      ),
    ]);

    // (45000 + 4000 + 1000) / 100 = 500, sin los 200000 de compra.
    expect(r.costoDeEngorde, 50000);
    expect(r.costoPorKiloGanado, 500);
  });

  test('sin kilos ganados no hay costo por kilo en vez de dividir entre cero', () {
    final r = sumarFinanciero([aporte(alimentacion: 5000)]);
    expect(r.kilosGanados, 0);
    expect(r.costoPorKiloGanado, isNull);
  });

  test('el desglose ordena de mayor a menor y omite lo que está en cero', () {
    final r = sumarFinanciero([
      aporte(compra: 100, alimentacion: 300, sanidad: 100, gastosFijos: 0),
    ]);

    final tipos = r.desglose.map((p) => p.tipo).toList();
    expect(tipos, ['Dietas', 'Compra', 'Sanidad']);
    expect(r.desglose.first.porcentaje, 60);
    expect(tipos, isNot(contains('Gastos fijos')));
  });

  test('sin costos el desglose viene vacío', () {
    expect(sumarFinanciero([aporte()]).desglose, isEmpty);
    expect(sumarFinanciero([]).costoTotal, 0);
  });
}
