import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../core/services/dados_ponto_cache_service.dart';
import '../domain/models/leitura_profundidade.dart';

/// Única classe que conhece a URL/parâmetros da API pública OpenTopoData
/// (batimetria/elevação GEBCO2020). Não passa pelo [ApiService] do
/// backend Blue Ocean — é um serviço externo, sem autenticação.
class ProfundidadeRepository {
  static const _baseUrl = 'https://api.opentopodata.org/v1/gebco2020';
  static const _tipoCache = 'profundidade';

  /// Mesmo padrão de [WaveForecastRepository]: checar logo depois de
  /// [buscarPonto] pra saber se o dado veio do cache local.
  bool ultimoResultadoOffline = false;
  DateTime? ultimaAtualizacaoCache;

  /// Busca a profundidade/elevação num único ponto — tem cache próprio
  /// (ver [DadosPontoCacheService]), diferente de [buscarVarios] (usada só
  /// pela grade batimétrica, sem cache: um lote de pontos não cabe na
  /// mesma chave "tipo+ponto").
  Future<LeituraProfundidade> buscarPonto({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'locations': '$latitude,$longitude',
      'interpolation': 'bilinear',
    });

    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar profundidade: ${response.statusCode}');
      }
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] != 'OK') {
        throw Exception('Erro ao buscar profundidade: ${json['status']}');
      }
      await DadosPontoCacheService.salvar(
        tipo: _tipoCache,
        latitude: latitude,
        longitude: longitude,
        corpo: response.body,
      );
      ultimoResultadoOffline = false;
      return LeituraProfundidade.fromJson(
          (json['results'] as List).first as Map<String, dynamic>);
    } catch (e) {
      final cache = await DadosPontoCacheService.ler(
        tipo: _tipoCache,
        latitude: latitude,
        longitude: longitude,
      );
      if (cache == null) rethrow;
      final json = jsonDecode(cache.corpo) as Map<String, dynamic>;
      ultimoResultadoOffline = true;
      ultimaAtualizacaoCache = cache.em;
      return LeituraProfundidade.fromJson(
          (json['results'] as List).first as Map<String, dynamic>);
    }
  }

  /// Busca profundidade/elevação em vários pontos numa única chamada
  /// (a API aceita até 100 pontos por requisição).
  Future<List<LeituraProfundidade>> buscarVarios(List<LatLng> pontos) async {
    if (pontos.isEmpty) return [];

    final locations =
        pontos.map((p) => '${p.latitude},${p.longitude}').join('|');
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'locations': locations,
      'interpolation': 'bilinear',
    });

    final response =
        await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar profundidade: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['status'] != 'OK') {
      throw Exception('Erro ao buscar profundidade: ${json['status']}');
    }

    final resultados = json['results'] as List;
    return resultados
        .map((r) => LeituraProfundidade.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
