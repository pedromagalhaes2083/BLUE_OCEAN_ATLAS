import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/metereologia/data/previsao_tempo_repository.dart';
import '../../features/metereologia/data/wave_forecast_repository.dart';
import '../config/config.dart';
import '../config/constantes.dart';
import '../config/limiares_alerta.dart';
import '../utils/proximidade.dart';
import '../utils/severidade_condicoes.dart';

/// Notificação (com vibração) quando vento, corrente, onda ou swell no
/// ponto à frente da embarcação ficam severos — checado tanto em primeiro
/// plano (`AlertaRotaScreen`, a cada busca) quanto em segundo plano
/// (`location_worker.callbackDispatcher`, durante uma viagem em
/// andamento), pelo mesmo método, pra não duplicar a lógica de limiar em
/// dois lugares. Canal e inicialização são independentes de
/// [RecomendacaoNotificationService] — plugins/canais separados, mesmo
/// pacote.
class AlertaCondicaoNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  static const _canalId = 'alerta_condicao_severa';
  static const _canalNome = 'Condição severa à frente';
  static const _canalDescricao =
      'Avisa quando vento, corrente ou onda/swell no ponto à frente ficam severos';

  /// Intervalo mínimo entre duas notificações — sem isso, uma condição
  /// severa que persiste por horas (ex: viagem inteira com mar agitado)
  /// notificaria de novo a cada checagem em segundo plano (15 em 15 min).
  static const _intervaloMinimoEntreAlertas = Duration(hours: 1);

  static Future<void> inicializar() async {
    if (_inicializado) return;

    const configAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: configAndroid));

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _canalId,
          _canalNome,
          description: _canalDescricao,
          importance: Importance.max,
        ));

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _inicializado = true;
  }

  /// Confere os valores informados contra os limiares de
  /// `core/utils/severidade_condicoes.dart` e notifica se algum estourar —
  /// respeitando o intervalo mínimo entre alertas. Parâmetros nulos são
  /// ignorados (nem toda chamada tem swell, por exemplo).
  static Future<void> avaliarECondicionalmenteNotificar({
    double? ventoKmh,
    double? correnteNos,
    double? ondaM,
    double? swellM,
    double? temperaturaC,
  }) async {
    try {
      final limiares = await LimiaresAlerta.carregar();

      final motivos = <String>[];
      if (limiares.ventoAtivo &&
          ventoKmh != null &&
          ventoSevero(ventoKmh, limiares.ventoLimiarKmh)) {
        motivos.add('vento ${ventoKmh.toStringAsFixed(0)} km/h');
      }
      if (limiares.correnteAtivo &&
          correnteNos != null &&
          correnteSevera(correnteNos, limiares.correnteLimiarNos)) {
        motivos.add('corrente ${correnteNos.toStringAsFixed(1)} nós');
      }
      if (limiares.ondaAtivo &&
          ondaM != null &&
          alturaSevera(ondaM, limiares.ondaLimiarM)) {
        motivos.add('onda ${ondaM.toStringAsFixed(1)} m');
      }
      if (limiares.ondaAtivo &&
          swellM != null &&
          alturaSevera(swellM, limiares.ondaLimiarM)) {
        motivos.add('swell ${swellM.toStringAsFixed(1)} m');
      }
      if (limiares.temperaturaAtivo &&
          temperaturaC != null &&
          temperaturaSevera(temperaturaC, limiares.temperaturaLimiarC)) {
        motivos.add('temperatura ${temperaturaC.toStringAsFixed(1)}°C');
      }
      if (motivos.isEmpty) return;

      final ultimaStr =
          await Config.obtem(Constantes.ultimoAlertaCondicaoSeveraEm);
      final ultima = DateTime.tryParse(ultimaStr);
      if (ultima != null &&
          DateTime.now().difference(ultima) < _intervaloMinimoEntreAlertas) {
        return;
      }

      await inicializar();
      const detalhesAndroid = AndroidNotificationDetails(
        _canalId,
        _canalNome,
        channelDescription: _canalDescricao,
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
      );
      await _plugin.show(
        _canalId.hashCode,
        'Condição severa à frente',
        motivos.join(', ').replaceFirstMapped(
            RegExp('^.'), (m) => m.group(0)!.toUpperCase()),
        const NotificationDetails(android: detalhesAndroid),
      );

      await Config.grava(
        Constantes.ultimoAlertaCondicaoSeveraEm,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('❌ Erro ao avaliar/notificar condição severa: $e');
    }
  }

  /// Versão da checagem pra rodar em segundo plano, durante uma viagem —
  /// chamada pela mesma tarefa periódica do rastreamento de GPS (ver
  /// `location_worker.callbackDispatcher`), então só roda enquanto há uma
  /// viagem em andamento (é quando esse worker existe). Captura a posição
  /// e o rumo atuais, projeta o ponto à frente no alcance configurado (o
  /// mesmo usado em `AlertaRotaScreen`, salvo em [Constantes.alcanceAlertaRotaMn])
  /// e reaproveita [avaliarECondicionalmenteNotificar] pro resto.
  ///
  /// Sem rumo confiável (embarcação parada — mesmo critério de
  /// `AlertaRotaScreen._rumoValido`) não tem pra onde projetar, então só
  /// sai sem erro.
  static Future<void> verificarCondicoesAFrente() async {
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 20));

      if (posicao.speed <= 0.5 || posicao.heading < 0) return;

      final alcanceStr = await Config.obtem(Constantes.alcanceAlertaRotaMn, '30');
      final alcance = double.tryParse(alcanceStr) ?? 30;

      final ponto = projetarPontoNoRumo(
        posicao.latitude,
        posicao.longitude,
        posicao.heading,
        alcance,
      );

      // Em paralelo — no mar a conexão já é lenta, esperar as duas chamadas
      // em série dobraria a latência (e o risco de estourar a janela de
      // execução do WorkManager) à toa, já que uma não depende da outra.
      final previsaoFuture = PrevisaoTempoRepository()
          .buscar(latitude: ponto.latitude, longitude: ponto.longitude);
      final ondaFuture = WaveForecastRepository()
          .buscar(latitude: ponto.latitude, longitude: ponto.longitude);
      final previsao = await previsaoFuture;
      final onda = await ondaFuture;

      final velocidadeCorrenteKmh = onda.current?.oceanCurrentVelocity;
      await avaliarECondicionalmenteNotificar(
        ventoKmh: previsao.atual?.velocidadeVento,
        correnteNos:
            velocidadeCorrenteKmh != null ? velocidadeCorrenteKmh * 0.539957 : null,
        ondaM: onda.current?.waveHeight,
        swellM: onda.current?.swellWaveHeight,
        temperaturaC: onda.current?.seaSurfaceTemperature,
      );
    } catch (e) {
      debugPrint('❌ Erro ao verificar condições à frente em segundo plano: $e');
    }
  }
}
