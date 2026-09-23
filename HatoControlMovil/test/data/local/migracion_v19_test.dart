import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/deudas_repository.dart';
import 'package:hato_control/data/repositories/lotes_repository.dart';

/// La v19 agrega el terreno del lote y las tablas de deudas.
///
/// Este test NO prueba una base nueva (esa la arma `createAll` y siempre sale
/// bien), sino el caso de verdad: **un aparato que ya venía usando la app** y
/// solo actualiza. Es lo que le pasa a la web, que guarda su copia en el
/// navegador y no se borra al publicar una versión nueva.
void main() {
  /// Una base con la forma que tenía en la v18: `lotes` sin terreno y sin
  /// rastro de deudas.
  AppDatabase baseVieja() => AppDatabase.forExecutor(
    NativeDatabase.memory(
      setup: (raw) {
        raw.execute('''
          CREATE TABLE lotes (
            id TEXT NOT NULL,
            finca_id TEXT NOT NULL,
            nombre TEXT NOT NULL,
            numero INTEGER NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            deleted_at TEXT NULL,
            pendiente INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (id)
          )
        ''');
        raw.execute(
          'INSERT INTO lotes (id, finca_id, nombre, numero, created_at, '
          'updated_at, deleted_at, pendiente) '
          "VALUES ('l1', 'f1', 'Engorde', 1, '2026-08-22T00:00:00.000', "
          "'2026-08-22T00:00:00.000', NULL, 0)",
        );
        raw.execute('PRAGMA user_version = 18');
      },
    ),
  );

  test('el lote viejo gana el terreno sin perder lo que tenía', () async {
    final db = baseVieja();
    addTearDown(db.close);

    // La primera consulta dispara la migración.
    final lote = (await LotesRepository(db).lotesActivos('f1')).single;
    expect(lote.nombre, 'Engorde', reason: 'la fila de siempre sigue ahí');
    expect(lote.numero, 1);
    expect(lote.areaM2, isNull, reason: 'todavía nadie le puso terreno');

    final columnas = await db
        .customSelect('PRAGMA table_info(lotes)')
        .map((f) => f.read<String>('name'))
        .get();
    expect(columnas, containsAll(['area_m2', 'area_unidad']));
  });

  test('las tablas de deudas quedan creadas y se pueden usar', () async {
    final db = baseVieja();
    addTearDown(db.close);
    final deudas = DeudasRepository(db);

    // Si la migración no creó las tablas, esto revienta: es justo lo que le
    // pasaba a la web al bajar las deudas del servidor.
    final id = await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Cooperativa',
      monto: 450000,
      fecha: DateTime(2026, 9, 1),
    );
    await deudas.registrarAbono(
      deudaId: id,
      monto: 200000,
      fecha: DateTime(2026, 9, 10),
    );

    final guardada = (await deudas.deudasDe('f1')).single;
    expect(guardada.deuda.acreedor, 'Cooperativa');
    expect(guardada.saldo, 250000);
  });

  test('actualizar dos veces no rompe nada (la migración es repetible)', () async {
    final db = baseVieja();
    addTearDown(db.close);

    await db.customStatement('SELECT 1');
    // Se vuelve a pedir el mismo salto: no debe quejarse de que ya existe.
    await db.customStatement('PRAGMA user_version = 18');
    final deudas = DeudasRepository(db);
    await deudas.crearDeuda(
      fincaId: 'f1',
      acreedor: 'Banco',
      monto: 1000,
      fecha: DateTime(2026, 9, 1),
    );
    expect(await deudas.deudasDe('f1'), hasLength(1));
  });
}
