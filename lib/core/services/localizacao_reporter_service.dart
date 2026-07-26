import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/dispositivo/data/dispositivo_repository.dart';
import '../../features/localizacao/data/localizacao_repository.dart';
import '../../features/localizacao/domain/models/localizacao_envio.dart';
import '../config/config.dart';
import '../config/constantes.dart';
import 'device_id_service.dart';

/// Obtém a posição atual do dispositivo e envia pra API via
/// [LocalizacaoRepository].
///
/// Chamado periodicamente (a cada 30 min) pela tarefa em background
/// registrada em [LocationTrackingService.startEnviarLocalizacaoParaApi].
class LocalizacaoReporterService {
  /// Valor padrão informado pelo usuário — usado enquanto a tela de
  /// Configurações não tiver um valor próprio salvo para este aparelho.
  static const _embarcacaoIdPadrao = '9b2aac19-ad31-4e6d-baf5-fb101a976c1b';

  static Future<void> enviarLocalizacaoAtual() async {
    try {
      final embarcacaoId = await Config.obtem(
        Constantes.embarcacaoId,
        _embarcacaoIdPadrao,
      );
      if (embarcacaoId.isEmpty) {
        debugPrint(
            '⚠️ Envio de localização pulado: embarcacaoId não configurado (ver tela de Configurações).');
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 20));

      final deviceIdentificador = await DeviceIdService.obtemId();
      final dispositivo = await DispositivoRepository()
          .buscarPorIdentificador(deviceIdentificador);

      int? bateriaNivel;
      try {
        bateriaNivel = await Battery().batteryLevel;
      } catch (_) {
        // Nível de bateria é informativo — segue sem ele se indisponível.
      }

      await LocalizacaoRepository().enviar(LocalizacaoEnvio(
        embarcacaoId: embarcacaoId,
        dispositivoId: dispositivo.id,
        instante: DateTime.now().toUtc(),
        latitude: posicao.latitude,
        longitude: posicao.longitude,
        precisaoMetros: posicao.accuracy,
        altitude: posicao.altitude,
        velocidadeNos: posicao.speed * 1.94384,
        direcao: posicao.heading.round(),
        bateriaNivel: bateriaNivel,
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
