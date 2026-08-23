import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/recomendacao/data/recomendacao_repository.dart';
import '../../features/recomendacao/domain/models/recomendacao.dart';
import '../config/config.dart';
import '../config/constantes.dart';

/// Avisa (notificação local) quando o servidor gera uma recomendação nova —
/// checado pela mesma tarefa periódica do rastreamento de GPS (ver
/// `location_worker.dart`), então só roda enquanto há uma viagem em
/// andamento, no intervalo configurado pelo usuário (mínimo 15 min no
/// Android). Não é push de verdade (não exige servidor/Firebase): compara o
/// que a API retorna agora com a última verificação salva localmente.
class RecomendacaoNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _inicializado = false;

  static const _canalId = 'recomendacoes';
  static const _canalNome = 'Recomendações';
  static const _canalDescricao =
      'Avisa quando uma recomendação de pesca nova é gerada';

  /// Chamado tanto no app em primeiro plano (main.dart) quanto na isolate
  /// de background do WorkManager — precisa ser idempotente e não depender
  /// de nada que só exista com o app aberto.
  static Future<void> inicializar({
    void Function(String? payload)? aoTocarNotificacao,
  }) async {
    if (_inicializado) return;

    const configAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: configAndroid),
      onDidReceiveNotificationResponse: (resposta) {
        aoTocarNotificacao?.call(resposta.payload);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _canalId,
          _canalNome,
          description: _canalDescricao,
          importance: Importance.high,
        ));

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _inicializado = true;
  }

  /// Busca as recomendações atuais e notifica se houver alguma criada
  /// depois da última verificação. Na primeira execução (nunca verificou
  /// antes) só grava a marca d'água, sem notificar — senão toda recomendação
  /// já existente virava notificação na estreia da funcionalidade.
  static Future<void> verificarNovas() async {
    try {
      await inicializar();

      final recomendacoes = await RecomendacaoRepository().listar();
      if (recomendacoes.isEmpty) return;

      final comData = recomendacoes.where((r) => r.criadoEm != null).toList();
      if (comData.isEmpty) return;

      final maisRecente = comData
          .map((r) => r.criadoEm!)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      final ultimaVerificacaoStr =
          await Config.obtem(Constantes.ultimaVerificacaoRecomendacoes);

      if (ultimaVerificacaoStr.isEmpty) {
        await _salvarMarcaDagua(maisRecente);
        return;
      }

      final ultimaVerificacao = DateTime.tryParse(ultimaVerificacaoStr);
      if (ultimaVerificacao == null) {
        await _salvarMarcaDagua(maisRecente);
        return;
      }

      final novas = comData
          .where((r) => r.criadoEm!.isAfter(ultimaVerificacao))
          .toList()
        ..sort((a, b) => b.criadoEm!.compareTo(a.criadoEm!));

      if (novas.isNotEmpty) {
        await _notificar(novas);
      }

      await _salvarMarcaDagua(maisRecente);
    } catch (e) {
      debugPrint('❌ Erro ao verificar novas recomendações: $e');
    }
  }

  static Future<void> _salvarMarcaDagua(DateTime instante) {
    return Config.grava(
      Constantes.ultimaVerificacaoRecomendacoes,
      instante.toIso8601String(),
    );
  }

  static Future<void> _notificar(List<Recomendacao> novas) async {
    const detalhesAndroid = AndroidNotificationDetails(
      _canalId,
      _canalNome,
      channelDescription: _canalDescricao,
      importance: Importance.high,
      priority: Priority.high,
    );
    const detalhes = NotificationDetails(android: detalhesAndroid);

    if (novas.length == 1) {
      final r = novas.first;
      await _plugin.show(
        r.id.hashCode,
        'Nova recomendação de pesca',
        r.titulo.isNotEmpty
            ? '${r.titulo} · score ${r.score.round()}'
            : 'Score ${r.score.round()}',
        detalhes,
        payload: r.id,
      );
    } else {
      await _plugin.show(
        'recomendacoes_multiplas'.hashCode,
        '${novas.length} novas recomendações de pesca',
        novas.map((r) => r.titulo.isNotEmpty ? r.titulo : 'Recomendação').join(', '),
        detalhes,
      );
    }
  }
}
