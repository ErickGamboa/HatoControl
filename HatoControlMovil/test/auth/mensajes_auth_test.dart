import 'package:flutter_test/flutter_test.dart';
import 'package:hato_control/auth/mensajes_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('evaluator: AuthException de red habilita mensaje de modo offline', () {
    final error = AuthException('SocketException: Failed host lookup');

    expect(esErrorRedAuth(error), isTrue);
    expect(traducirErrorAuth(error), contains('Podés entrar sin conexión'));
  });

  test('credenciales inválidas siguen siendo error de usuario', () {
    final error = AuthException(
      'Invalid login credentials',
      statusCode: '400',
      code: 'invalid_credentials',
    );

    expect(esErrorRedAuth(error), isFalse);
    expect(traducirErrorAuth(error), 'Correo o contraseña incorrectos.');
  });
}
