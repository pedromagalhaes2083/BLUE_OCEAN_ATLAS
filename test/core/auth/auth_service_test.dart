import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/auth/auth_service.dart';

void main() {
  group('AuthService.deveLimparAoTrocarUsuario', () {
    test('primeiro login do aparelho (nada salvo ainda) não limpa', () {
      expect(AuthService.deveLimparAoTrocarUsuario('', 'usuario-1'), isFalse);
    });

    test('mesmo usuário logando de novo não limpa', () {
      expect(AuthService.deveLimparAoTrocarUsuario('usuario-1', 'usuario-1'),
          isFalse);
    });

    test('usuário diferente do último login limpa', () {
      expect(AuthService.deveLimparAoTrocarUsuario('usuario-1', 'usuario-2'),
          isTrue);
    });

    test('resposta de login sem id extraível nunca limpa', () {
      expect(AuthService.deveLimparAoTrocarUsuario('usuario-1', ''), isFalse);
    });
  });
}
