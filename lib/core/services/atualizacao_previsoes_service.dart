import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../features/mapa/data/clorofila_repository.dart';
import '../../features/metereologia/data/fase_lua_repository.dart';
import '../../features/metereologia/data/previsao_tempo_repository.dart';
import '../../features/metereologia/data/profundidade_repository.dart';
import '../../features/metereologia/data/wave_forecast_repository.dart';
import '../../features/termoclina/data/rfrom_ocean_repository.dart';
import '../database/database_helper.dart';
import 'dados_ponto_cache_service.dart';

/// Uma fonte de dados a atualizar pra posição da embarcação.
typedef FontePrevisao = Future<void> Function(double latitude, double longitude);

/// Atualiza em segundo plano o cache das previsões (ondas, tempo, lua e
/// sol, RFROM, clorofila, profundidade) pra última posição conhecida da
/// embarcação, no intervalo configurado ([opcoesMinutos]) — assim, quando o
/// mestre abre uma tela, o dado já está no aparelho e é recente, mesmo
/// que no momento não haja sinal.
///
/// Onde roda: no serviço de rastreamento (a cada rodada, ver
/// `LocationForegroundTaskHandler`) — ou seja, em segundo plano **durante
/// uma viagem**, mesmo com o app fechado — e na abertura do app. Fora de
/// uma viagem e com o app fechado não roda: o Android não mantém o app
/// executando sem um serviço em primeiro plano. A cadência real é a das
/// rodadas do rastreamento: com rastreamento a cada 15 min e atualização a
/// cada 30 min, atualiza a cada 30–45 min.
///
/// Intervalo e marcas de tempo ficam no SQLite (ver
/// [DadosPontoCacheService.salvarMeta]), visíveis tanto pro app quanto pro
/// serviço de rastreamento (isolates diferentes).
class AtualizacaoPrevisoesService {
  static const opcoesMinutos = [30, 60, 120, 180, 240];
  static const intervaloPadraoMinutos = 60;

  /// Depois de uma tentativa sem nenhuma fonte atualizada (sem rede), não
  /// tenta de novo antes disso — nem antes do intervalo, se for menor.
  static const esperaAposFalha = Duration(minutes: 15);

  static const _metaIntervalo = 'atualizacao_previsoes_intervalo_min';
  static const _metaUltimaAtualizacao = 'atualizacao_previsoes_ultima';
  static const _metaUltimaTentativa = 'atualizacao_previsoes_tentativa';

  static Future<bool>? _emAndamento;

  static Future<int> intervaloMinutos() async {
    final valor = int.tryParse(
        await DadosPontoCacheService.lerMeta(_metaIntervalo) ?? '');
    return valor != null && opcoesMinutos.contains(valor)
        ? valor
        : intervaloPadraoMinutos;
  }

  static Future<void> definirIntervaloMinutos(int minutos) async {
    if (!opcoesMinutos.contains(minutos)) {
      throw ArgumentError.value(minutos, 'minutos', 'fora das opções');
    }
    await DadosPontoCacheService.salvarMeta(_metaIntervalo, '$minutos');
  }

  /// Quando a última atualização trouxe ao menos uma fonte com sucesso.
  static Future<DateTime?> ultimaAtualizacao() async =>
      DateTime.tryParse(
          await DadosPontoCacheService.lerMeta(_metaUltimaAtualizacao) ?? '');

  /// Atualiza se já passou o intervalo desde a última atualização. Devolve
  /// se rodou. Nunca lança — roda dentro do serviço em segundo plano.
  /// Chamadas simultâneas nesta isolate compartilham a mesma execução.
  static Future<bool> atualizarSeNecessario({
    @visibleForTesting DateTime? agora,
    @visibleForTesting Map<String, FontePrevisao>? fontes,
  }) {
    return _emAndamento ??= _atualizar(
      agora: (agora ?? DateTime.now()).toUtc(),
      fontes: fontes ?? _fontesPadrao(),
    ).whenComplete(() {
      _emAndamento = null;
    });
  }

  static Future<bool> _atualizar({
    required DateTime agora,
    required Map<String, FontePrevisao> fontes,
  }) async {
    try {
      final intervalo = Duration(minutes: await intervaloMinutos());
      final ultima = await ultimaAtualizacao();
      if (ultima != null && _dentro(agora, ultima, intervalo)) return false;

      final tentativa = DateTime.tryParse(
          await DadosPontoCacheService.lerMeta(_metaUltimaTentativa) ?? '');
      final espera = Duration(
          minutes: math.min(esperaAposFalha.inMinutes, intervalo.inMinutes));
      if (tentativa != null &&
          (ultima == null || tentativa.isAfter(ultima)) &&
          _dentro(agora, tentativa, espera)) {
        return false;
      }

      final posicao = await _ultimaPosicaoValida();
      if (posicao == null) {
        _log('sem posição da embarcação ainda — atualização adiada');
        return false;
      }

      // Marca antes de buscar: o app e o serviço de rastreamento (isolates
      // diferentes) veem a marca no SQLite e não atualizam ao mesmo tempo.
      await DadosPontoCacheService.salvarMeta(
          _metaUltimaTentativa, agora.toIso8601String());

      final resultados = await Future.wait(fontes.entries.map((fonte) async {
        try {
          await fonte.value(posicao.latitude, posicao.longitude);
          return true;
        } catch (e) {
          _log('${fonte.key}: não atualizou (${_resumo(e)})');
          return false;
        }
      }));

      final atualizadas = resultados.where((ok) => ok).length;
      if (atualizadas > 0) {
        await DadosPontoCacheService.salvarMeta(
            _metaUltimaAtualizacao, agora.toIso8601String());
      }
      _log('$atualizadas/${fontes.length} fontes atualizadas '
          '(próxima em ${intervalo.inMinutes} min)');
      return true;
    } catch (e) {
      _log('falha na atualização das previsões (${_resumo(e)})');
      return false;
    }
  }

  /// [desde] foi há menos de [duracao] — um [desde] no futuro (relógio do
  /// aparelho voltou no tempo) não conta, pra não travar a atualização.
  static bool _dentro(DateTime agora, DateTime desde, Duration duracao) {
    final decorrido = agora.difference(desde);
    return !decorrido.isNegative && decorrido < duracao;
  }

  static Future<({double latitude, double longitude})?>
      _ultimaPosicaoValida() async {
    final db = await DatabaseHelper.instance.database;
    final linhas = await db.query(
      'localizacao_historico',
      columns: ['latitude', 'longitude'],
      where: 'validacao = ?',
      whereArgs: ['valida'],
      orderBy: 'data_hora DESC',
      limit: 1,
    );
    if (linhas.isEmpty) return null;
    return (
      latitude: (linhas.first['latitude'] as num).toDouble(),
      longitude: (linhas.first['longitude'] as num).toDouble(),
    );
  }

  /// Previsões que mudam vão à rede mesmo com cache válido
  /// (`forcarAtualizacao`); profundidade (fixa) e clorofila (produto diário,
  /// com validade própria) seguem as regras normais de cache — só buscam se
  /// ainda não tiverem o dado.
  ///
  /// Sem rede, os repositórios não lançam: devolvem o que já estava salvo,
  /// marcado offline. Isso não é uma atualização — por isso cada fonte
  /// confere a marca e falha nesse caso.
  static Map<String, FontePrevisao> _fontesPadrao() => {
        'ondas': (lat, lon) async {
          final repo = WaveForecastRepository();
          await repo.buscar(
              latitude: lat, longitude: lon, forcarAtualizacao: true);
          _exigirOnline(repo.ultimoResultadoOffline);
        },
        'tempo': (lat, lon) async {
          final repo = PrevisaoTempoRepository();
          await repo.buscar(
              latitude: lat, longitude: lon, forcarAtualizacao: true);
          _exigirOnline(repo.ultimoResultadoOffline);
        },
        'lua e sol': (lat, lon) async {
          final repo = FaseLuaRepository();
          await repo.buscar(
              latitude: lat, longitude: lon, forcarAtualizacao: true);
          _exigirOnline(repo.ultimoResultadoOffline);
        },
        'RFROM': (lat, lon) async {
          final repo = RfromOceanRepository();
          await repo.buscarPerfil(
              latitude: lat, longitude: lon, forcarAtualizacao: true);
          _exigirOnline(repo.ultimoResultadoOffline);
        },
        'profundidade': (lat, lon) =>
            ProfundidadeRepository().buscarPonto(latitude: lat, longitude: lon),
        'clorofila': (lat, lon) async {
          final leitura = await ClorofilaRepository()
              .buscarPontoOuAproximado(latitude: lat, longitude: lon);
          _exigirOnline(leitura.desatualizada);
        },
      };

  static void _exigirOnline(bool veioDoCachePorFaltaDeRede) {
    if (veioDoCachePorFaltaDeRede) {
      throw StateError('sem rede — mantido o dado já salvo');
    }
  }

  static void _log(String mensagem) => debugPrint('[Previsões] $mensagem');

  static String _resumo(Object e) {
    final texto = '$e'.replaceAll('\n', ' ');
    return texto.length > 160 ? '${texto.substring(0, 160)}…' : texto;
  }
}
