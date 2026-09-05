import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';

/// Busca a linha local de `embarcacao` que corresponde à embarcação
/// *atual* (`Constantes.embarcacaoId`, resolvida pela viagem ativa — ver
/// `ContextoViagemService`), não simplesmente a primeira linha da tabela.
///
/// Por quê: cada embarcação remota distinta que o mestre já usou vira uma
/// linha própria localmente (casada por `remoto_id`, nunca sobrescrita —
/// ver `ContextoViagemService._resolverEmbarcacao`). Um mestre reatribuído
/// de uma embarcação pra outra ao longo do tempo acumula mais de uma linha
/// no aparelho; `.first` pegaria a mais antiga, não necessariamente a de
/// agora. Sem id configurado ou sem linha correspondente (instalação
/// antiga, antes de `remoto_id` existir), cai de volta pra primeira linha
/// da tabela — mesmo comportamento de sempre.
Future<Map<String, dynamic>?> buscarEmbarcacaoLocalAtual(
  DatabaseHelper dbHelper,
) async {
  final embarcacaoId = (await Config.obtem(Constantes.embarcacaoId, '')).trim();
  if (embarcacaoId.isNotEmpty) {
    final porRemotoId = await dbHelper.queryWhere(
      'embarcacao',
      where: 'remoto_id = ?',
      whereArgs: [embarcacaoId],
    );
    if (porRemotoId.isNotEmpty) return porRemotoId.first;
  }

  final todas = await dbHelper.query('embarcacao');
  return todas.isNotEmpty ? todas.first : null;
}
