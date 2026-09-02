import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/estadisticas/estadisticas_gastos_fijos.dart';

/// Julio 2026 tiene 31 días; agosto también. Se usa un "hoy" fijo para que los
/// meses cerrados no dependan de la fecha real de la corrida.
final _hoy = DateTime(2026, 8, 15);
final _julio = DateTime(2026, 7, 1);

GastoFijoVigencia _peon({double monto = 300000, DateTime? hasta}) =>
    GastoFijoVigencia(
      gastoFijoId: 'g-peon',
      monto: monto,
      mensual: true,
      desde: _julio,
      hasta: hasta,
    );

void main() {
  group('días y meses', () {
    test('días del mes contempla bisiestos', () {
      expect(diasDelMes(DateTime(2026, 2, 1)), 28);
      expect(diasDelMes(DateTime(2028, 2, 1)), 29);
      expect(diasDelMes(DateTime(2000, 2, 1)), 29);
      expect(diasDelMes(DateTime(1900, 2, 1)), 28);
      expect(diasDelMes(DateTime(2026, 7, 1)), 31);
      expect(diasDelMes(DateTime(2026, 4, 1)), 30);
    });

    test('el animal que entró el día 20 estuvo 12 días (inclusivos)', () {
      final e = EstanciaAnimal(animalId: 'k', ingreso: DateTime(2026, 7, 20));
      expect(diasEnMes(e, _julio, hoy: _hoy), 12);
    });

    test('animal presente todo el mes estuvo 31 días', () {
      final e = EstanciaAnimal(animalId: 'a', ingreso: DateTime(2026, 6, 1));
      expect(diasEnMes(e, _julio, hoy: _hoy), 31);
    });

    test('el mes en curso se corta en hoy, no corre al futuro', () {
      final e = EstanciaAnimal(animalId: 'a', ingreso: DateTime(2026, 6, 1));
      expect(diasEnMes(e, DateTime(2026, 8, 1), hoy: _hoy), 15);
    });

    test('animal vendido no cuenta días después de la salida', () {
      final e = EstanciaAnimal(
        animalId: 'a',
        ingreso: DateTime(2026, 6, 1),
        salida: DateTime(2026, 7, 10),
      );
      expect(diasEnMes(e, _julio, hoy: _hoy), 10);
      expect(diasEnMes(e, DateTime(2026, 8, 1), hoy: _hoy), 0);
    });

    test('mes anterior al ingreso da 0 días', () {
      final e = EstanciaAnimal(animalId: 'a', ingreso: DateTime(2026, 7, 5));
      expect(diasEnMes(e, DateTime(2026, 6, 1), hoy: _hoy), 0);
    });

    test('gasto mensual devenga el monto completo en meses cerrados', () {
      final meses = mesesDeGasto(_peon(), hoy: _hoy);
      expect(meses.length, 2);
      expect(meses.first.mes, _julio);
      expect(meses.first.montoDevengado, closeTo(300000, 0.01));
    });

    test('el mes en curso devenga solo los días transcurridos', () {
      final meses = mesesDeGasto(_peon(), hoy: _hoy);
      // 15 de 31 días de agosto.
      expect(meses.last.mes, DateTime(2026, 8, 1));
      expect(meses.last.montoDevengado, closeTo(300000 * 15 / 31, 0.01));
    });

    test('dar de baja corta el devengo en el mes de la baja', () {
      final meses = mesesDeGasto(
        _peon(hasta: DateTime(2026, 7, 20)),
        hoy: _hoy,
      );
      expect(meses.length, 1);
      expect(meses.single.montoDevengado, closeTo(300000 * 20 / 31, 0.01));
    });

    test('gasto único devenga el monto completo en su mes', () {
      final meses = mesesDeGasto(
        GastoFijoVigencia(
          gastoFijoId: 'g-cerca',
          monto: 85000,
          mensual: false,
          desde: DateTime(2026, 8, 12),
        ),
        hoy: _hoy,
      );
      expect(meses.length, 1);
      expect(meses.single.mes, DateTime(2026, 8, 1));
      expect(meses.single.montoDevengado, 85000);
    });

    test('gasto que todavía no empieza no devenga nada', () {
      final meses = mesesDeGasto(
        GastoFijoVigencia(
          gastoFijoId: 'g',
          monto: 1000,
          mensual: true,
          desde: DateTime(2026, 12, 1),
        ),
        hoy: _hoy,
      );
      expect(meses, isEmpty);
    });
  });

  group('prorrateo por días-animal', () {
    test('caso del usuario: 10 animales el mes completo + 1 de 12 días', () {
      final activos = [
        for (var i = 0; i < 10; i++)
          EstanciaAnimal(animalId: 'a$i', ingreso: DateTime(2026, 6, 1)),
        EstanciaAnimal(animalId: 'k', ingreso: DateTime(2026, 7, 20)),
      ];

      final partes = prorratearGastoMes(
        gastoMes: GastoMes(
          gastoFijoId: 'g-peon',
          mes: _julio,
          montoDevengado: 300000,
        ),
        activos: activos,
        congelados: const [],
        hoy: _hoy,
      );

      // 10 × 31 + 12 = 322 días-animal → ₡931,68 por animal-día.
      expect(totalDeAnimal(partes, 'a0'), closeTo(28881.99, 0.05));
      expect(totalDeAnimal(partes, 'k'), closeTo(11180.12, 0.05));

      final sumaTotal = partes.fold<double>(0, (s, p) => s + p.monto);
      expect(sumaTotal, closeTo(300000, 0.000001));
      expect(partes.firstWhere((p) => p.animalId == 'k').dias, 12);
    });

    test('reparte exactamente el 100% con entradas y salidas mezcladas', () {
      final activos = [
        EstanciaAnimal(animalId: 'a', ingreso: DateTime(2026, 1, 1)),
        EstanciaAnimal(animalId: 'b', ingreso: DateTime(2026, 7, 15)),
        EstanciaAnimal(
          animalId: 'c',
          ingreso: DateTime(2026, 7, 3),
          salida: DateTime(2026, 7, 25),
        ),
      ];

      final partes = prorratearGastos(
        gastos: [_peon(monto: 137500)],
        activos: activos,
        congelados: const [],
        hoy: _hoy,
      );

      final devengado = mesesDeGasto(
        _peon(monto: 137500),
        hoy: _hoy,
      ).fold<double>(0, (s, m) => s + m.montoDevengado);
      final repartido = partes.fold<double>(0, (s, p) => s + p.monto);
      expect(repartido, closeTo(devengado, 0.000001));
    });

    test('lo ya congelado se descuenta antes de repartir', () {
      final activos = [
        EstanciaAnimal(animalId: 'b', ingreso: DateTime(2026, 6, 1)),
        EstanciaAnimal(animalId: 'c', ingreso: DateTime(2026, 6, 1)),
      ];

      final partes = prorratearGastoMes(
        gastoMes: GastoMes(
          gastoFijoId: 'g-peon',
          mes: _julio,
          montoDevengado: 300000,
        ),
        activos: activos,
        // A ya se vendió con ⅓ congelado.
        congelados: [
          CargoCongelado(gastoFijoId: 'g-peon', mes: _julio, monto: 100000),
        ],
        hoy: _hoy,
      );

      // Queda ₡200.000 para B y C: ₡100.000 cada uno, igual que cuando A
      // estaba activo y los tres veían ⅓. Sin saltos.
      expect(totalDeAnimal(partes, 'b'), closeTo(100000, 0.01));
      expect(totalDeAnimal(partes, 'c'), closeTo(100000, 0.01));
    });

    test('gasto atrasado lo absorben completo los no vendidos', () {
      // El gasto de julio se digita cuando A ya se vendió: A no tiene cargo
      // congelado de este gasto, así que B y C se llevan el 100%.
      final partes = prorratearGastoMes(
        gastoMes: GastoMes(
          gastoFijoId: 'g-luz',
          mes: _julio,
          montoDevengado: 60000,
        ),
        activos: [
          EstanciaAnimal(animalId: 'b', ingreso: DateTime(2026, 6, 1)),
          EstanciaAnimal(animalId: 'c', ingreso: DateTime(2026, 6, 1)),
        ],
        congelados: const [],
        hoy: _hoy,
      );

      expect(totalDeAnimal(partes, 'b'), closeTo(30000, 0.01));
      expect(totalDeAnimal(partes, 'c'), closeTo(30000, 0.01));
    });

    test('sin animales presentes no se reparte nada (no es error)', () {
      final partes = prorratearGastoMes(
        gastoMes: GastoMes(
          gastoFijoId: 'g',
          mes: _julio,
          montoDevengado: 50000,
        ),
        activos: [EstanciaAnimal(animalId: 'a', ingreso: DateTime(2026, 8, 1))],
        congelados: const [],
        hoy: _hoy,
      );
      expect(partes, isEmpty);
    });

    test('un gasto ya cubierto por lo congelado no vuelve a repartirse', () {
      final partes = prorratearGastoMes(
        gastoMes: GastoMes(
          gastoFijoId: 'g',
          mes: _julio,
          montoDevengado: 50000,
        ),
        activos: [EstanciaAnimal(animalId: 'a', ingreso: DateTime(2026, 6, 1))],
        congelados: [
          CargoCongelado(gastoFijoId: 'g', mes: _julio, monto: 50000),
        ],
        hoy: _hoy,
      );
      expect(partes, isEmpty);
    });

    test('sin gastos no hay partes', () {
      expect(
        prorratearGastos(
          gastos: const [],
          activos: [
            EstanciaAnimal(animalId: 'a', ingreso: DateTime(2026, 6, 1)),
          ],
          congelados: const [],
          hoy: _hoy,
        ),
        isEmpty,
      );
    });
  });
}
