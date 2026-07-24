import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth/jwt_utils.dart';
import '../config/config.dart';
import '../config/constantes.dart';
import 'excecoes.dart';

/// Cliente HTTP cru (URL, headers, token). Não deve ser chamado direto de
/// telas/widgets — cada recurso da API tem um `<recurso>_repository.dart`
/// (ex: [DispositivoRepository], [RecomendacaoRepository],
/// [LocalizacaoRepository]) que é o único lugar que conhece a rota exata
/// e o formato de corpo esperado, e converte a resposta num modelo de
/// domínio estável. Assim, quando uma rota mudar, o ajuste fica isolado
/// no repositório correspondente — os modelos e quem os consome não
/// precisam mudar.
class ApiService {
  // ── URL base da API de produção ────────────────────────────────────────────
  static const _apiPadrao = 'blue-ocean-app-api.up.railway.app';

  // ── Login ──────────────────────────────────────────────────────────────────

  static Future<void> login(String usuario, String senha) async {
    var api = _apiPadrao;
    while (api.endsWith('/')) {
      api = api.substring(0, api.length - 1);
    }

    final responseLogin = await http.post(
      Uri.parse('https://$api/api/v1/autenticacao'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'chave': usuario, 'senha': senha}),
    );

    if (responseLogin.statusCode == 401) {
      throw const UnauthorisedException('Credenciais inválidas');
    }
    _analisa(responseLogin);

    final token = jsonDecode(responseLogin.body)['accessToken'] as String;
    await Config.grava(Constantes.api, api);
    await Config.grava(Constantes.authToken, token);
    await Config.grava(Constantes.authCredencial, responseLogin.body);

    // A organização não vem no corpo do login — é uma claim do próprio JWT.
    final claims = decodeJwtPayload(token);
    final organizacaoId = claims['organizacaoId'] as String?;
    if (organizacaoId != null) {
      await Config.grava(Constantes.organizacaoId, organizacaoId);
    }
  }

  // ── GET ────────────────────────────────────────────────────────────────────

  static Future<dynamic> get(String recurso) async {
    recurso = _limpaRota(recurso);
    final api = await _api();
    final response = await http.get(
      Uri.parse('https://$api/api/v1/$recurso'),
      headers: await _headers(),
    );
    return _analisa(response);
  }

  // ── POST ───────────────────────────────────────────────────────────────────

  static Future<dynamic> post(String recurso, dynamic data) async {
    recurso = _limpaRota(recurso);
    final api = await _api();
    debugPrint('POST https://$api/api/v1/$recurso');
    debugPrint(jsonEncode(data));
    final response = await http.post(
      Uri.parse('https://$api/api/v1/$recurso'),
      headers: await _headers(comCorpo: true),
      body: jsonEncode(data),
    );
    return _analisa(response);
  }

  // ── PUT ────────────────────────────────────────────────────────────────────

  static Future<dynamic> put(String recurso, dynamic data) async {
    recurso = _limpaRota(recurso);
    final api = await _api();
    final response = await http.put(
      Uri.parse('https://$api/api/v1/$recurso'),
      headers: await _headers(comCorpo: true),
      body: jsonEncode(data),
    );
    return _analisa(response);
  }

  // ── Carga paginada ─────────────────────────────────────────────────────────
  // Percorre todas as páginas e retorna a lista completa.

  static Future<List<Map<String, dynamic>>> carga(
    String recurso,
    DateTime inicio,
  ) async {
    recurso = _limpaRota(recurso);
    final api = await _api();
    final headers = await _headers();
    final retorno = <Map<String, dynamic>>[];
    var pagina = 1;
    var paginas = 1;

    while (pagina <= paginas) {
      final response = await http.get(
        Uri.parse(
          'https://$api/api/v1/$recurso/carga'
          '?inicio=${inicio.toIso8601String()}&pagina=$pagina',
        ),
        headers: headers,
      );
      final resposta = await _analisa(response);
      paginas = (resposta['paginas'] as num?)?.toInt() ?? 0;
      for (final elemento in (resposta['lista'] as List? ?? [])) {
        retorno.add(Map<String, dynamic>.from(elemento as Map));
      }
      pagina++;
    }
    return retorno;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static dynamic _analisa(http.Response response) {
    final statusCode = response.statusCode;
    final conteudo = jsonDecode(response.body);
    if (statusCode >= 200 && statusCode < 300) return conteudo;
    final mensagem =
        'A requisição falhou: $statusCode\n\n'
        'URL: ${response.request?.url}\n'
        '${(conteudo as Map)['message'] ?? ''}';
    throw Exception(mensagem);
  }

  static Future<String> _api() async {
    final api = await Config.obtem(Constantes.api);
    if (api.isEmpty) throw Exception('Configuração da API não disponível');
    return api;
  }

  static Future<String> _token() async {
    return Config.obtem(Constantes.authToken);
  }

  // TODO: usar a organização do usuário/dispositivo em vez de um valor fixo.
  static const _organizacaoIdEstatica = '11111111-1111-1111-1111-111111111111';

  /// Cabeçalhos padrão de toda chamada autenticada: token do usuário e
  /// organização atual (exigida pelos recursos em `base/estrutura`).
  static Future<Map<String, String>> _headers({bool comCorpo = false}) async {
    final token = await _token();
    return {
      if (comCorpo) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'x-organization-id': _organizacaoIdEstatica,
    };
  }

  static String _limpaRota(String rota) {
    while (rota.startsWith('/')) {
      rota = rota.substring(1);
    }
    return rota;
  }
}
