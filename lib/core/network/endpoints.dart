/// Paths dos recursos da API relacionados ao usuário logado.
///
/// Recursos em `base/estrutura` exigem o header `x-organization-id`
/// (adicionado automaticamente por [ApiService] a partir do que foi salvo
/// no login) além do Bearer token.
class Endpoints {
  static String dispositivoPorIdentificador(String identificador) =>
      'base/estrutura/dispositivos/identificador/$identificador';

  static const recomendacoes = 'base/inteligencia/recomendacoes';

  static String recomendacaoPorId(String id) =>
      'base/inteligencia/recomendacoes/$id';

  /// Usado por [LocalizacaoReporterService] para o envio periódico
  /// (a cada 30 min) da localização do dispositivo.
  static const localizacaoDispositivo = 'base/navegacao/posicionamento/salva';
}
