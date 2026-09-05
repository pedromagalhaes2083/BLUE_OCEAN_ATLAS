/// Paths dos recursos da API relacionados ao usuário logado.
///
/// Recursos em `base/estrutura` exigem o header `x-organization-id`
/// (adicionado automaticamente por [ApiService] a partir do que foi salvo
/// no login) além do Bearer token.
class Endpoints {
  /// Organizações que o usuário logado participa — usado logo após o
  /// login pra escolher qual organização fica ativa (ver
  /// [AuthService.listarMinhasOrganizacoes]), já que um usuário pode
  /// participar de mais de uma.
  static const euOrganizacoes = 'autenticacao/eu/organizacoes';

  static String dispositivoPorIdentificador(String identificador) =>
      'base/estrutura/dispositivos/identificador/$identificador';

  static const recomendacoes = 'base/inteligencia/recomendacoes';

  static String recomendacaoPorId(String id) =>
      'base/inteligencia/recomendacoes/$id';

  /// Usado por [LocalizacaoReporterService] para o envio periódico
  /// (a cada 30 min) da localização do dispositivo.
  static const localizacaoDispositivo = 'base/navegacao/posicionamento/salva';

  static const portosIndice = 'base/operacao/portos/indice';
  static const portos = 'base/operacao/portos';
  static const viagens = 'base/operacao/viagens';

  /// Viagem ativa do usuário logado — base do fluxo login → viagem ativa
  /// → embarcação dela (ver [ViagemRepository.buscarAtual]). Retornava
  /// 422/QueryFailedError do backend nos primeiros testes em 2026-09;
  /// corrigido no backend no mesmo mês — confirmado com curl real (HTTP
  /// 200, corpo `{"viagem": {...}}`, ver [ViagemAtualRemota]).
  static const viagemAtual = 'base/operacao/viagens/eu/atual';

  /// Catálogo de embarcações cadastradas na plataforma online — o app só
  /// lista pra escolha (ver [EmbarcacaoRepository]), nunca cria.
  static const embarcacoesIndice = 'base/operacao/embarcacoes/indice';

  /// Embarcação de um id específico — usado por [EmbarcacaoRepository.buscarPorId]
  /// pra resolver a embarcação da viagem ativa (ver [ContextoViagemService]),
  /// já que o fluxo login → viagem ativa fornece só o `embarcacaoId`, não o
  /// objeto inteiro. Confirmado em 2026-09 (curl com token real, HTTP 200).
  static String embarcacaoPorId(String id) => 'base/operacao/embarcacoes/$id';

  /// Catálogo de espécies cadastradas na plataforma online — mesmo padrão
  /// de [embarcacoesIndice], só listagem pra escolha.
  static const especiesIndice = 'base/resultado/especies/indice';

  /// Capturas de produção (confirmado no backend em 2026-08) — ver
  /// [ProducaoRepository].
  static const capturas = 'base/resultado/capturas';
}
