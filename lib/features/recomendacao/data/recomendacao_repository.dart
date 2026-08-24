import 'dart:convert';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/recomendacao.dart';

/// Única classe que conhece a rota/formato da API para recomendações. Se
/// o backend mudar, o ajuste fica isolado aqui — o modelo [Recomendacao]
/// e quem o consome não precisam mudar.
class RecomendacaoRepository {
  /// Se a última chamada de [listar] veio da rede (`false`) ou do cache
  /// local por falta de conexão (`true`) — checar logo depois de chamar
  /// `listar()` na mesma instância, pra decidir se mostra um aviso de
  /// "dados desatualizados" na tela.
  bool ultimoResultadoOffline = false;

  /// Quando o cache foi salvo (data da última sincronização bem-sucedida)
  /// — só relevante quando [ultimoResultadoOffline] é `true`.
  DateTime? ultimaAtualizacaoCache;

  /// Busca as recomendações do backend e, se conseguir, atualiza o cache
  /// local (última lista completa, com timestamp) — se a chamada falhar
  /// (sem rede, no mar), cai pro cache em vez de propagar o erro, então a
  /// tela sempre tem algo pra mostrar depois da 1ª sincronização
  /// bem-sucedida. Só propaga o erro se nem a rede nem o cache tiverem
  /// nada (1ª tentativa, sem conexão nenhuma ainda).
  Future<List<Recomendacao>> listar() async {
    try {
      final json = await ApiService.get(Endpoints.recomendacoes);
      final lista = (json as Map<String, dynamic>)['recomendacoes'] as List? ?? [];
      await _salvarCache(lista);
      ultimoResultadoOffline = false;
      return lista
          .map((e) => Recomendacao.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      final doCache = await _lerCache();
      if (doCache == null) rethrow;
      ultimoResultadoOffline = true;
      return doCache;
    }
  }

  Future<Recomendacao> buscarPorId(String id) async {
    final json = await ApiService.get(Endpoints.recomendacaoPorId(id));
    return Recomendacao.fromJson(
      (json as Map<String, dynamic>)['recomendacao'] as Map<String, dynamic>,
    );
  }

  Future<void> _salvarCache(List<dynamic> listaBruta) async {
    await Config.grava(Constantes.cacheRecomendacoes, jsonEncode(listaBruta));
    await Config.grava(
        Constantes.cacheRecomendacoesEm, DateTime.now().toIso8601String());
  }

  Future<List<Recomendacao>?> _lerCache() async {
    final bruto = await Config.obtem(Constantes.cacheRecomendacoes);
    if (bruto.isEmpty) return null;

    final emStr = await Config.obtem(Constantes.cacheRecomendacoesEm);
    ultimaAtualizacaoCache = DateTime.tryParse(emStr);

    try {
      final lista = jsonDecode(bruto) as List;
      return lista
          .map((e) => Recomendacao.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
