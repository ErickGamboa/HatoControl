import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        // El AuthGate detecta la sesión y cambia de pantalla solo.
      }
    } on AuthException catch (e) {
      if (mounted) _mostrarMensaje(traducirErrorAuth(e), error: true);
    } catch (e) {
      if (mounted) _mostrarMensaje(traducirErrorAuth(e), error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
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
                    Icon(Icons.agriculture,
                        size: 72, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'HatoControl',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
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
                      controller: _passCtrl,
                      obscureText: !_verPass,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_verPass
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _verPass = !_verPass),
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
                      onPressed: _cargando ? null : _enviar,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_esRegistro ? 'Crear cuenta' : 'Entrar'),
                    ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: _cargando
                          ? null
                          : () => setState(() => _esRegistro = !_esRegistro),
                      child: Text(_esRegistro
                          ? '¿Ya tenés cuenta? Iniciá sesión'
                          : '¿No tenés cuenta? Creá una'),
                    ),

                    // Acceso para personas a las que les compartieron una finca.
                    if (!_esRegistro) ...[
                      const Divider(height: 24),
                      OutlinedButton.icon(
                        onPressed: _cargando
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const InvitadoScreen()),
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
