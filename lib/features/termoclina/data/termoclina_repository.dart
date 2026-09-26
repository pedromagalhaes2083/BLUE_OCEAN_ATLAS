import '../domain/models/leitura_termoclina.dart';
import 'fonte_termoclina.dart';
import 'fonte_termoclina_estimada.dart';

/// Única classe que a tela (`TermoclinaScreen`) conhece pra buscar dados
/// de termoclina — mesmo papel de `WaveForecastRepository`/
/// `ClorofilaRepository` pras APIs externas já existentes: isola de onde
/// o dado realmente vem (hoje [FonteTermoclinaEstimada], que já usa SST
/// real da Open-Meteo Marine; futuramente uma fonte com perfil vertical
/// real, ver `fonte_termoclina.dart`).
///
/// Injeção simples via construtor (`fonte:`) — cobre tanto testes (ex:
/// `FonteTermoclinaMock`, sem rede) quanto a troca definitiva pra uma
/// fonte real (basta mudar o valor padrão abaixo, ou passar explicitamente
/// na tela) sem tocar em mais nada.
class TermoclinaRepository {
  final FonteTermoclina _fonte;

  TermoclinaRepository({FonteTermoclina? fonte})
      : _fonte = fonte ?? FonteTermoclinaEstimada();

  Future<LeituraTermoclina> buscar({
    required double latitude,
    required double longitude,
    DateTime? data,
  }) {
    return _fonte.buscar(latitude: latitude, longitude: longitude, data: data);
  }
}
