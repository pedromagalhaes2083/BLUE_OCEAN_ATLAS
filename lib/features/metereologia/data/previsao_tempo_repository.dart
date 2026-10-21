import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/services/dados_ponto_cache_service.dart';
import '../domain/models/previsao_tempo.dart';
import 'wave_forecast_repository.dart';

/// Única classe que conhece a URL/parâmetros da API pública Open-Meteo
/// (clima geral). Não passa pelo [ApiService] do backend Blue Ocean —
/// é um serviço externo, sem autenticação.
class PrevisaoTempoRepository {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const _tipoCache = 'clima';

  /// Mesmo padrão de [WaveForecastRepository]/`RecomendacaoRepository`:
  /// checar logo depois de [buscar] pra saber se o dado veio do cache local
  /// (sem rede agora) em vez da API ao vivo.
  bool ultimoResultadoOffline = false;
  DateTime? ultimaAtualizacaoCache;

  /// Busca vento/clima num ponto — cai pro último dado cacheado desse
  /// ponto (ver [DadosPontoCacheService]) se a rede falhar; só propaga o
  /// erro se nem a rede nem o cache tiverem nada.
  Future<PrevisaoTempo> buscar({
    required double latitude,
    required double longitude,
    bool forcarAtualizacao = false,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'hourly':
          'windspeed_10m,winddirection_10m,precipitation,temperature_2m,pressure_msl,relativehumidity_2m',
      'current_weather': 'true',
      'timezone': 'auto',
      'forecast_days': '2',
    });

    // Cache primeiro — mesma validade da previsão de ondas (mesma origem,
    // Open-Meteo, mesmo ritmo de atualização do modelo).
    final resultado = await DadosPontoCacheService.buscarComCache(
      tipo: _tipoCache,
      latitude: latitude,
      longitude: longitude,
      aindaValido: DadosPontoCacheService.maisRecenteQue(
          WaveForecastRepository.validadeCache),
      forcarAtualizacao: forcarAtualizacao,
      daRede: (timeout) async {
        final response = await http.get(uri).timeout(timeout);
        if (response.statusCode != 200) {
          throw Exception(
              'Erro ao buscar previsão do tempo: ${response.statusCode}');
        }
        return response.body;
      },
    );
    ultimoResultadoOffline = resultado.offlineDesde != null;
    if (ultimoResultadoOffline) ultimaAtualizacaoCache = resultado.offlineDesde;
    return PrevisaoTempo.fromJson(
        jsonDecode(resultado.corpo) as Map<String, dynamic>);
  }
}
