import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/recomendacao.dart';

class RecomendacaoRepository {
  Future<List<Recomendacao>> listar() async {
    final json = await ApiService.get(Endpoints.recomendacoes);
    final lista = (json as Map<String, dynamic>)['recomendacoes'] as List? ?? [];
    return lista
        .map((e) => Recomendacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Recomendacao> buscarPorId(String id) async {
    final json = await ApiService.get(Endpoints.recomendacaoPorId(id));
    return Recomendacao.fromJson(
      (json as Map<String, dynamic>)['recomendacao'] as Map<String, dynamic>,
    );
  }
}
