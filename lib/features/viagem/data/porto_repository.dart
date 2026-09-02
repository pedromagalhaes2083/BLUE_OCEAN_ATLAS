import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/porto.dart';

/// Único lugar que conhece a rota/formato de `base/operacao/portos` —
/// listar (autocomplete de origem/destino de viagem) e criar quando o
/// porto que o mestre precisa ainda não está cadastrado.
class PortoRepository {
  Future<List<Porto>> listar({String? nome, String? codigo}) async {
    final query = {
      'pagina': '1',
      'linhas': '100',
      'salto': '0',
      if (nome != null && nome.trim().isNotEmpty) 'nome': nome.trim(),
      if (codigo != null && codigo.trim().isNotEmpty) 'codigo': codigo.trim(),
    };
    final rota =
        '${Endpoints.portosIndice}?${Uri(queryParameters: query).query}';
    final json = await ApiService.get(rota) as Map<String, dynamic>;
    final linhas = json['linhas'] as List? ?? [];
    return linhas
        .map((e) => Porto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cria um porto novo — antes, busca por código (mais confiável, tipo
  /// UN/LOCODE) e por nome, pra não duplicar um que já existe: o backend
  /// não garante unicidade sozinho, e o filtro de busca é por substring
  /// (`nome=Santos` também acha "Porto de Santos"), então a comparação
  /// final é sempre por igualdade exata (sem diferenciar maiúsculas),
  /// não pelo resultado bruto da busca.
  Future<Porto> criarOuReaproveitar({
    required String nome,
    String? codigo,
    String? sigla,
    String? pais,
    required double latitude,
    required double longitude,
    String? observacoes,
  }) async {
    final existentes = await listar(nome: nome, codigo: codigo);
    final nomeNormalizado = nome.trim().toLowerCase();
    final codigoNormalizado = codigo?.trim().toUpperCase();
    for (final p in existentes) {
      final mesmoNome = p.nome.trim().toLowerCase() == nomeNormalizado;
      final mesmoCodigo = codigoNormalizado != null &&
          codigoNormalizado.isNotEmpty &&
          p.codigo?.trim().toUpperCase() == codigoNormalizado;
      if (mesmoNome || mesmoCodigo) return p;
    }

    // Sem `id` no corpo: o backend documenta esse campo como "omitido para
    // criação" e rejeita (404) quando um é enviado — confirmado em 2026-09
    // (mesmo comportamento em `ViagemRepository`). O id de verdade vem na
    // resposta.
    final corpo = {
      'nome': nome.trim(),
      'codigo': codigo?.trim(),
      'sigla': sigla?.trim(),
      'pais': pais?.trim(),
      'status': 1,
      'observacoes': observacoes,
      'latitude': latitude,
      'longitude': longitude,
      'coordenadas': _coordenadasCompactas(latitude, longitude),
    };
    final resposta =
        await ApiService.post(Endpoints.portos, corpo) as Map<String, dynamic>;
    return Porto.fromJson(resposta);
  }

  /// DMS compacto, sem espaços (`23°57'39"S 46°19'59"W`) — formato que a
  /// API espera nesse campo, só um texto solto pra exibição, não usado de
  /// volta pelo app (as coordenadas de verdade são `latitude`/`longitude`).
  String _coordenadasCompactas(double lat, double lon) {
    String parte(double valor, bool isLat) {
      final dir = isLat
          ? (valor >= 0 ? 'N' : 'S')
          : (valor >= 0 ? 'E' : 'W');
      final abs = valor.abs();
      final graus = abs.floor();
      final minDecimal = (abs - graus) * 60;
      final min = minDecimal.floor();
      final seg = ((minDecimal - min) * 60).round();
      return '$graus°$min\'$seg"$dir';
    }

    return '${parte(lat, true)} ${parte(lon, false)}';
  }
}
