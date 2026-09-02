/// Dados de uma captura a enviar para a API
/// (`POST base/resultado/capturas` — ver [ProducaoRepository]).
///
/// O corpo aceito pelo backend é bem mais simples que o registro local
/// ([ProducaoRegistro]): não existe conceito de tipo/classificação de
/// peixe, dispositivo, ou coordenada — só `viagemId` (remoto),
/// `especieId` (do catálogo), peso total e quantidade de animais. Quem
/// resolve esses dois IDs a partir do registro local é
/// [ProducaoReporterService], não este modelo.
class ProducaoEnvio {
  final String viagemId;
  final String especieId;
  final double pesoKg;
  final int quantidade;
  final DateTime instante;

  const ProducaoEnvio({
    required this.viagemId,
    required this.especieId,
    required this.pesoKg,
    required this.quantidade,
    required this.instante,
  });
}
