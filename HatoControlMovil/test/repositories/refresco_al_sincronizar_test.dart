import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/dietas_repository.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';
import 'package:hato_control/data/repositories/sanidad_repository.dart';
import 'package:hato_control/data/repositories/ventas_repository.dart';

/// Las pantallas se tienen que mover SOLAS cuando la sincronización guarda
/// algo nuevo. No basta con bajar el dato: si la lista no se entera, el
/// ganadero toca el botón de sincronizar, no ve ningún cambio y concluye que
/// la app no trajo nada (pasó con el peso del inventario).
///
/// El detalle técnico: estas listas se arman leyendo DOS tablas, y antes solo
/// escuchaban una. Acá se cambia únicamente la tabla "de adentro" —la que no
/// se escuchaba— y se exige que el stream vuelva a emitir.
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  late DietasRepository dietas;
  late SanidadRepository sanidad;
  late VentasRepository ventas;

  final hoy = DateTime(2026, 9, 22);

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
    dietas = DietasRepository(db);
    sanidad = SanidadRepository(db);
    ventas = VentasRepository(db);

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
    await db
        .into(db.lotes)
        .insert(
          LotesCompanion.insert(
            id: 'l1',
            fincaId: 'f1',
            nombre: 'Engorde',
            createdAt: hoy,
            updatedAt: hoy,
          ),
        );
    await pesajes.crearAnimalConPesaje(
      fincaId: 'f1',
      loteId: 'l1',
      identificador: '0001',
      peso: 200,
      registradoPor: 'u1',
      pesoCompra: 200,
      precioKgCompra: 1000,
    );
  });

  tearDown(() async => db.close());

  Future<AnimalRow> animal() async =>
      (await pesajes.buscarAnimal('f1', '0001'))!;

  test('el inventario del lote muestra el peso que acaba de bajar', () async {
    final a = await animal();
    final emisiones = pesajes.observarAnimalesDeLote('l1');

    final pesos = emisiones.map((lista) => lista.single.pesoActual);
    final futuro = pesos.take(2).toList();

    // Llega un pesaje del servidor: NO se toca la tabla de animales.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await pesajes.registrarPesajeEnFecha(
      animalId: a.id,
      peso: 257,
      fecha: hoy.add(const Duration(days: 1)),
      registradoPor: 'u1',
    );

    final vistos = await futuro;
    expect(
      vistos.last,
      257,
      reason: 'la lista se movió sola al entrar el pesaje nuevo',
    );
  });

  test(
    'la ficha del animal se mueve al bajarle un evento de sanidad',
    () async {
      final a = await animal();
      final futuro = ventas
          .observarResumen(a.id)
          .map((r) => r.costoSanitario)
          .take(2)
          .toList();

      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sanidad.registrarEvento(
        animalId: a.id,
        tipo: 'medicamento',
        producto: 'Ivermectina',
        fecha: hoy,
        costo: 3500,
      );

      final vistos = await futuro;
      expect(vistos.last, 3500);
    },
  );

  test('la tarjeta de dieta del lote se mueve al editar la dieta', () async {
    await dietas.crearDieta(
      fincaId: 'f1',
      nombre: 'Engorde',
      costoKg: 500,
      kgAnimalDia: 2,
    );
    final dieta = (await dietas.observarDietas('f1').first).single;
    await dietas.asignarDietaALote(loteId: 'l1', dietaId: dieta.id);

    final futuro = dietas
        .observarDietaVigente('l1')
        .map((v) => v?.dieta.nombre)
        .take(2)
        .toList();

    await Future<void>.delayed(const Duration(milliseconds: 50));
    // Se cambia SOLO la dieta, no la asignación del lote.
    await dietas.editarDieta(
      dietaId: dieta.id,
      nombre: 'Engorde fuerte',
      costoKg: 600,
      kgAnimalDia: 2,
    );

    final vistos = await futuro;
    expect(vistos.last, 'Engorde fuerte');
  });

  test('un pesaje BORRADO en el servidor también mueve la lista', () async {
    final a = await animal();
    final suyo = (await (db.select(
      db.pesajes,
    )..where((t) => t.animalId.equals(a.id))).get()).single;

    final futuro = pesajes
        .observarAnimalesDeLote('l1')
        .map((lista) => lista.single.pesoActual)
        .take(2)
        .toList();

    await Future<void>.delayed(const Duration(milliseconds: 50));
    // Exactamente como lo escribe la bajada del sync: la misma fila que ya
    // existe, ahora con `deleted_at`.
    await db
        .into(db.pesajes)
        .insertOnConflictUpdate(
          PesajeRow(
            id: suyo.id,
            animalId: suyo.animalId,
            peso: suyo.peso,
            fecha: suyo.fecha,
            registradoPor: suyo.registradoPor,
            createdAt: suyo.createdAt,
            updatedAt: hoy,
            deletedAt: hoy,
            pendiente: false,
          ).toCompanion(false),
        );

    final vistos = await futuro;
    expect(vistos.last, isNull, reason: 'el pesaje borrado ya no cuenta');
  });

  test('borrar un pesaje también mueve la lista', () async {
    final a = await animal();
    final futuro = pesajes
        .observarAnimalesDeLote('l1')
        .map((lista) => lista.single.pesoActual)
        .take(2)
        .toList();

    await Future<void>.delayed(const Duration(milliseconds: 50));
    final suyos = await (db.select(
      db.pesajes,
    )..where((t) => t.animalId.equals(a.id))).get();
    await (db.update(db.pesajes)..where((t) => t.id.equals(suyos.single.id)))
        .write(PesajesCompanion(deletedAt: Value(hoy)));

    final vistos = await futuro;
    expect(vistos.last, isNull, reason: 'se quedó sin pesajes');
  });

  /// Este es el que faltaba: en el celular, el inventario sí se movía al
  /// BAJAR un pesaje nuevo, pero no al bajar uno borrado. La diferencia no
  /// estaba en el borrado sino en QUÉ otras pantallas se habían abierto
  /// antes: dos listas abiertas a la vez terminaban compartiendo el mismo
  /// aviso, y la segunda se quedaba escuchando las tablas de la primera.
  test('dos listas abiertas a la vez, cada una escucha lo suyo', () async {
    await dietas.crearDieta(
      fincaId: 'f1',
      nombre: 'Engorde',
      costoKg: 500,
      kgAnimalDia: 2,
    );
    final dieta = (await dietas.observarDietas('f1').first).single;
    await dietas.asignarDietaALote(loteId: 'l1', dietaId: dieta.id);

    // La tarjeta de la dieta se abre PRIMERO y se queda escuchando.
    final tarjeta = dietas
        .observarDietaVigente('l1')
        .listen((_) {}, onError: (Object _) {});
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // Y después se abre el inventario del lote.
    final a = await animal();
    final futuro = pesajes
        .observarAnimalesDeLote('l1')
        .map((lista) => lista.single.pesoActual)
        .take(2)
        .toList();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    await pesajes.registrarPesajeEnFecha(
      animalId: a.id,
      peso: 311,
      fecha: hoy.add(const Duration(days: 2)),
      registradoPor: 'u1',
    );

    final vistos = await futuro.timeout(
      const Duration(seconds: 3),
      onTimeout: () => throw StateError(
        'el inventario nunca se enteró del pesaje: está escuchando las '
        'tablas de la tarjeta de dieta',
      ),
    );
    expect(vistos.last, 311);
    await tarjeta.cancel();
  });
}
