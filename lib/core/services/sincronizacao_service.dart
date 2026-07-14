import '../../features/dispositivo/data/dispositivo_repository.dart';
import '../../features/dispositivo/domain/models/dispositivo.dart';
import '../../features/recomendacao/data/recomendacao_repository.dart';
import '../../features/recomendacao/domain/models/recomendacao.dart';
import 'device_id_service.dart';

class ResultadoSincronizacao {
  final Dispositivo dispositivo;
  final List<Recomendacao> recomendacoes;

  const ResultadoSincronizacao({
    required this.dispositivo,
    required this.recomendacoes,
  });
}

/// Orquestra a busca de dados do usuário logado logo após o login:
/// resolve o dispositivo atual (pelo identificador local persistente) e
/// busca as recomendações da organização.
class SincronizacaoService {
  static Future<ResultadoSincronizacao> sincronizar() async {
    final deviceId = await DeviceIdService.obtemId();
    final dispositivo =
        await DispositivoRepository().buscarPorIdentificador(deviceId);
    final recomendacoes = await RecomendacaoRepository().listar();

    return ResultadoSincronizacao(
      dispositivo: dispositivo,
      recomendacoes: recomendacoes,
    );
  }
}
