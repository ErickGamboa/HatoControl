import 'package:flutter/material.dart';
import 'package:hato_control/app/theme.dart';
import 'package:hato_control/data/estadisticas/estadisticas_finca.dart';
import 'package:hato_control/data/local/database.dart';
import 'package:hato_control/data/repositories/fincas_repository.dart';
import 'package:hato_control/fincas/crear_finca_flujo.dart';
import 'package:hato_control/services.dart';

import 'contenido_escritorio.dart';

/// Pantalla de entrada en la computadora: todas las fincas del usuario en una
/// cuadrícula ancha, con sus números a la vista, en vez de la lista vertical
/// del teléfono.
class PanelFincas extends StatefulWidget {
  const PanelFincas({
    super.key,
    required this.usuarioId,
    required this.sinConexion,
    required this.alAbrirFinca,
  });

  final String usuarioId;
  final bool sinConexion;
  final ValueChanged<FincaRow> alAbrirFinca;

  @override
  State<PanelFincas> createState() => _PanelFincasState();
}

class _PanelFincasState extends State<PanelFincas> {
  EstadoLicencia? _estado;

  @override
  void initState() {
    super.initState();
    sincronizarSiSePuede();
    _cargarEstado();
    syncService.sincronizando.addListener(_alCambiarSync);
  }

  @override
  void dispose() {
    syncService.sincronizando.removeListener(_alCambiarSync);
    super.dispose();
  }

  void _alCambiarSync() {
    if (!syncService.sincronizando.value) _cargarEstado();
  }

  Future<void> _cargarEstado() async {
    final estado = await fincasRepo.estadoLicencia(widget.usuarioId);
    if (mounted) setState(() => _estado = estado);
  }

  Future<void> _crearFinca() async {
    final aviso = await flujoCrearFinca(
      context,
      usuarioId: widget.usuarioId,
      estado: _estado,
    );
    if (!mounted) return;
    if (aviso != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(aviso)));
      return;
    }
    await _cargarEstado();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estado = _estado;

    return ContenidoEscritorio(
      child: StreamBuilder<List<FincaRow>>(
        stream: fincasRepo.observarFincas(widget.usuarioId),
        builder: (context, snapshot) {
          final fincas = snapshot.data ?? const <FincaRow>[];
          return ListView(
            padding: const EdgeInsets.all(HatoSpacing.xl),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mis fincas',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (estado != null) ...[
                          const SizedBox(height: HatoSpacing.xs),
                          Text(
                            'Plan ${estado.planNombre} · ${estado.usadas} '
                            'de ${estado.limiteTexto} finca(s)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _crearFinca,
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva finca'),
                  ),
                ],
              ),
              const SizedBox(height: HatoSpacing.xl),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  fincas.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (fincas.isEmpty)
                _SinFincas(sinConexion: widget.sinConexion)
              else
                GridView.extent(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  maxCrossAxisExtent: 340,
                  mainAxisSpacing: HatoSpacing.lg,
                  crossAxisSpacing: HatoSpacing.lg,
                  childAspectRatio: 1.05,
                  children: [
                    for (final finca in fincas)
                      _TarjetaFinca(
                        finca: finca,
                        alTocar: () => widget.alAbrirFinca(finca),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SinFincas extends StatelessWidget {
  const _SinFincas({required this.sinConexion});

  final bool sinConexion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            Icons.holiday_village_outlined,
            size: 56,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: HatoSpacing.lg),
          Text(
            sinConexion
                ? 'Sin internet todavía no se ven tus fincas.'
                : 'Todavía no tenés fincas registradas.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: HatoSpacing.sm),
          Text(
            'Creá la primera con el botón Nueva finca.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaFinca extends StatelessWidget {
  const _TarjetaFinca({required this.finca, required this.alTocar});

  final FincaRow finca;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _FotoFincaWeb(finca: finca)),
            Padding(
              padding: const EdgeInsets.all(HatoSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    finca.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: HatoSpacing.sm),
                  Row(
                    children: [
                      _MiniDato(
                        asset: 'assets/iconos/lotes.png',
                        etiqueta: 'Lotes',
                        valor: lotesRepo
                            .observarLotes(finca.id)
                            .map((l) => l.length),
                      ),
                      const SizedBox(width: HatoSpacing.xl),
                      _MiniDato(
                        asset: 'assets/iconos/animales.png',
                        etiqueta: 'Animales',
                        valor: observarAnimalesActivos(db, finca.id),
                      ),
                    ],
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

/// En web no hay archivos locales: la foto se ve desde el servidor (D-09).
class _FotoFincaWeb extends StatelessWidget {
  const _FotoFincaWeb({required this.finca});

  final FincaRow finca;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = finca.fotoUrl;
    final marcador = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.landscape_outlined,
        size: 44,
        color: theme.colorScheme.outlineVariant,
      ),
    );
    if (url == null || url.isEmpty) return marcador;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => marcador,
      loadingBuilder: (context, child, progreso) =>
          progreso == null ? child : marcador,
    );
  }
}

class _MiniDato extends StatelessWidget {
  const _MiniDato({
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
    return StreamBuilder<int>(
      stream: valor,
      builder: (context, snapshot) {
        final numero = snapshot.data;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              asset,
              width: 18,
              height: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: HatoSpacing.sm),
            Text(
              numero == null ? '--' : '$numero',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: HatoSpacing.xs),
            Text(
              etiqueta,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        );
      },
    );
  }
}
