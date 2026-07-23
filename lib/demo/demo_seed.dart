import 'package:drift/drift.dart';

import '../data/estadisticas/estadisticas_sanidad.dart';
import '../data/local/database.dart';
import '../data/repositories/dietas_repository.dart';
import '../data/repositories/fincas_repository.dart';
import '../data/repositories/lotes_repository.dart';
import '../data/repositories/medicamentos_repository.dart';
import '../data/repositories/pesajes_repository.dart';
import '../data/repositories/sanidad_repository.dart';
import '../data/repositories/ventas_repository.dart';
import '../services.dart';
import 'demo_env.dart';
import 'demo_seed_ids.dart';

/// Seeds a rich offline demo finca (oro modules) for simulators and tours.
class DemoSeed {
  DemoSeed({
    AppDatabase? database,
    FincasRepository? fincas,
    LotesRepository? lotes,
    PesajesRepository? pesajes,
    DietasRepository? dietas,
    SanidadRepository? sanidad,
    VentasRepository? ventas,
    MedicamentosRepository? medicamentos,
  }) : _db = database ?? db,
       _fincas = fincas ?? fincasRepo,
       _lotes = lotes ?? lotesRepo,
       _pesajes = pesajes ?? pesajesRepo,
       _dietas = dietas ?? dietasRepo,
       _sanidad = sanidad ?? sanidadRepo,
       _ventas = ventas ?? ventasRepo,
       _medicamentos = medicamentos ?? medicamentosRepo;

  final AppDatabase _db;
  final FincasRepository _fincas;
  final LotesRepository _lotes;
  final PesajesRepository _pesajes;
  final DietasRepository _dietas;
  final SanidadRepository _sanidad;
  final VentasRepository _ventas;
  final MedicamentosRepository _medicamentos;

  /// Idempotent: skips if demo finca already exists for this user.
  Future<DemoSeedSnapshot> seedIfAbsent({required String usuarioId}) async {
    final fincas = await _fincas.observarFincas(usuarioId).first;
    FincaRow? existente;
    for (final f in fincas) {
      if (f.nombre == DemoSeedIds.fincaNombre) {
        existente = f;
        break;
      }
    }
    if (existente != null) {
      final lotes = await _lotes.lotesActivos(existente.id);
      await _ensureTourFixtures(
        finca: existente,
        lotes: lotes,
        usuarioId: usuarioId,
      );
      return DemoSeedSnapshot(
        fincaId: existente.id,
        fincaNombre: existente.nombre,
        loteDesteteId: lotes
            .firstWhere((l) => l.nombre == DemoSeedIds.loteDestete)
            .id,
        loteEngordeId: lotes
            .firstWhere((l) => l.nombre == DemoSeedIds.loteEngorde)
            .id,
      );
    }

    await _ensureCuenta(usuarioId);
    await _fincas.crearFinca(
      nombre: DemoSeedIds.fincaNombre,
      creadaPor: usuarioId,
    );
    final finca = (await _fincas.observarFincas(usuarioId).first).firstWhere(
      (f) => f.nombre == DemoSeedIds.fincaNombre,
    );

    await _lotes.crearLote(
      fincaId: finca.id,
      nombre: DemoSeedIds.loteDestete,
      numero: 1,
    );
    await _lotes.crearLote(
      fincaId: finca.id,
      nombre: DemoSeedIds.loteLevante,
      numero: 2,
    );
    await _lotes.crearLote(
      fincaId: finca.id,
      nombre: DemoSeedIds.loteEngorde,
      numero: 3,
    );
    final lotes = await _lotes.lotesActivos(finca.id);
    final loteDestete = lotes.firstWhere(
      (l) => l.nombre == DemoSeedIds.loteDestete,
    );
    final loteLevante = lotes.firstWhere(
      (l) => l.nombre == DemoSeedIds.loteLevante,
    );
    final loteEngorde = lotes.firstWhere(
      (l) => l.nombre == DemoSeedIds.loteEngorde,
    );

    await _dietas.crearDieta(
      fincaId: finca.id,
      nombre: 'Concentrado engorde',
      costoAnimalDia: 450,
      descripcion: 'Demo — ración alta energía',
    );
    await _dietas.crearDieta(
      fincaId: finca.id,
      nombre: 'Pasto + mineral',
      costoAnimalDia: 120,
    );
    final dietas = await _db.select(_db.dietas).get();
    final dietaEngorde = dietas.firstWhere(
      (d) => d.nombre == 'Concentrado engorde',
    );
    final dietaPasto = dietas.firstWhere((d) => d.nombre == 'Pasto + mineral');
    await _dietas.asignarDietaALote(
      loteId: loteDestete.id,
      dietaId: dietaEngorde.id,
    );
    await _dietas.asignarDietaALote(
      loteId: loteLevante.id,
      dietaId: dietaPasto.id,
    );

    await _ensureMedicamentos(finca.id);

    // Animal 1001 — historial de pesajes + sanidad
    await _pesajes.crearAnimalConPesaje(
      fincaId: finca.id,
      loteId: loteDestete.id,
      identificador: DemoSeedIds.animalCorral,
      peso: 180,
      registradoPor: usuarioId,
    );
    final animal1001 = await _pesajes.buscarAnimal(
      finca.id,
      DemoSeedIds.animalCorral,
    );
    await _pesajes.agregarPesaje(
      animalId: animal1001!.id,
      peso: 195,
      registradoPor: usuarioId,
    );
    await _pesajes.agregarPesaje(
      animalId: animal1001.id,
      peso: 210,
      registradoPor: usuarioId,
    );
    await _sanidad.registrarEvento(
      animalId: animal1001.id,
      tipo: TipoEventoSanitario.vacuna,
      producto: 'Clostridial 7 vías',
      dosis: '5 ml',
      costo: 8500,
      responsableId: usuarioId,
      fecha: DateTime(2026, 2, 15),
    );

    // Animal 1002 — economía abierta (compra + sanidad, sin vender)
    await _pesajes.crearAnimalConPesaje(
      fincaId: finca.id,
      loteId: loteDestete.id,
      identificador: DemoSeedIds.animalEconomia,
      peso: 200,
      registradoPor: usuarioId,
    );
    final animal1002 = await _pesajes.buscarAnimal(
      finca.id,
      DemoSeedIds.animalEconomia,
    );
    await _ventas.actualizarCompra(
      animalId: animal1002!.id,
      precioCompra: 520000,
      fechaCompra: DateTime(2025, 6, 1),
    );
    await _sanidad.registrarEvento(
      animalId: animal1002.id,
      tipo: TipoEventoSanitario.medicamento,
      producto: 'Ivermectina',
      costo: 18000,
      responsableId: usuarioId,
    );

    // Animal 1003 — lote destete extra
    await _pesajes.crearAnimalConPesaje(
      fincaId: finca.id,
      loteId: loteDestete.id,
      identificador: '1003',
      peso: 175,
      registradoPor: usuarioId,
    );

    // Batch sanidad al lote destete (demo corral batch)
    await _sanidad.registrarEventoEnLote(
      loteId: loteEngorde.id,
      tipo: TipoEventoSanitario.desparasitacion,
      producto: 'Albendazol',
      dosis: '10 ml',
      costo: 3200,
      responsableId: usuarioId,
      fecha: DateTime(2026, 3, 1),
    );

    // Animal 3001 — vendido con rentabilidad (fixture roadmap)
    await _pesajes.crearAnimalConPesaje(
      fincaId: finca.id,
      loteId: loteEngorde.id,
      identificador: DemoSeedIds.animalVendido,
      peso: 380,
      registradoPor: usuarioId,
    );
    final animal3001 = await _pesajes.buscarAnimal(
      finca.id,
      DemoSeedIds.animalVendido,
    );
    await _ventas.actualizarCompra(
      animalId: animal3001!.id,
      precioCompra: 520000,
      fechaCompra: DateTime(2025, 1, 1),
    );
    await _sanidad.registrarEvento(
      animalId: animal3001.id,
      tipo: TipoEventoSanitario.medicamento,
      producto: 'Kit sanitario engorde',
      costo: 18000,
      responsableId: usuarioId,
    );
    // ~10 días × ~9500 ₡/día ≈ 95000 alimentación (see estadisticas test)
    await _ventas.registrarVenta(
      animalId: animal3001.id,
      precio: 780000,
      fecha: DateTime(2026, 3, 10),
      comprador: 'Frigorífico Demo',
    );

    return DemoSeedSnapshot(
      fincaId: finca.id,
      fincaNombre: finca.nombre,
      loteDesteteId: loteDestete.id,
      loteEngordeId: loteEngorde.id,
    );
  }

  /// Catálogo oro: Catosal (por peso) + spray curabicheras.
  Future<void> _ensureMedicamentos(String fincaId) async {
    final existentes = await _medicamentos.listarMedicamentos(fincaId);
    final nombres = existentes.map((m) => m.nombre).toSet();
    if (!nombres.contains('Catosal')) {
      await _medicamentos.crearMedicamento(
        fincaId: fincaId,
        nombre: 'Catosal',
        costoEnvase: 10000,
        tipoAplicacion: TipoAplicacionMedicamento.porPeso,
        mlEnvase: 100,
        dosisCantidad: 50,
        dosisPorCadaKg: 10,
        diasRetiro: 0,
      );
    }
    if (!nombres.contains('Curabicheras spray')) {
      await _medicamentos.crearMedicamento(
        fincaId: fincaId,
        nombre: 'Curabicheras spray',
        costoEnvase: 15000,
        tipoAplicacion: TipoAplicacionMedicamento.porAplicacion,
        aplicacionesPorEnvase: 50,
        diasRetiro: 0,
      );
    }
    if (!nombres.contains('Ivermectina')) {
      await _medicamentos.crearMedicamento(
        fincaId: fincaId,
        nombre: 'Ivermectina',
        costoEnvase: 25000,
        tipoAplicacion: TipoAplicacionMedicamento.dosisFija,
        mlEnvase: 50,
        dosisCantidad: 5,
        diasRetiro: 35,
      );
    }
  }

  /// Older demo seeds applied Albendazol batch to [loteDestete]; drop for tour UX.
  Future<void> _quitarAlbendazolObsoletoEnDestete(String loteDesteteId) async {
    final animalesDestete =
        await (_db.select(_db.animales)..where(
              (t) => t.loteId.equals(loteDesteteId) & t.deletedAt.isNull(),
            ))
            .get();
    final ahora = DateTime.now();
    for (final a in animalesDestete) {
      await (_db.update(_db.eventosSanitarios)..where(
            (t) =>
                t.animalId.equals(a.id) &
                t.producto.equals('Albendazol') &
                t.deletedAt.isNull(),
          ))
          .write(
            EventosSanitariosCompanion(
              deletedAt: Value(ahora),
              updatedAt: Value(ahora),
              pendiente: const Value(true),
            ),
          );
    }
  }

  /// Fills gaps when an older demo finca already exists on disk (tour builds).
  Future<void> _ensureTourFixtures({
    required FincaRow finca,
    required List<LoteRow> lotes,
    required String usuarioId,
  }) async {
    if (!kSeedDemoEnabled) return;

    LoteRow loteOrThrow(String nombre) =>
        lotes.firstWhere((l) => l.nombre == nombre);

    final loteDestete = loteOrThrow(DemoSeedIds.loteDestete);
    final loteEngorde = loteOrThrow(DemoSeedIds.loteEngorde);

    await _quitarAlbendazolObsoletoEnDestete(loteDestete.id);
    await _ensureMedicamentos(finca.id);

    Future<AnimalRow?> animal(String ident) =>
        _pesajes.buscarAnimal(finca.id, ident);

    var a1001 = await animal(DemoSeedIds.animalCorral);
    if (a1001 == null) {
      await _pesajes.crearAnimalConPesaje(
        fincaId: finca.id,
        loteId: loteDestete.id,
        identificador: DemoSeedIds.animalCorral,
        peso: 180,
        registradoPor: usuarioId,
      );
      a1001 = await animal(DemoSeedIds.animalCorral);
    }
    if (a1001 != null && await _sanidad.ultimoEvento(a1001.id) == null) {
      await _sanidad.registrarEvento(
        animalId: a1001.id,
        tipo: TipoEventoSanitario.vacuna,
        producto: 'Clostridial 7 vías',
        dosis: '5 ml',
        costo: 8500,
        responsableId: usuarioId,
        fecha: DateTime(2026, 2, 15),
      );
    }

    var a1002 = await animal(DemoSeedIds.animalEconomia);
    if (a1002 == null) {
      await _pesajes.crearAnimalConPesaje(
        fincaId: finca.id,
        loteId: loteDestete.id,
        identificador: DemoSeedIds.animalEconomia,
        peso: 200,
        registradoPor: usuarioId,
      );
      a1002 = await animal(DemoSeedIds.animalEconomia);
    }
    if (a1002 != null) {
      if (a1002.precioCompra == null) {
        await _ventas.actualizarCompra(
          animalId: a1002.id,
          precioCompra: 520000,
          fechaCompra: DateTime(2025, 6, 1),
        );
      }
      if (await _sanidad.ultimoEvento(a1002.id) == null) {
        await _sanidad.registrarEvento(
          animalId: a1002.id,
          tipo: TipoEventoSanitario.medicamento,
          producto: 'Ivermectina',
          costo: 18000,
          responsableId: usuarioId,
        );
      }
    }

    var a3001 = await animal(DemoSeedIds.animalVendido);
    if (a3001 == null) {
      await _pesajes.crearAnimalConPesaje(
        fincaId: finca.id,
        loteId: loteEngorde.id,
        identificador: DemoSeedIds.animalVendido,
        peso: 380,
        registradoPor: usuarioId,
      );
      a3001 = await animal(DemoSeedIds.animalVendido);
    }
    if (a3001 != null && a3001.estado != EstadoAnimal.vendido) {
      if (a3001.precioCompra == null) {
        await _ventas.actualizarCompra(
          animalId: a3001.id,
          precioCompra: 520000,
          fechaCompra: DateTime(2025, 1, 1),
        );
      }
      if (await _sanidad.ultimoEvento(a3001.id) == null) {
        await _sanidad.registrarEvento(
          animalId: a3001.id,
          tipo: TipoEventoSanitario.medicamento,
          producto: 'Kit sanitario engorde',
          costo: 18000,
          responsableId: usuarioId,
        );
      }
      await _ventas.registrarVenta(
        animalId: a3001.id,
        precio: 780000,
        fecha: DateTime(2026, 3, 10),
        comprador: 'Frigorífico Demo',
      );
    }
  }

  Future<void> _ensureCuenta(String usuarioId) async {
    final existe = await (_db.select(
      _db.usuarios,
    )..where((t) => t.id.equals(usuarioId))).getSingleOrNull();
    if (existe != null) return;

    final ts = DateTime(2026, 1, 1);
    await _db
        .into(_db.planes)
        .insertOnConflictUpdate(
          PlanesCompanion.insert(
            codigo: 'pro',
            nombre: 'Pro',
            limiteFincas: 20,
            updatedAt: ts,
          ),
        );
    await _db
        .into(_db.cuentas)
        .insert(
          CuentasCompanion.insert(
            id: DemoSeedIds.cuentaId,
            nombre: 'Cuenta Demo HatoControl',
            duenoId: usuarioId,
            plan: 'pro',
            estado: 'activa',
            createdAt: ts,
            updatedAt: ts,
          ),
        );
    await _db
        .into(_db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: usuarioId,
            nombre: const Value('Productor Demo'),
            email: const Value('demo@hatocontrol.cr'),
            cuentaId: const Value(DemoSeedIds.cuentaId),
            createdAt: ts,
            updatedAt: ts,
          ),
        );
  }
}

/// Activates offline demo session (call after [DemoSeed.seedIfAbsent]).
Future<void> activateDemoOfflineSession({String? usuarioId}) async {
  final uid = usuarioId ?? DemoSeedIds.userId;
  await sesionLocalRepo.guardarUsuarioVerificado(
    usuarioId: uid,
    email: 'demo@hatocontrol.cr',
    nombre: 'Productor Demo',
  );
  await sesionLocalRepo.activarOffline();
}

/// Seeds demo data + offline session when `SEED_DEMO` is true.
Future<void> maybeSeedDemoOnStartup() async {
  if (!kSeedDemoEnabled) return;

  const uid = String.fromEnvironment(
    'DEMO_USER_ID',
    defaultValue: DemoSeedIds.userId,
  );
  await DemoSeed().seedIfAbsent(usuarioId: uid);
  try {
    await supabase.auth.signOut();
  } catch (_) {
    // Tour/demo: no real session required.
  }
  await activateDemoOfflineSession(usuarioId: uid);
}
