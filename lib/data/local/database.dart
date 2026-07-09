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

  @override
  List<String> get customConstraints => [
    "CHECK (plan IN ('invitado','light','medium','pro'))",
    "CHECK (estado IN ('activa','suspendida'))",
  ];
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

  @override
  List<String> get customConstraints => ["CHECK (rol IN ('admin','operario'))"];
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

  /// activo | vendido | muerto (D-08)
  TextColumn get estado => text().withDefault(const Constant('activo'))();
  RealColumn get precioCompra => real().nullable()();
  DateTimeColumn get fechaCompra => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (estado IN ('activo','vendido','muerto'))",
    'CHECK (precio_compra IS NULL OR precio_compra >= 0)',
  ];
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

  @override
  List<String> get customConstraints => ['CHECK (costo_animal_dia >= 0)'];
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

/// Aplicación sanitaria por animal (D-04): vacuna, medicamento, etc.
@DataClassName('EventoSanitarioRow')
class EventosSanitarios extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get tipo =>
      text()(); // vacuna | medicamento | desparasitacion | otro
  TextColumn get producto => text()();
  TextColumn get dosis => text().nullable()();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get responsableId => text().nullable()();
  TextColumn get observaciones => text().nullable()();
  RealColumn get costo => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (tipo IN ('vacuna','medicamento','desparasitacion','otro'))",
    'CHECK (costo IS NULL OR costo >= 0)',
  ];
}

/// Venta de un animal (Module 4). Al registrar, el animal pasa a estado vendido.
@DataClassName('VentaRow')
class Ventas extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  DateTimeColumn get fecha => dateTime()();
  RealColumn get precio => real()();
  TextColumn get comprador => text().nullable()();
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (precio >= 0)'];
}

/// Otros costos directos del animal (Module 4).
@DataClassName('CostoOtroRow')
class CostosOtros extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get concepto => text()();
  RealColumn get monto => real()();
  DateTimeColumn get fecha => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (monto >= 0)'];
}

/// Feature flags por scope (D-15): habilitan/deshabilitan módulos por
/// finca/cuenta/global. Gestionadas solo por el CLI (`hatoctl`) vía
/// `service_role`; la app únicamente las lee (RLS solo da SELECT). Por eso
/// no tiene columna `pendiente`: nunca hay escritura local que sincronizar.
@DataClassName('FeatureFlagRow')
class FeatureFlags extends Table {
  TextColumn get id => text()();
  TextColumn get scope => text()(); // 'global' | 'cuenta' | 'finca'
  TextColumn get scopeId =>
      text().nullable()(); // null solo cuando scope = 'global'
  TextColumn get clave => text()();
  BoolColumn get habilitado => boolean().withDefault(const Constant(true))();
  TextColumn get nota => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (scope IN ('global','cuenta','finca'))",
    "CHECK ((scope = 'global') = (scope_id IS NULL))",
  ];
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

  @override
  List<String> get customConstraints => ['CHECK (peso > 0)'];
}

/// Guarda, por cada tabla, la fecha (y el id, para desempatar filas con el
/// mismo `updated_at`) del último registro que bajamos del servidor. Sirve
/// como "marcador" para pedir solo lo nuevo en la próxima sincronización.
/// `ultimaBajadaId` es null solo si `ultimaBajada` también lo es (tabla
/// nunca sincronizada) — ver `SyncCursor` en `sync_remote_gateway.dart`.
@DataClassName('SyncCursorRow')
class SyncCursores extends Table {
  TextColumn get tabla => text()();
  DateTimeColumn get ultimaBajada => dateTime().nullable()();
  TextColumn get ultimaBajadaId => text().nullable()();

  @override
  Set<Column> get primaryKey => {tabla};
}

/// Estado de sincronización por tabla, solo local (D-13): para qué el
/// usuario/soporte pueda ver "N cambios pendientes" y el último error sin
/// tener que leer logs. `ultimaSincronizacionOk` se actualiza en cada BAJADA
/// exitosa (aunque no haya filas nuevas); `ultimoError`/`ultimoErrorEn` se
/// llenan cuando un paso falla y se limpian en el próximo éxito.
@DataClassName('SyncEstadoRow')
class SyncEstados extends Table {
  TextColumn get tabla => text()();
  DateTimeColumn get ultimaSincronizacionOk => dateTime().nullable()();
  TextColumn get ultimoError => text().nullable()();
  DateTimeColumn get ultimoErrorEn => dateTime().nullable()();

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
    EventosSanitarios,
    Ventas,
    CostosOtros,
    FeatureFlags,
    SyncCursores,
    SyncEstados,
    SesionesLocales,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  /// Constructor para pruebas: permite usar una base en memoria y mantener los
  /// tests aislados del archivo SQLite real de la app.
  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 11;

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
      if (from < 8) {
        // v8: eventos sanitarios por animal.
        await m.createTable(eventosSanitarios);
      }
      if (from < 9) {
        // v9: economía — compra, venta, otros costos, estado del animal.
        await m.addColumn(animales, animales.estado);
        await m.addColumn(animales, animales.precioCompra);
        await m.addColumn(animales, animales.fechaCompra);
        await customStatement(
          "UPDATE animales SET estado = 'activo' WHERE estado IS NULL",
        );
        await m.createTable(ventas);
        await m.createTable(costosOtros);
      }
      if (from < 10) {
        // v10: feature flags por scope (D-15), solo lectura, bajadas por sync.
        await m.createTable(featureFlags);
      }
      if (from < 11) {
        // v11: CHECK constraints locales (Fase 3, ver ARCHITECTURE_REVIEW.md
        // #3) + cursor de sync compuesto (updated_at, id) + sync_estado
        // (D-13). Sin usuarios en producción todavía, así que las tablas
        // que ganan un CHECK se recrean en vez de migrar datos con cuidado
        // (decisión explícita, no un atajo permanente).
        for (final tabla in <TableInfo>[
          cuentas,
          fincaMiembros,
          animales,
          pesajes,
          dietas,
          eventosSanitarios,
          ventas,
          costosOtros,
          featureFlags,
        ]) {
          await m.deleteTable(tabla.actualTableName);
          await m.createTable(tabla);
        }
        await m.addColumn(syncCursores, syncCursores.ultimaBajadaId);
        await m.createTable(syncEstados);
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
