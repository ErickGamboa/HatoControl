import 'package:drift/drift.dart' show OrderingTerm, BooleanExpressionOperators;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';

/// "Nuevo pesaje" del inventario: pasar a la app los pesajes del cuaderno,
/// con la fecha del día en que se pesó de verdad.
void main() {
  late AppDatabase db;
  late PesajesRepository pesajes;
  final hoy = DateTime.now();

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    pesajes = PesajesRepository(db);
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

  Future<List<PesajeRow>> pesajesDe(String animalId) {
    return (db.select(db.pesajes)
          ..where((t) => t.animalId.equals(animalId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.fecha)]))
        .get();
  }

  test('guarda el pesaje en el día elegido, no en el de hoy', () async {
    final a = await animal();
    final haceUnaSemana = hoy.subtract(const Duration(days: 7));

    final corrigio = await pesajes.registrarPesajeEnFecha(
      animalId: a.id,
      peso: 230,
      fecha: haceUnaSemana,
      registradoPor: 'u1',
    );

    expect(corrigio, isFalse);
    final todos = await pesajesDe(a.id);
    final delCuaderno = todos.firstWhere((p) => p.peso == 230);
    expect(delCuaderno.fecha.year, haceUnaSemana.year);
    expect(delCuaderno.fecha.month, haceUnaSemana.month);
    expect(delCuaderno.fecha.day, haceUnaSemana.day);
    // Al mediodía: así el día no se corre al viajar entre husos horarios.
    expect(delCuaderno.fecha.hour, 12);
    expect(delCuaderno.pendiente, isTrue);
  });

  test('un segundo pesaje el MISMO día corrige el que estaba', () async {
    final a = await animal();
    final ayer = hoy.subtract(const Duration(days: 1));

    await pesajes.registrarPesajeEnFecha(
      animalId: a.id,
      peso: 210,
      fecha: ayer,
      registradoPor: 'u1',
    );
    final corrigio = await pesajes.registrarPesajeEnFecha(
      animalId: a.id,
      peso: 215,
      fecha: ayer,
      registradoPor: 'u1',
    );

    expect(corrigio, isTrue, reason: 'un animal, un peso por día');
    final deAyer = (await pesajesDe(a.id))
        .where((p) => p.fecha.day == ayer.day && p.fecha.month == ayer.month)
        .toList();
    expect(deAyer, hasLength(1));
    expect(deAyer.single.peso, 215);
  });

  test('el pesaje viejo no le gana al de hoy al leer el último peso', () async {
    final a = await animal();

    await pesajes.registrarPesajeEnFecha(
      animalId: a.id,
      peso: 180,
      fecha: hoy.subtract(const Duration(days: 30)),
      registradoPor: 'u1',
    );

    // El del alta (200 kg, de hoy) sigue siendo el último.
    expect(await pesajes.ultimoPeso(a.id), 200);
    expect(await pesajes.primerPeso(a.id), 180);
  });

  test('con la fecha de hoy se comporta como el pesaje normal del día', () async {
    final a = await animal();

    final corrigio = await pesajes.registrarPesajeEnFecha(
      animalId: a.id,
      peso: 205,
      fecha: hoy,
      registradoPor: 'u1',
    );

    expect(corrigio, isTrue, reason: 'el del alta ya era de hoy');
    expect(await pesajes.ultimoPeso(a.id), 205);
    expect(await pesajesDe(a.id), hasLength(1));
  });
}
