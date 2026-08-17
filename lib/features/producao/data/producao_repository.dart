import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/producao_envio.dart';

/// Única classe que conhece a rota e o formato exato de corpo esperados
/// pela API para envio de produção. Quando o backend definir o endpoint de
/// verdade (ver `Endpoints.producaoRegistro`), só este arquivo — e o path
/// em `Endpoints` — devem precisar mudar.
class ProducaoRepository {
  Future<void> enviar(ProducaoEnvio dados) async {
    await ApiService.post(Endpoints.producaoRegistro, {
      'embarcacaoId': dados.embarcacaoId,
      'dispositivoId': dados.dispositivoId,
      'instante': dados.instante.toIso8601String(),
      'tipoPeixe': dados.tipoPeixe.name,
      'classificacao': dados.classificacao.name,
      'quantidadeUnidades': dados.quantidadeUnidades,
      'pesoMedioUnitario': dados.pesoMedioUnitario,
      'quantidadeKg': dados.quantidadeKg,
      if (dados.latitude != null) 'latitude': dados.latitude,
      if (dados.longitude != null) 'longitude': dados.longitude,
      if (dados.precisaoMetros != null)
        'precisaoMetros': dados.precisaoMetros,
      if (dados.viagemId != null) 'viagemId': dados.viagemId,
      if (dados.observacao != null) 'observacao': dados.observacao,
    });
  }
}
