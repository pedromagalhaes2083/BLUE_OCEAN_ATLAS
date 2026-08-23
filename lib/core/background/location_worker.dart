import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:atlas/core/services/localizacao_reporter_service.dart';
import 'package:atlas/core/services/recomendacao_notification_service.dart';

/// Nome da tarefa periódica única de rastreamento: captura a posição
/// atual, grava localmente (associada à viagem em andamento, se houver),
/// sincroniza com a API todos os registros pendentes — inclusive os que se
/// acumularam de execuções anteriores sem internet — e checa se há
/// recomendação nova pra notificar (ver [RecomendacaoNotificationService]).
/// Compartilhado entre o registro (LocationTrackingService) e o dispatcher.
const String rastreamentoLocalizacaoTaskName = 'rastreamentoLocalizacaoPeriodic';

@pragma('vm:entry-point') // Obrigatório para background
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Roda numa isolate nova, sem passar por main() — Hive (usado por
      // Config, para ler token/embarcacaoId) precisa ser inicializado
      // aqui também, senão quebra com "You need to initialize Hive".
      await Hive.initFlutter();
      await LocalizacaoReporterService.registrarESincronizar();
      await RecomendacaoNotificationService.verificarNovas();
      return true;
    } catch (e) {
      debugPrint('❌ Erro no rastreamento de localização: $e');
      return false;
    }
  });
}
