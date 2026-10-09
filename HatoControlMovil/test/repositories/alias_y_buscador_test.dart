import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/pesajes_repository.dart';

/// Alias del animal y el buscador por arete o alias: sin lector, el ganadero
/// digita los últimos números (o el alias) y escoge.
void main() {
  group('sugerencias', () {
    const animales = [
      AnimalBuscable(
        id: '1',
        identificador: '982000111223344',
        alias: 'Pinta',
        loteNombre: 'Engorde',
      ),
      AnimalBuscable(
        id: '2',
        identificador: '982000111225544',
        alias: null,
        loteNombre: 'Engorde',
      ),
      AnimalBuscable(
        id: '3',
        identificador: '982000999990001',
        alias: 'Muñeca',
        loteNombre: 'Montaña',
      ),
    ];

    test('los últimos dígitos encuentran el arete', () {
      final r = sugerencias(animales, '3344');
      expect(r.map((a) => a.id), ['1']);
    });

    test('calzan varios por el final, en orden de arete', () {
      final r = sugerencias(animales, '44');
      expect(r.map((a) => a.id), ['1', '2']);
    });

    test('el alias se busca sin mayúsculas ni tildes', () {
      expect(sugerencias(animales, 'pin').single.id, '1');
      expect(sugerencias(animales, 'MUNE').single.id, '3');
    });

    test('lo exacto va primero', () {
      final r = sugerencias([
        ...animales,
        const AnimalBuscable(
          id: '4',
          identificador: '0001',
          alias: null,
          loteNombre: 'Engorde',
        ),
      ], '0001');
      expect(r.first.id, '4');
    });

    test('con un solo carácter no sugiere nada', () {
      expect(sugerencias(animales, '4'), isEmpty);
    });

    test('el filtro de la lista respeta el alias', () {
      expect(calzaConBusqueda('pinta', '982000111223344', 'Pinta'), isTrue);
      expect(calzaConBusqueda('3344', '982000111223344', null), isTrue);
      expect(calzaConBusqueda('vaca', '982000111223344', 'Pinta'), isFalse);
    });
  });

  group('alias en la base', () {
    late AppDatabase db;
    late PesajesRepository repo;
    final hoy = DateTime.now();

    setUp(() async {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repo = PesajesRepository(db);
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
    });

    tearDown(() async => db.close());

    Future<AnimalRow> alta(String ident, {String? alias}) async {
      await repo.crearAnimalConPesaje(
        fincaId: 'f1',
        loteId: 'l1',
        identificador: ident,
        peso: 300,
        registradoPor: 'u1',
        alias: alias,
      );
      return (await repo.buscarAnimal('f1', ident))!;
    }

    test('se guarda al dar de alta y lo encuentra por alias', () async {
      final a = await alta('982000111223344', alias: '  La   Pinta ');
      expect(a.alias, 'La Pinta');
      final porAlias = await repo.buscarActivoPorIdOAlias('f1', 'la pinta');
      expect(porAlias?.id, a.id);
      final porArete = await repo.buscarActivoPorIdOAlias(
        'f1',
        '982000111223344',
      );
      expect(porArete?.id, a.id);
      expect(await repo.buscarActivoPorIdOAlias('f1', '3344'), isNull);
    });

    test('no se repite el alias entre animales activos', () async {
      await alta('111', alias: 'Pinta');
      expect(
        () => alta('222', alias: 'pinta'),
        throwsA(isA<AliasEnUsoException>()),
      );
      // Tampoco puede ser el arete de otro: el buscador no sabría cuál es.
      final b = await alta('333');
      expect(
        () => repo.cambiarAlias(animalId: b.id, alias: '111'),
        throwsA(isA<AliasEnUsoException>()),
      );
    });

    test('cambiar y quitar el alias deja pendiente de subir', () async {
      final a = await alta('111');
      await (db.update(
        db.animales,
      )).write(const AnimalesCompanion(pendiente: Value(false)));
      await repo.cambiarAlias(animalId: a.id, alias: 'Negra');
      var fila = (await repo.buscarAnimal('f1', '111'))!;
      expect(fila.alias, 'Negra');
      expect(fila.pendiente, isTrue);

      await repo.cambiarAlias(animalId: a.id, alias: '  ');
      fila = (await repo.buscarAnimal('f1', '111'))!;
      // '' y no null: así quitarlo también sube a la nube.
      expect(fila.alias, '');
      expect(limpiarAlias(fila.alias), isNull);
    });

    test('el buscador ofrece los activos con su lote', () async {
      await alta('982000111223344', alias: 'Pinta');
      final lista = await repo.observarBuscables('f1').first;
      expect(lista.single.alias, 'Pinta');
      expect(lista.single.loteNombre, 'Engorde');
    });
  });
}
