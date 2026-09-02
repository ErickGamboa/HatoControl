import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/app/permisos_finca.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';

/// Invitados de solo lectura: `finca_miembros.rol = 'lector'`.
void main() {
  late AppDatabase db;
  late FincasRepository repo;

  final ahora = DateTime(2026, 8, 21);

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = FincasRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedMembresia({
    required String usuarioId,
    required String rol,
  }) async {
    await db
        .into(db.fincas)
        .insert(
          FincasCompanion.insert(
            id: 'finca-1',
            nombre: 'La Esperanza',
            creadaPor: 'dueno-1',
            cuentaId: const Value('cuenta-1'),
            createdAt: ahora,
            updatedAt: ahora,
          ),
        );
    await db
        .into(db.fincaMiembros)
        .insert(
          FincaMiembrosCompanion.insert(
            id: 'miembro-$usuarioId',
            fincaId: 'finca-1',
            usuarioId: usuarioId,
            rol: rol,
            createdAt: ahora,
            updatedAt: ahora,
          ),
        );
  }

  group('RolFinca', () {
    test('solo el rol lector es de solo lectura', () {
      expect(RolFinca.esSoloLectura(RolFinca.lector), isTrue);
      expect(RolFinca.esSoloLectura(RolFinca.admin), isFalse);
      expect(RolFinca.esSoloLectura(RolFinca.operario), isFalse);
    });

    test('un rol desconocido NO bloquea la UI (la RLS es el candado)', () {
      // Pasa cuando la membresía todavía no bajó o la sesión es offline.
      expect(RolFinca.esSoloLectura(null), isFalse);
      expect(RolFinca.esSoloLectura('otro'), isFalse);
    });
  });

  group('observarMiRol', () {
    test('acepta el rol lector en la base local', () async {
      await seedMembresia(usuarioId: 'invitado-1', rol: RolFinca.lector);

      final rol = await repo.observarMiRol('finca-1', 'invitado-1').first;

      expect(rol, RolFinca.lector);
    });

    test(
      'devuelve null si la membresía está borrada (acceso quitado)',
      () async {
        await seedMembresia(usuarioId: 'invitado-1', rol: RolFinca.lector);
        await repo.quitarAcceso('miembro-invitado-1');

        final rol = await repo.observarMiRol('finca-1', 'invitado-1').first;

        expect(rol, isNull);
      },
    );

    test('devuelve null para alguien que no es miembro', () async {
      await seedMembresia(usuarioId: 'invitado-1', rol: RolFinca.lector);

      final rol = await repo.observarMiRol('finca-1', 'ajeno').first;

      expect(rol, isNull);
    });
  });

  group('PermisosFinca', () {
    test('marca solo lectura al seguir a un invitado', () async {
      await seedMembresia(usuarioId: 'invitado-1', rol: RolFinca.lector);
      final permisos = PermisosFinca();
      addTearDown(permisos.limpiar);

      expect(permisos.esSoloLectura, isFalse);
      permisos.seguir(repo.observarMiRol('finca-1', 'invitado-1'));
      await _hastaQue(() => permisos.esSoloLectura);

      expect(permisos.esSoloLectura, isTrue);
      expect(permisos.siPuedeEscribir(() {}), isNull);
    });

    test('un admin queda con permiso de escritura', () async {
      await seedMembresia(usuarioId: 'dueno-1', rol: RolFinca.admin);
      final permisos = PermisosFinca();
      addTearDown(permisos.limpiar);

      permisos.seguir(repo.observarMiRol('finca-1', 'dueno-1'));
      await Future<void>.delayed(Duration.zero);

      expect(permisos.esSoloLectura, isFalse);
      expect(permisos.siPuedeEscribir(() {}), isNotNull);
    });

    test('limpiar vuelve al estado normal al salir de la finca', () async {
      await seedMembresia(usuarioId: 'invitado-1', rol: RolFinca.lector);
      final permisos = PermisosFinca();

      permisos.seguir(repo.observarMiRol('finca-1', 'invitado-1'));
      await _hastaQue(() => permisos.esSoloLectura);
      permisos.limpiar();

      expect(permisos.esSoloLectura, isFalse);
    });
  });
}

/// Espera a que [condicion] se cumpla (el stream de Drift emite asíncrono).
Future<void> _hastaQue(bool Function() condicion) async {
  for (var i = 0; i < 50; i++) {
    if (condicion()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('La condición no se cumplió a tiempo');
}
