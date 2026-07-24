import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/dispositivo.dart';

/// Única classe que conhece a rota/formato da API para dados de
/// dispositivo. Se o backend mudar, o ajuste fica isolado aqui — o modelo
/// [Dispositivo] e quem o consome não precisam mudar.
class DispositivoRepository {
  /// Busca o registro do dispositivo atual no backend pelo identificador
  /// local (ver `DeviceIdService.obtemId`).
  Future<Dispositivo> buscarPorIdentificador(String identificador) async {
    final json = await ApiService.get(
      Endpoints.dispositivoPorIdentificador(identificador),
    );
    return Dispositivo.fromJson(json as Map<String, dynamic>);
  }
}
