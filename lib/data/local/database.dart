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
  TextColumn get plan => text()(); // 'invitado' | 'light' | 'medium' | 'pro'
  TextColumn get estado => text()(); // 'activa' | 'suspendida'
  // Fin de la prueba gratis de 7 días. null = sin prueba (pagado o invitado).
  DateTimeColumn get pruebaTermina => dateTime().nullable()();
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
  BoolColumn get fotoPendiente =>
      boolean().withDefault(const Constant(false))();
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

/// Catálogo de dietas por finca (D-02, D-03).
@DataClassName('DietaRow')
class Dietas extends Table {
  TextColumn get id => text()();
  TextColumn get fincaId => text()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();
  RealColumn get costoAnimalDia => real()();
  TextColumn get moneda => text().withDefault(const Constant('CRC'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Historial de asignación de dieta a un lote. `hasta` null = vigente.
/// `costoAnimalDiaSnapshot` congela el costo al asignar (D-02).
@DataClassName('LoteDietaRow')
class LoteDietas extends Table {
  TextColumn get id => text()();
  TextColumn get loteId => text()();
  TextColumn get dietaId => text()();
  DateTimeColumn get desde => dateTime()();
  DateTimeColumn get hasta => dateTime().nullable()();
  RealColumn get costoAnimalDiaSnapshot => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Historial de movimientos de un animal entre lotes (D-05).
@DataClassName('MovimientoLoteRow')
class MovimientosLote extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get loteOrigen => text().nullable()();
  TextColumn get loteDestino => text()();
  DateTimeColumn get fecha => dateTime()();
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

/// Identidad verificada localmente para permitir entrar sin conexión después
/// de un inicio de sesión exitoso en este dispositivo.
@DataClassName('SesionLocalRow')
class SesionesLocales extends Table {
  TextColumn get id => text()(); // fila única: 'actual'
  TextColumn get usuarioId => text()();
  TextColumn get email => text().nullable()();
  TextColumn get nombre => text().nullable()();
  DateTimeColumn get ultimoLoginOnline => dateTime()();
  BoolColumn get offlineActiva =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
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
    Dietas,
    LoteDietas,
    MovimientosLote,
    SyncCursores,
    SesionesLocales,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  /// Constructor para pruebas: permite usar una base en memoria y mantener los
  /// tests aislados del archivo SQLite real de la app.
  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _crearIndicesUnicosLocales();
    },
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
      if (from < 4) {
        // v4: fin de la prueba gratis de 7 días en la cuenta.
        await m.addColumn(cuentas, cuentas.pruebaTermina);
      }
      if (from < 5) {
        // v5: identidad local para entrar sin conexión tras login online.
        await m.createTable(sesionesLocales);
      }
      if (from < 6) {
        // v6: alinear la base local con las restricciones únicas del servidor
        // para evitar duplicados que luego quedan reintentando en sync.
        await _crearIndicesUnicosLocales();
      }
      if (from < 7) {
        // v7: dietas, asignaciones lote-dieta y movimientos entre lotes.
        await m.createTable(dietas);
        await m.createTable(loteDietas);
        await m.createTable(movimientosLote);
      }
    },
  );

  Future<void> _crearIndicesUnicosLocales() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      'idx_finca_miembros_finca_usuario_activos '
      'ON finca_miembros (finca_id, usuario_id) '
      'WHERE deleted_at IS NULL',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      'idx_animales_finca_identificador_activos '
      'ON animales (finca_id, identificador) '
      'WHERE deleted_at IS NULL',
    );
  }
}

QueryExecutor _abrirConexion() {
  // drift_flutter resuelve la ruta del archivo y las librerías nativas de
  // SQLite en Android/iOS/escritorio automáticamente.
  return driftDatabase(name: 'hatocontrol');
}
