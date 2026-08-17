import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../core/models/sst_ponto.dart';
import '../../../core/models/wave_forecast.dart';

/// Única classe que conhece a URL/parâmetros da API pública Open-Meteo
/// Marine (ondas, swell, corrente oceânica e temperatura da superfície
/// do mar). Não passa pelo [ApiService] do backend Blue Ocean — é um
/// serviço externo, sem autenticação.
class WaveForecastRepository {
  static const _baseUrl = 'https://marine-api.open-meteo.com/v1/marine';

  Future<WaveForecast> buscar({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'hourly': 'wave_height,wave_direction,wave_period,'
          'swell_wave_height,swell_wave_direction,swell_wave_period,'
          'ocean_current_velocity,ocean_current_direction,'
          'sea_surface_temperature',
      'forecast_days': '2',
      'timezone': 'auto',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao buscar previsão de ondas: ${response.statusCode}');
    }

    return WaveForecast.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Busca a temperatura da superfície do mar (SST) atual em vários pontos
  /// de uma vez — usado pela grade de temperatura sobreposta ao mapa (ver
  /// `MapaWidget`). A Open-Meteo aceita listas de lat/lon separadas por
  /// vírgula numa única chamada, então uma grade inteira custa 1 requisição,
  /// não uma por ponto.
  ///
  /// Pede só `current` (não `hourly`) — mais leve, já que a grade só
  /// precisa do valor de agora, não da série horária completa.
  Future<List<SstPonto>> buscarGrade(List<LatLng> pontos) async {
    if (pontos.isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': pontos.map((p) => p.latitude.toStringAsFixed(4)).join(','),
      'longitude': pontos.map((p) => p.longitude.toStringAsFixed(4)).join(','),
      'current': 'sea_surface_temperature',
      'timezone': 'auto',
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao buscar grade de temperatura: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    // Com 1 ponto só, a API responde um objeto único em vez de lista.
    final itens = decoded is List ? decoded : [decoded];
    return itens
        .map((item) => SstPonto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
