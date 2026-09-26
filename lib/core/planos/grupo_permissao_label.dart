import '../../l10n/gen/app_localizations.dart';
import 'grupo_permissao.dart';

/// Rótulo traduzido de cada [GrupoPermissao] — separado do enum em si
/// (`grupo_permissao.dart` não depende de `l10n`, mantém o domínio puro).
extension GrupoPermissaoLabel on GrupoPermissao {
  String rotulo(AppLocalizations l10n) => switch (this) {
        GrupoPermissao.navegacaoEssencial => l10n.planoGrupoNavegacaoEssencial,
        GrupoPermissao.cartas => l10n.planoGrupoCartas,
        GrupoPermissao.oceanografia => l10n.planoGrupoOceanografia,
        GrupoPermissao.producao => l10n.planoGrupoProducao,
        GrupoPermissao.rotas => l10n.planoGrupoRotas,
        GrupoPermissao.rastreamento => l10n.planoGrupoRastreamento,
        GrupoPermissao.inteligencia => l10n.planoGrupoInteligencia,
        GrupoPermissao.operacao => l10n.planoGrupoOperacao,
        GrupoPermissao.frota => l10n.planoGrupoFrota,
      };
}
