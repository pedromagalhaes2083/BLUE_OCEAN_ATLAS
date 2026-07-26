import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:atlas/core/services/localizacao_reporter_service.dart';

/// Nome da tarefa periódica única de rastreamento: captura a posição
/// atual, grava localmente (associada à viagem em andamento, se houver) e
/// sincroniza com a API todos os registros pendentes — inclusive os que se
/// acumularam de execuções anteriores sem internet.
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
      return true;
    } catch (e) {
      print('❌ Erro no rastreamento de localização: $e');
      return false;
    }
  });
}
