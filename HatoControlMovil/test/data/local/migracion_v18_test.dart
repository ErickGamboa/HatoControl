import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/data/local/database.dart';

/// La v18 le saca `prueba_termina` a `cuentas`. SQLite viejo no sabe soltar
/// columnas, así que la migración recrea la tabla copiando las filas: si eso
/// fallara, al actualizar la app el aparato se quedaría sin su cuenta y el
/// dueño no vería sus fincas. Por eso se prueba contra una base con la forma
/// que tenía en la v17.
void main() {
  test(
    'al subir de la v17 la cuenta sobrevive y prueba_termina desaparece',
    () async {
      final db = AppDatabase.forExecutor(
        NativeDatabase.memory(
          setup: (raw) {
            raw.execute('''
            CREATE TABLE cuentas (
              id TEXT NOT NULL,
              nombre TEXT NOT NULL,
              dueno_id TEXT NOT NULL,
              plan TEXT NOT NULL,
              estado TEXT NOT NULL,
              prueba_termina TEXT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              deleted_at TEXT NULL,
              pendiente INTEGER NOT NULL DEFAULT 0,
              PRIMARY KEY (id)
            )
          ''');
            // Una cuenta con la prueba ya vencida: el caso que antes dejaba al
            // cliente encerrado en "Tu prueba gratis terminó".
            raw.execute(
              'INSERT INTO cuentas (id, nombre, dueno_id, plan, estado, '
              'prueba_termina, created_at, updated_at, deleted_at, pendiente) '
              "VALUES ('cuenta-1', 'Mi cuenta', 'user-1', 'light', 'activa', "
              "'2026-08-29T00:00:00.000', '2026-08-22T00:00:00.000', "
              "'2026-08-22T00:00:00.000', NULL, 0)",
            );
            raw.execute('PRAGMA user_version = 17');
          },
        ),
      );
      addTearDown(db.close);

      // La primera consulta dispara la migración.
      final cuenta = await (db.select(
        db.cuentas,
      )..where((t) => t.id.equals('cuenta-1'))).getSingle();

      expect(cuenta.nombre, 'Mi cuenta', reason: 'la fila se copió tal cual');
      expect(cuenta.plan, 'light');
      expect(cuenta.estado, 'activa');

      final columnas = await db
          .customSelect('PRAGMA table_info(cuentas)')
          .map((f) => f.read<String>('name'))
          .get();
      expect(columnas, isNot(contains('prueba_termina')));
      expect(
        columnas,
        containsAll([
          'id',
          'nombre',
          'dueno_id',
          'plan',
          'estado',
          'pendiente',
        ]),
        reason: 'lo demás de la tabla queda igual',
      );
    },
  );
}
