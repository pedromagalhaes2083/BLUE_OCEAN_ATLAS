import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/services/dados_ponto_cache_service.dart';
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

  /// Mesmo padrão dos outros repositórios de meteorologia: checar logo
  /// depois de [buscar] se o dado veio do cache por falta de rede.
  bool ultimoResultadoOffline = false;
  DateTime? ultimaAtualizacaoCache;

  Future<List<DiaLunar>> buscar({
    required double latitude,
    required double longitude,
    int dias = diasMaximos,
    bool forcarAtualizacao = false,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': 'sunrise,sunset,moonrise,moonset',
      'timezone': 'auto',
      'forecast_days': dias.clamp(1, diasMaximos).toString(),
    });

    // Cache primeiro (antes não havia cache nenhum: sem rede, a tela ficava
    // sem horários depois de 15 s de espera). A resposta traz os horários
    // do dia inteiro, então a salva hoje vale o dia todo.
    final hoje = DateTime.now();
    final resultado = await DadosPontoCacheService.buscarComCache(
      tipo: 'lua${dias.clamp(1, diasMaximos)}',
      latitude: latitude,
      longitude: longitude,
      aindaValido: (salvoEm) =>
          salvoEm.year == hoje.year &&
          salvoEm.month == hoje.month &&
          salvoEm.day == hoje.day,
      // Sem rede, uma resposta de até 2 semanas ainda cobre hoje — ela traz
      // até 16 dias à frente, e as telas procuram o dia pela data (ver
      // FaseLuaScreen._diaHoje), nunca pela posição na lista.
      serveOffline:
          DadosPontoCacheService.maisRecenteQue(const Duration(days: 14)),
      forcarAtualizacao: forcarAtualizacao,
      daRede: (timeout) async {
        final response = await http.get(uri).timeout(timeout);
        if (response.statusCode != 200) {
          throw Exception('Erro ao buscar nascer/pôr do sol e da lua: '
              '${response.statusCode}');
        }
        return response.body;
      },
    );
    ultimoResultadoOffline = resultado.offlineDesde != null;
    ultimaAtualizacaoCache = resultado.offlineDesde;

    final json = jsonDecode(resultado.corpo) as Map<String, dynamic>;
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
