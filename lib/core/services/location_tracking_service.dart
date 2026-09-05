import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:atlas/core/background/location_foreground_task_handler.dart';
import 'package:atlas/core/database/database_helper.dart';

/// Intervalo padrão/mínimo sugerido pra UI (ver telas de Configurações,
/// Dashboard e Splash) — não é mais um piso técnico do WorkManager (esse
/// serviço em primeiro plano não tem essa limitação, ver comentário de
/// [iniciarRastreamento]), só um valor sensato de bateria por padrão.
const int intervaloMinimoMinutos = 15;

/// Rastreamento de posição durante uma viagem — roda como serviço em
/// primeiro plano de verdade (`flutter_foreground_task`), com notificação
/// persistente, em vez de tarefa periódica do WorkManager. Diferença que
/// importa na prática (ver auditoria BOA-008): o WorkManager é melhor
/// esforço — o Android podia atrasar, agrupar ou simplesmente não rodar a
/// tarefa com o app fechado, dependendo do fabricante e do modo Doze. Um
/// serviço em primeiro plano com notificação continua rodando mesmo com o
/// app fechado/removido dos recentes, e só para quando o mestre finaliza
/// a viagem ou o sistema mata o app via "Forçar parada" — o mais perto de
/// "rastreamento contínuo" que dá pra garantir sem um dispositivo de
/// rastreamento dedicado.
class LocationTrackingService {
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Se o serviço em primeiro plano está rodando agora — consulta o
  /// sistema (não um flag em memória): sobrevive a reaberturas do app,
  /// diferente do booleano antigo que resetava a cada cold start.
  Future<bool> get isTracking => FlutterForegroundTask.isRunningService;

  /// Configura o canal de notificação e o comportamento do serviço —
  /// idempotente, chamado de novo a cada [iniciarRastreamento] pra
  /// atualizar o intervalo caso o mestre tenha mudado nas Configurações
  /// desde a última vez.
  Future<void> _configurar({required int intervaloMinutos}) async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'atlas_rastreamento',
        channelName: 'Rastreamento de viagem',
        channelDescription:
            'Notificação permanente enquanto o Atlas está enviando a '
            'posição da embarcação durante uma viagem em andamento.',
        onlyAlertOnce: true,
      ),
      // No iOS não existe "serviço em primeiro plano" — o rastreamento em
      // segundo plano depende do modo de localização em background do
      // sistema (ver Info.plist: UIBackgroundModes com "location" e
      // permissão "Sempre"), não dessa notificação. Mantém desativada.
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction:
            ForegroundTaskEventAction.repeat(intervaloMinutos * 60 * 1000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Pede a permissão de notificação (obrigatória a partir do Android 13
  /// pra sequer mostrar a notificação do serviço) e a isenção de
  /// otimização de bateria — sem ela, muitos fabricantes matam o serviço
  /// de qualquer jeito. Melhor-esforço: nunca bloqueia o início do
  /// rastreamento, só reduz a chance dele sobreviver por muito tempo.
  Future<void> _pedirPermissoesNecessarias() async {
    try {
      final permissao = await FlutterForegroundTask.checkNotificationPermission();
      if (permissao != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    } catch (e) {
      debugPrint('Erro ao verificar/pedir permissão de notificação: $e');
    }

    if (!Platform.isAndroid) return;
    try {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    } catch (e) {
      debugPrint('Erro ao pedir isenção de otimização de bateria: $e');
    }
  }

  /// Inicia o serviço em primeiro plano: captura a posição, grava no
  /// histórico local (associada à viagem em andamento, se houver) e
  /// sincroniza com a API os registros pendentes — no intervalo
  /// configurado pelo usuário. Roda do início da viagem até finalizá-la,
  /// mesmo com o app fechado (ver documentação da classe).
  Future<void> iniciarRastreamento({required int intervaloMinutos}) async {
    final intervalo = intervaloMinutos < 1 ? intervaloMinimoMinutos : intervaloMinutos;

    await _configurar(intervaloMinutos: intervalo);
    await _pedirPermissoesNecessarias();

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.restartService();
    } else {
      await FlutterForegroundTask.startService(
        serviceId: 257,
        notificationTitle: 'Atlas Blue Ocean — Rastreamento ativo',
        notificationText: 'Iniciando envio de posição...',
        callback: iniciarLocationForegroundTaskHandler,
      );
    }

    debugPrint('🚀 Rastreamento de localização iniciado (a cada $intervalo min)');
  }

  Future<void> pararRastreamento() async {
    await FlutterForegroundTask.stopService();
    debugPrint('⏹️ Rastreamento de localização parado');
  }

  // ====================== HISTÓRICO ======================
  Future<List<Map<String, dynamic>>> getHistory({int? viagemId}) async {
    final db = await _dbHelper.database;

    if (viagemId != null) {
      return await db.query(
        'localizacao_historico',
        where: 'viagem_id = ?',
        whereArgs: [viagemId],
        orderBy: 'data_hora DESC',
      );
    }

    return await db.query('localizacao_historico', orderBy: 'data_hora DESC');
  }
}
