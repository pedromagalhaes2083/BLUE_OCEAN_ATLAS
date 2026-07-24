import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/models/previsao_tempo.dart';

/// Única classe que conhece a URL/parâmetros da API pública Open-Meteo
/// (clima geral). Não passa pelo [ApiService] do backend Blue Ocean —
/// é um serviço externo, sem autenticação.
class PrevisaoTempoRepository {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<PrevisaoTempo> buscar({
    required double latitude,
    required double longitude,
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

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao buscar previsão do tempo: ${response.statusCode}');
    }

    return PrevisaoTempo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
