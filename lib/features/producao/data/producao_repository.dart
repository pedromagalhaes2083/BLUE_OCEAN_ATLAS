import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/producao_envio.dart';

/// Única classe que conhece a rota e o formato exato de corpo esperados
/// pela API para envio de captura (`POST base/resultado/capturas`).
class ProducaoRepository {
  Future<void> enviar(ProducaoEnvio dados) async {
    // Sem `id` no corpo: o backend documenta esse campo como "omitido para
    // criação" e rejeita quando um é enviado — mesmo comportamento
    // confirmado em `PortoRepository`/`ViagemRepository`.
    await ApiService.post(Endpoints.capturas, {
      'viagemId': dados.viagemId,
      'especieId': dados.especieId,
      'pesoKg': dados.pesoKg,
      'quantidade': dados.quantidade,
      'instante': dados.instante.toUtc().toIso8601String(),
    });
  }
}
