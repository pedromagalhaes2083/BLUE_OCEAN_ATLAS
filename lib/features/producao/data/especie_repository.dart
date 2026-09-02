import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/especie_remota.dart';

/// Único lugar que conhece a rota `base/resultado/especies` — lista o
/// catálogo de espécies já cadastradas na plataforma online. O app nunca
/// cria espécie nenhuma aqui: quem cadastra é a plataforma (mesmo padrão
/// de `EmbarcacaoRepository`).
class EspecieRepository {
  Future<List<EspecieRemota>> listar({String? nome}) async {
    final query = {
      'pagina': '1',
      'linhas': '100',
      'salto': '0',
      if (nome != null && nome.trim().isNotEmpty) 'nome': nome.trim(),
    };
    final rota =
        '${Endpoints.especiesIndice}?${Uri(queryParameters: query).query}';
    final json = await ApiService.get(rota) as Map<String, dynamic>;
    final linhas = json['linhas'] as List? ?? [];
    return linhas
        .map((e) => EspecieRemota.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
