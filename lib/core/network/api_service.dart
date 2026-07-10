import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../config/constantes.dart';
import 'excecoes.dart';

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
  }

  // ── GET ────────────────────────────────────────────────────────────────────

  static Future<dynamic> get(String recurso) async {
    recurso = _limpaRota(recurso);
    final api = await _api();
    final token = await _token();
    final response = await http.get(
      Uri.parse('https://$api/api/$recurso'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return _analisa(response);
  }

  // ── POST ───────────────────────────────────────────────────────────────────

  static Future<dynamic> post(String recurso, dynamic data) async {
    recurso = _limpaRota(recurso);
    final api = await _api();
    final token = await _token();
    debugPrint('POST https://$api/api/$recurso');
    debugPrint(jsonEncode(data));
    final response = await http.post(
      Uri.parse('https://$api/api/$recurso'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return _analisa(response);
  }

  // ── PUT ────────────────────────────────────────────────────────────────────

  static Future<dynamic> put(String recurso, dynamic data) async {
    recurso = _limpaRota(recurso);
    final api = await _api();
    final token = await _token();
    final response = await http.put(
      Uri.parse('https://$api/api/$recurso'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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
    final token = await _token();
    final retorno = <Map<String, dynamic>>[];
    var pagina = 1;
    var paginas = 1;

    while (pagina <= paginas) {
      final response = await http.get(
        Uri.parse(
          'https://$api/api/$recurso/carga'
          '?inicio=${inicio.toIso8601String()}&pagina=$pagina',
        ),
        headers: {'Authorization': 'Bearer $token'},
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

  static String _limpaRota(String rota) {
    while (rota.startsWith('/')) {
      rota = rota.substring(1);
    }
    return rota;
  }
}
