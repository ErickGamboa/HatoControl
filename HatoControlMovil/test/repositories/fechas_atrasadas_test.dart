import 'package:drift/drift.dart' show OrderingTerm, BooleanExpressionOperators;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/medicamentos_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/reglas_de_fechas.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

/// Datos que se digitan días después de que pasaron: el peón pesa el 5 y el
/// patrón lo pasa a la app el 8. Todo tiene que quedar con el día real, y las
/// fechas imposibles se bloquean con un mensaje.
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  late DietasRepository dietas;
  late VentasRepository ventas;
  late SanidadRepository sanidad;
  late MedicamentosRepository meds;

  final hoy = DateTime.now();
  DateTime haceDias(int n) {
    final d = hoy.subtract(Duration(days: n));
    return DateTime(d.year, d.month, d.day);
  }

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
    dietas = DietasRepository(db);
    ventas = VentasRepository(db);
    sanidad = SanidadRepository(db);
    meds = MedicamentosRepository(db);
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'f1',
            nombre: 'Finca',
            creadaPor: 'u1',
            createdAt: hoy,
            updatedAt: hoy,
          ),
        );
    for (final (id, nombre) in [('l1', 'Engorde'), ('l2', 'Montaña')]) {
      await db
          .into(db.lotes)
          .insert(
            LotesCompanion.insert(
              id: id,
              fincaId: 'f1',
              nombre: nombre,
              createdAt: hoy,
              updatedAt: hoy,
            ),
          );
    }
  });

  tearDown(() async => db.close());

  Future<AnimalRow> animal(String ident) async =>
      (await pesajes.buscarAnimal('f1', ident))!;

  Future<List<PesajeRow>> pesajesDe(String animalId) {
    return (db.select(db.pesajes)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
        .get();
  }

  Future<AnimalRow> alta(
    String ident, {
    double? peso = 300,
    required int haceNDias,
  }) async {
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: 'l1',
      identificador: ident,
      peso: peso,
      registradoPor: 'u1',
      pesoCompra: peso,
      precioKgCompra: peso == null ? null : 1000,
      precioCompra: peso == null ? 300000 : null,
      fecha: haceDias(haceNDias),
    );
    return animal(ident);
  }

  group('Trabajo con fecha de jornada', () {
    test('el alta con fecha atrás deja todo en ese día', () async {
      final a = await alta('A-1', haceNDias: 3);
      final dia = haceDias(3);

      expect(a.fechaCompra, DateTime(dia.year, dia.month, dia.day, 12));
      final mov = (await db.select(db.movimientosLote).get()).single;
      expect(mov.fecha, a.fechaCompra);
      final entrada = (await pesajesDe(a.id)).single;
      expect(entrada.fecha, a.fechaCompra);
      // Cuándo se digitó sí es hoy: así se sabe que se pasó tarde.
      expect(mismoDia(entrada.createdAt, hoy), isTrue);
      expect(await pesajes.fechaIngreso(a), a.fechaCompra);
    });

    test('no se registra con una fecha que todavía no llega', () async {
      expect(
        () => pesajes.crearAnimalConPesaje(
          fincaId: 'f1',
          loteId: 'l1',
          identificador: 'F-1',
          peso: 300,
          registradoPor: 'u1',
          fecha: hoy.add(const Duration(days: 1)),
        ),
        throwsA(isA<FechaInvalidaException>()),
      );
    });

    test('no se pesa antes de que el animal entrara', () async {
      final a = await alta('A-1', haceNDias: 3);
      expect(
        () => pesajes.agregarPesaje(
          animalId: a.id,
          peso: 280,
          registradoPor: 'u1',
          fecha: haceDias(5),
        ),
        throwsA(isA<FechaInvalidaException>()),
      );
    });

    test(
      'la lista de Trabajo muestra lo digitado hoy aunque sea de otro día',
      () async {
        final a = await alta('A-1', haceNDias: 10);
        await pesajes.agregarPesaje(
          animalId: a.id,
          peso: 320,
          registradoPor: 'u1',
          fecha: haceDias(3),
        );
        final lista = await pesajes
            .observarPesajesDelDia('f1', DateTime(hoy.year, hoy.month, hoy.day))
            .first;
        expect(lista.map((p) => p.peso), containsAll([300.0, 320.0]));
      },
    );
  });

  group('animal sin peso y compra por monto total', () {
    test('entra sin pesaje y el primero le saca el ₡/kg', () async {
      final a = await alta('S-1', peso: null, haceNDias: 2);
      expect(await pesajesDe(a.id), isEmpty);
      expect(a.precioCompra, 300000);
      expect(a.pesoCompra, isNull);
      expect(a.precioKgCompra, isNull);

      await pesajes.agregarPesaje(
        animalId: a.id,
        peso: 250,
        registradoPor: 'u1',
      );
      final pesado = await animal('S-1');
      expect(pesado.pesoCompra, 250);
      expect(pesado.precioKgCompra, closeTo(1200, 0.001));
      expect(pesado.precioCompra, 300000);
    });

    test('sale en la lista de Trabajo aunque no tenga peso', () async {
      final a = await alta('S-1', peso: null, haceNDias: 2);
      final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final lista = await pesajes.observarPesajesDelDia('f1', inicioHoy).first;
      final fila = lista.single;
      expect(fila.sinPeso, isTrue);
      expect(fila.animalId, a.id);
      expect(fila.fecha, a.fechaCompra);

      // En cuanto se pesa, la fila pasa a ser la del pesaje (no se duplica).
      await pesajes.registrarPesajeEnFecha(
        animalId: a.id,
        peso: 250,
        fecha: fila.fecha,
        registradoPor: 'u1',
      );
      final despues = await pesajes
          .observarPesajesDelDia('f1', inicioHoy)
          .first;
      expect(despues.single.peso, 250);
    });

    test('monto total con peso calcula el ₡/kg de una vez', () async {
      await pesajes.crearAnimalConPesaje(
        fincaId: 'f1',
        loteId: 'l1',
        identificador: 'M-1',
        peso: 449,
        registradoPor: 'u1',
        pesoCompra: 449,
        precioCompra: 716040,
      );
      final a = await animal('M-1');
      expect(a.precioKgCompra, closeTo(716040 / 449, 0.001));
    });
  });

  group('hoja de vida: corregir pesajes y el ingreso', () {
    test('editar cambia el peso y el día', () async {
      final a = await alta('A-1', haceNDias: 10);
      final p = (await pesajesDe(a.id)).single;
      await pesajes.editarPesaje(pesajeId: p.id, peso: 305, fecha: haceDias(8));
      final editado = (await pesajesDe(a.id)).single;
      expect(editado.peso, 305);
      expect(mismoDia(editado.fecha, haceDias(8)), isTrue);
      expect(editado.pendiente, isTrue);
    });

    test('no se mueve a un día que ya tiene otro pesaje', () async {
      final a = await alta('A-1', haceNDias: 10);
      await pesajes.agregarPesaje(
        animalId: a.id,
        peso: 330,
        registradoPor: 'u1',
        fecha: haceDias(2),
      );
      final ultimo = (await pesajesDe(a.id)).last;
      expect(
        () => pesajes.editarPesaje(
          pesajeId: ultimo.id,
          peso: 330,
          fecha: haceDias(10),
        ),
        throwsA(isA<FechaInvalidaException>()),
      );
    });

    test('cambiar el ingreso mueve la compra y el primer movimiento', () async {
      final a = await alta('A-1', haceNDias: 3);
      await pesajes.cambiarFechaIngreso(animalId: a.id, fecha: haceDias(20));
      final b = await animal('A-1');
      expect(mismoDia(b.fechaCompra!, haceDias(20)), isTrue);
      final mov = (await db.select(db.movimientosLote).get()).single;
      expect(mismoDia(mov.fecha, haceDias(20)), isTrue);
    });

    test('el ingreso no puede quedar después de su primer pesaje', () async {
      final a = await alta('A-1', haceNDias: 10);
      expect(
        () => pesajes.cambiarFechaIngreso(animalId: a.id, fecha: haceDias(5)),
        throwsA(isA<FechaInvalidaException>()),
      );
    });

    test('editar la compra respeta la fecha de compra', () async {
      final a = await alta('A-1', haceNDias: 10);
      await ventas.actualizarCompra(
        animalId: a.id,
        pesoCompra: 300,
        precioKgCompra: 1100,
        fechaCompra: a.fechaCompra,
      );
      final b = await animal('A-1');
      expect(b.fechaCompra, a.fechaCompra);
      expect(b.precioCompra, 330000);
    });
  });

  group('mover de lote con fecha', () {
    test('queda con el día real', () async {
      final a = await alta('A-1', haceNDias: 10);
      await pesajes.moverAnimalDeLote(
        animalId: a.id,
        nuevoLoteId: 'l2',
        fecha: haceDias(4),
      );
      final movs = await (db.select(
        db.movimientosLote,
      )..orderBy([(t) => OrderingTerm.asc(t.fecha)])).get();
      expect(movs, hasLength(2));
      expect(mismoDia(movs.last.fecha, haceDias(4)), isTrue);
    });

    test('no antes de su último movimiento', () async {
      final a = await alta('A-1', haceNDias: 10);
      await pesajes.moverAnimalDeLote(
        animalId: a.id,
        nuevoLoteId: 'l2',
        fecha: haceDias(4),
      );
      expect(
        () => pesajes.moverAnimalDeLote(
          animalId: a.id,
          nuevoLoteId: 'l1',
          fecha: haceDias(6),
        ),
        throwsA(isA<FechaInvalidaException>()),
      );
    });

    test('corregir el lote del alta no inventa un movimiento', () async {
      final a = await alta('A-1', haceNDias: 3);
      await pesajes.corregirLote(animalId: a.id, nuevoLoteId: 'l2');
      final mov = (await db.select(db.movimientosLote).get()).single;
      expect(mov.loteDestino, 'l2');
      expect((await animal('A-1')).loteId, 'l2');
    });
  });

  group('dieta desde una fecha', () {
    Future<String> dieta(String nombre) async {
      await dietas.crearDieta(
        fincaId: 'f1',
        nombre: nombre,
        costoKg: 500,
        kgAnimalDia: 2,
      );
      final todas = await db.select(db.dietas).get();
      return todas.firstWhere((d) => d.nombre == nombre).id;
    }

    test('la nueva cierra la anterior el mismo día', () async {
      final a = await dieta('A');
      final b = await dieta('B');
      await dietas.asignarDietaALote(
        loteId: 'l1',
        dietaId: a,
        desde: haceDias(20),
      );
      await dietas.asignarDietaALote(
        loteId: 'l1',
        dietaId: b,
        desde: haceDias(5),
      );
      final asig = await (db.select(
        db.loteDietas,
      )..orderBy([(t) => OrderingTerm.asc(t.desde)])).get();
      expect(asig, hasLength(2));
      expect(asig.first.hasta, asig.last.desde);
      expect(mismoDia(asig.last.desde, haceDias(5)), isTrue);
      expect(asig.last.hasta, isNull);
    });

    test('no antes del inicio de la anterior', () async {
      final a = await dieta('A');
      final b = await dieta('B');
      await dietas.asignarDietaALote(
        loteId: 'l1',
        dietaId: a,
        desde: haceDias(5),
      );
      expect(
        () => dietas.asignarDietaALote(
          loteId: 'l1',
          dietaId: b,
          desde: haceDias(8),
        ),
        throwsA(isA<FechaInvalidaException>()),
      );
    });

    test('la misma dieta desde antes corrige su inicio', () async {
      final a = await dieta('A');
      await dietas.asignarDietaALote(loteId: 'l1', dietaId: a);
      await dietas.asignarDietaALote(
        loteId: 'l1',
        dietaId: a,
        desde: haceDias(6),
      );
      final asig = (await db.select(db.loteDietas).get()).single;
      expect(mismoDia(asig.desde, haceDias(6)), isTrue);
    });

    test('se cobra desde el día real aunque se asigne hoy', () async {
      final animalA = await alta('A-1', haceNDias: 10);
      final a = await dieta('A');
      await dietas.asignarDietaALote(
        loteId: 'l1',
        dietaId: a,
        desde: haceDias(10),
      );
      final r = await ventas.resumenDe(animalA.id);
      // ₡1.000 por día × 10 días de calendario.
      expect(r.costoAlimentacion, closeTo(10000, 1));
    });
  });

  group('venta y sanidad con fecha', () {
    test('la venta no puede ser antes de su último pesaje', () async {
      final a = await alta('A-1', haceNDias: 10);
      await pesajes.agregarPesaje(
        animalId: a.id,
        peso: 320,
        registradoPor: 'u1',
        fecha: haceDias(2),
      );
      expect(
        () => ventas.confirmarLoteVenta(
          fincaId: 'f1',
          fecha: haceDias(4),
          items: [(animalId: a.id, peso: 320)],
        ),
        throwsA(isA<FechaInvalidaException>()),
      );
    });

    test('el retiro se mira a la fecha de la venta', () async {
      final a = await alta('A-1', haceNDias: 30);
      final med = await meds.crearMedicamento(
        fincaId: 'f1',
        nombre: 'Ivermectina',
        costoEnvase: 10000,
        tipoAplicacion: 'dosis_fija',
        mlEnvase: 10,
        dosisCantidad: 1,
        diasRetiro: 7,
      );
      // Aplicado hace 20 días: el retiro terminó hace 13.
      await sanidad.aplicarMedicamento(
        animalId: a.id,
        medicamentoId: med,
        pesoKg: 300,
        fecha: haceDias(20),
      );
      final evento = (await db.select(db.eventosSanitarios).get()).single;
      expect(mismoDia(evento.fecha, haceDias(20)), isTrue);
      expect(mismoDia(evento.createdAt, hoy), isTrue);

      // Vender hace 15 días: todavía estaba en retiro.
      expect(
        () => ventas.confirmarLoteVenta(
          fincaId: 'f1',
          fecha: haceDias(15),
          items: [(animalId: a.id, peso: 330)],
        ),
        throwsA(isA<AnimalEnRetiroException>()),
      );
      // Vender hace 5 días: ya había salido del retiro.
      await ventas.confirmarLoteVenta(
        fincaId: 'f1',
        fecha: haceDias(5),
        items: [(animalId: a.id, peso: 330)],
      );
      final venta = (await db.select(db.ventas).get()).single;
      expect(mismoDia(venta.fecha, haceDias(5)), isTrue);
      final salida = (await pesajesDe(a.id)).last;
      expect(mismoDia(salida.fecha, haceDias(5)), isTrue);
    });
  });

  group('muerte del animal', () {
    test('sale del inventario con su fecha y corta la dieta', () async {
      final a = await alta('A-1', haceNDias: 10);
      await dietas.crearDieta(
        fincaId: 'f1',
        nombre: 'A',
        costoKg: 500,
        kgAnimalDia: 2,
      );
      final dietaId = (await db.select(db.dietas).get()).single.id;
      await dietas.asignarDietaALote(
        loteId: 'l1',
        dietaId: dietaId,
        desde: haceDias(10),
      );

      await ventas.registrarMuerte(animalId: a.id, fecha: haceDias(4));

      final muerto = await animal('A-1');
      expect(muerto.estado, EstadoAnimal.muerto);
      expect(mismoDia(muerto.fechaMuerte!, haceDias(4)), isTrue);
      expect(muerto.pendiente, isTrue);
      expect(await pesajes.observarAnimalesDeLote('l1').first, isEmpty);
      // 6 días de dieta (del día 10 al día 4), no 10.
      final r = await ventas.resumenDe(a.id);
      expect(r.costoAlimentacion, closeTo(6000, 1));
    });

    test('no puede morir antes de su último pesaje', () async {
      final a = await alta('A-1', haceNDias: 10);
      await pesajes.agregarPesaje(
        animalId: a.id,
        peso: 320,
        registradoPor: 'u1',
        fecha: haceDias(2),
      );
      expect(
        () => ventas.registrarMuerte(animalId: a.id, fecha: haceDias(5)),
        throwsA(isA<FechaInvalidaException>()),
      );
    });
  });
}
