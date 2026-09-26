/// Os planos comerciais do Blue Ocean Atlas (ver
/// `docs/Plano_Comercial_Blue_Ocean_Atlas.docx` e
/// `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md`) — cada embarcação ativa
/// assina um destes.
///
/// **Fleet** não tem superfície própria no app mobile hoje (dashboard de
/// frota/gestão de usuários ficam na plataforma web) — no mobile, herda
/// tudo que o Offshore libera (ver `matrizEntitlements`).
enum PlanoAtlas {
  start(
    nomeComercial: 'Atlas Start',
    precoReferencia: 49.90,
    descricaoCurta: 'Pescador / operação pequena — digitalizar navegação e registros',
  ),
  pro(
    nomeComercial: 'Atlas Pro',
    precoReferencia: 99.90,
    descricaoCurta: 'Pesca profissional — navegação + oceanografia + inteligência histórica',
  ),
  offshore(
    nomeComercial: 'Atlas Offshore',
    precoReferencia: 199.90,
    descricaoCurta: 'Pesca comercial/offshore — inteligência operacional avançada',
  ),
  fleet(
    nomeComercial: 'Atlas Fleet',
    precoReferencia: 499.00,
    descricaoCurta: 'Armadores / empresas — gestão e monitoramento de frota (sob consulta)',
  );

  final String nomeComercial;
  final double precoReferencia;
  final String descricaoCurta;

  const PlanoAtlas({
    required this.nomeComercial,
    required this.precoReferencia,
    required this.descricaoCurta,
  });
}
