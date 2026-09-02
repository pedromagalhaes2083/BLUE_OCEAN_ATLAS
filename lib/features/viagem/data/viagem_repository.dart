import '../../../core/network/api_service.dart';
import '../../../core/network/endpoints.dart';

/// Único lugar que conhece a rota/formato de `POST base/operacao/viagens`
/// — cria a viagem no backend depois que ela já foi salva localmente
/// (a viagem local sempre existe e sempre funciona sem rede; o registro
/// remoto é melhor-esforço, best-effort, igual à sincronização de
/// localização/dispositivo).
///
/// Tripulantes não são configurados pelo app (sempre enviado vazio); a
/// entidade não existe no app hoje.
class ViagemRepository {
  /// Retorna o ID que o backend gerou pra viagem criada — quem chama deve
  /// guardá-lo junto do registro local (`viagem.remoto_id`) pra poder
  /// referenciar essa viagem em chamadas futuras, como
  /// `POST base/resultado/capturas` (ver [ProducaoReporterService]).
  ///
  /// Não manda `id` no corpo: o backend documenta esse campo como
  /// "omitido para criação" e, na prática, rejeita a chamada (404) se um
  /// id for enviado — confirmado em 2026-09 tanto aqui quanto em
  /// `PortoRepository`. O id de verdade vem de volta na resposta.
  Future<String> criar({
    required String embarcacaoId,
    required String portoOrigemId,
    String? portoDestinoId,
    required DateTime inicioPrevisto,
    DateTime? fimPrevisto,
    double? latitudeInicial,
    double? longitudeInicial,
    String? dispositivoId,
  }) async {
    final corpo = {
      'embarcacaoId': embarcacaoId,
      'portoOrigemId': portoOrigemId,
      'portoDestinoId': portoDestinoId,
      'inicioPrevisto': inicioPrevisto.toUtc().toIso8601String(),
      'fimPrevisto': fimPrevisto?.toUtc().toIso8601String(),
      if (latitudeInicial != null && longitudeInicial != null)
        'posicaoInicial': {
          'latitude': latitudeInicial,
          'longitude': longitudeInicial,
        },
      'dispositivos': dispositivoId != null
          ? [
              {'dispositivoId': dispositivoId}
            ]
          : <Map<String, String>>[],
      'tripulantes': <Map<String, String>>[],
      'status': 1,
    };
    final resposta = await ApiService.post(Endpoints.viagens, corpo)
        as Map<String, dynamic>;
    return resposta['id'] as String;
  }
}
