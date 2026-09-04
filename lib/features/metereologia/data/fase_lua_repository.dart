import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/models/dia_lunar.dart';

/// Única classe que conhece a URL/parâmetros da Open-Meteo pra
/// nascer/pôr do sol e da lua (`daily=sunrise,sunset,moonrise,moonset`)
/// — mesma API pública já usada pelo resto da meteorologia do app (ver
/// [PrevisaoTempoRepository]), sem autenticação. A fase da lua em si não
/// depende de coordenada e é calculada localmente, sem rede — ver
/// `core/utils/fase_lua.dart`.
class FaseLuaRepository {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Limite da própria API pra previsão diária — pedir mais que isso
  /// retorna erro, não trunca silenciosamente.
  static const diasMaximos = 16;

  Future<List<DiaLunar>> buscar({
    required double latitude,
    required double longitude,
    int dias = diasMaximos,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': 'sunrise,sunset,moonrise,moonset',
      'timezone': 'auto',
      'forecast_days': dias.clamp(1, diasMaximos).toString(),
    });

    final response =
        await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao buscar nascer/pôr do sol e da lua: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final datas = (daily['time'] as List).cast<String>();
    final nascerSol = (daily['sunrise'] as List).cast<String?>();
    final porSol = (daily['sunset'] as List).cast<String?>();
    final nascer = (daily['moonrise'] as List).cast<String?>();
    final poesta = (daily['moonset'] as List).cast<String?>();

    return List.generate(datas.length, (i) {
      DateTime? parse(String? s) => s == null ? null : DateTime.parse(s);
      return DiaLunar(
        data: DateTime.parse(datas[i]),
        nascerSol: parse(nascerSol[i]),
        porSol: parse(porSol[i]),
        nascer: parse(nascer[i]),
        poesta: parse(poesta[i]),
      );
    });
  }
}
