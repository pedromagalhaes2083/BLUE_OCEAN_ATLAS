import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:intl/intl.dart';

@pragma('vm:entry-point') // Obrigatório para background
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final dbHelper = DatabaseHelper.instance;

      // Obtém posição
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );

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
