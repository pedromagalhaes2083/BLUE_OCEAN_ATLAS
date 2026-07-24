import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/services/localizacao_reporter_service.dart';

/// Nome da tarefa periódica que envia a localização pra API (a cada 30 min).
/// Compartilhado entre o registro (LocationTrackingService) e o dispatcher.
const String enviarLocalizacaoApiTaskName = 'enviarLocalizacaoApiPeriodic';

@pragma('vm:entry-point') // Obrigatório para background
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == enviarLocalizacaoApiTaskName) {
        await LocalizacaoReporterService.enviarLocalizacaoAtual();
        return true;
      }

      // Tarefa padrão: grava a posição no histórico local da viagem.
      final dbHelper = DatabaseHelper.instance;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 20));

      final String dataHora = DateTime.now().toIso8601String();
      final int viagemId = inputData?['viagem_id'] ?? 0;

      await dbHelper.insert('localizacao_historico', {
        'data_hora': dataHora,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'velocidade': position.speed,
        'precisao': position.accuracy,
        'viagem_id': viagemId,
        'sincronizado': 0,
      });

      print(
          '📍 [WorkManager] Posição salva: ${position.latitude}, ${position.longitude}');
      return true;
    } catch (e) {
      print('❌ Erro no WorkManager: $e');
      return false;
    }
  });
}
