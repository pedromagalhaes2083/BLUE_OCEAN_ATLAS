import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/localizacao_envio.dart';

/// Única classe que conhece a rota e o formato exato de corpo esperados
/// pela API para envio de localização. Quando o backend mudar, é aqui
/// (e só aqui) que o ajuste entra.
class LocalizacaoRepository {
  Future<void> enviar(LocalizacaoEnvio dados) async {
    await ApiService.post(Endpoints.localizacaoDispositivo, {
      'embarcacaoId': dados.embarcacaoId,
      'dispositivoId': dados.dispositivoId,
      'instante': dados.instante.toIso8601String(),
      'latitude': dados.latitude,
      'longitude': dados.longitude,
      if (dados.precisaoMetros != null) 'precisaoMetros': dados.precisaoMetros,
      if (dados.altitude != null) 'altitude': dados.altitude,
      if (dados.velocidadeNos != null) 'velocidade': dados.velocidadeNos,
      if (dados.direcao != null) 'direcao': dados.direcao,
      if (dados.bateriaNivel != null) 'bateriaNivel': dados.bateriaNivel,
      'gpsStatus': dados.gpsStatus,
      'origem': dados.origem,
    });
  }
}
