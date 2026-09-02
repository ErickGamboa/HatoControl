import 'package:flutter/material.dart';
import 'package:hato_control/app/theme.dart';
import 'package:hato_control/data/local/database.dart';

import 'contenido_escritorio.dart';
import 'secciones.dart';

/// Menú fijo de la izquierda: logo, fincas, módulos de la finca abierta y, al
/// pie, la cuenta. Siempre visible, para que en la computadora no haya que
/// devolverse una pantalla para cambiar de módulo.
class BarraLateral extends StatelessWidget {
  const BarraLateral({
    super.key,
    required this.finca,
    required this.seccion,
    required this.soloLectura,
    required this.correo,
    required this.alElegirSeccion,
    required this.alIrAFincas,
    required this.alCerrarSesion,
  });

  static const double ancho = 268;

  final FincaRow? finca;
  final SeccionEscritorio seccion;
  final bool soloLectura;
  final String? correo;
  final ValueChanged<SeccionEscritorio> alElegirSeccion;
  final VoidCallback alIrAFincas;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fincaAbierta = finca;

    return Container(
      width: ancho,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Marca(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: HatoSpacing.md,
                vertical: HatoSpacing.md,
              ),
              children: [
                _ItemLateral(
                  etiqueta: 'Mis fincas',
                  icono: Icons.holiday_village_outlined,
                  activo: fincaAbierta == null,
                  alTocar: alIrAFincas,
                ),
                if (fincaAbierta != null) ...[
                  const SizedBox(height: HatoSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      HatoSpacing.md,
                      0,
                      HatoSpacing.md,
                      HatoSpacing.sm,
                    ),
                    child: Text(
                      fincaAbierta.nombre.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  for (final s in SeccionEscritorio.paraFinca(
                    soloLectura: soloLectura,
                  ))
                    _ItemLateral(
                      etiqueta: s.etiqueta,
                      icono: s.icono,
                      asset: s.asset,
                      activo: s == seccion,
                      alTocar: () => alElegirSeccion(s),
                    ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          _PieCuenta(correo: correo, alCerrarSesion: alCerrarSesion),
        ],
      ),
    );
  }
}

/// La marca en la barra lateral: el emblema del logo sobre una placa blanca y
/// el nombre en tipografía.
///
/// No se usa el PNG completo del logo porque ese archivo trae el fondo blanco
/// pegado y la palabra "HATO CONTROL" queda diminuta a este tamaño. Con el
/// emblema y el nombre por separado, el texto sale nítido en cualquier
/// pantalla y la placa blanca hace que el trazo azul marino del logo se lea
/// bien también en modo oscuro.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final claro = theme.brightness == Brightness.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HatoSpacing.lg,
        HatoSpacing.lg,
        HatoSpacing.lg,
        HatoSpacing.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: claro
                  ? Border.all(color: theme.colorScheme.outlineVariant)
                  : null,
            ),
            padding: const EdgeInsets.all(5),
            child: Image.asset(
              'assets/logo/emblema_sin_fondo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: HatoSpacing.md),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'Hato',
                      style: TextStyle(
                        color: claro ? kAzulHato : theme.colorScheme.onSurface,
                      ),
                    ),
                    const TextSpan(
                      text: 'Control',
                      style: TextStyle(color: kVerdeHato),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemLateral extends StatelessWidget {
  const _ItemLateral({
    required this.etiqueta,
    required this.activo,
    required this.alTocar,
    this.icono,
    this.asset,
  });

  final String etiqueta;
  final IconData? icono;
  final String? asset;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activo
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: activo
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: alTocar,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HatoSpacing.md,
              vertical: 11,
            ),
            child: Row(
              children: [
                IconoSeccion(asset: asset, icono: icono, color: color),
                const SizedBox(width: HatoSpacing.md),
                Expanded(
                  child: Text(
                    etiqueta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PieCuenta extends StatelessWidget {
  const _PieCuenta({required this.correo, required this.alCerrarSesion});

  final String? correo;
  final VoidCallback alCerrarSesion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(HatoSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: kAzulHato,
            child: Text(
              (correo ?? '?').substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: HatoSpacing.md),
          Expanded(
            child: Text(
              correo ?? 'Sesión activa',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, size: 20),
            onPressed: alCerrarSesion,
          ),
        ],
      ),
    );
  }
}
