import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/fincas_repository.dart';
import '../data/sync/sync_service.dart';
import '../services.dart';
import 'crear_finca_flujo.dart';
import 'finca_detalle_screen.dart';
import 'foto_picker.dart';
import 'sync_status_sheet.dart';

/// Lista de fincas del usuario, con opción de crear (con foto) y sincronizar.
class FincasScreen extends StatefulWidget {
  const FincasScreen({
    super.key,
    required this.usuarioId,
    required this.sinConexion,
  });

  final String usuarioId;
  final bool sinConexion;

  @override
  State<FincasScreen> createState() => _FincasScreenState();
}

class _FincasScreenState extends State<FincasScreen> {
  EstadoLicencia? _estado;
  Map<String, int> _pendientesPorTabla = const {};
  List<SyncEstadoRow> _estadoSync = const [];

  @override
  void initState() {
    super.initState();
    sincronizarSiSePuede();
    _cargarEstado();
    _cargarEstadoSync();
    syncService.sincronizando.addListener(_alCambiarSync);
  }

  @override
  void dispose() {
    syncService.sincronizando.removeListener(_alCambiarSync);
    super.dispose();
  }

  void _alCambiarSync() {
    if (!syncService.sincronizando.value) {
      _cargarEstado();
      _cargarEstadoSync();
    }
  }

  String get _usuarioId => widget.usuarioId;

  Future<void> _cargarEstado() async {
    final estado = await fincasRepo.estadoLicencia(_usuarioId);
    if (mounted) setState(() => _estado = estado);
  }

  Future<void> _cargarEstadoSync() async {
    final pendientes = await syncService.pendientesPorTabla();
    final estados = await syncService.estadoPorTabla();
    if (mounted) {
      setState(() {
        _pendientesPorTabla = pendientes;
        _estadoSync = estados;
      });
    }
  }

  bool get _hayAlgoQueMostrarEnSync =>
      _pendientesPorTabla.values.any((n) => n > 0) ||
      _estadoSync.any((e) => e.ultimoError != null);

  void _mostrar(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _crearFincaDialog() async {
    final aviso = await flujoCrearFinca(
      context,
      usuarioId: _usuarioId,
      estado: _estado,
    );
    if (aviso != null) {
      _mostrar(aviso);
      return;
    }
    await _cargarEstado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis fincas'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: estadoConexion.hayConexion,
            builder: (context, hayConexion, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: syncService.sincronizando,
                builder: (context, sincronizando, _) {
                  if (sincronizando) {
                    // Mostramos cuánto va subido: una ruedita sin números
                    // parece trabada y hace que uno apriete el botón de más.
                    return ValueListenableBuilder<SyncProgreso>(
                      valueListenable: syncService.progreso,
                      builder: (context, avance, _) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            if (avance.activo) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${avance.hechas}/${avance.total}',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }
                  final puedeSincronizar =
                      hayConexion && supabase.auth.currentSession != null;
                  return IconButton(
                    tooltip: puedeSincronizar
                        ? 'Sincronizar'
                        : 'Sin conexión para sincronizar',
                    icon: const Icon(Icons.sync),
                    onPressed: puedeSincronizar
                        ? () => sincronizarSiSePuede()
                        : null,
                  );
                },
              );
            },
          ),
          if (_hayAlgoQueMostrarEnSync)
            IconButton(
              key: const ValueKey('fincas.syncStatus'),
              tooltip: 'Estado de sincronización',
              icon: const Icon(Icons.info_outline),
              onPressed: () => mostrarSyncStatusSheet(
                context,
                pendientes: _pendientesPorTabla,
                estados: _estadoSync,
              ),
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: cerrarSesion,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('fincas.create'),
        onPressed: _crearFincaDialog,
        icon: const Icon(Icons.add),
        label: const Text('Finca'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: estadoConexion.hayConexion,
            builder: (context, hayConexion, _) {
              if (hayConexion && !widget.sinConexion) {
                return const SizedBox.shrink();
              }
              return _BannerSinConexion(
                requiereSesionOnline: hayConexion && widget.sinConexion,
              );
            },
          ),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: fincas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _TarjetaFinca(
                    finca: fincas[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FincaDetalleScreen(
                          finca: fincas[i],
                          usuarioId: _usuarioId,
                          sinConexion: widget.sinConexion,
                        ),
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
        child: AspectRatio(
          // Proporción de foto (16:9): se aprecia bien la finca y se adapta
          // al ancho de la pantalla.
          aspectRatio: 16 / 9,
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
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
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
    if (local != null && existeFotoLocal(local)) {
      return imagenFotoLocal(local);
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
            : Icon(
                Icons.landscape_outlined,
                size: 40,
                color: theme.colorScheme.outline,
              ),
      ),
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
    // Color neutro siempre, también al alcanzar el límite (sin rojo).
    final color = theme.colorScheme.surfaceContainerHighest;
    final textColor = theme.colorScheme.onSurfaceVariant;

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
              'Plan ${estado.planNombre} · ${estado.usadas} de '
              '${estado.limiteTexto} fincas',
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerSinConexion extends StatelessWidget {
  const _BannerSinConexion({required this.requiereSesionOnline});

  final bool requiereSesionOnline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            requiereSesionOnline
                ? Icons.lock_clock_outlined
                : Icons.cloud_off_outlined,
            size: 20,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              requiereSesionOnline
                  ? 'Entraste sin conexión. Iniciá sesión online para sincronizar los cambios pendientes.'
                  : 'Sin conexión. Podés trabajar con datos guardados; los cambios quedarán pendientes.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
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
            Icon(
              Icons.holiday_village_outlined,
              size: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('Todavía no tenés fincas', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Creá tu primera finca con el botón de abajo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
