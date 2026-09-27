import 'grupo_permissao.dart';

/// Permissões específicas (nível 2) — cada valor é UMA funcionalidade
/// dentro de um [GrupoPermissao] já liberado (ver
/// `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md` §3.0). Um recurso nunca
/// libera nada sozinho se o grupo pai estiver bloqueado — ver
/// `PlanoService.possui`.
enum RecursoAtlas {
  // ── oceanografia ──────────────────────────────────────────────────────
  mapaSst(GrupoPermissao.oceanografia),
  oceanografiaCorrentes(GrupoPermissao.oceanografia),
  oceanografiaAlertasAvancados(GrupoPermissao.oceanografia),
  oceanografiaConfigurarAlertas(GrupoPermissao.oceanografia),

  // ── inteligencia ──────────────────────────────────────────────────────
  mapaClorofila(GrupoPermissao.inteligencia),
  mapaIndiceProdutividade(GrupoPermissao.inteligencia),
  oceanografiaMareEPescaAtum(GrupoPermissao.inteligencia),
  oceanografiaTermoclina(GrupoPermissao.inteligencia),
  intelligenceOceanica(GrupoPermissao.inteligencia),
  rotasAnaliseRota(GrupoPermissao.inteligencia),
  recomendacaoScoreEConfianca(GrupoPermissao.inteligencia),

  // ── rastreamento ──────────────────────────────────────────────────────
  mapaTrilhaViagem(GrupoPermissao.rastreamento),

  // ── producao ──────────────────────────────────────────────────────────
  producaoHistorico(GrupoPermissao.producao),
  producaoPorPonto(GrupoPermissao.producao),

  // ── rotas ─────────────────────────────────────────────────────────────
  rotasHistorico(GrupoPermissao.rotas),
  rotasInteligente(GrupoPermissao.rotas),

  // ── operacao ──────────────────────────────────────────────────────────
  viagemTripulacao(GrupoPermissao.operacao);

  /// O grupo amplo que precisa estar liberado pra esse recurso fazer
  /// sentido (ver [GrupoPermissao]).
  final GrupoPermissao grupo;

  const RecursoAtlas(this.grupo);
}
