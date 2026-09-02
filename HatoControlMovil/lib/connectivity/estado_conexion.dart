import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class EstadoConexion {
  final ValueNotifier<bool> hayConexion = ValueNotifier(true);

  StreamSubscription<List<ConnectivityResult>>? _sub;

  Future<void> iniciar({Future<void> Function()? alRecuperarConexion}) async {
    final inicial = await Connectivity().checkConnectivity();
    _actualizar(inicial);
    _sub = Connectivity().onConnectivityChanged.listen((resultados) async {
      final antes = hayConexion.value;
      _actualizar(resultados);
      if (!antes && hayConexion.value) {
        await alRecuperarConexion?.call();
      }
    });
  }

  void _actualizar(List<ConnectivityResult> resultados) {
    hayConexion.value = resultados.any((r) => r != ConnectivityResult.none);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
