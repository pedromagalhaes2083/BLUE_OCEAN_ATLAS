/// Grupos amplos de permissão (nível 1) — cada um libera um módulo
/// inteiro do app. Decidido em `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md`
/// §3.0; a granularidade fina dentro de um grupo já liberado é
/// [RecursoAtlas] (nível 2).
enum GrupoPermissao {
  /// GPS, mapa base, marcar ponto, planejar rota manual — nunca bloqueado
  /// por plano (navegação essencial, ver regra 5 do pedido original).
  navegacaoEssencial,

  /// Cartas náuticas, solicitações de carta.
  cartas,

  /// Meteorologia, maré, profundidade, correntes.
  oceanografia,

  /// Registro de captura, histórico de produção.
  producao,

  /// Minhas Rotas (manual, +histórico, +inteligente).
  rotas,

  /// GPS em segundo plano, trilha da viagem no mapa.
  rastreamento,

  /// Recomendações, índice de produtividade, maré e pesca de atum,
  /// análise de rota.
  inteligencia,

  /// Gestão de viagem/tripulação.
  operacao,

  /// Dashboard web, multi-embarcação — sem superfície no mobile hoje, só
  /// documentado (ver tela Planos).
  frota,
}
