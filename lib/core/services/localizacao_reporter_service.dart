import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/dispositivo/data/dispositivo_repository.dart';
import '../../features/localizacao/data/localizacao_repository.dart';
import '../../features/localizacao/domain/models/localizacao_envio.dart';
import '../auth/auth_service.dart';
import '../config/config.dart';
import '../config/constantes.dart';
import '../database/database_helper.dart';
import 'device_id_service.dart';
import 'location_tracking_service.dart';

/// Captura a posição atual, grava no histórico local (`localizacao_historico`,
/// associada à viagem em andamento se houver) e sincroniza com a API todos
/// os registros ainda não enviados — inclusive os que ficaram pendentes de
/// execuções anteriores sem internet (`sincronizado = 0`).
///
/// Chamado periodicamente pela tarefa registrada em
/// [LocationTrackingService.iniciarRastreamento], no intervalo configurado
/// pelo usuário.
class LocalizacaoReporterService {
  /// Valor padrão informado pelo usuário — usado enquanto a tela de
  /// Configurações não tiver um valor próprio salvo para este aparelho.
  static const _embarcacaoIdPadrao = 'c8f1da10-e015-41c9-920f-ce2c512c3a95';

  static Future<void> registrarESincronizar() async {
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 20));

      int? bateriaNivel;
      try {
        bateriaNivel = await Battery().batteryLevel;
      } catch (_) {
        // Nível de bateria é informativo — segue sem ele se indisponível.
      }

      final viagens = await DatabaseHelper.instance.queryWhere(
        'viagem',
        where: 'status = ?',
        whereArgs: ['em_andamento'],
      );
      final viagemId = viagens.isNotEmpty ? viagens.first['id'] as int? : null;

      await DatabaseHelper.instance.insert('localizacao_historico', {
        'data_hora': DateTime.now().toUtc().toIso8601String(),
        'latitude': posicao.latitude,
        'longitude': posicao.longitude,
        'velocidade': posicao.speed,
        'precisao': posicao.accuracy,
        'altitude': posicao.altitude,
        'direcao': posicao.heading.round(),
        'bateria_nivel': bateriaNivel,
        'viagem_id': viagemId,
        'sincronizado': 0,
      });

      debugPrint(
          '📍 Posição registrada: ${posicao.latitude}, ${posicao.longitude}');
    } catch (e) {
      debugPrint('❌ Erro ao capturar/gravar posição: $e');
    }

    await sincronizarPendentes();
  }

  /// Envia pra API todos os registros locais ainda não sincronizados —
  /// funciona tanto pro registro que acabou de ser gravado quanto pra
  /// qualquer backlog acumulado enquanto o aparelho estava sem internet.
  static Future<void> sincronizarPendentes() async {
    if (!await AuthService.isLoggedIn()) {
      debugPrint(
          '⚠️ Sessão expirada — parando rastreamento em vez de tentar sincronizar sem token.');
      await LocationTrackingService().pararRastreamento();
      return;
    }

    final embarcacaoId = await Config.obtem(
      Constantes.embarcacaoId,
      _embarcacaoIdPadrao,
    );
    if (embarcacaoId.isEmpty) {
      debugPrint(
          '⚠️ Sincronização pulada: embarcacaoId não configurado (ver tela de Configurações).');
      return;
    }

    final pendentes = await DatabaseHelper.instance.queryWhere(
      'localizacao_historico',
      where: 'sincronizado = ?',
      whereArgs: [0],
      orderBy: 'data_hora ASC',
    );
    if (pendentes.isEmpty) return;

    // O backend exige um UUID nesse campo (confirmado via erro de
    // validação "dispositivoId must be a UUID") — não aceita o
    // identificador bruto do aparelho, só o UUID do registro correspondente.
    String dispositivoId;
    try {
      final deviceIdentificador = await DeviceIdService.obtemId();
      final dispositivo = await DispositivoRepository()
          .buscarPorIdentificador(deviceIdentificador);
      dispositivoId = dispositivo.id;
    } catch (e) {
      debugPrint(
          '❌ Sem internet ou erro ao buscar dispositivo — sincronização adiada: $e');
      return;
    }

    var enviados = 0;
    for (final registro in pendentes) {
      try {
        final velocidadeMs = (registro['velocidade'] as num?)?.toDouble();
        await LocalizacaoRepository().enviar(LocalizacaoEnvio(
          embarcacaoId: embarcacaoId,
          dispositivoId: dispositivoId,
          instante: DateTime.parse(registro['data_hora'] as String),
          latitude: registro['latitude'] as double,
          longitude: registro['longitude'] as double,
          precisaoMetros: (registro['precisao'] as num?)?.toDouble() ?? 0,
          altitude: (registro['altitude'] as num?)?.toDouble(),
          velocidadeNos: velocidadeMs != null ? velocidadeMs * 1.94384 : null,
          direcao: (registro['direcao'] as num?)?.toInt(),
          bateriaNivel: (registro['bateria_nivel'] as num?)?.toInt(),
        ));
        await DatabaseHelper.instance.update(
          'localizacao_historico',
          {'sincronizado': 1},
          id: registro['id'] as int,
        );
        enviados++;
      } catch (e) {
        debugPrint('❌ Erro ao sincronizar registro ${registro['id']}: $e');
        // Um registro com erro não deve travar a fila inteira — segue
        // tentando os outros pendentes.
      }
    }
    debugPrint(
        '🌐 Sincronização: $enviados/${pendentes.length} registros enviados');
  }
}
