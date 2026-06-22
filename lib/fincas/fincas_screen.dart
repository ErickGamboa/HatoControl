import 'dart:io';

import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/fincas_repository.dart';
import '../services.dart';
import 'finca_detalle_screen.dart';
import 'foto_picker.dart';

/// Lista de fincas del usuario, con opción de crear (con foto) y sincronizar.
class FincasScreen extends StatefulWidget {
  const FincasScreen({super.key});

  @override
  State<FincasScreen> createState() => _FincasScreenState();
}

class _FincasScreenState extends State<FincasScreen> {
  EstadoLicencia? _estado;

  @override
  void initState() {
    super.initState();
    syncService.sincronizar();
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

  String get _usuarioId => supabase.auth.currentUser!.id;

  Future<void> _cargarEstado() async {
    final estado = await fincasRepo.estadoLicencia(_usuarioId);
    if (mounted) setState(() => _estado = estado);
  }

  void _mostrar(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _crearFincaDialog() async {
    // Aviso temprano si ya alcanzó el límite (mejor experiencia).
    if (_estado != null && _estado!.alcanzoLimite) {
      _mostrar(
        'Tu plan ${_estado!.planNombre} permite ${_estado!.limite} '
        'finca(s). Cambiá a un plan superior para agregar más.',
      );
      return;
    }

    final resultado = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => const _DialogoNuevaFinca(),
    );
    if (resultado == null) return;
    final (nombre, fotoLocalPath) = resultado;
    if (nombre.isEmpty) return;

    try {
      await fincasRepo.crearFinca(
        nombre: nombre,
        creadaPor: _usuarioId,
        fotoLocalPath: fotoLocalPath,
      );
      syncService.sincronizar();
      await _cargarEstado();
    } on LimiteFincasException catch (e) {
      _mostrar(
        'Tu plan ${e.planNombre} permite ${e.limite} finca(s). '
        'Cambiá a un plan superior para agregar más.',
      );
    } on LicenciaNoDisponibleException {
      _mostrar('Conectate a internet una vez para activar tu cuenta.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis fincas'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: syncService.sincronizando,
            builder: (context, sincronizando, _) {
              if (sincronizando) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return IconButton(
                tooltip: 'Sincronizar',
                icon: const Icon(Icons.sync),
                onPressed: () => syncService.sincronizar(),
              );
            },
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearFincaDialog,
        icon: const Icon(Icons.add),
        label: const Text('Finca'),
      ),
      body: Column(
        children: [
          if (_estado != null) _BannerLicencia(estado: _estado!),
          Expanded(
            child: StreamBuilder<List<FincaRow>>(
              stream: fincasRepo.observarFincas(_usuarioId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final fincas = snapshot.data ?? const [];
                if (fincas.isEmpty) {
                  return _VacioFincas(onCrear: _crearFincaDialog);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                  itemCount: fincas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _TarjetaFinca(
                    finca: fincas[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FincaDetalleScreen(finca: fincas[i]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta horizontal grande: la foto cubre toda la tarjeta y el nombre va
/// encima, con un degradado oscuro abajo para que siempre se lea bien.
class _TarjetaFinca extends StatelessWidget {
  const _TarjetaFinca({required this.finca, required this.onTap});

  final FincaRow finca;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pendiente = finca.pendiente || finca.fotoPendiente;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 130,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Foto de fondo (cubre toda la tarjeta)
              _FotoFinca(finca: finca),
              // Degradado para legibilidad del texto
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
              ),
              // Nombre de la finca, abajo a la izquierda
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Text(
                  finca.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black87)],
                  ),
                ),
              ),
              // Aviso de pendiente de sincronizar, arriba a la derecha
              if (pendiente)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined,
                        size: 18, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Muestra la foto de la finca: archivo local si existe, si no la URL del
/// servidor, y si no hay ninguna, un marcador de posición.
class _FotoFinca extends StatelessWidget {
  const _FotoFinca({required this.finca});

  final FincaRow finca;

  @override
  Widget build(BuildContext context) {
    final local = finca.fotoLocalPath;
    if (local != null && File(local).existsSync()) {
      return Image.file(File(local), fit: BoxFit.cover);
    }
    final url = finca.fotoUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const _PlaceholderFoto(cargando: true),
        errorBuilder: (_, _, _) => const _PlaceholderFoto(),
      );
    }
    return const _PlaceholderFoto();
  }
}

class _PlaceholderFoto extends StatelessWidget {
  const _PlaceholderFoto({this.cargando = false});

  final bool cargando;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: cargando
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.landscape_outlined,
                size: 40, color: theme.colorScheme.outline),
      ),
    );
  }
}

/// Diálogo para crear una finca: nombre + foto opcional.
class _DialogoNuevaFinca extends StatefulWidget {
  const _DialogoNuevaFinca();

  @override
  State<_DialogoNuevaFinca> createState() => _DialogoNuevaFincaState();
}

class _DialogoNuevaFincaState extends State<_DialogoNuevaFinca> {
  final _ctrl = TextEditingController();
  String? _fotoPath;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final path = await elegirFotoFinca(context);
    if (path != null && mounted) setState(() => _fotoPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Nueva finca'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Foto opcional (toca para elegir)
          GestureDetector(
            onTap: _elegirFoto,
            child: Container(
              height: 140,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: _fotoPath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined,
                            size: 36, color: theme.colorScheme.outline),
                        const SizedBox(height: 8),
                        Text('Agregar foto (opcional)',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    )
                  : Image.file(File(_fotoPath!), fit: BoxFit.cover),
            ),
          ),
          if (_fotoPath != null)
            TextButton.icon(
              onPressed: () => setState(() => _fotoPath = null),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Quitar foto'),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
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
              Navigator.pop(context, (_ctrl.text.trim(), _fotoPath)),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}

/// Banner simple que muestra el plan y cuántas fincas se usan de las permitidas.
class _BannerLicencia extends StatelessWidget {
  const _BannerLicencia({required this.estado});

  final EstadoLicencia estado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lleno = estado.alcanzoLimite;
    final color = lleno
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = lleno
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.workspace_premium, size: 20, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Plan ${estado.planNombre} · ${estado.usadas} de ${estado.limite} fincas',
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _VacioFincas extends StatelessWidget {
  const _VacioFincas({required this.onCrear});

  final VoidCallback onCrear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.holiday_village_outlined,
                size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Todavía no tenés fincas',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Creá tu primera finca con el botón de abajo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
