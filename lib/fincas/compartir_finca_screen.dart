import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/database.dart';
import '../data/repositories/fincas_repository.dart';
import '../services.dart';

/// Pantalla para administrar el acceso a una finca: invitar personas por correo
/// (como administrador) y ver/quitar a quienes ya tienen acceso.
class CompartirFincaScreen extends StatefulWidget {
  const CompartirFincaScreen({
    super.key,
    required this.finca,
    required this.usuarioId,
  });

  final FincaRow finca;
  final String usuarioId;

  @override
  State<CompartirFincaScreen> createState() => _CompartirFincaScreenState();
}

class _CompartirFincaScreenState extends State<CompartirFincaScreen> {
  String get _miUsuarioId => widget.usuarioId;

  void _mostrar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Pide un correo y comparte la finca con esa persona como administrador.
  Future<void> _invitar() async {
    if (!estadoConexion.hayConexion.value ||
        supabase.auth.currentSession == null) {
      _mostrar('Conectate a internet para compartir una finca.');
      return;
    }
    final email = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoCompartir(),
    );
    if (email == null || email.isEmpty || !mounted) return;

    _mostrar('Compartiendo…');
    try {
      final res = await supabase.functions.invoke(
        'compartir-finca',
        body: {'finca_id': widget.finca.id, 'email': email, 'rol': 'admin'},
      );
      final data = res.data;
      final status = data is Map ? data['status'] as String? : null;
      switch (status) {
        case 'agregado':
          sincronizarSiSePuede();
          _mostrar(
            'Listo. Compartiste la finca con $email '
            'como administrador.',
          );
        case 'ya_es_miembro':
          _mostrar('Esa persona ya tiene acceso a esta finca.');
        case 'invitado_nuevo':
          sincronizarSiSePuede();
          _mostrar(
            'Listo. Invitamos a $email. Pedile que abra HatoControl, '
            'toque "Me invitaron a una finca", escriba su correo y siga '
            'los pasos con el código que le llegará.',
          );
        default:
          _mostrar('No se pudo compartir. Intentá de nuevo.');
      }
    } on FunctionException catch (e) {
      final det = e.details;
      final err = det is Map ? det['error'] as String? : null;
      _mostrar(switch (err) {
        'sin_permiso' => 'Solo un administrador de la finca puede compartirla.',
        'no_autenticado' => 'Tu sesión expiró. Iniciá sesión de nuevo.',
        'datos_incompletos' => 'Falta el correo.',
        _ => 'No se pudo compartir. Revisá tu conexión e intentá de nuevo.',
      });
    } catch (_) {
      _mostrar('No se pudo compartir. Revisá tu conexión e intentá de nuevo.');
    }
  }

  /// Quita el acceso de una persona, pidiendo confirmación primero.
  Future<void> _quitarAcceso(MiembroConUsuario m) async {
    final quien = m.nombre ?? m.email ?? 'esta persona';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitar acceso'),
        content: Text(
          '¿Seguro que querés quitarle el acceso a $quien? '
          'Dejará de ver esta finca.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quitar acceso'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await fincasRepo.quitarAcceso(m.miembro.id);
    sincronizarSiSePuede();
    _mostrar('Listo. Le quitaste el acceso a $quien.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Compartir finca')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _invitar,
                icon: const Icon(Icons.person_add_alt_1),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                label: const Text('Invitar a alguien'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personas con acceso',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<MiembroConUsuario>>(
              stream: fincasRepo.observarMiembros(widget.finca.id),
              builder: (context, snapshot) {
                final miembros = snapshot.data ?? const <MiembroConUsuario>[];
                if (miembros.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.separated(
                  itemCount: miembros.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _filaMiembro(theme, miembros[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaMiembro(ThemeData theme, MiembroConUsuario m) {
    final esYo = m.miembro.usuarioId == _miUsuarioId;
    final esDueno = m.miembro.usuarioId == widget.finca.creadaPor;
    final esAdmin = m.miembro.rol == 'admin';

    final titulo = m.nombre ?? m.email ?? 'Usuario (pendiente de sincronizar)';
    final partes = <String>[
      if (m.nombre != null && m.email != null) m.email!,
      if (esDueno) 'Dueño' else if (esAdmin) 'Administrador' else 'Operario',
      if (esYo) 'vos',
    ];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          esAdmin ? Icons.shield_outlined : Icons.person_outline,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(titulo),
      subtitle: Text(partes.join(' · ')),
      // No se puede quitar al dueño ni a uno mismo.
      trailing: (esYo || esDueno)
          ? null
          : IconButton(
              tooltip: 'Quitar acceso',
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () => _quitarAcceso(m),
            ),
    );
  }
}

/// Diálogo que pide el correo de la persona con quien compartir la finca.
/// Devuelve el correo (en minúsculas) o null si se cancela. Por ahora el rol
/// es siempre administrador (mismos poderes que el dueño en la finca).
class _DialogoCompartir extends StatefulWidget {
  const _DialogoCompartir();

  @override
  State<_DialogoCompartir> createState() => _DialogoCompartirState();
}

class _DialogoCompartirState extends State<_DialogoCompartir> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _compartir() {
    final email = _ctrl.text.trim().toLowerCase();
    final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valido) {
      setState(() => _error = 'Escribí un correo válido.');
      return;
    }
    Navigator.pop(context, email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Invitar a una finca'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Escribí el correo de la persona con quien querés compartir esta '
            'finca. Tendrá los mismos permisos que vos dentro de la finca.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            onSubmitted: (_) => _compartir(),
            decoration: InputDecoration(
              labelText: 'Correo',
              hintText: 'persona@correo.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Se compartirá como Administrador',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _compartir,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Invitar'),
        ),
      ],
    );
  }
}
