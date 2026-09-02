import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local/database.dart';

/// Guarda la última identidad verificada online para permitir uso local cuando
/// no hay sesión Supabase disponible por falta de conexión.
class SesionLocalRepository {
  SesionLocalRepository(this.db);

  static const _filaActual = 'actual';

  final AppDatabase db;
  final ValueNotifier<SesionLocalRow?> sesion = ValueNotifier(null);

  String? get usuarioId => sesion.value?.usuarioId;
  bool get offlineActiva => sesion.value?.offlineActiva ?? false;

  Future<void> cargar() async {
    sesion.value = await obtener();
  }

  Future<SesionLocalRow?> obtener() {
    return (db.select(
      db.sesionesLocales,
    )..where((t) => t.id.equals(_filaActual))).getSingleOrNull();
  }

  Future<void> guardarUsuarioVerificado({
    required String usuarioId,
    String? email,
    String? nombre,
  }) async {
    // Si en este aparato estaba OTRA cuenta, su caché no solo sobra: estorba.
    // Los cursores de bajada son del aparato, así que el que entra heredaría
    // un cursor más nuevo que sus propias filas y nunca las vería bajar (ver
    // [AppDatabase.borrarDatosLocales]). Se limpia antes de guardar la
    // identidad nueva.
    final anterior = await obtener();
    if (anterior != null && anterior.usuarioId != usuarioId) {
      await db.borrarDatosLocales();
    }

    final fila = SesionLocalRow(
      id: _filaActual,
      usuarioId: usuarioId,
      email: email,
      nombre: nombre,
      ultimoLoginOnline: DateTime.now(),
      offlineActiva: false,
    );
    await db.into(db.sesionesLocales).insertOnConflictUpdate(fila);
    sesion.value = fila;
  }

  Future<void> activarOffline() async {
    final actual = await obtener();
    if (actual == null) return;
    await (db.update(db.sesionesLocales)
          ..where((t) => t.id.equals(_filaActual)))
        .write(const SesionesLocalesCompanion(offlineActiva: Value(true)));
    sesion.value = actual.copyWith(offlineActiva: true);
  }

  Future<bool> activarOfflineParaEmail(String email) async {
    final actual = await obtener();
    if (actual == null) return false;

    final emailCacheado = actual.email?.trim().toLowerCase();
    final emailIngresado = email.trim().toLowerCase();
    if (emailCacheado != null &&
        emailCacheado.isNotEmpty &&
        emailCacheado != emailIngresado) {
      return false;
    }

    await activarOffline();
    return true;
  }

  Future<void> desactivarOffline() async {
    final actual = await obtener();
    if (actual == null) return;
    await (db.update(db.sesionesLocales)
          ..where((t) => t.id.equals(_filaActual)))
        .write(const SesionesLocalesCompanion(offlineActiva: Value(false)));
    sesion.value = actual.copyWith(offlineActiva: false);
  }

  Future<void> borrar() async {
    await (db.delete(
      db.sesionesLocales,
    )..where((t) => t.id.equals(_filaActual))).go();
    sesion.value = null;
  }
}
