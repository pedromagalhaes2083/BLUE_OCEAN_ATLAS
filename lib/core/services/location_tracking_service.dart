import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';
import 'package:atlas/core/background/location_worker.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:intl/intl.dart';

class LocationTrackingService {
  static final LocationTrackingService _instance =
      LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  static const String _taskName = "trackingLocationPeriodic";

  Timer? _foregroundTimer;
  bool _isForegroundTracking = false;
  bool _isBackgroundTracking = false;
  bool _initialized = false;

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool get isTracking => _isForegroundTracking || _isBackgroundTracking;

  // ====================== INICIALIZAÇÃO ======================
  Future<void> initialize() async {
    if (_initialized) return;

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // ← Mude para false em produção
    );
    _initialized = true;
  }

  // ====================== BACKGROUND (WorkManager) ======================
  Future<void> startBackgroundTracking({int viagemId = 0}) async {
    await initialize();

    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15), // Mínimo confiável no Android
      initialDelay: const Duration(minutes: 1),
      inputData: {'viagem_id': viagemId},
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
      ),
    );

    _isBackgroundTracking = true;
    print('🚀 WorkManager: Rastreamento em segundo plano iniciado');
  }

  // ====================== FOREGROUND (Timer - 5 em 5 min) ======================
  Future<void> startForegroundTracking({int viagemId = 0}) async {
    if (_isForegroundTracking) return;

    _isForegroundTracking = true;

    // Primeira gravação imediata
    await _saveCurrentLocation(viagemId);

    // Depois a cada 5 minutos
    _foregroundTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _saveCurrentLocation(viagemId);
    });

    print('📍 Timer (Foreground): Rastreamento a cada 5 minutos iniciado');
  }

  Future<void> _saveCurrentLocation(int viagemId) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final String dataHora = DateTime.now().toIso8601String();

      await _dbHelper.insert('localizacao_historico', {
        'data_hora': dataHora,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'velocidade': position.speed,
        'precisao': position.accuracy,
        'viagem_id': viagemId,
        'sincronizado': 0,
      });

      print(
          '📍 Posição salva: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)} - ${DateFormat('HH:mm:ss').format(DateTime.now())}');
    } catch (e) {
      print('❌ Erro ao salvar localização: $e');
    }
  }

  // ====================== PARAR RASTREAMENTO ======================
  Future<void> stopAllTracking() async {
    // Para WorkManager (background)
    await Workmanager().cancelByUniqueName(_taskName);
    _isBackgroundTracking = false;

    // Para Timer (foreground)
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
    _isForegroundTracking = false;

    print('⏹️ Todos os rastreamentos foram parados');
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
