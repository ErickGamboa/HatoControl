import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/local/database.dart';
import '../services.dart';
import 'invitado_screen.dart';
import 'mensajes_auth.dart';

/// Pantalla de inicio de sesión / registro con correo y contraseña.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _esRegistro = false; // false = iniciar sesión, true = crear cuenta
  bool _cargando = false;
  bool _verPass = false;
  bool _falloRedReciente = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);

    final auth = Supabase.instance.client.auth;
    try {
      if (_esRegistro) {
        await auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          data: {'nombre': _nombreCtrl.text.trim()},
        );
        if (!mounted) return;
        // Si el proyecto exige confirmación por correo, no habrá sesión aún.
        final haySesion = auth.currentSession != null;
        final usuario = auth.currentUser;
        if (haySesion && usuario != null) {
          await _guardarSesionOnline(usuario);
        }
        _mostrarMensaje(
          haySesion
              ? '¡Cuenta creada! Bienvenido.'
              : 'Cuenta creada. Revisá tu correo para confirmarla y luego iniciá sesión.',
        );
        if (!haySesion) setState(() => _esRegistro = false);
      } else {
        await auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
        final usuario = auth.currentUser;
        if (usuario != null) {
          await _guardarSesionOnline(usuario);
        }
        // El AuthGate detecta la sesión y cambia de pantalla solo.
      }
      _falloRedReciente = false;
    } on AuthException catch (e) {
      _falloRedReciente = esErrorRedAuth(e);
      if (_falloRedReciente && !_esRegistro) {
        final entroOffline = await sesionLocalRepo.activarOfflineParaEmail(
          _emailCtrl.text,
        );
        if (entroOffline) return;
      }
      if (mounted) _mostrarMensaje(traducirErrorAuth(e), error: true);
    } catch (e) {
      _falloRedReciente = esErrorRedAuth(e);
      if (_falloRedReciente && !_esRegistro) {
        final entroOffline = await sesionLocalRepo.activarOfflineParaEmail(
          _emailCtrl.text,
        );
        if (entroOffline) return;
      }
      if (mounted) _mostrarMensaje(traducirErrorAuth(e), error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarSesionOnline(User usuario) {
    return sesionLocalRepo.guardarUsuarioVerificado(
      usuarioId: usuario.id,
      email: usuario.email,
      nombre: usuario.userMetadata?['nombre'] as String?,
    );
  }

  Future<void> _entrarSinConexion() async {
    await sesionLocalRepo.activarOffline();
  }

  void _mostrarMensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/logo/hatocontrol_logo.png',
                      height: 220,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _esRegistro ? 'Creá tu cuenta' : 'Iniciá sesión',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),

                    // Nombre (solo en registro)
                    if (_esRegistro) ...[
                      TextFormField(
                        controller: _nombreCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresá tu nombre'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Correo
                    TextFormField(
                      key: const ValueKey('login.email'),
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Ingresá tu correo';
                        if (!t.contains('@') || !t.contains('.')) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contraseña
                    TextFormField(
                      key: const ValueKey('login.password'),
                      controller: _passCtrl,
                      obscureText: !_verPass,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _verPass ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _verPass = !_verPass),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresá tu contraseña';
                        }
                        if (_esRegistro && v.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    FilledButton(
                      key: const ValueKey('login.submit'),
                      onPressed: _cargando ? null : _enviar,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_esRegistro ? 'Crear cuenta' : 'Entrar'),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: _cargando
                          ? null
                          : () => setState(() => _esRegistro = !_esRegistro),
                      child: Text(
                        _esRegistro
                            ? '¿Ya tenés cuenta? Iniciá sesión'
                            : '¿No tenés cuenta? Creá una',
                      ),
                    ),

                    if (!_esRegistro)
                      ValueListenableBuilder<SesionLocalRow?>(
                        valueListenable: sesionLocalRepo.sesion,
                        builder: (context, sesionLocal, _) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: estadoConexion.hayConexion,
                            builder: (context, hayConexion, _) {
                              return OfflineLoginAction(
                                sesionLocal: sesionLocal,
                                hayConexion: hayConexion,
                                falloRedReciente: _falloRedReciente,
                                cargando: _cargando,
                                onEntrarSinConexion: _entrarSinConexion,
                              );
                            },
                          );
                        },
                      ),

                    // Acceso para personas a las que les compartieron una finca.
                    if (!_esRegistro) ...[
                      const Divider(height: 24),
                      OutlinedButton.icon(
                        onPressed: _cargando
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const InvitadoScreen(),
                                ),
                              ),
                        icon: const Icon(Icons.mark_email_read_outlined),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        label: const Text('Me invitaron a una finca'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OfflineLoginAction extends StatelessWidget {
  const OfflineLoginAction({
    super.key,
    required this.sesionLocal,
    required this.hayConexion,
    required this.falloRedReciente,
    required this.cargando,
    required this.onEntrarSinConexion,
  });

  final SesionLocalRow? sesionLocal;
  final bool hayConexion;
  final bool falloRedReciente;
  final bool cargando;
  final VoidCallback onEntrarSinConexion;

  @override
  Widget build(BuildContext context) {
    final sesion = sesionLocal;
    if (sesion == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final usuario = sesion.email ?? sesion.nombre;
    final necesitaAyudaOffline = !hayConexion || falloRedReciente;
    final textoAyuda = necesitaAyudaOffline
        ? 'Usarás los datos guardados en este dispositivo. '
              'La sincronización se retomará cuando vuelva internet.'
        : 'Disponible para trabajar con datos guardados si no tenés internet.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const ValueKey('login.offline'),
          onPressed: cargando ? null : onEntrarSinConexion,
          icon: const Icon(Icons.cloud_off_outlined),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          label: Text(
            usuario == null
                ? 'Entrar sin conexión'
                : 'Entrar sin conexión como $usuario',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          textoAyuda,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
