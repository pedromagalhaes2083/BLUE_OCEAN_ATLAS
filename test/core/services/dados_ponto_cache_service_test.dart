import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/services/dados_ponto_cache_service.dart';

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atlas_cache_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    await DatabaseHelper.resetForTesting();
  });

  tearDown(() async {
    await DatabaseHelper.resetForTesting();
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

  group('buscarComCache — cache primeiro', () {
    Future<String> semRede(Duration _) async =>
        throw const SocketException('sem sinal (simulado)');

    Future<void> salvarOnda(String corpo) => DadosPontoCacheService.salvar(
        tipo: 'onda', latitude: -2.9, longitude: -39.9, corpo: corpo);

    test('cache válido volta na hora, sem ir à rede', () async {
      await salvarOnda('{"v": 1}');
      var foiARede = false;

      final r = await DadosPontoCacheService.buscarComCache(
        tipo: 'onda',
        latitude: -2.9,
        longitude: -39.9,
        aindaValido: (_) => true,
        daRede: (_) async {
          foiARede = true;
          return '{"v": 2}';
        },
      );

      expect(foiARede, isFalse);
      expect(r.corpo, '{"v": 1}');
      expect(r.offlineDesde, isNull);
    });

    test('cache vencido: tenta a rede com timeout curto e atualiza', () async {
      await salvarOnda('{"v": 1}');
      Duration? timeoutUsado;

      final r = await DadosPontoCacheService.buscarComCache(
        tipo: 'onda',
        latitude: -2.9,
        longitude: -39.9,
        aindaValido: (_) => false,
        daRede: (timeout) async {
          timeoutUsado = timeout;
          return '{"v": 2}';
        },
      );

      expect(r.corpo, '{"v": 2}');
      expect(timeoutUsado, DadosPontoCacheService.timeoutComCache);
      final salvo = await DadosPontoCacheService.ler(
          tipo: 'onda', latitude: -2.9, longitude: -39.9);
      expect(salvo!.corpo, '{"v": 2}');
    });

    test('cache vencido e sem rede: usa o salvo, marcado offline', () async {
      await salvarOnda('{"v": 1}');

      final r = await DadosPontoCacheService.buscarComCache(
        tipo: 'onda',
        latitude: -2.9,
        longitude: -39.9,
        aindaValido: (_) => false,
        daRede: semRede,
      );

      expect(r.corpo, '{"v": 1}');
      expect(r.offlineDesde, isNotNull);
    });

    test('sem cache: usa o timeout longo e propaga o erro da rede', () async {
      Duration? timeoutUsado;
      await expectLater(
        DadosPontoCacheService.buscarComCache(
          tipo: 'onda',
          latitude: -2.9,
          longitude: -39.9,
          aindaValido: (_) => true,
          timeoutSemCache: const Duration(seconds: 20),
          daRede: (timeout) {
            timeoutUsado = timeout;
            return semRede(timeout);
          },
        ),
        throwsA(isA<SocketException>()),
      );
      expect(timeoutUsado, const Duration(seconds: 20));
    });

    test('serveOffline recusa um salvo antigo demais', () async {
      await salvarOnda('{"v": 1}');
      await expectLater(
        DadosPontoCacheService.buscarComCache(
          tipo: 'onda',
          latitude: -2.9,
          longitude: -39.9,
          aindaValido: (_) => false,
          serveOffline: (_) => false,
          daRede: semRede,
        ),
        throwsA(isA<SocketException>()),
      );
    });

    test('resposta inválida da rede não sobrescreve o cache', () async {
      await salvarOnda('{"v": 1}');
      final r = await DadosPontoCacheService.buscarComCache(
        tipo: 'onda',
        latitude: -2.9,
        longitude: -39.9,
        aindaValido: (_) => false,
        daRede: (_) async => throw Exception('HTTP 503'),
      );

      expect(r.corpo, '{"v": 1}');
      final salvo = await DadosPontoCacheService.ler(
          tipo: 'onda', latitude: -2.9, longitude: -39.9);
      expect(salvo!.corpo, '{"v": 1}');
    });

    test('chave própria (ex.: profundidade exata) não se mistura com a padrão',
        () async {
      await salvarOnda('{"aproximado": true}');

      final r = await DadosPontoCacheService.buscarComCache(
        tipo: 'onda',
        latitude: -2.9,
        longitude: -39.9,
        chave: 'onda_exata:-2.9000:-39.9000',
        aindaValido: (_) => true,
        daRede: (_) async => '{"exato": true}',
      );

      expect(r.corpo, '{"exato": true}');
      final exata =
          await DadosPontoCacheService.lerPorChave('onda_exata:-2.9000:-39.9000');
      expect(exata!.corpo, '{"exato": true}');
    });

    test('forcarAtualizacao: vai à rede mesmo com cache válido, timeout longo',
        () async {
      await salvarOnda('{"v": 1}');
      Duration? timeoutUsado;

      final r = await DadosPontoCacheService.buscarComCache(
        tipo: 'onda',
        latitude: -2.9,
        longitude: -39.9,
        aindaValido: (_) => true,
        forcarAtualizacao: true,
        timeoutSemCache: const Duration(seconds: 15),
        daRede: (timeout) async {
          timeoutUsado = timeout;
          return '{"v": 2}';
        },
      );

      expect(r.corpo, '{"v": 2}');
      expect(timeoutUsado, const Duration(seconds: 15));
    });

    test('forcarAtualizacao sem rede: mantém o cache e marca offline',
        () async {
      await salvarOnda('{"v": 1}');

      final r = await DadosPontoCacheService.buscarComCache(
        tipo: 'onda',
        latitude: -2.9,
        longitude: -39.9,
        aindaValido: (_) => true,
        forcarAtualizacao: true,
        daRede: semRede,
      );

      expect(r.corpo, '{"v": 1}');
      expect(r.offlineDesde, isNotNull);
    });
  });

  group('armazenamento no SQLite', () {
    test('poda as entradas mais antigas acima do limite, sem tocar nas meta',
        () async {
      await DadosPontoCacheService.salvarMeta('preferencia', '30');
      for (var i = 0; i < 305; i++) {
        await DadosPontoCacheService.salvarPorChave('ponto:$i', '{}');
      }

      final db = await DatabaseHelper.instance.database;
      final restantes = await db.rawQuery(
          "SELECT COUNT(*) AS n FROM cache_dados WHERE chave LIKE 'ponto:%'");
      expect(restantes.single['n'], 300);
      expect(await DadosPontoCacheService.lerMeta('preferencia'), '30');
    });

    test('sobrevive a fechar e reabrir o banco ("reiniciar o app")', () async {
      await DadosPontoCacheService.salvar(
          tipo: 'onda', latitude: -2.9, longitude: -39.9, corpo: '{"v": 1}');
      await DatabaseHelper.resetForTesting();

      final salvo = await DadosPontoCacheService.ler(
          tipo: 'onda', latitude: -2.9, longitude: -39.9);
      expect(salvo!.corpo, '{"v": 1}');
    });
  });

  group('maisRecenteQue', () {
    final agora = DateTime(2026, 10, 21, 12);
    final validade = DadosPontoCacheService.maisRecenteQue(
        const Duration(minutes: 30),
        relogio: () => agora);

    test('dentro da validade', () {
      expect(validade(agora.subtract(const Duration(minutes: 29))), isTrue);
    });

    test('fora da validade', () {
      expect(validade(agora.subtract(const Duration(minutes: 31))), isFalse);
    });

    test('salvo "no futuro" (relógio voltou) não conta como recente', () {
      expect(validade(agora.add(const Duration(hours: 1))), isFalse);
    });
  });
}
