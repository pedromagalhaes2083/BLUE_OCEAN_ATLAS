import 'package:flutter/foundation.dart';

import '../../features/embarcacao/data/embarcacao_repository.dart';
import '../../features/viagem/data/viagem_repository.dart';
import '../../features/viagem/domain/models/viagem_atual_remota.dart';
import '../config/config.dart';
import '../config/constantes.dart';
import '../database/database_helper.dart';

/// Resolve o contexto operacional a partir da viagem ativa do usuário no
/// backend: busca a viagem, e a partir do `embarcacaoId` dela, resolve a
/// embarcação em uso — fluxo login → viagem ativa → embarcação (novo
/// desenho combinado em 2026-09, ver conversa: antes tanto a viagem quanto
/// a embarcação eram cadastradas manualmente no app; agora as duas só
/// existem na retaguarda/plataforma, e o app apenas espelha localmente o
/// que a viagem ativa aponta — não cria nem edita nenhuma das duas).
///
/// Best-effort de propósito, igual [SincronizacaoService]: nunca pode
/// travar nem falhar visivelmente — sem viagem ativa (usuário não está no
/// meio de uma viagem agora) ou erro de rede/backend (ver nota no
/// [Endpoints.viagemAtual] sobre o 422 visto em 2026-09), o app simplesmente
/// segue sem contexto de viagem novo, mantendo o que já tinha localmente.
class ContextoViagemService {
  /// Chama depois do login (ver `LoginScreen._fazerLogin`). Não lança —
  /// qualquer falha fica só no log, pro chamador não precisar de
  /// try/catch próprio.
  static Future<void> resolverAoLogar(DatabaseHelper dbHelper) async {
    await sincronizar(dbHelper);
  }

  /// Mesma resolução acima, mas pensada pra ser chamada a qualquer momento
  /// (não só no login) e com retorno pra UI dar feedback ao mestre — usada
  /// pelos botões "Sincronizar" no Dashboard e em "Configurar Embarcação"
  /// agora que nem viagem nem embarcação são mais criadas pelo app (ver
  /// DashboardScreen._exigirViagemAtiva/_exigirEmbarcacaoCadastrada e
  /// EmbarcacaoConfiguracaoScreen). Retorna `true` só quando encontrou e
  /// sincronizou uma viagem ativa; `false` tanto pra "sem viagem ativa"
  /// quanto pra erro de rede/backend — a UI não distingue os dois casos,
  /// só mostra que não há nada novo por enquanto.
  static Future<bool> sincronizar(DatabaseHelper dbHelper) async {
    try {
      final viagemAtual = await ViagemRepository().buscarAtual();
      if (viagemAtual == null) {
        debugPrint('Contexto de viagem: usuário sem viagem ativa agora.');
        return false;
      }
      await _sincronizarViagemLocal(dbHelper, viagemAtual);
      await _resolverEmbarcacao(dbHelper, viagemAtual.embarcacaoId);
      return true;
    } catch (e) {
      // Cobre tanto "sem viagem ativa" quanto qualquer erro de rede/
      // servidor (ex: o 422/QueryFailedError visto em 2026-09) — os dois
      // casos têm o mesmo tratamento aqui: não travar o chamador, o app
      // segue funcionando com o que já tinha localmente antes.
      debugPrint('Contexto de viagem: não foi possível resolver a viagem '
          'ativa do backend ($e) — mantendo estado local.');
      return false;
    }
  }

  /// Espelha a viagem ativa do backend na tabela local `viagem` — sem
  /// isso, os pontos que hoje decidem "tem viagem em andamento?" olhando
  /// só o SQLite local (retomada de GPS no login, telas que exigem viagem
  /// ativa) ficariam cegos pra uma viagem que só existe no backend (ex:
  /// criada pela plataforma/retaguarda ou por outro dispositivo).
  ///
  /// Cascata: só ATUALIZA uma linha local já ligada a esse
  /// [ViagemAtualRemota.id] (por `remoto_id`), ou INSERE uma nova se não
  /// houver nenhuma viagem `em_andamento` local ainda — nunca sobrescreve
  /// nem finaliza uma viagem local `em_andamento` diferente da que veio do
  /// backend, pra não arriscar perder rastreamento/produção já em
  /// andamento por causa de um conflito de sincronização. Esse caso
  /// (viagem local diferente da remota, as duas "em_andamento") fica só
  /// registrado no log — não é resolvido sozinho aqui.
  static Future<void> _sincronizarViagemLocal(
    DatabaseHelper dbHelper,
    ViagemAtualRemota remota,
  ) async {
    final porRemotoId = await dbHelper.queryWhere(
      'viagem',
      where: 'remoto_id = ?',
      whereArgs: [remota.id],
    );
    if (porRemotoId.isNotEmpty) {
      await dbHelper.update(
        'viagem',
        {'embarcacao_id': remota.embarcacaoId, 'status': 'em_andamento'},
        id: porRemotoId.first['id'] as int,
      );
      return;
    }

    final emAndamento = await dbHelper.queryWhere(
      'viagem',
      where: 'status = ?',
      whereArgs: ['em_andamento'],
    );
    if (emAndamento.isNotEmpty) {
      debugPrint('Contexto de viagem: já existe uma viagem em_andamento '
          'local (id ${emAndamento.first['id']}) diferente da viagem ativa '
          'do backend (${remota.id}) — mantendo a local, sem sobrescrever.');
      return;
    }

    await dbHelper.insert('viagem', {
      'nome': remota.nome,
      'data_inicio': (remota.dataInicio ?? DateTime.now()).toIso8601String(),
      'data_termino': remota.dataTermino?.toIso8601String(),
      'embarcacao_id': remota.embarcacaoId,
      'status': 'em_andamento',
      'remoto_id': remota.id,
    });
  }

  /// Grava o `embarcacaoId` da viagem ativa como a embarcação em uso pelo
  /// app (mesma config global que antes só vinha da tela "Configurar
  /// Embarcação" — ver `Constantes.embarcacaoId`) e espelha os dados que o
  /// catálogo remoto devolve na tabela local `embarcacao`, pra telas como
  /// `EmbarcacaoScreen` terem o que mostrar sem exigir cadastro manual.
  /// Melhor-esforço: sem rede ou embarcação não encontrada no catálogo, só
  /// fica registrado no log — nunca bloqueia por causa disso (ver TODO em
  /// [EmbarcacaoRepository.buscarPorId] sobre esse método ainda ser
  /// provisório).
  static Future<void> _resolverEmbarcacao(
    DatabaseHelper dbHelper,
    String embarcacaoId,
  ) async {
    await Config.grava(Constantes.embarcacaoId, embarcacaoId);
    try {
      final embarcacao = await EmbarcacaoRepository().buscarPorId(embarcacaoId);
      if (embarcacao == null) {
        debugPrint('Contexto de viagem: embarcacaoId $embarcacaoId da '
            'viagem ativa não encontrado no catálogo remoto.');
        return;
      }

      final porRemotoId = await dbHelper.queryWhere(
        'embarcacao',
        where: 'remoto_id = ?',
        whereArgs: [embarcacaoId],
      );
      if (porRemotoId.isNotEmpty) {
        await dbHelper.update(
          'embarcacao',
          {
            'nome': embarcacao.nome,
            'dono': embarcacao.dono,
            'quantidade_urnas': embarcacao.quantidadeUrnas ?? 1,
            'registro': embarcacao.registro,
          },
          id: porRemotoId.first['id'] as int,
        );
        return;
      }

      // Nenhuma embarcação local ainda vinculada a esse id remoto — cria a
      // linha espelho. Campos que o catálogo remoto (`EmbarcacaoRemota`)
      // ainda não traz (capacidade de gelo/diesel, tripulação, mestre,
      // motor) ficam nulos; não são mais editáveis à mão no app (ver
      // EmbarcacaoConfiguracaoScreen).
      await dbHelper.insert('embarcacao', {
        'nome': embarcacao.nome,
        'dono': embarcacao.dono,
        'quantidade_urnas': embarcacao.quantidadeUrnas ?? 1,
        'registro': embarcacao.registro,
        'data_cadastro': DateTime.now().toIso8601String(),
        'ativo': 1,
        'remoto_id': embarcacaoId,
      });
    } catch (e) {
      debugPrint('Contexto de viagem: erro ao sincronizar embarcação '
          '$embarcacaoId no catálogo ($e).');
    }
  }
}
