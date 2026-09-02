import 'package:flutter/material.dart';
import 'package:hato_control/app/permisos_finca.dart';
import 'package:hato_control/app/theme.dart';
import 'package:hato_control/data/estadisticas/estadisticas_finca.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/services.dart';

import 'contenido_escritorio.dart';
import 'secciones.dart';

/// Inicio de la finca en la computadora.
///
/// Muestra lo mismo que el home de finca del teléfono — los dos números de
/// cabecera, la Recolección de datos como acción principal y los módulos —
/// pero repartido a lo ancho, con los números arriba y los módulos en una
/// fila, que es como se lee cómodo en un monitor.
class PanelFinca extends StatelessWidget {
  const PanelFinca({
    super.key,
    required this.finca,
    required this.alElegirSeccion,
    required this.alCompartir,
    required this.alEditar,
  });

  final FincaRow finca;
  final ValueChanged<SeccionEscritorio> alElegirSeccion;
  final VoidCallback? alCompartir;
  final VoidCallback alEditar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: permisosFinca.soloLectura,
      builder: (context, soloLectura, _) {
        final modulos = SeccionEscritorio.paraFinca(soloLectura: soloLectura)
            .where((s) => s != SeccionEscritorio.inicio)
            .where((s) => s != SeccionEscritorio.pesaje)
            .toList();

        return ContenidoEscritorio(
          child: ListView(
            padding: const EdgeInsets.all(HatoSpacing.xl),
            children: [
              AvisoSoloLectura(permisos: permisosFinca),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      finca.nombre,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!soloLectura) ...[
                    TextButton.icon(
                      onPressed: alCompartir,
                      icon: const Icon(Icons.person_add_alt_1, size: 18),
                      label: const Text('Compartir'),
                    ),
                    const SizedBox(width: HatoSpacing.sm),
                    TextButton.icon(
                      onPressed: alEditar,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar finca'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: HatoSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _Kpi(
                      asset: 'assets/iconos/lotes.png',
                      etiqueta: 'Lotes',
                      valor: lotesRepo
                          .observarLotes(finca.id)
                          .map((l) => l.length),
                    ),
                  ),
                  const SizedBox(width: HatoSpacing.lg),
                  Expanded(
                    child: _Kpi(
                      asset: 'assets/iconos/animales.png',
                      etiqueta: 'Animales activos',
                      valor: observarAnimalesActivos(db, finca.id),
                    ),
                  ),
                  const SizedBox(width: HatoSpacing.lg),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: HatoSpacing.xl),
              // Recolección de datos es puro registro: un invitado de solo
              // lectura no entra a la manga.
              if (!soloLectura) ...[
                _HeroTrabajo(
                  alTocar: () => alElegirSeccion(SeccionEscritorio.pesaje),
                ),
                const SizedBox(height: HatoSpacing.xl),
              ],
              Text(
                'Módulos',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: HatoSpacing.md),
              GridView.extent(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                maxCrossAxisExtent: 230,
                mainAxisSpacing: HatoSpacing.md,
                crossAxisSpacing: HatoSpacing.md,
                childAspectRatio: 1.35,
                children: [
                  for (final s in modulos)
                    _TarjetaModulo(
                      seccion: s,
                      alTocar: () => alElegirSeccion(s),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.asset,
    required this.etiqueta,
    required this.valor,
  });

  final String asset;
  final String etiqueta;
  final Stream<int> valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(HatoSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(asset, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: HatoSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<int>(
                    stream: valor,
                    builder: (context, snapshot) {
                      final numero = snapshot.data;
                      return Text(
                        numero == null ? '--' : '$numero',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  Text(
                    etiqueta,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La acción principal de la finca, igual que en el teléfono pero a lo ancho.
class _HeroTrabajo extends StatelessWidget {
  const _HeroTrabajo({required this.alTocar});

  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(HatoSpacing.xl),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/iconos/recoleccion.png',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: HatoSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recolección de datos',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: HatoSpacing.xs),
                    Text(
                      'Pesar, registrar animales y aplicar tratamientos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaModulo extends StatelessWidget {
  const _TarjetaModulo({required this.seccion, required this.alTocar});

  final SeccionEscritorio seccion;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(HatoSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconoSeccion(
                asset: seccion.asset,
                icono: seccion.icono,
                color: theme.colorScheme.primary,
                tamano: 36,
              ),
              const SizedBox(height: HatoSpacing.md),
              Text(
                seccion.etiqueta,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
