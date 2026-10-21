import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:atlas/core/background/location_foreground_task_handler.dart';
import 'package:atlas/core/config/config.dart';
import 'package:atlas/core/config/constantes.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/gps/fonte_gps.dart';
import 'package:atlas/core/gps/gps_log.dart';
import 'package:atlas/core/gps/permissao_gps.dart';

/// Resultado de [LocationTrackingService.iniciarRastreamento].
enum StatusInicioRastreamento {
  iniciado,

  /// Sem permissão de localização — não inicia: o serviço rodaria sem
  /// conseguir capturar nada (e no Android 14+ o sistema nem deixa iniciar
  /// um serviço de localização sem ela).
  semPermissao,

  /// Negada de vez — só o usuário, nas configurações do app, pode liberar.
  permissaoNegadaPermanentemente,

  /// O sistema recusou iniciar o serviço (ver log `[GPS]`).
  falhou,
}

class ResultadoInicioRastreamento {
  final StatusInicioRastreamento status;

  /// Permissão e serviço de localização no momento da tentativa — ex.: pra
  /// avisar que o GPS do aparelho está desligado mesmo com o rastreamento
  /// iniciado.
  final DiagnosticoGps? diagnostico;

  const ResultadoInicioRastreamento(this.status, [this.diagnostico]);

  bool get iniciado => status == StatusInicioRastreamento.iniciado;
}

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
  Future<void> _configurar({
    required int intervaloMinutos,
    required bool retomarAoReiniciarAparelho,
  }) async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        // "_v2": o canal antigo ("atlas_rastreamento") foi criado com
        // importância padrão da lib (LOW) — Android trava a importância
        // de um canal na criação e não deixa mudar depois via código
        // (só o próprio usuário, manualmente, nas configurações do
        // sistema). Em prioridade baixa, a OneUI (Samsung) deixa
        // dispensar a notificação com um simples swipe, mesmo sendo de um
        // serviço em primeiro plano — testado no dispositivo, confirmado
        // que dispensava. Precisa de um id de canal novo pra recriar do
        // zero com a importância certa; o antigo fica órfão no aparelho
        // (inofensivo, sem notificação nova associada a ele).
        channelId: 'atlas_rastreamento_v2',
        channelName: 'Rastreamento de viagem',
        channelDescription:
            'Notificação permanente enquanto o Atlas está enviando a '
            'posição da embarcação durante uma viagem em andamento. Não é '
            'possível dispensar enquanto a viagem estiver ativa — '
            'finalize a viagem no app pra parar o rastreamento.',
        // DEFAULT (não LOW, o padrão da lib) — é o que impede o gesto de
        // swipe-pra-dispensar em notificações de serviço em primeiro
        // plano na maioria dos fabricantes, inclusive OneUI.
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
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
        // Retomar depois de reiniciar o aparelho inicia o serviço sem o app
        // estar em primeiro plano — a partir do Android 14, isso só é
        // permitido pra um serviço de localização com a permissão "Permitir
        // o tempo todo"; sem ela, o sistema recusaria (SecurityException)
        // logo no boot. Sem essa permissão, o rastreamento volta quando o
        // mestre abrir o app (ver SplashScreen).
        autoRunOnBoot: retomarAoReiniciarAparelho,
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
  ///
  /// Não inicia sem permissão de localização. [solicitarPermissao] só deve
  /// ser true quando há uma tela em primeiro plano pra mostrar o pedido
  /// (ex.: o mestre acabou de sincronizar a viagem) — na retomada
  /// automática (splash) fica false, pra não perguntar a cada abertura.
  ///
  /// Chamadas simultâneas (splash + dashboard, toque duplo) compartilham o
  /// mesmo início — nunca dois serviços nem um "parar" no meio de um
  /// "iniciar".
  Future<ResultadoInicioRastreamento> iniciarRastreamento({
    required int intervaloMinutos,
    bool solicitarPermissao = false,
    @visibleForTesting FonteGps fonte = const FonteGpsGeolocator(),
  }) {
    return _inicioEmAndamento ??= _iniciar(
      intervaloMinutos: intervaloMinutos,
      solicitarPermissao: solicitarPermissao,
      fonte: fonte,
    ).whenComplete(() {
      _inicioEmAndamento = null;
    });
  }

  static Future<ResultadoInicioRastreamento>? _inicioEmAndamento;

  Future<ResultadoInicioRastreamento> _iniciar({
    required int intervaloMinutos,
    required bool solicitarPermissao,
    required FonteGps fonte,
  }) async {
    final intervalo = intervaloMinutos < 1 ? intervaloMinimoMinutos : intervaloMinutos;

    final DiagnosticoGps diagnostico;
    try {
      diagnostico = await PermissaoGps.diagnosticar(
          fonte: fonte, solicitar: solicitarPermissao);
    } catch (e) {
      GpsLog.evento('rastreamento não iniciado: falha ao verificar permissão', '$e');
      return const ResultadoInicioRastreamento(StatusInicioRastreamento.falhou);
    }
    if (diagnostico.permissao == EstadoPermissaoGps.negadaPermanentemente) {
      GpsLog.evento('rastreamento não iniciado: permissão negada permanentemente');
      return ResultadoInicioRastreamento(
          StatusInicioRastreamento.permissaoNegadaPermanentemente, diagnostico);
    }
    if (!diagnostico.permissao.permiteRastrear) {
      GpsLog.evento('rastreamento não iniciado: sem permissão de localização');
      return ResultadoInicioRastreamento(
          StatusInicioRastreamento.semPermissao, diagnostico);
    }
    if (!diagnostico.servicoHabilitado) {
      // Inicia mesmo assim: o serviço passa a capturar assim que o GPS for
      // ligado. Quem chamou recebe o diagnóstico pra avisar o mestre.
      GpsLog.evento('serviço de localização desligado — rastreamento inicia, '
          'mas só captura quando o GPS for ligado');
    }

    try {
      return await _iniciarServico(intervalo, diagnostico);
    } catch (e) {
      GpsLog.evento('rastreamento não iniciado: erro ao iniciar o serviço', '$e');
      return ResultadoInicioRastreamento(
          StatusInicioRastreamento.falhou, diagnostico);
    }
  }

  Future<ResultadoInicioRastreamento> _iniciarServico(
      int intervalo, DiagnosticoGps diagnostico) async {
    await _configurar(
      intervaloMinutos: intervalo,
      retomarAoReiniciarAparelho:
          diagnostico.permissao == EstadoPermissaoGps.concedidaSempre,
    );
    await _pedirPermissoesNecessarias();

    if (await FlutterForegroundTask.isRunningService) {
      // Não usa `restartService()` aqui: o Android reinicia o serviço
      // sozinho após um update do app (`autoRunOnMyPackageReplaced`),
      // reaproveitando as opções nativas persistidas *antes* desse
      // `_configurar()` acima rodar — na prática, `restartService()`
      // então mantinha o canal/importância antigos em vez de aplicar os
      // novos (foi assim que a notificação de "atlas_rastreamento" (LOW)
      // sobreviveu à troca pra "atlas_rastreamento_v2" (DEFAULT) num
      // teste real no dispositivo). Parar e iniciar de novo garante que a
      // notificação atual sempre reflete a config atual.
      await FlutterForegroundTask.stopService();
    }
    final resultado = await FlutterForegroundTask.startService(
      serviceId: 257,
      serviceTypes: [ForegroundServiceTypes.location],
      notificationTitle: 'Atlas Blue Ocean — Rastreamento ativo',
      notificationText: 'Iniciando envio de posição...',
      callback: iniciarLocationForegroundTaskHandler,
    );
    if (resultado is ServiceRequestFailure) {
      GpsLog.evento('rastreamento não iniciado: o sistema recusou o serviço',
          '${resultado.error}');
      return ResultadoInicioRastreamento(
          StatusInicioRastreamento.falhou, diagnostico);
    }

    GpsLog.evento('rastreamento iniciado',
        'a cada $intervalo min, permissão: ${diagnostico.permissao.name}');
    return ResultadoInicioRastreamento(
        StatusInicioRastreamento.iniciado, diagnostico);
  }

  /// Inicia o rastreamento se houver uma viagem em andamento no banco local
  /// — o mesmo critério da splash, do login e de quando a viagem ativa é
  /// sincronizada do backend (antes, nesse último caso, o rastreamento só
  /// começava depois de fechar e abrir o app). Devolve null se não há
  /// viagem ativa.
  Future<ResultadoInicioRastreamento?> garantirRastreamentoSeViagemAtiva({
    bool solicitarPermissao = false,
  }) async {
    final viagensAtivas = await _dbHelper.queryWhere(
      'viagem',
      where: 'status = ?',
      whereArgs: ['em_andamento'],
    );
    if (viagensAtivas.isEmpty) return null;

    final intervalo = int.tryParse(await Config.obtem(
          Constantes.intervaloRastreamentoMinutos,
          '$intervaloMinimoMinutos',
        )) ??
        intervaloMinimoMinutos;
    return iniciarRastreamento(
      intervaloMinutos: intervalo,
      solicitarPermissao: solicitarPermissao,
    );
  }

  Future<void> pararRastreamento() async {
    await FlutterForegroundTask.stopService();
    GpsLog.evento('rastreamento encerrado');
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
