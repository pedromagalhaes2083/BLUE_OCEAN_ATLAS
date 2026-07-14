import 'dart:convert';

/// Decodifica o payload de um JWT sem verificar assinatura — usado apenas
/// para ler claims (usuarioId, organizacaoId, etc.) do token já autenticado
/// pelo backend, nunca para validar autenticidade.
Map<String, dynamic> decodeJwtPayload(String token) {
  final partes = token.split('.');
  if (partes.length != 3) return {};

  try {
    final normalizado = base64Url.normalize(partes[1]);
    final payload = utf8.decode(base64Url.decode(normalizado));
    return jsonDecode(payload) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}
