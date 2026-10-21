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
      // Cache primeiro, sem validade: batimetria (GEBCO 2020) é um dado
      // fixo, o fundo do mar não muda entre uma consulta e outra. Por isso
      // a chave é o ponto com 4 casas (~11 m), não a padrão de 2 (~1,1 km):
      // um valor que nunca vence não pode ser servido pra outro ponto a até
      // 1 km — perto da quebra da plataforma, a profundidade muda centenas
      // de metros nessa distância.
      final resultado = await DadosPontoCacheService.buscarComCache(
        tipo: _tipoCache,
        latitude: latitude,
        longitude: longitude,
        chave: '${_tipoCache}_exata:'
            '${latitude.toStringAsFixed(4)}:${longitude.toStringAsFixed(4)}',
        aindaValido: (_) => true,
        daRede: (timeout) async {
          final response = await http.get(uri).timeout(timeout);
          if (response.statusCode != 200) {
            throw Exception(
                'Erro ao buscar profundidade: ${response.statusCode}');
          }
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          if (json['status'] != 'OK') {
            throw Exception('Erro ao buscar profundidade: ${json['status']}');
          }
          // Também na chave aproximada de sempre — é a reserva offline pra
          // pontos vizinhos que nunca foram consultados (ver o catch).
          await DadosPontoCacheService.salvar(
            tipo: _tipoCache,
            latitude: latitude,
            longitude: longitude,
            corpo: response.body,
          );
          return response.body;
        },
      );
      ultimoResultadoOffline = false;
      return _primeiraLeitura(resultado.corpo);
    } catch (e) {
      // Ponto nunca consultado e sem rede: usa o de um ponto vizinho (até
      // ~1 km), como já era antes — marcado offline pra tela avisar.
      final aproximado = await DadosPontoCacheService.ler(
        tipo: _tipoCache,
        latitude: latitude,
        longitude: longitude,
      );
      if (aproximado == null) rethrow;
      ultimoResultadoOffline = true;
      ultimaAtualizacaoCache = aproximado.em;
      return _primeiraLeitura(aproximado.corpo);
    }
  }

  LeituraProfundidade _primeiraLeitura(String corpo) {
    final json = jsonDecode(corpo) as Map<String, dynamic>;
    return LeituraProfundidade.fromJson(
        (json['results'] as List).first as Map<String, dynamic>);
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
