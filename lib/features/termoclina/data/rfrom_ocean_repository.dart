import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/services/dados_ponto_cache_service.dart';
import '../domain/models/perfil_temperatura_ponto.dart';

/// Perfil oceânico real (medido) devolvido por [RfromOceanRepository] —
/// temperatura em profundidade (quando a região tem cobertura) e a
/// salinidade de superfície, pra uso em qualquer tela/fórmula que precise
/// de um dado real em vez de estimado (hoje: `FonteTermoclinaEstimada` usa
/// [temperatura], `CondicoesMarScreen` mostra [salinidadeSuperficieUps]).
class PerfilOceanicoRfrom {
  /// Pontos reais de temperatura × profundidade — só os níveis com dado
  /// (bóias Argo não cobrem todo o globo/toda profundidade; ver comentário
  /// da classe), já marcados `medido: true`. Pode vir vazio (sem cobertura
  /// nenhuma nesse ponto).
  final List<PerfilTemperaturaPonto> temperatura;

  /// Salinidade na superfície (nível de pressão mais raso disponível,
  /// ~2,5m), em PSU — ou `null` sem cobertura nesse ponto.
  final double? salinidadeSuperficieUps;

  const PerfilOceanicoRfrom({
    required this.temperatura,
    this.salinidadeSuperficieUps,
  });
}

/// Fonte de dados oceânicos reais medidos: RFROM v2.3 (Random Forest
/// Regression Ocean Maps), NOAA PMEL/CIMAR — um mapa global grade 0,25°,
/// atualizado semanalmente, construído a partir de bóias Argo (perfis
/// verticais reais de temperatura/salinidade) por regressão estatística.
/// Ver `references`/`summary` do próprio dataset em
/// https://data.pmel.noaa.gov/pmel/erddap/griddap/argo_rfromv23_temp_realtime.html
///
/// **Cobertura é irregular perto da costa**: bóias Argo operam em mar
/// aberto (não sobem a plataforma continental), então em pontos costeiros
/// rasos é comum só os 1-2 níveis mais superficiais terem dado e o resto
/// vir `null` — por isso [buscarPerfil] nunca lança por cobertura parcial,
/// só filtra os níveis sem dado. É responsabilidade de quem chama decidir
/// se o que sobrou é suficiente (ver `FonteTermoclinaEstimada`, que só usa
/// a termoclina medida com uma faixa de profundidade mínima coberta).
class RfromOceanRepository {
  static const _baseTemperatura =
      'https://data.pmel.noaa.gov/pmel/erddap/griddap/argo_rfromv23_temp_realtime.json';
  static const _baseSalinidade =
      'https://data.pmel.noaa.gov/pmel/erddap/griddap/argo_rfromv23_sal_realtime.json';

  /// Mesmos 58 níveis de pressão (2,5 a 1975 decibar) nos dois datasets —
  /// índice 0 a 57 na dimensão `mean_pressure` do griddap.
  static const _ultimoIndicePressao = 57;

  static const _tipoCacheTemperatura = 'rfrom_temperatura';
  static const _tipoCacheSalinidade = 'rfrom_salinidade';

  /// Mesmo padrão de `WaveForecastRepository`/`ProfundidadeRepository`:
  /// checar logo depois de [buscarPerfil] se o dado veio do cache (sem
  /// rede agora). Reflete o resultado da última chamada QUE TEVE QUE cair
  /// pro cache — se temperatura e salinidade vieram de fontes diferentes
  /// (uma da rede, outra do cache), fica `true` (o pior caso).
  bool ultimoResultadoOffline = false;
  DateTime? ultimaAtualizacaoCache;

  Future<PerfilOceanicoRfrom> buscarPerfil({
    required double latitude,
    required double longitude,
  }) async {
    ultimoResultadoOffline = false;
    ultimaAtualizacaoCache = null;

    final resultados = await Future.wait([
      _buscarVariavel(
        baseUrl: _baseTemperatura,
        variavel: 'ocean_temperature',
        tipoCache: _tipoCacheTemperatura,
        latitude: latitude,
        longitude: longitude,
      ),
      _buscarVariavel(
        baseUrl: _baseSalinidade,
        variavel: 'ocean_salinity',
        tipoCache: _tipoCacheSalinidade,
        latitude: latitude,
        longitude: longitude,
      ),
    ]);

    final pontosTemperatura = resultados[0];
    final pontosSalinidade = resultados[1];

    return PerfilOceanicoRfrom(
      temperatura: pontosTemperatura
          .map((p) => PerfilTemperaturaPonto(
                profundidadeM: p.pressao,
                temperaturaC: p.valor,
                medido: true,
              ))
          .toList(),
      // Níveis vêm ordenados da superfície pro fundo — o primeiro com dado
      // é o mais raso disponível (idealmente ~2,5m).
      salinidadeSuperficieUps:
          pontosSalinidade.isEmpty ? null : pontosSalinidade.first.valor,
    );
  }

  /// Busca uma única variável (temperatura ou salinidade) no nível de
  /// pressão mais próximo do ponto pedido — `(last)` pra sempre pegar a
  /// atualização semanal mais recente do mapa, ponto/longitude convertida
  /// pra 0-360 (convenção do dataset) e o ERDDAP resolve pro ponto de
  /// grade mais próximo (resolução 0,25°) sozinho.
  Future<List<({double pressao, double valor})>> _buscarVariavel({
    required String baseUrl,
    required String variavel,
    required String tipoCache,
    required double latitude,
    required double longitude,
  }) async {
    final longitudeErddap = longitude < 0 ? longitude + 360 : longitude;
    final uri = Uri.parse(
      '$baseUrl?$variavel%5B(last)%5D%5B0:$_ultimoIndicePressao%5D'
      '%5B($latitude)%5D%5B($longitudeErddap)%5D',
    );

    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar $variavel: ${response.statusCode}');
      }
      await DadosPontoCacheService.salvar(
        tipo: tipoCache,
        latitude: latitude,
        longitude: longitude,
        corpo: response.body,
      );
      return _parsear(response.body);
    } catch (_) {
      final cache = await DadosPontoCacheService.ler(
        tipo: tipoCache,
        latitude: latitude,
        longitude: longitude,
      );
      // Sem cache nem rede: devolve vazio (best-effort) em vez de lançar —
      // quem chama trata como "sem cobertura", igual a uma resposta cheia
      // de nulos da API.
      if (cache == null) return [];
      ultimoResultadoOffline = true;
      ultimaAtualizacaoCache = cache.em;
      return _parsear(cache.corpo);
    }
  }

  List<({double pressao, double valor})> _parsear(String corpo) {
    final json = jsonDecode(corpo) as Map<String, dynamic>;
    final tabela = json['table'] as Map<String, dynamic>;
    final linhas = tabela['rows'] as List;

    final pontos = <({double pressao, double valor})>[];
    for (final linha in linhas) {
      final valorBruto = (linha as List)[4];
      if (valorBruto == null) continue;
      pontos.add((
        pressao: (linha[1] as num).toDouble(),
        valor: (valorBruto as num).toDouble(),
      ));
    }
    return pontos;
  }
}
