import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/local/database.dart';
import '../data/repositories/fincas_repository.dart';
import '../data/repositories/lotes_repository.dart';
import '../data/repositories/ventas_repository.dart' show EstadoAnimal;
import '../corral/corral_screen.dart';
import '../dietas/dietas_screen.dart';
import '../lotes/lotes_screen.dart';
import '../pesaje/pesaje_screen.dart';
import '../services.dart';
import 'compartir_finca_screen.dart';
import 'foto_picker.dart';

/// Detalle de una finca: KPIs rápidos + menú de opciones (botonera) + editar
/// la finca.
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
    final db = widget.database;
    final conteo = db.animales.id.count();
    final consulta = db.selectOnly(db.animales)
      ..addColumns([conteo])
      ..where(
        db.animales.fincaId.equals(fincaId) &
            db.animales.deletedAt.isNull() &
            db.animales.estado.equals(EstadoAnimal.activo),
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
                icono: Icons.grid_view_outlined,
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
                icono: Icons.pets_outlined,
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
            children: [
              _kpiHeader(finca),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.all(HatoSpacing.lg),
                  crossAxisCount: 2,
                  mainAxisSpacing: HatoSpacing.lg,
                  crossAxisSpacing: HatoSpacing.lg,
                  childAspectRatio: 1,
                  children: [
                    _BotonOpcion(
                      key: const ValueKey('fincaDetail.corral'),
                      icono: Icon(
                        Icons.agriculture_outlined,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                      label: 'Corral',
                      onTap: () => _abrir(
                        CorralScreen(finca: finca, usuarioId: widget.usuarioId),
                      ),
                    ),
                    _BotonOpcion(
                      key: const ValueKey('fincaDetail.pesaje'),
                      icono: Image.asset(
                        'assets/iconos/pesaje.png',
                        width: 60,
                        height: 60,
                        color: theme.colorScheme.primary,
                      ),
                      label: 'Pesaje',
                      onTap: () => _abrir(
                        PesajeScreen(finca: finca, usuarioId: widget.usuarioId),
                      ),
                    ),
                    _BotonOpcion(
                      key: const ValueKey('fincaDetail.lotes'),
                      icono: Image.asset(
                        'assets/iconos/lotes.png',
                        width: 60,
                        height: 60,
                        color: theme.colorScheme.primary,
                      ),
                      label: 'Lotes',
                      onTap: () => _abrir(
                        LotesScreen(finca: finca, usuarioId: widget.usuarioId),
                      ),
                    ),
                    _BotonOpcion(
                      key: const ValueKey('fincaDetail.dietas'),
                      icono: Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                      label: 'Dietas',
                      onTap: () => _abrir(DietasScreen(finca: finca)),
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

/// Tarjeta compacta con un número (KPI) y su etiqueta, para el encabezado de
/// la finca. [valor] null mientras el stream todavía no entrega el primer
/// dato.
class _KpiTile extends StatelessWidget {
  const _KpiTile({
    super.key,
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
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

/// Botón cuadrado con un ícono (widget) y etiqueta para el menú de la finca.
class _BotonOpcion extends StatelessWidget {
  const _BotonOpcion({
    super.key,
    required this.icono,
    required this.label,
    required this.onTap,
  });

  final Widget icono;
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
            SizedBox(height: 64, child: Center(child: icono)),
            const SizedBox(height: 12),
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

/// Diálogo para editar una finca: nombre + (opcional) reemplazar la foto.
/// Devuelve (nombre, nuevaFotoLocalPath?). nuevaFotoLocalPath null = no cambió.
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
