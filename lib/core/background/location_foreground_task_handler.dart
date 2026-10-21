import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../gps/gps_log.dart';
import '../services/alerta_condicao_notification_service.dart';
import '../services/atualizacao_previsoes_service.dart';
import '../services/localizacao_reporter_service.dart';
import '../services/recomendacao_notification_service.dart';

/// Ponto de entrada do serviço em primeiro plano (ver
/// `LocationTrackingService.iniciarRastreamento`) — precisa ser uma
/// função de nível superior anotada com `vm:entry-point` (a isolate do
/// serviço é criada de novo a partir daqui, não reaproveita a do app).
@pragma('vm:entry-point')
void iniciarLocationForegroundTaskHandler() {
  FlutterForegroundTask.setTaskHandler(LocationForegroundTaskHandler());
}

/// Handler do serviço em primeiro plano do rastreamento: a cada disparo
/// (intervalo configurado em [ForegroundTaskOptions], ver
/// `LocationTrackingService`), captura a posição atual, grava localmente
/// (associada à viagem em andamento, se houver), sincroniza com a API
/// todos os registros pendentes — inclusive os acumulados de execuções
/// anteriores sem internet —, checa se há recomendação nova pra notificar
/// (ver [RecomendacaoNotificationService]) e checa se vento/corrente/onda
/// no ponto à frente ficaram severos (ver [AlertaCondicaoNotificationService]).
///
/// Roda numa isolate própria, separada da isolate principal do app — e
/// sobrevive ao app ser fechado/removido dos recentes, porque é um
/// serviço em primeiro plano de verdade (com notificação persistente),
/// não mais uma tarefa periódica de melhor esforço do WorkManager (que o
/// Android podia atrasar ou simplesmente não rodar com o app fechado,
/// dependendo do fabricante/Doze — ver auditoria BOA-008). Só é encerrado
/// quando o mestre finaliza a viagem (ver
/// `HistoricoLocalizacoesScreen._finalizarViagem`) ou o sistema mata o
/// app via "Forçar parada" nas configurações.
class LocationForegroundTaskHandler extends TaskHandler {
  var _execucoes = 0;

  /// O disparo periódico não espera a rodada anterior terminar — sem isso,
  /// um envio lento (backlog grande de horas sem internet, rede fraca)
  /// sobrepunha a rodada seguinte.
  var _executando = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Hive (usado por Config, pra ler token/embarcacaoId) precisa ser
    // inicializado aqui também — essa isolate não passa por main().
    await Hive.initFlutter();
    // starter: developer (iniciado pelo app) ou system (boot/atualização do
    // app) — ajuda a saber se o serviço voltou sozinho depois de morrer.
    GpsLog.evento('serviço de rastreamento ativo', 'início: ${starter.name}');
    await _executar();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _executar();
  }

  Future<void> _executar() async {
    if (_executando) {
      GpsLog.evento('rodada pulada: a anterior ainda está em andamento');
      return;
    }
    _executando = true;
    _execucoes++;
    try {
      await LocalizacaoReporterService.registrarESincronizar();
      // Depois da posição (usa a mais recente) e antes dos alertas (que
      // leem as mesmas previsões do cache). Só busca quando passou o
      // intervalo configurado; nunca lança.
      await AtualizacaoPrevisoesService.atualizarSeNecessario();
      await RecomendacaoNotificationService.verificarNovas();
      await AlertaCondicaoNotificationService.verificarCondicoesAFrente();
    } catch (e) {
      GpsLog.evento('erro na rodada de rastreamento', '$e');
    } finally {
      _executando = false;
    }

    // Notificação atualizada a cada execução — mostra que o serviço ainda
    // está vivo e enviando posição, em vez de um texto estático que não
    // muda nunca (o mestre não teria como distinguir "rodando" de
    // "travado" só olhando a notificação).
    FlutterForegroundTask.updateService(
      notificationTitle: 'Atlas Blue Ocean — Rastreamento ativo',
      notificationText:
          'Última posição enviada às ${_horaAgora()} · $_execucoes envio(s) nesta viagem',
    );
  }

  String _horaAgora() {
    final agora = DateTime.now();
    final h = agora.hour.toString().padLeft(2, '0');
    final m = agora.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    GpsLog.evento('serviço de rastreamento encerrado',
        'timeout: $isTimeout, rodadas: $_execucoes');
  }

  // Sem uso hoje (nenhum botão/dado enviado à notificação) — só
  // implementações vazias exigidas pela classe abstrata.
  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}

  @override
  void onNotificationDismissed() {}

  @override
  void onReceiveData(Object data) {}
}
