import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/local/database.dart';
import '../data/repositories/fincas_repository.dart';
import '../data/repositories/lotes_repository.dart';
import '../data/repositories/ventas_repository.dart' show EstadoAnimal;
import '../dietas/dietas_screen.dart';
import '../lotes/lotes_screen.dart';
import '../pesaje/pesaje_screen.dart';
import '../sanidad/sanidad_screen.dart';
import '../services.dart';
import '../venta/venta_screen.dart';
import 'compartir_finca_screen.dart';
import 'foto_picker.dart';

/// Home de la finca según el documento oro: Trabajo (Pesaje) como acción
/// principal, y módulos Sanidad · Lotes · Dietas · Venta.
class FincaDetalleScreen extends StatefulWidget {
  FincaDetalleScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
    required this.sinConexion,
    AppDatabase? database,
    FincasRepository? fincasRepository,
    LotesRepository? lotesRepository,
  }) : database = database ?? db,
       fincasRepository = fincasRepository ?? fincasRepo,
       lotesRepository = lotesRepository ?? lotesRepo;

  final FincaRow finca;
  final String usuarioId;
  final bool sinConexion;
  final AppDatabase database;
  final FincasRepository fincasRepository;
  final LotesRepository lotesRepository;

  @override
  State<FincaDetalleScreen> createState() => _FincaDetalleScreenState();
}

class _FincaDetalleScreenState extends State<FincaDetalleScreen> {
  Future<void> _editarFincaDialog(FincaRow finca) async {
    final resultado = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => _DialogoEditarFinca(finca: finca),
    );
    if (resultado == null) return;
    final (nombre, nuevaFotoPath) = resultado;
    if (nombre.isEmpty) return;

    await widget.fincasRepository.editarFinca(
      fincaId: finca.id,
      nombre: nombre,
      nuevaFotoLocalPath: nuevaFotoPath,
    );
    sincronizarSiSePuede();
  }

  void _abrir(Widget pantalla) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
  }

  Stream<int> _contarLotes(String fincaId) {
    return widget.lotesRepository
        .observarLotes(fincaId)
        .map((lotes) => lotes.length);
  }

  Stream<int> _contarAnimalesActivos(String fincaId) {
    final database = widget.database;
    final conteo = database.animales.id.count();
    final consulta = database.selectOnly(database.animales)
      ..addColumns([conteo])
      ..where(
        database.animales.fincaId.equals(fincaId) &
            database.animales.deletedAt.isNull() &
            database.animales.estado.equals(EstadoAnimal.activo),
      );
    return consulta.watchSingle().map((fila) => fila.read(conteo) ?? 0);
  }

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
        return Scaffold(
          appBar: AppBar(
            title: Text(finca.nombre),
            actions: [
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
              _kpiHeader(finca),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(HatoSpacing.lg),
                  children: [
                    _TrabajoHero(
                      key: const ValueKey('fincaDetail.pesaje'),
                      onTap: () => _abrir(
                        PesajeScreen(finca: finca, usuarioId: widget.usuarioId),
                      ),
                    ),
                    const SizedBox(height: HatoSpacing.lg),
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
                      ],
                    ),
                  ],
                ),
              ),
            ],
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

class _DialogoEditarFinca extends StatefulWidget {
  const _DialogoEditarFinca({required this.finca});

  final FincaRow finca;

  @override
  State<_DialogoEditarFinca> createState() => _DialogoEditarFincaState();
}

class _DialogoEditarFincaState extends State<_DialogoEditarFinca> {
  late final TextEditingController _ctrl = TextEditingController(
    text: widget.finca.nombre,
  );
  String? _nuevaFoto;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _cambiarFoto() async {
    final path = await elegirFotoFinca(context);
    if (path != null && mounted) setState(() => _nuevaFoto = path);
  }

  Widget _fotoActual() {
    if (_nuevaFoto != null) {
      return Image.file(File(_nuevaFoto!), fit: BoxFit.cover);
    }
    final local = widget.finca.fotoLocalPath;
    if (local != null && File(local).existsSync()) {
      return Image.file(File(local), fit: BoxFit.cover);
    }
    final url = widget.finca.fotoUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.cover);
    }
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 36,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'Agregar foto',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Editar finca'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _cambiarFoto,
            child: Container(
              height: 140,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: _fotoActual(),
            ),
          ),
          TextButton.icon(
            onPressed: _cambiarFoto,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Cambiar foto'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre de la finca',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, (_ctrl.text.trim(), _nuevaFoto)),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
