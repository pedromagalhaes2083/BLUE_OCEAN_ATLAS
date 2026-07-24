/// Dados de localização a enviar para a API.
///
/// Este é o contrato estável consumido pelo restante do app — se a rota,
/// os nomes de campo ou o formato do corpo da requisição mudarem no
/// backend, só [LocalizacaoRepository] precisa mudar; este modelo e quem
/// o utiliza permanecem os mesmos.
class LocalizacaoEnvio {
  final String dispositivoIdentificador;
  final double latitude;
  final double longitude;
  final double precisao;
  final DateTime capturadoEm;

  const LocalizacaoEnvio({
    required this.dispositivoIdentificador,
    required this.latitude,
    required this.longitude,
    required this.precisao,
    required this.capturadoEm,
  });
}
