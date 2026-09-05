import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/embarcacao_remota.dart';

/// Único lugar que conhece a rota `base/operacao/embarcacoes` — lista o
/// catálogo de embarcações já cadastradas na plataforma online (ver
/// [EmbarcacaoRemota]). O app nunca cria embarcação nenhuma aqui: quem
/// cadastra é a plataforma, o mestre só escolhe qual delas é a dele.
class EmbarcacaoRepository {
  Future<List<EmbarcacaoRemota>> listar({String? nome}) async {
    final query = {
      'pagina': '1',
      'linhas': '100',
      'salto': '0',
      if (nome != null && nome.trim().isNotEmpty) 'nome': nome.trim(),
    };
    final rota =
        '${Endpoints.embarcacoesIndice}?${Uri(queryParameters: query).query}';
    final json = await ApiService.get(rota) as Map<String, dynamic>;
    final linhas = json['linhas'] as List? ?? [];
    return linhas
        .map((e) => EmbarcacaoRemota.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Embarcação de um id específico — usado pra resolver a embarcação da
  /// viagem ativa (ver `ContextoViagemService`), já que o fluxo
  /// login → viagem ativa fornece só o `embarcacaoId`, não o objeto
  /// inteiro. Confirmado em 2026-09 (curl com token real, HTTP 200).
  Future<EmbarcacaoRemota?> buscarPorId(String id) async {
    final json =
        await ApiService.get(Endpoints.embarcacaoPorId(id)) as Map<String, dynamic>;
    return EmbarcacaoRemota.fromJson(json);
  }
}
