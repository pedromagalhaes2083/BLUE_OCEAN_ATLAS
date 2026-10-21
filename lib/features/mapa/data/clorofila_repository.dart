import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/dados_ponto_cache_service.dart';
import '../../../core/utils/proximidade.dart';
import '../domain/models/leitura_clorofila.dart';

/// Onde o cache de clorofila é guardado — atrás de uma interface pros
/// testes simularem falha de leitura/gravação. A implementação real usa o
/// mesmo armazenamento persistente (SQLite) do resto dos dados por ponto
/// ([DadosPontoCacheService]), sem um segundo sistema de cache.
abstract class ArmazenamentoCacheClorofila {
  Future<String?> ler(String chave);
  Future<void> salvar(String chave, String valor);
}

class ArmazenamentoCacheClorofilaPersistente
    implements ArmazenamentoCacheClorofila {
  const ArmazenamentoCacheClorofilaPersistente();

  @override
  Future<String?> ler(String chave) async =>
      (await DadosPontoCacheService.lerPorChave(chave))?.corpo;

  @override
  Future<void> salvar(String chave, String valor) =>
      DadosPontoCacheService.salvarPorChave(chave, valor);
}

/// Única classe que conhece a URL/parâmetros do NOAA CoastWatch ERDDAP pra
/// clorofila-a — API pública, sem autenticação, não passa pelo backend
/// Blue Ocean (mesmo padrão de [WaveForecastRepository] pra Open-Meteo).
///
/// Decisão de 2026-09: o pedido original era usar o Copernicus Marine
/// Toolbox, mas ele não tem uma API REST simples de "lat/lon → valor" —
/// o acesso oficial exige credencial (usuário/senha, não uma "chave") e um
/// processo de subset de NetCDF bem mais pesado, adequado a rodar num
/// backend dedicado, não a uma consulta pontual simples. O ERDDAP do NOAA
/// CoastWatch expõe o mesmo tipo de dado (cor do oceano/clorofila-a) como
/// uma API REST pública de verdade — confirmado com curl real, inclusive
/// no ponto de teste combinado (-2.10600, -38.89306), ver histórico.
///
/// **Cache diário** (ver [buscarPontoOuAproximado]): o produto é diário, e
/// sem cache cada consulta custava até 45 s (ponto, 20 s + grade, 25 s) —
/// e a Inteligência Oceânica espera a mais lenta das suas 6 fontes.
class ClorofilaRepository {
  static const dataset = 'noaacwNPPN20S3ASCIDINEOF2kmDaily';
  static const _baseUrl =
      'https://coastwatch.noaa.gov/erddap/griddap/$dataset.csv';

  /// Resolução da grade do dataset: células de 1/48° (~2,3 km). Confirmado
  /// pelas respostas reais do ERDDAP (ver testes): longitudes consecutivas
  /// -39.51041, -39.489582, -39.46874 (passo 0,0208333…) e toda coordenada
  /// devolvida num centro de célula (k + 0,5)/48 — ex.: -2.1145885 × 48 =
  /// -101,5. Como o ERDDAP responde o centro mais próximo, o pixel usado pra
  /// um ponto é sempre o da célula ⌊lat·48⌋, ⌊lon·48⌋.
  static const celulasPorGrau = 48;

  /// De quanto em quanto tempo perguntar ao ERDDAP qual é o produto diário
  /// mais recente. Não é a validade do dado (essa é a data do produto): é
  /// só o intervalo pra descobrir se saiu um produto novo.
  static const intervaloVerificacaoProduto = Duration(hours: 6);

  /// Depois de uma falha ao consultar o produto mais recente (sem rede,
  /// ERDDAP fora do ar), não tenta de novo antes disso — sem isso, cada
  /// consulta offline esperaria o timeout de novo.
  static const esperaAposFalhaVerificacao = Duration(minutes: 2);

  static const _timeoutPonto = Duration(seconds: 20);
  static const _timeoutGrade = Duration(seconds: 25);
  static const _timeoutDataProduto = Duration(seconds: 8);
  static const _toleranciaRelogio = Duration(minutes: 5);

  /// Muda quando o formato salvo ou a regra de busca mudar — entradas
  /// antigas deixam de casar com a chave em vez de serem lidas errado.
  static const versaoCache = 'v1';
  static const _chaveProduto = 'clorofila:$versaoCache:$dataset:produto';

  final http.Client? _client;
  final ArmazenamentoCacheClorofila _cache;
  final DateTime Function() _agora;

  ClorofilaRepository({
    http.Client? client,
    ArmazenamentoCacheClorofila cache =
        const ArmazenamentoCacheClorofilaPersistente(),
    DateTime Function()? relogio,
  })  : _client = client,
        _cache = cache,
        _agora = relogio ?? DateTime.now;

  /// Consultas em andamento por chave de cache — estáticas porque cada tela
  /// cria o seu próprio [ClorofilaRepository] (mapa, Inteligência...).
  static final Map<String, Future<LeituraClorofilaPonto>> _consultasEmAndamento =
      {};
  static Future<String>? _verificacaoEmAndamento;
  static DateTime? _ultimaFalhaVerificacao;

  @visibleForTesting
  static void resetEstadoParaTestes() {
    _consultasEmAndamento.clear();
    _verificacaoEmAndamento = null;
    _ultimaFalhaVerificacao = null;
  }

  Future<http.Response> _get(Uri uri, Duration timeout) =>
      (_client?.get(uri) ?? http.get(uri)).timeout(timeout);

  /// Busca a clorofila-a mais recente disponível num ponto específico —
  /// usa `(last)` no eixo de tempo em vez de uma data fixa, porque o
  /// produto tem alguns dias de atraso em relação a "hoje" (a satélite
  /// observa, mas o processamento/composição diária leva um tempo) — pedir
  /// uma data futura demais faz o ERDDAP devolver 404 ("Start is greater
  /// than the axis maximum"), confirmado durante o desenvolvimento.
  Future<LeituraClorofilaPonto> buscarPonto({
    required double latitude,
    required double longitude,
  }) async {
    // Uri.replace(query:) recodificaria os %5B/%5D já prontos (virariam
    // %255B) — monta a URL crua e usa Uri.parse direto nela, mesma string
    // testada com curl real durante o desenvolvimento.
    final uri = Uri.parse(
      '$_baseUrl?chlor_a%5B(last)%5D%5B(0.0):1:(0.0)%5D'
      '%5B($latitude):1:($latitude)%5D%5B($longitude):1:($longitude)%5D',
    );

    final response = await _get(uri, _timeoutPonto);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar clorofila-a: ${response.statusCode}');
    }
    return parseRespostaCsv(response.body);
  }

  /// Busca clorofila-a numa grade ao redor de (latitude, longitude), num
  /// raio de [raioNm] milhas náuticas — **uma única chamada HTTP**, ao
  /// contrário de [buscarPonto] (mesmo padrão de lote de
  /// [WaveForecastRepository.buscarGrade]/[ProfundidadeRepository.buscarVarios]).
  ///
  /// Griddap (o protocolo do ERDDAP) aceita nativamente um intervalo de
  /// lat/lon em vez de um valor fixo — construído aqui com
  /// [projetarPontoNoRumo] pros 4 pontos cardeais a partir do centro, em vez
  /// de aproximar com graus fixos (a distância de 1° de longitude varia com
  /// a latitude). A resolução devolvida é a nativa do dataset (~2km —
  /// confirmado com curl real: um pouco mais de 1 milha náutica por célula,
  /// já próximo do "1 ponto por milha quadrada" — nenhuma reamostragem
  /// adicional necessária).
  Future<List<LeituraClorofilaPonto>> buscarGrade({
    required double latitude,
    required double longitude,
    double raioNm = 10,
  }) async {
    final norte = projetarPontoNoRumo(latitude, longitude, 0, raioNm);
    final sul = projetarPontoNoRumo(latitude, longitude, 180, raioNm);
    final leste = projetarPontoNoRumo(latitude, longitude, 90, raioNm);
    final oeste = projetarPontoNoRumo(latitude, longitude, 270, raioNm);

    final uri = Uri.parse(
      '$_baseUrl?chlor_a%5B(last)%5D%5B(0.0):1:(0.0)%5D'
      '%5B(${sul.latitude}):1:(${norte.latitude})%5D'
      '%5B(${oeste.longitude}):1:(${leste.longitude})%5D',
    );

    final response = await _get(uri, _timeoutGrade);
    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao buscar grade de clorofila-a: ${response.statusCode}');
    }
    return parseRespostaCsvGrade(response.body);
  }

  /// Mesmo que [buscarPonto], mas quando o pixel exato vier sem dado
  /// (nuvem, turbidez perto da costa — ver doc de [LeituraClorofilaPonto])
  /// busca numa grade pequena ao redor ([raioAproximacaoNm], padrão 10 mn)
  /// e usa o pixel válido mais próximo como aproximação — ainda é dado real
  /// de satélite, só de um ponto vizinho em vez do exato, nunca um valor
  /// inventado (ver `_cardParcial`/doc da classe sobre não fabricar dado).
  /// [LeituraClorofilaPonto.latitude]/[longitude] do retorno já são as do
  /// pixel usado de verdade (não as pedidas), e [LeituraClorofilaPonto.aproximado]
  /// fica `true` nesse caso — a UI decide como avisar disso.
  ///
  /// Se a grade também falhar (sem sinal, nenhum pixel com dado na área)
  /// devolve o resultado original sem dado, em vez de fingir que achou
  /// algo.
  ///
  /// **Cache diário por célula:** um resultado com dado fica salvo pela
  /// célula da grade do satélite ([chaveCache]) junto da data do produto
  /// diário de onde veio. Enquanto essa for a data do produto mais recente
  /// do ERDDAP ([intervaloVerificacaoProduto]), devolve do cache na hora,
  /// sem rede — inclusive depois de reiniciar o app. Saiu produto novo →
  /// busca de novo. Sem conseguir buscar (offline, ERDDAP fora do ar), usa
  /// o último resultado da célula marcado [LeituraClorofilaPonto.desatualizada],
  /// sempre com a data original da observação. Consultas simultâneas da
  /// mesma célula compartilham uma única busca.
  Future<LeituraClorofilaPonto> buscarPontoOuAproximado({
    required double latitude,
    required double longitude,
    double raioAproximacaoNm = 10,
  }) {
    final chave = chaveCache(
        latitude: latitude, longitude: longitude, raioNm: raioAproximacaoNm);
    return _consultasEmAndamento[chave] ??=
        _buscarComCache(chave, latitude, longitude, raioAproximacaoNm)
            .whenComplete(() {
      // Corpo em bloco de propósito: `() => remove(...)` devolveria a
      // própria Future removida, e o whenComplete esperaria ela pra sempre.
      _consultasEmAndamento.remove(chave);
    });
  }

  /// Célula da grade do dataset (ver [celulasPorGrau]) + raio de
  /// aproximação (muda o resultado quando o pixel exato não tem dado) +
  /// dataset + versão do formato. A data do produto fica dentro da entrada,
  /// não na chave: assim a célula sempre tem o seu último resultado à mão
  /// pra servir offline, e um produto novo simplesmente o substitui.
  static String chaveCache({
    required double latitude,
    required double longitude,
    double raioNm = 10,
  }) {
    final celulaLat = (latitude * celulasPorGrau).floor();
    final celulaLon = (longitude * celulasPorGrau).floor();
    return 'clorofila:$versaoCache:$dataset:r${raioNm.toStringAsFixed(1)}:'
        '$celulaLat:$celulaLon';
  }

  /// Data (UTC, `aaaa-mm-dd`) do produto diário de onde veio a leitura — a
  /// identidade do produto. O ERDDAP marca cada dia às 12:00Z
  /// (ex.: `2026-08-26T12:00:00Z`).
  static String dataDoProduto(DateTime dataObservacao) =>
      dataObservacao.toUtc().toIso8601String().substring(0, 10);

  Future<LeituraClorofilaPonto> _buscarComCache(
      String chave, double latitude, double longitude, double raioNm) async {
    final emCache = await _lerEntrada(chave);
    // Sem nada da célula no cache, a busca completa já traz a data do
    // produto — perguntar antes seria uma ida à rede a mais.
    final produtoAtual = emCache == null ? null : await _produtoMaisRecente();

    if (emCache != null &&
        produtoAtual != null &&
        emCache.produto.compareTo(produtoAtual) >= 0) {
      return emCache.leitura;
    }

    // Não deu pra saber qual é o produto mais recente (sem rede / ERDDAP
    // fora do ar) e a célula já tem resultado: usa ele na hora, marcado
    // como desatualizado — em vez de esperar mais um timeout de 20–45 s de
    // uma busca que vai falhar pelo mesmo motivo.
    if (emCache != null && produtoAtual == null) {
      _log('sem confirmar o produto mais recente — usando o de '
          '${emCache.produto} do cache, marcado como desatualizado');
      return emCache.leitura.comoDesatualizada();
    }

    try {
      final leitura = await _buscarDaRede(latitude, longitude, raioNm);
      if (leitura.valorMgM3 != null) {
        final produto = dataDoProduto(leitura.data);
        await _salvarEntrada(chave, produto, leitura);
        // A própria resposta diz qual é o produto mais recente — evita uma
        // consulta extra só pra isso nas próximas horas.
        await _registrarProduto(produto);
      }
      // Sem dado na célula (nem por aproximação) não é cacheado: não há
      // garantia de que um produto diário não seja reprocessado, e guardar
      // "sem dado" poderia esconder um valor que aparecer depois.
      return leitura;
    } catch (e) {
      if (emCache != null) {
        _log('falha ao buscar o produto $produtoAtual (${_resumo(e)}) — '
            'usando o de ${emCache.produto} do cache, marcado como desatualizado');
        return emCache.leitura.comoDesatualizada();
      }
      rethrow;
    }
  }

  /// O fluxo original, sem cache: ponto exato; sem dado, a grade ao redor.
  Future<LeituraClorofilaPonto> _buscarDaRede(
      double latitude, double longitude, double raioAproximacaoNm) async {
    final exato = await buscarPonto(latitude: latitude, longitude: longitude);
    if (exato.valorMgM3 != null) return exato;

    List<LeituraClorofilaPonto> grade;
    try {
      grade = await buscarGrade(
        latitude: latitude,
        longitude: longitude,
        raioNm: raioAproximacaoNm,
      );
    } catch (_) {
      return exato;
    }

    final candidatos = grade.where((p) => p.valorMgM3 != null).toList();
    if (candidatos.isEmpty) return exato;

    candidatos.sort((a, b) => calcularDistanciaNauticas(
            latitude, longitude, a.latitude, a.longitude)
        .compareTo(calcularDistanciaNauticas(
            latitude, longitude, b.latitude, b.longitude)));
    final maisProximo = candidatos.first;

    return LeituraClorofilaPonto(
      latitude: maisProximo.latitude,
      longitude: maisProximo.longitude,
      valorMgM3: maisProximo.valorMgM3,
      data: maisProximo.data,
      aproximado: true,
    );
  }

  // ── Produto diário mais recente ─────────────────────────────────────────

  /// Data do produto mais recente no ERDDAP — da memória persistida se foi
  /// verificada há menos de [intervaloVerificacaoProduto]; senão, pergunta
  /// ao ERDDAP só pelo eixo de tempo (resposta de poucos bytes). `null`
  /// quando não deu pra saber agora.
  Future<String?> _produtoMaisRecente() async {
    final agora = _agora().toUtc();
    final registro = await _lerProduto();
    if (registro != null) {
      final idade = agora.difference(registro.verificadoEm);
      // Idade negativa além da tolerância = relógio do aparelho voltou no
      // tempo; não dá pra confiar no registro, verifica de novo.
      if (idade >= -_toleranciaRelogio && idade < intervaloVerificacaoProduto) {
        return registro.data;
      }
    }

    final falha = _ultimaFalhaVerificacao;
    if (falha != null && agora.difference(falha).abs() < esperaAposFalhaVerificacao) {
      return null;
    }

    try {
      final data = await (_verificacaoEmAndamento ??=
          _consultarDataProduto().whenComplete(() {
        _verificacaoEmAndamento = null;
      }));
      await _registrarProduto(data);
      return data;
    } catch (e) {
      _ultimaFalhaVerificacao = agora;
      _log('não foi possível consultar o produto mais recente (${_resumo(e)})');
      return null;
    }
  }

  Future<String> _consultarDataProduto() async {
    final response =
        await _get(Uri.parse('$_baseUrl?time%5B(last)%5D'), _timeoutDataProduto);
    if (response.statusCode != 200) {
      throw Exception('ERDDAP respondeu ${response.statusCode}');
    }
    return dataDoProduto(parseRespostaDataProduto(response.body));
  }

  /// Resposta CSV do eixo de tempo: linha 0 = `time`, linha 1 = `UTC`,
  /// linha 2 = o instante do produto mais recente.
  static DateTime parseRespostaDataProduto(String corpo) {
    final linhas = const LineSplitter().convert(corpo);
    if (linhas.length < 3) {
      throw FormatException('Resposta inesperada do ERDDAP (tempo): $corpo');
    }
    return DateTime.parse(linhas[2].trim());
  }

  Future<({String data, DateTime verificadoEm})?> _lerProduto() async {
    try {
      final bruto = await _cache.ler(_chaveProduto);
      if (bruto == null) return null;
      final json = jsonDecode(bruto) as Map<String, dynamic>;
      return (
        data: json['data'] as String,
        verificadoEm: DateTime.parse(json['verificadoEm'] as String).toUtc(),
      );
    } catch (e) {
      _log('registro do produto mais recente ilegível (${_resumo(e)})');
      return null;
    }
  }

  Future<void> _registrarProduto(String data) async {
    try {
      await _cache.salvar(
        _chaveProduto,
        jsonEncode({
          'data': data,
          'verificadoEm': _agora().toUtc().toIso8601String(),
        }),
      );
    } catch (e) {
      _log('falha ao salvar o produto mais recente (${_resumo(e)})');
    }
  }

  // ── Entradas por célula ─────────────────────────────────────────────────

  Future<({String produto, LeituraClorofilaPonto leitura})?> _lerEntrada(
      String chave) async {
    try {
      final bruto = await _cache.ler(chave);
      if (bruto == null) return null;
      final json = jsonDecode(bruto) as Map<String, dynamic>;
      return (
        produto: json['produto'] as String,
        leitura: LeituraClorofilaPonto(
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
          valorMgM3: (json['valor'] as num?)?.toDouble(),
          data: DateTime.parse(json['data'] as String).toUtc(),
          source: json['source'] as String,
          aproximado: json['aproximado'] as bool,
        ),
      );
    } catch (e) {
      // Entrada corrompida ou armazenamento indisponível: trata como se não
      // houvesse cache (busca na rede), sem derrubar a tela.
      _log('cache de clorofila ilegível para $chave (${_resumo(e)})');
      return null;
    }
  }

  Future<void> _salvarEntrada(
      String chave, String produto, LeituraClorofilaPonto leitura) async {
    try {
      await _cache.salvar(
        chave,
        jsonEncode({
          'produto': produto,
          'latitude': leitura.latitude,
          'longitude': leitura.longitude,
          'valor': leitura.valorMgM3,
          'data': leitura.data.toUtc().toIso8601String(),
          'source': leitura.source,
          'aproximado': leitura.aproximado,
          'obtidoEm': _agora().toUtc().toIso8601String(),
        }),
      );
    } catch (e) {
      // Falha ao gravar não invalida o resultado já obtido — só não fica
      // pra próxima vez.
      _log('falha ao salvar clorofila no cache (${_resumo(e)})');
    }
  }

  static void _log(String mensagem) => debugPrint('[Clorofila] $mensagem');

  static String _resumo(Object e) {
    final texto = '$e'.replaceAll('\n', ' ');
    return texto.length > 160 ? '${texto.substring(0, 160)}…' : texto;
  }

  /// Parsing separado do fetch só pra dar pra testar sem rede — resposta
  /// CSV do ERDDAP: linha 0 = nomes das colunas, linha 1 = unidades, linha
  /// 2 = dado. Colunas: time, altitude, latitude, longitude, chlor_a.
  static LeituraClorofilaPonto parseRespostaCsv(String corpo) {
    final linhas = const LineSplitter().convert(corpo);
    if (linhas.length < 3) {
      throw FormatException('Resposta inesperada do ERDDAP (clorofila): $corpo');
    }
    final campos = linhas[2].split(',');
    if (campos.length < 5) {
      throw FormatException('Linha de dado incompleta do ERDDAP: ${linhas[2]}');
    }

    final valorBruto = campos[4].trim();
    // "NaN" é o próprio ERDDAP dizendo "sem dado válido pra esse pixel" —
    // nunca convertido pra 0 nem qualquer outro número (ver doc do campo
    // em LeituraClorofilaPonto).
    final valor =
        valorBruto.toUpperCase() == 'NAN' ? null : double.tryParse(valorBruto);

    return LeituraClorofilaPonto(
      latitude: double.parse(campos[2]),
      longitude: double.parse(campos[3]),
      valorMgM3: valor,
      data: DateTime.parse(campos[0]),
    );
  }

  /// Mesmo formato de [parseRespostaCsv], mas devolve um ponto por linha de
  /// dado (linhas 2 em diante) em vez de assumir uma única — usado por
  /// [buscarGrade]. Best-effort: pula silenciosamente uma linha malformada
  /// em vez de derrubar a grade inteira por causa de uma célula ruim.
  static List<LeituraClorofilaPonto> parseRespostaCsvGrade(String corpo) {
    final linhas = const LineSplitter().convert(corpo);
    if (linhas.length < 3) {
      throw FormatException('Resposta inesperada do ERDDAP (clorofila): $corpo');
    }

    final pontos = <LeituraClorofilaPonto>[];
    for (var i = 2; i < linhas.length; i++) {
      final campos = linhas[i].split(',');
      if (campos.length < 5) continue;

      final valorBruto = campos[4].trim();
      final valor =
          valorBruto.toUpperCase() == 'NAN' ? null : double.tryParse(valorBruto);
      final lat = double.tryParse(campos[2]);
      final lon = double.tryParse(campos[3]);
      final data = DateTime.tryParse(campos[0]);
      if (lat == null || lon == null || data == null) continue;

      pontos.add(LeituraClorofilaPonto(
        latitude: lat,
        longitude: lon,
        valorMgM3: valor,
        data: data,
      ));
    }
    return pontos;
  }
}
