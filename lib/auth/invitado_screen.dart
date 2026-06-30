import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mensajes_auth.dart';

/// Flujo para que una persona invitada (a la que un administrador le compartió
/// una finca) cree su contraseña por primera vez, usando un código de 6 dígitos
/// que le llega por correo. No necesita link ni navegador: todo pasa acá.
///
/// Paso 1: escribe su correo y pide el código.
/// Paso 2: escribe el código + su nueva contraseña y entra.
class InvitadoScreen extends StatefulWidget {
  const InvitadoScreen({super.key});

  @override
  State<InvitadoScreen> createState() => _InvitadoScreenState();
}

class _InvitadoScreenState extends State<InvitadoScreen> {
  final _emailCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  int _paso = 0; // 0 = pedir código, 1 = código + contraseña
  bool _cargando = false;
  bool _verPass = false;

  SupabaseClient get _sb => Supabase.instance.client;
  String get _email => _emailCtrl.text.trim().toLowerCase();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codigoCtrl.dispose();
    _nombreCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _msg(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }

  bool _emailValido(String e) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);

  /// Paso 1: enviar el código de 6 dígitos al correo del invitado.
  Future<void> _enviarCodigo() async {
    if (!_emailValido(_email)) {
      _msg('Escribí un correo válido.', error: true);
      return;
    }
    setState(() => _cargando = true);
    try {
      // shouldCreateUser: false => solo le llega a quien YA fue invitado.
      await _sb.auth.signInWithOtp(email: _email, shouldCreateUser: false);
      _msg('Te enviamos un código a $_email. Revisá tu correo.');
      setState(() => _paso = 1);
    } on AuthException catch (e) {
      // Si el correo no fue invitado, Supabase no permite crear el usuario.
      final m = e.message.toLowerCase();
      if (e.code == 'otp_disabled' ||
          m.contains('signups not allowed') ||
          m.contains('not allowed') ||
          m.contains('user not found')) {
        _msg(
          'No encontramos una invitación para ese correo. Pedile al '
          'administrador que te comparta una finca primero.',
          error: true,
        );
      } else {
        _msg(traducirErrorAuth(e), error: true);
      }
    } catch (e) {
      _msg(traducirErrorAuth(e), error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Paso 2: verificar el código y guardar la contraseña nueva.
  Future<void> _confirmar() async {
    final codigo = _codigoCtrl.text.trim();
    final pass = _passCtrl.text;
    if (codigo.length < 6) {
      _msg('Escribí el código de 6 dígitos que te llegó.', error: true);
      return;
    }
    if (pass.length < 6) {
      _msg('La contraseña debe tener al menos 6 caracteres.', error: true);
      return;
    }
    setState(() => _cargando = true);
    try {
      await _sb.auth.verifyOTP(
        email: _email,
        token: codigo,
        type: OtpType.email,
      );
      // Ya hay sesión: guardar la contraseña elegida.
      await _sb.auth.updateUser(UserAttributes(password: pass));
      // Guardar el nombre (opcional, no crítico).
      final nombre = _nombreCtrl.text.trim();
      if (nombre.isNotEmpty) {
        final uid = _sb.auth.currentUser?.id;
        if (uid != null) {
          try {
            await _sb.from('usuarios').update({'nombre': nombre}).eq('id', uid);
          } catch (_) {
            /* no crítico */
          }
        }
      }
      if (!mounted) return;
      _msg('¡Listo! Ya podés usar HatoControl.');
      // La sesión ya está activa: volver a la raíz para que el AuthGate
      // muestre la app.
      Navigator.of(context).popUntil((r) => r.isFirst);
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();
      if (e.code == 'otp_expired' ||
          m.contains('expired') ||
          m.contains('invalid') ||
          m.contains('token')) {
        _msg(
          'El código no es correcto o ya venció. Pedí uno nuevo.',
          error: true,
        );
      } else {
        _msg(traducirErrorAuth(e), error: true);
      }
    } catch (e) {
      _msg(traducirErrorAuth(e), error: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Soy invitado')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _paso == 0 ? _pasoEmail(theme) : _pasoCodigo(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pasoEmail(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Te invitaron a una finca',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escribí el mismo correo con el que te invitaron. Te enviaremos un '
          'código de 6 dígitos para crear tu contraseña.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Correo',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _cargando ? null : _enviarCodigo,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _cargando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar código'),
        ),
      ],
    );
  }

  Widget _pasoCodigo(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.password_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Revisá tu correo',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escribí el código de 6 dígitos que enviamos a $_email y creá tu '
          'contraseña.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _codigoCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 24, letterSpacing: 4),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            labelText: 'Código',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nombreCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Tu nombre (opcional)',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passCtrl,
          obscureText: !_verPass,
          decoration: InputDecoration(
            labelText: 'Creá tu contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_verPass ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _verPass = !_verPass),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _cargando ? null : _confirmar,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _cargando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Entrar'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _cargando ? null : _enviarCodigo,
          child: const Text('No me llegó. Reenviar código'),
        ),
      ],
    );
  }
}
