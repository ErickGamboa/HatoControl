import 'package:flutter/material.dart';

import '../data/local/database.dart';
import '../data/repositories/fincas_repository.dart';
import '../services.dart';
import 'finca_detalle_screen.dart';

/// Lista de fincas del usuario, con opción de crear y sincronizar.
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
    // Al entrar, intentar sincronizar (traer fincas de otros dispositivos).
    syncService.sincronizar();
    _cargarEstado();
    // Recargar el estado de licencia cuando termine una sincronización.
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

    final ctrl = TextEditingController();
    final nombre = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva finca'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nombre de la finca',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (nombre == null || nombre.isEmpty) return;
    try {
      await fincasRepo.crearFinca(nombre: nombre, creadaPor: _usuarioId);
      syncService.sincronizar(); // intentar subirla de inmediato
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
          // Indicador / botón de sincronización
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
                  padding: const EdgeInsets.all(12),
                  itemCount: fincas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final f = fincas[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            f.nombre.isNotEmpty
                                ? f.nombre[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(f.nombre),
                        subtitle: f.pendiente
                            ? const Text('Pendiente de sincronizar')
                            : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FincaDetalleScreen(finca: f),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
