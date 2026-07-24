import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/localizacao/data/localizacao_repository.dart';
import '../../features/localizacao/domain/models/localizacao_envio.dart';
import 'device_id_service.dart';

/// Obtém a posição atual do dispositivo e envia pra API via
/// [LocalizacaoRepository].
///
/// Chamado periodicamente (a cada 30 min) pela tarefa em background
/// registrada em [LocationTrackingService.startEnviarLocalizacaoParaApi].
class LocalizacaoReporterService {
  static Future<void> enviarLocalizacaoAtual() async {
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 20));

      final deviceId = await DeviceIdService.obtemId();

      await LocalizacaoRepository().enviar(LocalizacaoEnvio(
        dispositivoIdentificador: deviceId,
        latitude: posicao.latitude,
        longitude: posicao.longitude,
        precisao: posicao.accuracy,
        capturadoEm: DateTime.now(),
      ));

      debugPrint(
          '🌐 Localização enviada: ${posicao.latitude}, ${posicao.longitude}');
    } catch (e) {
      // Tarefa em background — falha aqui não deve travar nada, só tenta
      // de novo no próximo ciclo (30 min depois).
      debugPrint('❌ Erro ao enviar localização para a API: $e');
    }
  }
}
