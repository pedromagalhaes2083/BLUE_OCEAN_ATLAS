import 'package:workmanager/workmanager.dart';
import 'package:atlas/core/background/location_worker.dart';
import 'package:atlas/core/database/database_helper.dart';

/// Intervalo mínimo confiável para tarefas periódicas do WorkManager no
/// Android — valores menores são silenciosamente ajustados pra esse piso.
const int intervaloMinimoMinutos = 15;

class LocationTrackingService {
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  bool _initialized = false;
  bool _rastreando = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool get isTracking => _rastreando;

  Future<void> initialize() async {
    if (_initialized) return;
    await Workmanager().initialize(callbackDispatcher);
    _initialized = true;
  }

  /// Inicia o rastreamento único: captura a posição, grava no histórico
  /// local (associada à viagem em andamento, se houver) e sincroniza com a
  /// API os registros pendentes — no intervalo configurado pelo usuário.
  /// Roda do login até o logout, com ou sem viagem ativa.
  Future<void> iniciarRastreamento({required int intervaloMinutos}) async {
    await initialize();

    final intervalo = intervaloMinutos < intervaloMinimoMinutos
        ? intervaloMinimoMinutos
        : intervaloMinutos;

    await Workmanager().registerPeriodicTask(
      rastreamentoLocalizacaoTaskName,
      rastreamentoLocalizacaoTaskName,
      frequency: Duration(minutes: intervalo),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.notRequired),
    );

    _rastreando = true;
    print('🚀 Rastreamento de localização iniciado (a cada $intervalo min)');
  }

  Future<void> pararRastreamento() async {
    await Workmanager().cancelByUniqueName(rastreamentoLocalizacaoTaskName);
    _rastreando = false;
    print('⏹️ Rastreamento de localização parado');
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
