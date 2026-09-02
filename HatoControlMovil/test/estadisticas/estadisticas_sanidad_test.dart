import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/estadisticas/estadisticas_sanidad.dart';

void main() {
  group('dosis y costo oro', () {
    test('por peso: 50 ml cada 10 kg a 300 kg = 1500 ml', () {
      final d = calcularDosisMedicamento(
        tipoAplicacion: TipoAplicacionMedicamento.porPeso,
        costoEnvase: 10000,
        mlEnvase: 400,
        dosisCantidad: 50,
        dosisPorCadaKg: 10,
        pesoKg: 300,
      );
      expect(d.mlAplicados, 1500);
      expect(d.etiquetaDosis, '1500 ml');
      // 10000/400 * 1500 = 37500
      expect(d.costoUso, 37500);
    });

    test('líquido ejemplo oro: 10000/10ml * 2ml = 2000', () {
      expect(
        costoUsoLiquido(costoEnvase: 10000, mlEnvase: 10, mlAplicados: 2),
        2000,
      );
    });

    test('spray: 15000/50 = 300', () {
      final d = calcularDosisMedicamento(
        tipoAplicacion: TipoAplicacionMedicamento.porAplicacion,
        costoEnvase: 15000,
        aplicacionesPorEnvase: 50,
        pesoKg: 300,
      );
      expect(d.aplicaciones, 1);
      expect(d.costoUso, 300);
    });

    test('retiro: fecha + días', () {
      final fin = fechaFinRetiro(DateTime(2026, 1, 1), 30);
      expect(fin, DateTime(2026, 1, 31));
      expect(estaEnRetiro(fin, hoy: DateTime(2026, 1, 31)), isTrue);
      expect(estaEnRetiro(fin, hoy: DateTime(2026, 2, 1)), isFalse);
    });

    test('utilidad oro sin otros', () {
      expect(
        utilidadOro(
          precioVenta: 1000,
          precioCompra: 400,
          costoDietas: 100,
          costoSanidad: 50,
        ),
        450,
      );
    });
  });
}
