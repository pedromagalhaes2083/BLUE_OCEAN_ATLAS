import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';
import '../domain/models/dispositivo.dart';

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
