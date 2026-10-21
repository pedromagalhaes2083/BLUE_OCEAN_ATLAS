import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

/// Cache genérico "por ponto" pra respostas cruas de APIs externas de
/// meteorologia/mar (Open-Meteo, Open-Meteo Marine, OpenTopoData) — guarda
/// a última resposta bem-sucedida por tipo+coordenada arredondada, pra dar
/// alguma resiliência quando não há sinal no mar (decisão de 2026-09:
/// "cache local dos dados de meteorologia/maré por ponto" — hoje uma falha
/// de rede simplesmente deixa a tela sem dado nenhum).
///
/// Guarda a resposta crua (o corpo do JSON como veio da API), não o modelo
/// já parseado — quem chama decodifica com o mesmo `fromJson` que já usa
/// pra resposta de rede, sem precisar de `toJson`/`fromJson` extra nos
/// modelos nem duplicar lógica de parsing.
///
/// Coordenada arredondada a 2 casas decimais (~1,1 km no equador) — os
/// dados variam suavemente nessa escala, então uma consulta um pouco
/// deslocada da anterior (ex: embarcação se moveu um pouco) ainda
/// reaproveita o cache; não precisa ser um ponto exato.
///
/// Armazenado no SQLite (tabela `cache_dados`, ver `DatabaseHelper`), não
/// mais no Hive: a atualização em segundo plano (ver
/// `AtualizacaoPrevisoesService`) roda no isolate do serviço de
/// rastreamento, e o Hive não funciona entre isolates — o app aberto não
/// enxergaria o que o serviço gravou, e os dois gravando no mesmo arquivo
/// arriscavam corrompê-lo.
class DadosPontoCacheService {
  /// Limite de entradas guardadas — sem isso, cada ponto novo consultado
  /// (mapa, alerta de rota, condições do mar) cresceria a tabela pra
  /// sempre. 300 é generoso pra uma sessão de pesca (bem mais que os pontos
  /// que um mestre consultaria numa única viagem).
  static const _maxEntradas = 300;

  /// Prefixo de chaves de controle (não são cache de API) — ficam fora da
  /// poda por idade (ver [salvarMeta]).
  static const _prefixoMeta = 'meta:';

  static String _chave(String tipo, double latitude, double longitude) =>
      '$tipo:${latitude.toStringAsFixed(2)}:${longitude.toStringAsFixed(2)}';

  static Future<Database> get _db => DatabaseHelper.instance.database;

  /// Salva a resposta crua de uma consulta bem-sucedida. `tipo` distingue a
  /// origem (ex: `'onda'`, `'clima'`, `'profundidade'`) — o mesmo ponto pode
  /// ter uma entrada de cache por tipo.
  static Future<void> salvar({
    required String tipo,
    required double latitude,
    required double longitude,
    required String corpo,
  }) =>
      salvarPorChave(_chave(tipo, latitude, longitude), corpo);

  /// Lê a última resposta cacheada pra esse tipo+ponto, ou `null` se nunca
  /// foi salva (1ª consulta desse ponto sem nunca ter tido rede).
  static Future<({String corpo, DateTime em})?> ler({
    required String tipo,
    required double latitude,
    required double longitude,
  }) =>
      lerPorChave(_chave(tipo, latitude, longitude));

  /// Mesmo armazenamento de [salvar], com uma [chave] montada por quem
  /// chama — pra fontes cuja identidade não é "tipo + coordenada
  /// arredondada" (ex.: clorofila, que é por célula da grade do satélite e
  /// por data do produto, ver `ClorofilaRepository`). Entra na mesma poda
  /// por idade de [_maxEntradas].
  static Future<void> salvarPorChave(String chave, String corpo) async {
    final db = await _db;
    await db.insert(
      'cache_dados',
      {
        'chave': chave,
        'corpo': corpo,
        // UTC ISO-8601: ordenável como texto, pra poda por idade em SQL.
        'em': DateTime.now().toUtc().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (!chave.startsWith(_prefixoMeta)) await _podarSeNecessario(db);
  }

  /// Par de [salvarPorChave]. `null` se não existe ou não deu pra ler.
  static Future<({String corpo, DateTime em})?> lerPorChave(String chave) async {
    final db = await _db;
    final linhas = await db.query(
      'cache_dados',
      columns: ['corpo', 'em'],
      where: 'chave = ?',
      whereArgs: [chave],
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    try {
      return (
        corpo: linhas.first['corpo'] as String,
        em: DateTime.parse(linhas.first['em'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  /// Valor de controle (ex.: preferência ou marca de tempo da atualização
  /// em segundo plano) — no mesmo SQLite, pra ser visto pelo app e pelo
  /// serviço de rastreamento (isolates diferentes), e fora da poda do cache.
  static Future<void> salvarMeta(String nome, String valor) =>
      salvarPorChave('$_prefixoMeta$nome', valor);

  static Future<String?> lerMeta(String nome) async =>
      (await lerPorChave('$_prefixoMeta$nome'))?.corpo;

  /// Sem cache nenhum, espera a rede o mesmo que antes — é a única fonte.
  static const _timeoutSemCacheAtual = Duration(seconds: 15);

  /// Com algo salvo pra cair, desiste da rede bem antes: no mar, sem sinal,
  /// cada tela esperava 15–20 s de timeout antes de mostrar um dado que já
  /// estava no aparelho.
  static const timeoutComCache = Duration(seconds: 5);

  /// Cache primeiro. Se a última resposta deste tipo+ponto ainda vale
  /// ([aindaValido], que recebe quando foi salva), devolve na hora, sem
  /// rede. Senão busca com [daRede] (que recebe o timeout a usar e deve
  /// lançar em resposta inválida), salva e devolve. Se a rede falhar,
  /// devolve a resposta salva — desde que [serveOffline] aceite a idade
  /// dela — com `offlineDesde` = quando foi salva, pra tela avisar que está
  /// desatualizada. Sem nada salvo, o erro da rede segue pra quem chamou.
  ///
  /// [chave] substitui a chave padrão (tipo + coordenada com 2 casas,
  /// ~1,1 km) quando essa resolução é grossa demais pro dado (ex.:
  /// profundidade, que não vence e muda bastante em 1 km).
  /// [timeoutSemCache] é o timeout de quando não há nada salvo.
  ///
  /// [forcarAtualizacao]: vai à rede mesmo com o cache válido, com o
  /// timeout longo — usado pela atualização em segundo plano (ver
  /// `AtualizacaoPrevisoesService`), que não tem tela esperando. Se falhar,
  /// o cache existente fica como estava.
  static Future<({String corpo, DateTime? offlineDesde})> buscarComCache({
    required String tipo,
    required double latitude,
    required double longitude,
    required bool Function(DateTime salvoEm) aindaValido,
    required Future<String> Function(Duration timeout) daRede,
    bool Function(DateTime salvoEm)? serveOffline,
    String? chave,
    Duration timeoutSemCache = _timeoutSemCacheAtual,
    bool forcarAtualizacao = false,
  }) async {
    ({String corpo, DateTime em})? salvo;
    try {
      salvo = chave != null
          ? await lerPorChave(chave)
          : await ler(tipo: tipo, latitude: latitude, longitude: longitude);
    } catch (e) {
      debugPrint('Cache $tipo ilegível — buscando na rede: $e');
    }

    if (!forcarAtualizacao && salvo != null && aindaValido(salvo.em)) {
      return (corpo: salvo.corpo, offlineDesde: null);
    }

    final reserva = salvo != null && (serveOffline?.call(salvo.em) ?? true)
        ? salvo
        : null;
    try {
      final corpo = await daRede(reserva != null && !forcarAtualizacao
          ? timeoutComCache
          : timeoutSemCache);
      try {
        if (chave != null) {
          await salvarPorChave(chave, corpo);
        } else {
          await salvar(
              tipo: tipo, latitude: latitude, longitude: longitude, corpo: corpo);
        }
      } catch (e) {
        // Não conseguir salvar não invalida a resposta que já chegou.
        debugPrint('Falha ao salvar cache $tipo: $e');
      }
      return (corpo: corpo, offlineDesde: null);
    } catch (_) {
      if (reserva == null) rethrow;
      return (corpo: reserva.corpo, offlineDesde: reserva.em);
    }
  }

  /// Validade comum pro [buscarComCache]: salvo há menos de [idade]. Idade
  /// negativa (relógio do aparelho voltou no tempo) não conta como recente.
  static bool Function(DateTime salvoEm) maisRecenteQue(
    Duration idade, {
    @visibleForTesting DateTime Function()? relogio,
  }) =>
      (salvoEm) {
        final decorrido = (relogio ?? DateTime.now)().difference(salvoEm);
        return !decorrido.isNegative && decorrido < idade;
      };

  /// Remove as entradas de cache mais antigas acima de [_maxEntradas]
  /// (chaves de controle `meta:` ficam de fora).
  static Future<void> _podarSeNecessario(Database db) async {
    final total = Sqflite.firstIntValue(await db.rawQuery(
            "SELECT COUNT(*) FROM cache_dados WHERE chave NOT LIKE '$_prefixoMeta%'")) ??
        0;
    final excesso = total - _maxEntradas;
    if (excesso <= 0) return;
    await db.rawDelete(
      'DELETE FROM cache_dados WHERE chave IN ('
      "SELECT chave FROM cache_dados WHERE chave NOT LIKE '$_prefixoMeta%' "
      'ORDER BY em ASC LIMIT ?)',
      [excesso],
    );
  }

  /// Só pra teste — limpa a tabela entre um caso e outro.
  @visibleForTesting
  static Future<void> resetForTesting() async {
    final db = await _db;
    await db.delete('cache_dados');
  }
}
