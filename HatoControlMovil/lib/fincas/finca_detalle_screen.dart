import 'package:flutter/material.dart';

import '../app/permisos_finca.dart';
import '../app/theme.dart';
import '../data/estadisticas/estadisticas_finca.dart';
import '../data/local/database.dart';
import '../data/repositories/fincas_repository.dart';
import '../data/repositories/lotes_repository.dart';
import '../dietas/dietas_screen.dart';
import '../analisis/analisis_screen.dart';
import '../gastos_fijos/gastos_fijos_screen.dart';
import '../lotes/lotes_screen.dart';
import '../pesaje/pesaje_screen.dart';
import '../sanidad/sanidad_screen.dart';
import '../services.dart';
import '../venta/venta_screen.dart';
import 'compartir_finca_screen.dart';
import 'editar_finca_flujo.dart';

/// Home de la finca según el documento oro: Trabajo (Pesaje) como acción
/// principal, y módulos Sanidad · Lotes · Dietas · Venta · Gastos fijos.
class FincaDetalleScreen extends StatefulWidget {
  FincaDetalleScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
    required this.sinConexion,
    AppDatabase? database,
    FincasRepository? fincasRepository,
    LotesRepository? lotesRepository,
    PermisosFinca? permisos,
  }) : database = database ?? db,
       fincasRepository = fincasRepository ?? fincasRepo,
       lotesRepository = lotesRepository ?? lotesRepo,
       permisos = permisos ?? permisosFinca;

  final FincaRow finca;
  final String usuarioId;
  final bool sinConexion;
  final AppDatabase database;
  final FincasRepository fincasRepository;
  final LotesRepository lotesRepository;
  final PermisosFinca permisos;

  @override
  State<FincaDetalleScreen> createState() => _FincaDetalleScreenState();
}

class _FincaDetalleScreenState extends State<FincaDetalleScreen> {
  @override
  void initState() {
    super.initState();
    // Los módulos leen `permisos` para esconder sus acciones de escritura.
    widget.permisos.seguir(
      widget.fincasRepository.observarMiRol(widget.finca.id, widget.usuarioId),
    );
  }

  @override
  void dispose() {
    widget.permisos.limpiar();
    super.dispose();
  }

  Future<void> _editarFincaDialog(FincaRow finca) => flujoEditarFinca(
    context,
    finca: finca,
    repositorio: widget.fincasRepository,
  );
  void _abrir(Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  Stream<int> _contarLotes(String fincaId) {
    return widget.lotesRepository
        .observarLotes(fincaId)
        .map((lotes) => lotes.length);
  }

  Stream<int> _contarAnimalesActivos(String fincaId) =>
      observarAnimalesActivos(widget.database, fincaId);

  Widget _kpiHeader(FincaRow finca) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HatoSpacing.lg,
        HatoSpacing.lg,
        HatoSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: StreamBuilder<int>(
              stream: _contarLotes(finca.id),
              builder: (context, snapshot) => _KpiTile(
                key: const ValueKey('fincaDetail.kpiLotes'),
                assetIcono: 'assets/iconos/lotes.png',
                etiqueta: 'Lotes',
                valor: snapshot.data,
              ),
            ),
          ),
          const SizedBox(width: HatoSpacing.md),
          Expanded(
            child: StreamBuilder<int>(
              stream: _contarAnimalesActivos(finca.id),
              builder: (context, snapshot) => _KpiTile(
                key: const ValueKey('fincaDetail.kpiAnimales'),
                assetIcono: 'assets/iconos/animales.png',
                etiqueta: 'Animales activos',
                valor: snapshot.data,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FincaRow?>(
      stream: widget.fincasRepository.observarFinca(widget.finca.id),
      initialData: widget.finca,
      builder: (context, snapshot) {
        final finca = snapshot.data ?? widget.finca;
        final theme = Theme.of(context);
        return ValueListenableBuilder<bool>(
          valueListenable: widget.permisos.soloLectura,
          builder: (context, soloLectura, _) => Scaffold(
            appBar: AppBar(
              title: Text(finca.nombre),
              // Un invitado no comparte ni edita la finca: solo la ve.
              actions: soloLectura
                  ? const []
                  : [
                      IconButton(
                        tooltip: 'Compartir finca',
                        icon: const Icon(Icons.person_add_alt_1),
                        onPressed: widget.sinConexion
                            ? null
                            : () => _abrir(
                                CompartirFincaScreen(
                                  finca: finca,
                                  usuarioId: widget.usuarioId,
                                ),
                              ),
                      ),
                      IconButton(
                        tooltip: 'Editar finca',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editarFincaDialog(finca),
                      ),
                    ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AvisoSoloLectura(permisos: widget.permisos),
                _kpiHeader(finca),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(HatoSpacing.lg),
                    children: [
                      // Recolección de datos es puro registro: un invitado de
                      // solo lectura no entra a la manga.
                      if (!soloLectura) ...[
                        _TrabajoHero(
                          key: const ValueKey('fincaDetail.pesaje'),
                          onTap: () => _abrir(
                            PesajeScreen(
                              finca: finca,
                              usuarioId: widget.usuarioId,
                            ),
                          ),
                        ),
                        const SizedBox(height: HatoSpacing.lg),
                      ],
                      Text(
                        'Módulos',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: HatoSpacing.sm),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: HatoSpacing.md,
                        crossAxisSpacing: HatoSpacing.md,
                        childAspectRatio: 1.15,
                        children: [
                          _BotonOpcion(
                            key: const ValueKey('fincaDetail.sanidad'),
                            assetIcono: 'assets/iconos/sanidad.png',
                            label: 'Sanidad',
                            onTap: () => _abrir(SanidadScreen(finca: finca)),
                          ),
                          _BotonOpcion(
                            key: const ValueKey('fincaDetail.lotes'),
                            assetIcono: 'assets/iconos/lotes.png',
                            label: 'Lotes',
                            onTap: () => _abrir(
                              LotesScreen(
                                finca: finca,
                                usuarioId: widget.usuarioId,
                              ),
                            ),
                          ),
                          _BotonOpcion(
                            key: const ValueKey('fincaDetail.dietas'),
                            assetIcono: 'assets/iconos/dietas.png',
                            label: 'Dietas',
                            onTap: () => _abrir(DietasScreen(finca: finca)),
                          ),
                          _BotonOpcion(
                            key: const ValueKey('fincaDetail.venta'),
                            assetIcono: 'assets/iconos/venta.png',
                            label: 'Venta',
                            onTap: () => _abrir(
                              VentaScreen(
                                finca: finca,
                                usuarioId: widget.usuarioId,
                              ),
                            ),
                          ),
                          _BotonOpcion(
                            key: const ValueKey('fincaDetail.gastosFijos'),
                            icono: Icons.receipt_long_outlined,
                            label: 'Gastos fijos',
                            onTap: () =>
                                _abrir(GastosFijosScreen(finca: finca)),
                          ),
                          _BotonOpcion(
                            key: const ValueKey('fincaDetail.analisis'),
                            icono: Icons.insights_outlined,
                            label: 'Análisis',
                            onTap: () => _abrir(
                              AnalisisScreen(
                                finca: finca,
                                usuarioId: widget.usuarioId,
                              ),
                            ),
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
      },
    );
  }
}

/// CTA principal de la finca: Pantalla de Trabajo (Pesaje).
class _TrabajoHero extends StatelessWidget {
  const _TrabajoHero({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: HatoSpacing.xl,
            vertical: HatoSpacing.xl,
          ),
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
                  width: 44,
                  height: 44,
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trabajo en manga',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    super.key,
    this.icono,
    this.assetIcono,
    required this.etiqueta,
    required this.valor,
  }) : assert(
         icono != null || assetIcono != null,
         'Indicá un icono de Material o un asset',
       );

  /// Icono de Material. Se ignora si [assetIcono] viene definido.
  final IconData? icono;

  /// Ruta de un PNG de trazo transparente en assets/iconos/, teñido al primario.
  final String? assetIcono;
  final String etiqueta;
  final int? valor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(HatoSpacing.md),
        child: Row(
          children: [
            if (assetIcono != null)
              Image.asset(
                assetIcono!,
                width: 26,
                height: 26,
                color: theme.colorScheme.primary,
              )
            else
              Icon(icono, color: theme.colorScheme.primary),
            const SizedBox(width: HatoSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    valor?.toString() ?? '—',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    etiqueta,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
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

class _BotonOpcion extends StatelessWidget {
  const _BotonOpcion({
    super.key,
    this.icono,
    this.assetIcono,
    required this.label,
    required this.onTap,
  }) : assert(
         icono != null || assetIcono != null,
         'Indicá un icono de Material o un asset',
       );

  /// Icono de Material. Se ignora si [assetIcono] viene definido.
  final IconData? icono;

  /// Ruta de un PNG de trazo transparente en assets/iconos/, teñido al primario.
  final String? assetIcono;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (assetIcono != null)
              Image.asset(
                assetIcono!,
                width: 44,
                height: 44,
                color: theme.colorScheme.primary,
              )
            else
              Icon(icono, size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: HatoSpacing.sm),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
