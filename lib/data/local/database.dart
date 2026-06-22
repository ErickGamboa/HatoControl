import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// ============================================================================
// Base de datos local (SQLite vía Drift).
//
// Cada tabla refleja su equivalente en Supabase, más dos columnas de control
// de sincronización:
//   - updatedAt: cuándo se modificó por última vez (para "ganar el último").
//   - pendiente: true si el registro tiene cambios locales sin subir todavía.
// Las tablas de dominio agregan deletedAt (borrado suave).
// ============================================================================

/// Catálogo de licencias (referencia, se baja del servidor). Define cuántas
/// fincas permite cada plan.
@DataClassName('PlanRow')
class Planes extends Table {
  TextColumn get codigo => text()(); // 'light' | 'medium' | 'pro'
  TextColumn get nombre => text()();
  IntColumn get limiteFincas => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {codigo};
}

/// Cuenta = unidad de licenciamiento. Cada finca pertenece a una cuenta.
@DataClassName('CuentaRow')
class Cuentas extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get duenoId => text()();
  TextColumn get plan => text()(); // 'light' | 'medium' | 'pro'
  TextColumn get estado => text()(); // 'activa' | 'suspendida'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UsuarioRow')
class Usuarios extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get cuentaId => text().nullable()(); // cuenta propia del usuario
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FincaRow')
class Fincas extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  TextColumn get fotoUrl => text().nullable()();
  TextColumn get creadaPor => text()();
  // Nullable en local para simplificar la migración; se setea al crear.
  // El servidor lo mantiene NOT NULL.
  TextColumn get cuentaId => text().nullable()();
  // Foto: ruta del archivo local (sólo en este dispositivo) y bandera de si
  // falta subirla al servidor. fotoUrl guarda la URL pública ya subida.
  TextColumn get fotoLocalPath => text().nullable()();
  BoolColumn get fotoPendiente => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FincaMiembroRow')
class FincaMiembros extends Table {
  TextColumn get id => text()();
  TextColumn get fincaId => text()();
  TextColumn get usuarioId => text()();
  TextColumn get rol => text()(); // 'admin' | 'operario'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LoteRow')
class Lotes extends Table {
  TextColumn get id => text()();
  TextColumn get fincaId => text()();
  TextColumn get nombre => text()();
  IntColumn get numero => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AnimalRow')
class Animales extends Table {
  TextColumn get id => text()();
  TextColumn get fincaId => text()();
  TextColumn get loteId => text()();
  TextColumn get identificador => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PesajeRow')
class Pesajes extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  RealColumn get peso => real()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get registradoPor => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Guarda, por cada tabla, la fecha del último registro que bajamos del
/// servidor. Sirve como "marcador" para pedir solo lo nuevo en la próxima
/// sincronización.
@DataClassName('SyncCursorRow')
class SyncCursores extends Table {
  TextColumn get tabla => text()();
  DateTimeColumn get ultimaBajada => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {tabla};
}

@DriftDatabase(
  tables: [
    Planes,
    Cuentas,
    Usuarios,
    Fincas,
    FincaMiembros,
    Lotes,
    Animales,
    Pesajes,
    SyncCursores,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: capa de Cuenta + licencias.
            await m.createTable(planes);
            await m.createTable(cuentas);
            await m.addColumn(usuarios, usuarios.cuentaId);
            await m.addColumn(fincas, fincas.cuentaId);
          }
          if (from < 3) {
            // v3: foto de la finca (ruta local + bandera de subida pendiente).
            await m.addColumn(fincas, fincas.fotoLocalPath);
            await m.addColumn(fincas, fincas.fotoPendiente);
          }
        },
      );
}

QueryExecutor _abrirConexion() {
  // drift_flutter resuelve la ruta del archivo y las librerías nativas de
  // SQLite en Android/iOS/escritorio automáticamente.
  return driftDatabase(name: 'hatocontrol');
}
