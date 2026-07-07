import 'package:supabase_flutter/supabase_flutter.dart';

import 'connectivity/estado_conexion.dart';
import 'data/local/database.dart';
import 'data/repositories/cuentas_repository.dart';
import 'data/repositories/dietas_repository.dart';
import 'data/repositories/fincas_repository.dart';
import 'data/repositories/lotes_repository.dart';
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
final SanidadRepository sanidadRepo = SanidadRepository(db);
final VentasRepository ventasRepo = VentasRepository(db);
final SesionLocalRepository sesionLocalRepo = SesionLocalRepository(db);
final SyncService syncService = SyncService(db);
final EstadoConexion estadoConexion = EstadoConexion();

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

Future<void> cerrarSesion() async {
  await sesionLocalRepo.borrar();
  try {
    await supabase.auth.signOut();
  } catch (_) {
    // Sin conexión puede fallar el signOut remoto; la sesión local ya quedó
    // cerrada para este dispositivo.
  }
}
