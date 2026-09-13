import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:atlas/core/services/dados_ponto_cache_service.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atlas_hive_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ler() sem nada salvo devolve null', () async {
    final resultado = await DadosPontoCacheService.ler(
      tipo: 'onda',
      latitude: -2.9,
      longitude: -39.9,
    );
    expect(resultado, isNull);
  });

  test('salvar() e depois ler() devolve o mesmo corpo, com timestamp', () async {
    await DadosPontoCacheService.salvar(
      tipo: 'onda',
      latitude: -2.9,
      longitude: -39.9,
      corpo: '{"altura": 1.2}',
    );

    final resultado = await DadosPontoCacheService.ler(
      tipo: 'onda',
      latitude: -2.9,
      longitude: -39.9,
    );

    expect(resultado, isNotNull);
    expect(resultado!.corpo, '{"altura": 1.2}');
    expect(resultado.em.difference(DateTime.now()).abs().inMinutes, lessThan(1));
  });

  test('coordenada arredondada — ponto um pouco deslocado ainda reaproveita', () async {
    await DadosPontoCacheService.salvar(
      tipo: 'clima',
      latitude: -2.9012,
      longitude: -39.9034,
      corpo: '{"vento": 12}',
    );

    // Mesma 2ª casa decimal (-2.90 / -39.90) — deve bater com o cache acima.
    final resultado = await DadosPontoCacheService.ler(
      tipo: 'clima',
      latitude: -2.9041,
      longitude: -39.9009,
    );

    expect(resultado, isNotNull);
    expect(resultado!.corpo, '{"vento": 12}');
  });

  test('tipos diferentes no mesmo ponto não se confundem', () async {
    await DadosPontoCacheService.salvar(
      tipo: 'onda',
      latitude: -2.9,
      longitude: -39.9,
      corpo: '{"onda": true}',
    );
    await DadosPontoCacheService.salvar(
      tipo: 'clima',
      latitude: -2.9,
      longitude: -39.9,
      corpo: '{"clima": true}',
    );

    final onda = await DadosPontoCacheService.ler(
        tipo: 'onda', latitude: -2.9, longitude: -39.9);
    final clima = await DadosPontoCacheService.ler(
        tipo: 'clima', latitude: -2.9, longitude: -39.9);
    final profundidade = await DadosPontoCacheService.ler(
        tipo: 'profundidade', latitude: -2.9, longitude: -39.9);

    expect(onda!.corpo, '{"onda": true}');
    expect(clima!.corpo, '{"clima": true}');
    expect(profundidade, isNull);
  });

  test('salvar() de novo no mesmo ponto substitui o valor anterior', () async {
    await DadosPontoCacheService.salvar(
      tipo: 'onda',
      latitude: -2.9,
      longitude: -39.9,
      corpo: '{"versao": 1}',
    );
    await DadosPontoCacheService.salvar(
      tipo: 'onda',
      latitude: -2.9,
      longitude: -39.9,
      corpo: '{"versao": 2}',
    );

    final resultado = await DadosPontoCacheService.ler(
        tipo: 'onda', latitude: -2.9, longitude: -39.9);
    expect(resultado!.corpo, '{"versao": 2}');
  });
}
