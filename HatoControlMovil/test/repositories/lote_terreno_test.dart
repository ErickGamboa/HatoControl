import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';

/// Terreno del lote: se digita en la unidad de cada quien y se guarda en m²,
/// que es lo que permite sumar lotes medidos distinto en "Todos".
void main() {
  late AppDatabase db;
  late LotesRepository lotes;
  final hoy = DateTime(2026, 9, 21);

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    lotes = LotesRepository(db);
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
  });

  tearDown(() async => db.close());

  Future<LoteRow> unicoLote() async => (await lotes.lotesActivos('f1')).single;

  test('2 hectáreas se guardan como 20.000 m² y se muestran como se digitaron', () async {
    await lotes.crearLote(
      fincaId: 'f1',
      nombre: 'Engorde',
      area: 2,
      areaUnidad: UnidadArea.hectarea,
    );

    final lote = await unicoLote();
    expect(lote.areaM2, 20000);
    expect(lote.areaUnidad, UnidadArea.hectarea);
    expect(UnidadArea.formatear(lote.areaM2!, lote.areaUnidad!), '2 hectáreas');
  });

  test('una manzana son 6.988,96 m² (10.000 varas²), no 7.000 redondeados', () async {
    await lotes.crearLote(
      fincaId: 'f1',
      nombre: 'Potrero',
      area: 1,
      areaUnidad: UnidadArea.manzana,
    );

    final lote = await unicoLote();
    expect(lote.areaM2, closeTo(6988.96, 0.001));
    expect(UnidadArea.formatear(lote.areaM2!, UnidadArea.manzana), '1 manzana');
  });

  test('sin terreno no se guarda nada (y un cero tampoco cuenta)', () async {
    await lotes.crearLote(fincaId: 'f1', nombre: 'Sin medir');
    var lote = await unicoLote();
    expect(lote.areaM2, isNull);
    expect(lote.areaUnidad, isNull);

    await lotes.editarLote(
      loteId: lote.id,
      nombre: 'Sin medir',
      area: 0,
      areaUnidad: UnidadArea.hectarea,
    );
    lote = await unicoLote();
    expect(lote.areaM2, isNull);
  });

  test('editar cambia el terreno y deja el lote pendiente de sincronizar', () async {
    await lotes.crearLote(
      fincaId: 'f1',
      nombre: 'Engorde',
      area: 2,
      areaUnidad: UnidadArea.hectarea,
    );
    final lote = await unicoLote();

    await lotes.editarLote(
      loteId: lote.id,
      nombre: 'Engorde',
      area: 5000,
      areaUnidad: UnidadArea.metrosCuadrados,
    );

    final editado = await unicoLote();
    expect(editado.areaM2, 5000);
    expect(editado.areaUnidad, UnidadArea.metrosCuadrados);
    expect(editado.pendiente, isTrue);
  });

  test('lotes en unidades distintas se pueden sumar: todo está en m²', () async {
    await lotes.crearLote(
      fincaId: 'f1',
      nombre: 'Uno',
      area: 2,
      areaUnidad: UnidadArea.hectarea,
    );
    await lotes.crearLote(
      fincaId: 'f1',
      nombre: 'Dos',
      area: 1,
      areaUnidad: UnidadArea.manzana,
    );
    await lotes.crearLote(
      fincaId: 'f1',
      nombre: 'Tres',
      area: 5000,
      areaUnidad: UnidadArea.metrosCuadrados,
    );

    final todos = await lotes.lotesActivos('f1');
    final totalM2 = todos.fold<double>(0, (s, l) => s + (l.areaM2 ?? 0));

    expect(totalM2, closeTo(31988.96, 0.001));
    expect(
      UnidadArea.formatear(totalM2, UnidadArea.hectarea),
      '3.20 hectáreas',
    );
  });

  test('una unidad desconocida no rompe nada: cae en hectáreas', () {
    expect(UnidadArea.normalizar(null), UnidadArea.hectarea);
    expect(UnidadArea.normalizar('cuerdas'), UnidadArea.hectarea);
    expect(UnidadArea.aM2(1, 'cuerdas'), 10000);
  });
}
