import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Cache genérico "por ponto" pra respostas cruas de APIs externas de
/// meteorologia/mar (Open-Meteo, Open-Meteo Marine, OpenTopoData) — guarda
/// a última resposta bem-sucedida por tipo+coordenada arredondada, pra dar
/// alguma resiliência quando não há sinal no mar (decisão de 2026-09:
/// "cache local dos dados de meteorologia/maré por ponto" — hoje uma falha
/// de rede simplesmente deixa a tela sem dado nenhum).
///
/// Guarda a resposta crua (o corpo do JSON como veio da API), não o modelo
/// já parseado — quem chama decodifica com o mesmo `fromJson` que já usa
/// pra resposta de rede, sem precisar de `toJson`/`fromJson` extra nos
/// modelos nem duplicar lógica de parsing.
///
/// Coordenada arredondada a 2 casas decimais (~1,1 km no equador) — os
/// dados variam suavemente nessa escala, então uma consulta um pouco
/// deslocada da anterior (ex: embarcação se moveu um pouco) ainda
/// reaproveita o cache; não precisa ser um ponto exato.
class DadosPontoCacheService {
  static const _boxName = 'dados_ponto_cache';

  /// Limite de entradas guardadas — sem isso, cada ponto novo consultado
  /// (mapa, alerta de rota, condições do mar) cresceria a box pra sempre.
  /// 300 é generoso pra uma sessão de pesca (bem mais que os pontos que um
  /// mestre consultaria numa única viagem).
  static const _maxEntradas = 300;

  static Future<Box<String>> _abrirBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
    return Hive.box<String>(_boxName);
  }

  static String _chave(String tipo, double latitude, double longitude) =>
      '$tipo:${latitude.toStringAsFixed(2)}:${longitude.toStringAsFixed(2)}';

  /// Salva a resposta crua de uma consulta bem-sucedida. `tipo` distingue a
  /// origem (ex: `'onda'`, `'clima'`, `'profundidade'`) — o mesmo ponto pode
  /// ter uma entrada de cache por tipo.
  static Future<void> salvar({
    required String tipo,
    required double latitude,
    required double longitude,
    required String corpo,
  }) async {
    final box = await _abrirBox();
    await box.put(
      _chave(tipo, latitude, longitude),
      jsonEncode({'corpo': corpo, 'em': DateTime.now().toIso8601String()}),
    );
    await _podarSeNecessario(box);
  }

  /// Lê a última resposta cacheada pra esse tipo+ponto, ou `null` se nunca
  /// foi salva (1ª consulta desse ponto sem nunca ter tido rede).
  static Future<({String corpo, DateTime em})?> ler({
    required String tipo,
    required double latitude,
    required double longitude,
  }) async {
    final box = await _abrirBox();
    final bruto = box.get(_chave(tipo, latitude, longitude));
    if (bruto == null) return null;
    try {
      final json = jsonDecode(bruto) as Map<String, dynamic>;
      return (
        corpo: json['corpo'] as String,
        em: DateTime.parse(json['em'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  /// Remove as entradas mais antigas quando a box passa de [_maxEntradas].
  static Future<void> _podarSeNecessario(Box<String> box) async {
    if (box.length <= _maxEntradas) return;

    final porIdade = box.keys.cast<String>().map((chave) {
      DateTime em;
      try {
        final bruto = box.get(chave);
        em = DateTime.parse((jsonDecode(bruto!) as Map<String, dynamic>)['em'] as String);
      } catch (_) {
        em = DateTime.fromMillisecondsSinceEpoch(0);
      }
      return (chave: chave, em: em);
    }).toList()
      ..sort((a, b) => a.em.compareTo(b.em));

    final paraRemover = porIdade.length - _maxEntradas;
    for (var i = 0; i < paraRemover; i++) {
      await box.delete(porIdade[i].chave);
    }
  }

  /// Só pra teste — fecha e limpa a box entre um caso e outro (mesmo
  /// padrão de `DatabaseHelper.resetForTesting`/`Config.resetForTesting`).
  @visibleForTesting
  static Future<void> resetForTesting() async {
    if (Hive.isBoxOpen(_boxName)) {
      await Hive.box<String>(_boxName).deleteFromDisk();
    }
  }
}
