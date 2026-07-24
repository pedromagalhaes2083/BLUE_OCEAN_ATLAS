import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/localizacao_envio.dart';

/// Única classe que conhece a rota e o formato exato de corpo esperados
/// pela API para envio de localização. Quando o backend mudar, é aqui
/// (e só aqui) que o ajuste entra.
class LocalizacaoRepository {
  Future<void> enviar(LocalizacaoEnvio dados) async {
    await ApiService.post(Endpoints.localizacaoDispositivo, {
      'dispositivoIdentificador': dados.dispositivoIdentificador,
      'latitude': dados.latitude,
      'longitude': dados.longitude,
      'precisao': dados.precisao,
      'capturadoEm': dados.capturadoEm.toIso8601String(),
    });
  }
}
