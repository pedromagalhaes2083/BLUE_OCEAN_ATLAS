import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/models/wave_forecast.dart';

/// Única classe que conhece a URL/parâmetros da API pública Open-Meteo
/// Marine (ondas, swell e corrente oceânica). Não passa pelo [ApiService]
/// do backend Blue Ocean — é um serviço externo, sem autenticação.
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
          'ocean_current_velocity,ocean_current_direction',
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
}
