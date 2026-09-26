import 'plano_atlas.dart';

/// De onde `PlanoService` lê o plano da embarcação ativa — abstraído de
/// propósito (ver `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md` §4.1):
/// hoje só existe [FontePlanoLocal] (config local, sem backend nenhum
/// expondo plano ainda); quando o backend passar a devolver o plano da
/// embarcação (ver proposta de contrato, §5), basta escrever uma
/// `FontePlanoRemota implements FontePlano` e trocar a instância usada em
/// `PlanoService` — nenhum outro ponto do app muda.
abstract class FontePlano {
  Future<PlanoAtlas> obterPlanoAtual();
}
