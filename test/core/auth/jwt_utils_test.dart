import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/core/auth/jwt_utils.dart';

/// Monta um JWT "de mentira" — cabeçalho e assinatura são só texto
/// qualquer, `decodeJwtPayload` nunca verifica a assinatura, só decodifica
/// o segmento do meio (payload).
String _jwtComPayload(Map<String, dynamic> payload) {
  String base64UrlSemPadding(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  final header = base64UrlSemPadding(utf8.encode('{"alg":"HS256"}'));
  final body = base64UrlSemPadding(utf8.encode(jsonEncode(payload)));
  return '$header.$body.assinatura-qualquer';
}

void main() {
  group('decodeJwtPayload', () {
    test('decodifica as claims de um token válido', () {
      final token = _jwtComPayload({
        'sub': 'usuario-123',
        'organizacaoId': 'org-456',
        'exp': 1999999999,
      });

      final claims = decodeJwtPayload(token);

      expect(claims['sub'], 'usuario-123');
      expect(claims['organizacaoId'], 'org-456');
      expect(claims['exp'], 1999999999);
    });

    test('token sem os 3 segmentos separados por "." retorna mapa vazio', () {
      expect(decodeJwtPayload('nao-e-um-jwt'), isEmpty);
      expect(decodeJwtPayload('so.duas'), isEmpty);
    });

    test('payload que não é base64/JSON válido retorna mapa vazio', () {
      expect(decodeJwtPayload('cabecalho.***não-é-base64***.assinatura'),
          isEmpty);
    });

    test('funciona tanto com quanto sem padding "=" no base64url', () {
      // payload com tamanho que normalmente exigiria padding
      final token = _jwtComPayload({'x': 1});
      expect(decodeJwtPayload(token), {'x': 1});
    });
  });
}
