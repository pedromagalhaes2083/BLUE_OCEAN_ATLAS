import 'package:flutter/foundation.dart';

import '../config/config.dart';
import '../config/constantes.dart';
import 'fonte_plano.dart';
import 'fonte_plano_local.dart';
import 'grupo_permissao.dart';
import 'matriz_entitlements.dart';
import 'plano_atlas.dart';
import 'recurso_atlas.dart';

/// Estado global do plano comercial ativo — mesmo padrão de
/// `NightModeService`/`ThemeModeService` (`ValueNotifier` carregado uma vez
/// no boot, consultado de forma síncrona pelo resto do app depois disso).
///
/// A fonte de verdade de "o que cada plano libera" é
/// `matriz_entitlements.dart`, nunca esta classe — `possui`/`possuiGrupo`
/// só consultam a matriz. Hoje ([FontePlanoLocal]) tudo está liberado pra
/// todos os planos (ver comentário na matriz) — quando isso mudar, é só
/// editar a matriz, este serviço e os pontos de uso (`RecursoProtegido`)
/// não precisam mudar nada.
class PlanoService {
  PlanoService._();

  static FontePlano _fonte = const FontePlanoLocal();

  static final ValueNotifier<PlanoAtlas> planoAtual =
      ValueNotifier(PlanoAtlas.offshore);

  static bool _carregado = false;

  /// Troca a fonte do plano (ex: pra uma `FontePlanoRemota`, quando o
  /// backend passar a expor plano — ver `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md`
  /// §4/§5). Só existe pra permitir essa troca sem alterar mais nada.
  @visibleForTesting
  static void definirFonte(FontePlano fonte) => _fonte = fonte;

  /// Carrega o plano salvo — chamado uma vez no boot (`main.dart`, mesmo
  /// padrão de `ThemeModeService.carregar()`). Idempotente-o-bastante:
  /// pode ser chamado de novo (ex: depois de trocar o plano no seletor de
  /// debug) pra recarregar.
  static Future<void> carregar() async {
    planoAtual.value = await _fonte.obterPlanoAtual();
    _carregado = true;
  }

  /// Troca o plano ativo (usado pelo seletor de debug em Configurações —
  /// ver `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md` §2.2). Só grava
  /// local — não existe fluxo de upgrade/cobrança no app (ver regra 4 do
  /// pedido original).
  static Future<void> definirPlano(PlanoAtlas plano) async {
    planoAtual.value = plano;
    await Config.grava(Constantes.planoAtual, plano.name);
  }

  /// Se o grupo amplo (nível 1) está liberado pro plano atual — usado pra
  /// decidir se um módulo/tela inteira aparece.
  static bool possuiGrupo(GrupoPermissao grupo) {
    if (!_carregado) return true; // antes do boot carregar: nunca bloqueia
    return matrizGrupos[planoAtual.value]?.contains(grupo) ?? false;
  }

  /// Se a permissão específica (nível 2) está liberada pro plano atual —
  /// sempre exige o grupo pai liberado primeiro (um recurso nunca libera
  /// nada sozinho com o grupo bloqueado).
  static bool possui(RecursoAtlas recurso) {
    if (!possuiGrupo(recurso.grupo)) return false;
    if (!_carregado) return true;
    return matrizRecursos[planoAtual.value]?.contains(recurso) ?? false;
  }
}
