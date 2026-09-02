/// Dados de localização a enviar para a API
/// (`POST base/navegacao/posicionamento/salva`).
///
/// Este é o contrato estável consumido pelo restante do app — se a rota,
/// os nomes de campo ou o formato do corpo da requisição mudarem no
/// backend, só [LocalizacaoRepository] precisa mudar; este modelo e quem
/// o utiliza permanecem os mesmos.
class LocalizacaoEnvio {
  final String embarcacaoId;
  final String dispositivoId;
  final DateTime instante;
  final double latitude;
  final double longitude;

  /// Precisão do sinal GPS em metros — nulo quando desconhecida (nunca
  /// convertido pra `0`, que significaria precisão perfeita, um valor real
  /// diferente de "não sei").
  final double? precisaoMetros;
  final double? altitude;
  final double? velocidadeNos;
  final int? direcao;
  final int? bateriaNivel;

  /// Status do GPS no momento da captura (enum do backend, ainda não
  /// documentado — fixo em 1 por enquanto).
  final int gpsStatus;

  /// Origem da captura (enum do backend, ainda não documentado — fixo em
  /// 1, correspondente ao envio periódico automático).
  final int origem;

  const LocalizacaoEnvio({
    required this.embarcacaoId,
    required this.dispositivoId,
    required this.instante,
    required this.latitude,
    required this.longitude,
    required this.precisaoMetros,
    this.altitude,
    this.velocidadeNos,
    this.direcao,
    this.bateriaNivel,
    this.gpsStatus = 1,
    this.origem = 1,
  });
}
