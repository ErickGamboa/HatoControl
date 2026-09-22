import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/permisos_finca.dart';
import 'auth/cierre_sesion.dart';
import 'connectivity/estado_conexion.dart';
import 'data/local/database.dart';
import 'data/repositories/cuentas_repository.dart';
import 'data/repositories/deudas_repository.dart';
import 'data/repositories/dietas_repository.dart';
import 'data/repositories/feature_flags_repository.dart';
import 'data/repositories/fincas_repository.dart';
import 'data/repositories/gastos_fijos_repository.dart';
import 'data/repositories/lotes_repository.dart';
import 'data/repositories/medicamentos_repository.dart';
import 'data/repositories/pesajes_repository.dart';
import 'data/repositories/sanidad_repository.dart';
import 'data/repositories/sesion_local_repository.dart';
import 'data/repositories/ventas_repository.dart';
import 'data/sync/sync_service.dart';

/// Instancias compartidas de la app (se crean una sola vez, de forma perezosa).
/// Más adelante, si conviene, las podemos mover a Riverpod.
final AppDatabase db = AppDatabase();
final FincasRepository fincasRepo = FincasRepository(db);
final LotesRepository lotesRepo = LotesRepository(db);
final CuentasRepository cuentasRepo = CuentasRepository(db);
final PesajesRepository pesajesRepo = PesajesRepository(db);
final DietasRepository dietasRepo = DietasRepository(db);
final MedicamentosRepository medicamentosRepo = MedicamentosRepository(db);
final SanidadRepository sanidadRepo = SanidadRepository(db);
final GastosFijosRepository gastosFijosRepo = GastosFijosRepository(db);
final DeudasRepository deudasRepo = DeudasRepository(db);
final VentasRepository ventasRepo = VentasRepository(db);
final FeatureFlagsRepository featureFlagsRepo = FeatureFlagsRepository(db);
final SesionLocalRepository sesionLocalRepo = SesionLocalRepository(db);
final SyncService syncService = SyncService(db);
final EstadoConexion estadoConexion = EstadoConexion();

/// Permisos en la finca abierta (los invitados son de solo lectura).
/// La llena `FincaDetalleScreen` al entrar a una finca.
final PermisosFinca permisosFinca = PermisosFinca();

SupabaseClient get supabase => Supabase.instance.client;

SupabaseClient? get _supabaseClientOrNull {
  try {
    return Supabase.instance.client;
  } on AssertionError {
    return null;
  }
}

Future<void> sincronizarSiSePuede() async {
  if (!estadoConexion.hayConexion.value) {
    return;
  }
  final client = _supabaseClientOrNull;
  if (client == null || client.auth.currentSession == null) {
    return;
  }
  await syncService.sincronizar();
}

/// Intenta cerrar sesión. Devuelve `0` si cerró, o cuántos registros quedaban
/// sin subir si NO cerró (y entonces no tocó nada). La lógica —y el porqué—
/// están en [cerrarSesionEn]; la pantalla usa `cerrarSesionConAviso`.
Future<int> cerrarSesion({bool descartarPendientes = false}) {
  return cerrarSesionEn(
    db: db,
    sync: syncService,
    sesiones: sesionLocalRepo,
    signOut: () => supabase.auth.signOut(),
    descartarPendientes: descartarPendientes,
  );
}
