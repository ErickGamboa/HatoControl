import 'package:drift/drift.dart';

import '../data/estadisticas/estadisticas_sanidad.dart';
import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../data/repositories/fincas_repository.dart';
import '../data/repositories/gastos_fijos_repository.dart';
import '../data/repositories/lotes_repository.dart';
import '../data/repositories/medicamentos_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';

/// Bandera de compilación: `--dart-define=SEED_PRUEBA=1`.
const _seedPruebaRaw = String.fromEnvironment('SEED_PRUEBA', defaultValue: '');
const kSeedPruebaEnabled =
    _seedPruebaRaw == '1' ||
    _seedPruebaRaw == 'true' ||
    _seedPruebaRaw == 'yes';

/// Datos de prueba con **números redondos** para revisar a mano los cálculos de
/// cada módulo y cómo se entrelazan. A diferencia de `DemoSeed`, esto NO cierra
/// la sesión ni activa modo offline: usa el usuario que ya inició sesión, así
/// que todo queda `pendiente=true` y sube por sync como datos reales.
///
/// Cuentas esperadas (por animal, con 10 días de estadía):
///   compra          200 kg × ₡1.000/kg      = ₡200.000
///   dieta           ₡100/kg × 10 kg = ₡1.000/día × 10 días = ₡10.000
///   sanidad         envase ₡10.000 ÷ 100 aplicaciones      = ₡100
///   gasto fijo      ₡30.000 al mes ÷ 3 animales            = ₡10.000
///   ganancia        200 kg → 210 kg = 10 kg en 10 días     = 1,0 kg/día
///   venta (A-3)     dinero recibido                        = ₡300.000
///   utilidad A-3    300.000 − (200.000 + 10.000 + 100 + gasto fijo)
class SeedPrueba {
  SeedPrueba({
    AppDatabase? database,
    FincasRepository? fincas,
    LotesRepository? lotes,
    PesajesRepository? pesajes,
    DietasRepository? dietas,
    SanidadRepository? sanidad,
    VentasRepository? ventas,
    MedicamentosRepository? medicamentos,
    GastosFijosRepository? gastosFijos,
  }) : _db = database ?? db,
       _fincas = fincas ?? fincasRepo,
       _lotes = lotes ?? lotesRepo,
       _pesajes = pesajes ?? pesajesRepo,
       _dietas = dietas ?? dietasRepo,
       _sanidad = sanidad ?? sanidadRepo,
       _ventas = ventas ?? ventasRepo,
       _medicamentos = medicamentos ?? medicamentosRepo,
       _gastosFijos = gastosFijos ?? gastosFijosRepo;

  final AppDatabase _db;
  final FincasRepository _fincas;
  final LotesRepository _lotes;
  final PesajesRepository _pesajes;
  final DietasRepository _dietas;
  final SanidadRepository _sanidad;
  final VentasRepository _ventas;
  final MedicamentosRepository _medicamentos;
  final GastosFijosRepository _gastosFijos;

  static const String fincaNombre = 'Finca de Erick';
  static const String loteNombre = 'Lote 1';
  static const String dietaNombre = 'Engorde Simple';
  static const String medicamentoNombre = 'Vitamina B';
  static const List<String> animales = ['A-1', 'A-2', 'A-3'];

  /// Días de estadía: el pesaje de entrada y la dieta arrancan hace 10 días.
  static const int diasEstadia = 10;

  /// Idempotente. Reusa la finca si ya está creada (el plan light solo permite
  /// una, así que crear otra fallaría), y no toca nada si ya tiene lotes.
  Future<String?> sembrarSiFalta({required String usuarioId}) async {
    final existentes = await _fincas.observarFincas(usuarioId).first;
    FincaRow? finca;
    for (final f in existentes) {
      if (f.nombre == fincaNombre) {
        finca = f;
        break;
      }
    }

    if (finca == null) {
      await _fincas.crearFinca(nombre: fincaNombre, creadaPor: usuarioId);
      finca = (await _fincas.observarFincas(usuarioId).first).firstWhere(
        (f) => f.nombre == fincaNombre,
      );
    } else if ((await _lotes.lotesActivos(finca.id)).isNotEmpty) {
      return null; // ya sembrada
    }

    final hoy = DateTime.now();
    final entrada = DateTime(
      hoy.year,
      hoy.month,
      hoy.day,
    ).subtract(const Duration(days: diasEstadia));

    await _lotes.crearLote(fincaId: finca.id, nombre: loteNombre, numero: 1);
    final lote = (await _lotes.lotesActivos(finca.id)).single;

    // ₡100/kg × 10 kg = ₡1.000 por animal al día (₡7.000 la semana).
    await _dietas.crearDieta(
      fincaId: finca.id,
      nombre: dietaNombre,
      costoKg: 100,
      kgAnimalDia: 10,
      descripcion: 'Prueba — números redondos',
    );
    final dieta = (await _db.select(_db.dietas).get()).firstWhere(
      (d) => d.nombre == dietaNombre,
    );
    await _dietas.asignarDietaALote(loteId: lote.id, dietaId: dieta.id);
    await _retrasarAsignacionDieta(lote.id, entrada);

    // Envase ₡10.000 / 100 aplicaciones = ₡100 por aplicación.
    final medicamentoId = await _medicamentos.crearMedicamento(
      fincaId: finca.id,
      nombre: medicamentoNombre,
      costoEnvase: 10000,
      tipoAplicacion: TipoAplicacionMedicamento.porAplicacion,
      aplicacionesPorEnvase: 100,
    );

    for (final identificador in animales) {
      await _pesajes.crearAnimalConPesaje(
        fincaId: finca.id,
        loteId: lote.id,
        identificador: identificador,
        peso: 200,
        registradoPor: usuarioId,
      );
      final animal = (await _pesajes.buscarAnimal(finca.id, identificador))!;

      // El pesaje de entrada y el movimiento al lote nacen con fecha de hoy.
      // Se retrasan los dos: el pesaje para que la ganancia diaria dé un
      // número revisable, y el movimiento porque el costo de alimentación se
      // calcula desde que el animal entró al lote (no desde el pesaje).
      await _retrasarPesajeDeEntrada(animal.id, entrada);
      await _retrasarIngresoAlLote(animal.id, entrada);

      // Compra: 200 kg × ₡1.000/kg = ₡200.000.
      await _ventas.actualizarCompra(
        animalId: animal.id,
        pesoCompra: 200,
        precioKgCompra: 1000,
        precioCompra: 200000,
        fechaCompra: entrada,
      );

      // Segundo pesaje hoy: +10 kg en 10 días = 1,0 kg/día.
      await _pesajes.agregarPesaje(
        animalId: animal.id,
        peso: 210,
        registradoPor: usuarioId,
      );

      await _sanidad.aplicarMedicamento(
        animalId: animal.id,
        medicamentoId: medicamentoId,
        pesoKg: 210,
        fecha: entrada.add(const Duration(days: 1)),
        responsableId: usuarioId,
      );
    }

    // ₡30.000 al mes, desde el día 1 del mes en curso: con 3 animales toda la
    // permanencia, toca ₡10.000 a cada uno.
    await _gastosFijos.crearGasto(
      fincaId: finca.id,
      concepto: 'Peón',
      monto: 30000,
      periodicidad: PeriodicidadGasto.mensual,
      desde: DateTime(hoy.year, hoy.month),
    );

    // Se vende A-3: 210 kg de salida, la planta paga ₡300.000.
    final vendido = (await _pesajes.buscarAnimal(finca.id, animales.last))!;
    await _ventas.confirmarLoteVenta(
      fincaId: finca.id,
      items: [(animalId: vendido.id, peso: 210)],
    );
    final venta = (await (_db.select(
      _db.ventas,
    )..where((t) => t.animalId.equals(vendido.id))).get()).single;
    await _ventas.registrarDatosPlanta(
      ventaId: venta.id,
      pesoPie: 205,
      pesoCanal: 105, // rendimiento 105/205 = 51,2 %
      dineroRecibido: 300000,
    );

    return finca.id;
  }

  /// Mueve el pesaje más viejo del animal a [fecha]. Mantiene `pendiente` para
  /// que suba igual al sincronizar.
  Future<void> _retrasarPesajeDeEntrada(String animalId, DateTime fecha) async {
    final primero =
        await (_db.select(_db.pesajes)
              ..where((t) => t.animalId.equals(animalId))
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingle();
    await (_db.update(
      _db.pesajes,
    )..where((t) => t.id.equals(primero.id))).write(
      PesajesCompanion(
        fecha: Value(fecha),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  /// Mueve a [fecha] el movimiento de ingreso al lote. `observarDietasRecibidas`
  /// arranca el periodo en `max(movimiento.fecha, asignacion.desde)`, así que sin
  /// esto la dieta cuenta 0 días y el costo de alimentación sale en ₡0.
  Future<void> _retrasarIngresoAlLote(String animalId, DateTime fecha) async {
    final primero =
        await (_db.select(_db.movimientosLote)
              ..where((t) => t.animalId.equals(animalId))
              ..orderBy([(t) => OrderingTerm.asc(t.fecha)])
              ..limit(1))
            .getSingleOrNull();
    if (primero == null) return;
    await (_db.update(
      _db.movimientosLote,
    )..where((t) => t.id.equals(primero.id))).write(
      MovimientosLoteCompanion(
        fecha: Value(fecha),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }

  /// Retrasa el inicio de la dieta vigente del lote para que acumule días.
  Future<void> _retrasarAsignacionDieta(String loteId, DateTime desde) async {
    await (_db.update(
      _db.loteDietas,
    )..where((t) => t.loteId.equals(loteId) & t.hasta.isNull())).write(
      LoteDietasCompanion(
        desde: Value(desde),
        updatedAt: Value(DateTime.now()),
        pendiente: const Value(true),
      ),
    );
  }
}

/// Corre el sembrado al arrancar, solo con `--dart-define=SEED_PRUEBA=1` y si
/// ya hay un usuario con sesión (la propia, no una de demo).
Future<void> maybeSeedPruebaOnStartup() async {
  if (!kSeedPruebaEnabled) return;
  final usuarioId =
      supabase.auth.currentUser?.id ?? sesionLocalRepo.sesion.value?.usuarioId;
  if (usuarioId == null) return;
  await SeedPrueba().sembrarSiFalta(usuarioId: usuarioId);
}
