import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/local/database.dart';
import 'data/repositories/cuentas_repository.dart';
import 'data/repositories/fincas_repository.dart';
import 'data/repositories/lotes_repository.dart';
import 'data/repositories/pesajes_repository.dart';
import 'data/sync/sync_service.dart';

/// Instancias compartidas de la app (se crean una sola vez, de forma perezosa).
/// Más adelante, si conviene, las podemos mover a Riverpod.
final AppDatabase db = AppDatabase();
final FincasRepository fincasRepo = FincasRepository(db);
final LotesRepository lotesRepo = LotesRepository(db);
final CuentasRepository cuentasRepo = CuentasRepository(db);
final PesajesRepository pesajesRepo = PesajesRepository(db);
final SyncService syncService = SyncService(db);

SupabaseClient get supabase => Supabase.instance.client;
