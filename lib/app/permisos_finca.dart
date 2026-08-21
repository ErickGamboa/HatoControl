import 'dart:async';

import 'package:flutter/material.dart';

import '../data/repositories/fincas_repository.dart';

/// Permisos del usuario dentro de la finca que está abierta.
///
/// Los invitados (`finca_miembros.rol = 'lector'`) solo pueden ver: la UI les
/// esconde las acciones de escritura y la RLS del servidor las rechaza. Se
/// carga al entrar a la finca ([seguir]) y se suelta al salir ([limpiar]).
///
/// Ante la duda **se permite escribir**: si todavía no bajó la membresía o la
/// sesión es offline, el rol es desconocido y la app se comporta normal. El
/// candado de verdad está en la base de datos, no acá.
class PermisosFinca {
  /// true solo cuando sabemos que el rol de esta finca es `lector`.
  final ValueNotifier<bool> soloLectura = ValueNotifier<bool>(false);

  StreamSubscription<String?>? _suscripcion;

  bool get esSoloLectura => soloLectura.value;

  /// Empieza a seguir el rol del usuario en la finca abierta.
  void seguir(Stream<String?> rol) {
    _suscripcion?.cancel();
    soloLectura.value = false;
    _suscripcion = rol.listen(
      (r) => soloLectura.value = RolFinca.esSoloLectura(r),
    );
  }

  /// Deja de seguir el rol (al salir de la finca) y vuelve al estado normal.
  void limpiar() {
    _suscripcion?.cancel();
    _suscripcion = null;
    soloLectura.value = false;
  }

  /// Devuelve [accion] si el usuario puede escribir, o null si es de solo
  /// lectura — así el botón queda deshabilitado en vez de guardar.
  VoidCallback? siPuedeEscribir(VoidCallback accion) {
    return esSoloLectura ? null : accion;
  }
}

/// Banda que le recuerda al invitado que esta finca es de solo lectura.
/// Se esconde sola cuando el usuario sí puede escribir.
class AvisoSoloLectura extends StatelessWidget {
  const AvisoSoloLectura({super.key, required this.permisos});

  final PermisosFinca permisos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<bool>(
      valueListenable: permisos.soloLectura,
      builder: (context, soloLectura, _) {
        if (!soloLectura) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: theme.colorScheme.secondaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 20,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Solo lectura: te compartieron esta finca para verla, '
                  'no para hacer cambios.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
