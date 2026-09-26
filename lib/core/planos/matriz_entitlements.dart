import 'grupo_permissao.dart';
import 'plano_atlas.dart';
import 'recurso_atlas.dart';

/// Fonte única de verdade de "quem libera o quê" — `PlanoService` só
/// consulta este arquivo, nunca decide sozinho.
///
/// ⚠️ **TEMPORÁRIO (2026-09-25): tudo liberado pra todos os planos.**
/// A aplicação dos gates (`RecursoProtegido` nas telas, ver
/// `features/widgets/recurso_protegido.dart`) já está pronta e em uso —
/// só a definição fina de "o que cada plano realmente libera" ainda não
/// foi fechada (ver `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md` §3.1–3.3,
/// §3.5, §3.6 — o que é "básico" em cada grupo, o escopo exato de
/// `mapaIndiceProdutividade`, o que distingue alertas básicos de
/// avançados). Quando essas respostas chegarem, o ajuste é só nestes dois
/// mapas — nenhum outro ponto do código precisa mudar, é exatamente pra
/// isso que a matriz existe separada dos pontos de uso.
final Map<PlanoAtlas, Set<GrupoPermissao>> matrizGrupos = {
  for (final plano in PlanoAtlas.values) plano: GrupoPermissao.values.toSet(),
};

final Map<PlanoAtlas, Set<RecursoAtlas>> matrizRecursos = {
  for (final plano in PlanoAtlas.values) plano: RecursoAtlas.values.toSet(),
};

/// O plano mais barato que libera [recurso] — usado pelo card de upgrade
/// (`RecursoProtegido`) pra dizer "isso é do Atlas X". `null` só se nenhum
/// plano liberar (não deveria acontecer com a matriz atual — todo mundo
/// libera tudo — mas fica defensivo pra quando a matriz for apertada).
PlanoAtlas? planoMinimoPara(RecursoAtlas recurso) {
  final planosQueLiberam = PlanoAtlas.values.where(
    (plano) => matrizRecursos[plano]?.contains(recurso) ?? false,
  );
  if (planosQueLiberam.isEmpty) return null;
  return planosQueLiberam
      .reduce((a, b) => a.precoReferencia <= b.precoReferencia ? a : b);
}
