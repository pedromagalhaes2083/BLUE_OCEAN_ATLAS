import '../config/config.dart';
import '../config/constantes.dart';
import 'fonte_plano.dart';
import 'plano_atlas.dart';

/// Implementação local/config de [FontePlano] — lê o plano salvo em
/// [Config] (Hive), o mesmo padrão de `ThemeModeService`/`NightModeService`.
/// Usada enquanto não existe nenhum backend expondo o plano da embarcação
/// (ver proposta de contrato em `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md`
/// §5) — e também é o que o seletor de plano em modo debug (Configurações)
/// grava direto, pra testar/demonstrar cada plano sem precisar de backend.
class FontePlanoLocal implements FontePlano {
  const FontePlanoLocal();

  @override
  Future<PlanoAtlas> obterPlanoAtual() async {
    final salvo = await Config.obtem(Constantes.planoAtual, '');
    return PlanoAtlas.values.firstWhere(
      (plano) => plano.name == salvo,
      // Offshore como padrão: hoje a matriz libera tudo pra todos os
      // planos (ver matriz_entitlements.dart), então o padrão não muda
      // nada na prática — só evita que "nenhum plano configurado ainda"
      // pareça um Start restrito assim que a matriz for apertada de
      // verdade.
      orElse: () => PlanoAtlas.offshore,
    );
  }
}
