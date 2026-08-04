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

  /// Total derivado: pesoCompra × precioKgCompra (0 si nació en la finca).
  RealColumn get precioCompra => real().nullable()();

  /// Kilos de entrada al comprar (nullable en datos legacy).
  RealColumn get pesoCompra => real().nullable()();

  /// ₡/kg de compra. 0 = nació en la finca. null = legacy / sin precio.
  RealColumn get precioKgCompra => real().nullable()();
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
    'CHECK (peso_compra IS NULL OR peso_compra > 0)',
    'CHECK (precio_kg_compra IS NULL OR precio_kg_compra >= 0)',
  ];
}

/// Catálogo de dietas por finca (D-02, D-03).
@DataClassName('DietaRow')
class Dietas extends Table {
  TextColumn get id => text()();
  TextColumn get fincaId => text()();
  TextColumn get nombre => text()();
  TextColumn get descripcion => text().nullable()();

  /// Costo semanal por animal (como lo digita el ganadero).
  RealColumn get costoAnimalSemana => real().withDefault(const Constant(0))();

  /// Derivado: costoAnimalSemana ÷ 7 (para períodos y snapshots).
  RealColumn get costoAnimalDia => real()();
  TextColumn get moneda => text().withDefault(const Constant('CRC'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (costo_animal_dia >= 0)',
    'CHECK (costo_animal_semana >= 0)',
  ];
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

/// Aplicación sanitaria por animal. Con catálogo oro: medicamentoId + dosis/
/// retiro calculados; `producto`/`dosis` texto se conservan para UI e historial.
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
  TextColumn get medicamentoId => text().nullable()();
  RealColumn get mlAplicados => real().nullable()();
  IntColumn get aplicaciones => integer().nullable()();
  IntColumn get diasRetiro => integer().nullable()();
  DateTimeColumn get retiroHasta => dateTime().nullable()();
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

/// Catálogo de medicamentos de la finca (documento oro, Módulo 2).
@DataClassName('MedicamentoRow')
class Medicamentos extends Table {
  TextColumn get id => text()();
  TextColumn get fincaId => text()();
  TextColumn get nombre => text()();
  RealColumn get costoEnvase => real()();

  /// por_peso | dosis_fija | por_aplicacion
  TextColumn get tipoAplicacion => text()();
  RealColumn get mlEnvase => real().nullable()();
  RealColumn get aplicacionesPorEnvase => real().nullable()();

  /// ml de la dosis (por peso o fija).
  RealColumn get dosisCantidad => real().nullable()();

  /// "cada X kg" para por_peso.
  RealColumn get dosisPorCadaKg => real().nullable()();
  IntColumn get diasRetiro => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (tipo_aplicacion IN ('por_peso','dosis_fija','por_aplicacion'))",
    'CHECK (costo_envase >= 0)',
    'CHECK (dias_retiro >= 0)',
  ];
}

/// Ingrediente de una dieta: solo nombre informativo (costo queda en 0).
@DataClassName('DietaIngredienteRow')
class DietaIngredientes extends Table {
  TextColumn get id => text()();
  TextColumn get dietaId => text()();
  TextColumn get nombre => text()();

  /// Deja de usarse; se graba 0 para no romper sync con Supabase.
  RealColumn get costoAnimalDia => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (costo_animal_dia >= 0)'];
}

/// Lote de venta: grupo de animales vendidos juntos (oro Módulo 6).
@DataClassName('LoteVentaRow')
class LotesVenta extends Table {
  TextColumn get id => text()();
  TextColumn get fincaId => text()();
  DateTimeColumn get fecha => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Venta de un animal (Module 4). Al registrar, el animal pasa a estado vendido.
@DataClassName('VentaRow')
class Ventas extends Table {
  TextColumn get id => text()();
  TextColumn get animalId => text()();
  TextColumn get loteVentaId => text().nullable()();
  DateTimeColumn get fecha => dateTime()();

  /// Total derivado: peso × precioKg.
  RealColumn get precio => real()();

  /// Kilos de salida (obligatorio en ventas nuevas).
  RealColumn get peso => real().nullable()();

  /// ₡ por kilo de venta.
  RealColumn get precioKg => real().nullable()();
  TextColumn get comprador => text().nullable()();
  TextColumn get observaciones => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (precio >= 0)',
    'CHECK (peso IS NULL OR peso > 0)',
    'CHECK (precio_kg IS NULL OR precio_kg >= 0)',
  ];
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

/// Gasto fijo de la finca (Módulo 7, D-17): salario del peón, luz, agua.
/// No es de un animal en particular: se prorratea por días-animal.
/// `monto` es mensual cuando `periodicidad = 'mensual'`; `hasta` null = vigente.
@DataClassName('GastoFijoRow')
class GastosFijos extends Table {
  TextColumn get id => text()();
  TextColumn get fincaId => text()();
  TextColumn get concepto => text()();
  RealColumn get monto => real()();

  /// mensual | unico
  TextColumn get periodicidad => text()();

  /// mensual: primer día del mes en que empieza. unico: fecha del gasto.
  DateTimeColumn get desde => dateTime()();

  /// null = sigue vigente; se llena al dar de baja.
  DateTimeColumn get hasta => dateTime().nullable()();
  TextColumn get moneda => text().withDefault(const Constant('CRC'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (periodicidad IN ('mensual','unico'))",
    'CHECK (monto >= 0)',
  ];
}

/// Parte de un gasto fijo congelada para un animal en un mes (Módulo 7, D-17).
/// Se escribe **solo al vender**: mientras el animal está activo su parte se
/// calcula en vivo. Congelarla evita que la utilidad de un animal ya vendido
/// cambie cuando después se digita un gasto atrasado.
@DataClassName('GastoFijoCargoRow')
class GastoFijoCargos extends Table {
  TextColumn get id => text()();
  TextColumn get gastoFijoId => text()();
  TextColumn get animalId => text()();

  /// Primer día del mes al que corresponde el cargo.
  DateTimeColumn get mes => dateTime()();

  /// Días-animal que le tocaron en ese mes (para poder auditar el reparto).
  IntColumn get dias => integer()();
  RealColumn get monto => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get pendiente => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (monto >= 0)',
    'CHECK (dias >= 0)',
  ];
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
    DietaIngredientes,
    LoteDietas,
    MovimientosLote,
    Medicamentos,
    EventosSanitarios,
    LotesVenta,
    Ventas,
    CostosOtros,
    GastosFijos,
    GastoFijoCargos,
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
  int get schemaVersion => 14;

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
      if (from < 12) {
        // v12: documento oro — catálogo medicamentos, ingredientes de dieta,
        // lotes de venta, retiro/dosis en eventos, peso/lote en ventas.
        // Idempotent: if [from] < 11, v11 already recreated `eventos_sanitarios`
        // / `ventas` with the current Drift schema (incl. v12 columns).
        await _crearTablaSiFalta(m, medicamentos);
        await _crearTablaSiFalta(m, dietaIngredientes);
        await _crearTablaSiFalta(m, lotesVenta);
        await _agregarColumnaSiFalta(
          m,
          eventosSanitarios,
          eventosSanitarios.medicamentoId,
        );
        await _agregarColumnaSiFalta(
          m,
          eventosSanitarios,
          eventosSanitarios.mlAplicados,
        );
        await _agregarColumnaSiFalta(
          m,
          eventosSanitarios,
          eventosSanitarios.aplicaciones,
        );
        await _agregarColumnaSiFalta(
          m,
          eventosSanitarios,
          eventosSanitarios.diasRetiro,
        );
        await _agregarColumnaSiFalta(
          m,
          eventosSanitarios,
          eventosSanitarios.retiroHasta,
        );
        await _agregarColumnaSiFalta(m, ventas, ventas.loteVentaId);
        await _agregarColumnaSiFalta(m, ventas, ventas.peso);
      }
      if (from < 13) {
        // v13: utilidad por kg/semana — columnas derivadas + costo semanal.
        await _agregarColumnaSiFalta(m, animales, animales.pesoCompra);
        await _agregarColumnaSiFalta(m, animales, animales.precioKgCompra);
        await _agregarColumnaSiFalta(m, ventas, ventas.precioKg);
        await _agregarColumnaSiFalta(m, dietas, dietas.costoAnimalSemana);
        // Datos existentes se digitaron como costo/día → semanal = día × 7.
        await customStatement(
          'UPDATE dietas SET costo_animal_semana = costo_animal_dia * 7 '
          'WHERE costo_animal_semana = 0 OR costo_animal_semana IS NULL',
        );
      }
      if (from < 14) {
        // v14: Módulo 7 — gastos fijos de la finca y sus cargos congelados.
        await _crearTablaSiFalta(m, gastosFijos);
        await _crearTablaSiFalta(m, gastoFijoCargos);
        await _crearIndicesUnicosLocales();
      }
    },
  );

  Future<void> _crearTablaSiFalta(Migrator m, TableInfo table) async {
    final filas = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      variables: [Variable.withString(table.actualTableName)],
    ).get();
    if (filas.isEmpty) {
      await m.createTable(table);
    }
  }

  Future<void> _agregarColumnaSiFalta(
    Migrator m,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final filas = await customSelect(
      'PRAGMA table_info(`${table.actualTableName}`)',
    ).get();
    final nombres = filas.map((f) => f.read<String>('name')).toSet();
    if (nombres.contains(column.name)) return;
    await m.addColumn(table, column);
  }

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
    // Un solo cargo congelado por gasto × animal × mes.
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      'idx_gasto_fijo_cargos_gasto_animal_mes_activos '
      'ON gasto_fijo_cargos (gasto_fijo_id, animal_id, mes) '
      'WHERE deleted_at IS NULL',
    );
  }
}

QueryExecutor _abrirConexion() {
  // drift_flutter resuelve la ruta del archivo y las librerías nativas de
  // SQLite en Android/iOS/escritorio automáticamente.
  return driftDatabase(name: 'hatocontrol');
}
