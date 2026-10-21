import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/features/mapa/data/clorofila_repository.dart';

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

// ── Respostas no formato real do ERDDAP (ver clorofila_repository_test) ──

const _cabecalho = 'time,altitude,latitude,longitude,chlor_a\n'
    'UTC,m,degrees_north,degrees_east,mg m^-3\n';

String _ponto(String dia, double valor,
        {double lat = -2.1145885, double lon = -38.88541}) =>
    '$_cabecalho${dia}T12:00:00Z,0.0,$lat,$lon,$valor\n';

String _pontoSemDado(String dia) =>
    '$_cabecalho${dia}T12:00:00Z,0.0,-2.1145885,-38.88541,NaN\n';

String _grade(String dia) => '$_cabecalho'
    '${dia}T12:00:00Z,0.0,-2.1145885,-38.86458,NaN\n'
    '${dia}T12:00:00Z,0.0,-2.1354166,-38.88541,0.42\n'
    '${dia}T12:00:00Z,0.0,-1.9479166,-38.88541,0.55\n';

String _tempo(String dia) => 'time\nUTC\n${dia}T12:00:00Z\n';

/// ERDDAP simulado: conta as chamadas por tipo e responde conforme os
/// campos mutáveis.
class _ErddapFalso {
  String produto = '2026-10-15';
  String Function(String dia) respostaPonto = (dia) => _ponto(dia, 0.137);
  String Function(String dia) respostaGrade = _grade;
  Object? falhaPonto;
  Object? falhaGrade;
  Object? falhaTempo;
  int statusPonto = 200;

  /// Atraso simulado da rede, pra testes de concorrência.
  Duration atraso = Duration.zero;

  int chamadasPonto = 0;
  int chamadasGrade = 0;
  int chamadasTempo = 0;
  int get chamadas => chamadasPonto + chamadasGrade + chamadasTempo;

  late final cliente = MockClient((requisicao) async {
    final q = Uri.decodeComponent(requisicao.url.query);
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);
    if (q.startsWith('time[')) {
      chamadasTempo++;
      if (falhaTempo != null) throw falhaTempo!;
      return http.Response(_tempo(produto), 200);
    }
    // Ponto: intervalo de latitude com início == fim. Grade: intervalo.
    // Os intervalos na URL são altitude, latitude, longitude — a latitude é
    // o segundo.
    final lats = RegExp(r'\[\(([-\d.]+)\):1:\(([-\d.]+)\)\]')
        .allMatches(q)
        .elementAt(1);
    if (lats.group(1) == lats.group(2)) {
      chamadasPonto++;
      if (falhaPonto != null) throw falhaPonto!;
      return http.Response(respostaPonto(produto), statusPonto);
    }
    chamadasGrade++;
    if (falhaGrade != null) throw falhaGrade!;
    return http.Response(respostaGrade(produto), 200);
  });
}

class _CacheMemoria implements ArmazenamentoCacheClorofila {
  final dados = <String, String>{};
  bool falharLeitura = false;
  bool falharGravacao = false;

  @override
  Future<String?> ler(String chave) async {
    if (falharLeitura) throw const FileSystemException('leitura falhou (simulado)');
    return dados[chave];
  }

  @override
  Future<void> salvar(String chave, String valor) async {
    if (falharGravacao) throw const FileSystemException('disco cheio (simulado)');
    dados[chave] = valor;
  }
}

/// Ponto de teste combinado no histórico do projeto (-2.10600, -38.89306).
const _lat = -2.106;
const _lon = -38.89306;

void main() {
  late _ErddapFalso erddap;
  late _CacheMemoria cache;
  late DateTime agora;

  ClorofilaRepository repo({ArmazenamentoCacheClorofila? armazenamento}) =>
      ClorofilaRepository(
        client: erddap.cliente,
        cache: armazenamento ?? cache,
        relogio: () => agora,
      );

  setUp(() {
    ClorofilaRepository.resetEstadoParaTestes();
    erddap = _ErddapFalso();
    cache = _CacheMemoria();
    agora = DateTime.utc(2026, 10, 20, 9);
  });

  group('cache', () {
    test('miss: consulta a fonte externa e grava o resultado', () async {
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(r.valorMgM3, 0.137);
      expect(erddap.chamadasPonto, 1);
      expect(cache.dados.keys, contains(ClorofilaRepository.chaveCache(
          latitude: _lat, longitude: _lon)));
    });

    test('hit: mesmo produto e mesma célula, nenhuma chamada de rede', () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      final antes = erddap.chamadas;

      agora = agora.add(const Duration(hours: 2));
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(erddap.chamadas, antes);
      expect(r.valorMgM3, 0.137);
      expect(r.desatualizada, isFalse);
    });

    test('posições diferentes na mesma célula da grade compartilham o resultado',
        () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      final antes = erddap.chamadas;

      // ~300 m dali, ainda na mesma célula de 1/48°.
      await repo().buscarPontoOuAproximado(latitude: -2.108, longitude: -38.895);

      expect(erddap.chamadas, antes);
    });

    test('células diferentes nunca compartilham resultado', () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      erddap.respostaPonto = (dia) => _ponto(dia, 0.9, lat: -2.0729166);

      // Célula vizinha ao norte (+1/48°).
      final vizinha = await repo()
          .buscarPontoOuAproximado(latitude: _lat + 1 / 48, longitude: _lon);

      expect(erddap.chamadasPonto, 2);
      expect(vizinha.valorMgM3, 0.9);
      expect(
        ClorofilaRepository.chaveCache(latitude: _lat, longitude: _lon),
        isNot(ClorofilaRepository.chaveCache(latitude: _lat + 1 / 48, longitude: _lon)),
      );
    });

    test('raios de aproximação diferentes não se misturam', () {
      expect(
        ClorofilaRepository.chaveCache(latitude: _lat, longitude: _lon, raioNm: 10),
        isNot(ClorofilaRepository.chaveCache(latitude: _lat, longitude: _lon, raioNm: 5)),
      );
    });

    test('chave inclui dataset e versão do formato', () {
      final chave = ClorofilaRepository.chaveCache(latitude: _lat, longitude: _lon);
      expect(chave, contains(ClorofilaRepository.dataset));
      expect(chave, contains(ClorofilaRepository.versaoCache));
    });

    test('reutiliza o cache depois de "reiniciar" (repositório novo, armazenamento persistido)',
        () async {
      final dir = await Directory.systemTemp.createTemp('atlas_cloro_db_');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      PathProviderPlatform.instance = _FakePathProviderPlatform(dir.path);
      await DatabaseHelper.resetForTesting();
      try {
        const persistente = ArmazenamentoCacheClorofilaPersistente();
        await repo(armazenamento: persistente)
            .buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
        await DatabaseHelper.resetForTesting(); // "fecha o app"
        ClorofilaRepository.resetEstadoParaTestes();
        final antes = erddap.chamadas;

        // "Abre de novo": reabre o mesmo arquivo do banco.
        final r = await repo(armazenamento: persistente)
            .buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

        expect(erddap.chamadas, antes);
        expect(r.valorMgM3, 0.137);
      } finally {
        await DatabaseHelper.resetForTesting();
        await dir.delete(recursive: true);
      }
    });
  });

  group('validade pela data do produto', () {
    test('produto novo publicado: busca de novo e substitui', () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      erddap.produto = '2026-10-16';
      erddap.respostaPonto = (dia) => _ponto(dia, 0.25);
      agora = agora.add(ClorofilaRepository.intervaloVerificacaoProduto);
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(erddap.chamadasTempo, 1);
      expect(erddap.chamadasPonto, 2);
      expect(r.valorMgM3, 0.25);
      expect(r.data, DateTime.utc(2026, 10, 16, 12));
    });

    test('sem produto novo, depois do intervalo de verificação: só confere a data',
        () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      agora = agora.add(const Duration(hours: 7));
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(erddap.chamadasTempo, 1); // consulta leve, só o eixo de tempo
      expect(erddap.chamadasPonto, 1); // sem refazer a busca do dado
      expect(r.desatualizada, isFalse);
    });

    test('preserva a data original da observação (não a data da consulta)',
        () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      agora = DateTime.utc(2026, 10, 20, 23);
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(r.data, DateTime.utc(2026, 10, 15, 12));
    });

    test('relógio do aparelho voltou no tempo: não confia no registro, confere',
        () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      agora = agora.subtract(const Duration(days: 2));
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(erddap.chamadasTempo, 1);
    });
  });

  group('falhas e dados antigos', () {
    test('offline com cache: devolve na hora, marcado desatualizado, com a data original',
        () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      erddap.falhaTempo = const SocketException('sem rede');
      erddap.falhaPonto = const SocketException('sem rede');
      agora = agora.add(const Duration(hours: 8));
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(r.valorMgM3, 0.137);
      expect(r.desatualizada, isTrue);
      expect(r.data, DateTime.utc(2026, 10, 15, 12));
      // Não esperou mais um timeout tentando a busca completa.
      expect(erddap.chamadasPonto, 1);
    });

    test('produto novo existe mas a busca falha: devolve o antigo como desatualizado',
        () async {
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      erddap.produto = '2026-10-16';
      erddap.falhaPonto = TimeoutException('ERDDAP lento');
      agora = agora.add(const Duration(hours: 8));
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(r.desatualizada, isTrue);
      expect(r.data, DateTime.utc(2026, 10, 15, 12));
      // O cache não foi apagado: com a rede de volta, recupera o novo.
      erddap.falhaPonto = null;
      ClorofilaRepository.resetEstadoParaTestes();
      final depois =
          await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(depois.desatualizada, isFalse);
      expect(depois.data, DateTime.utc(2026, 10, 16, 12));
    });

    test('sem cache e sem rede: o erro chega a quem chamou (como antes)', () async {
      erddap.falhaPonto = const SocketException('sem rede');
      expect(
        repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon),
        throwsA(isA<SocketException>()),
      );
    });

    test('falha ao ler o cache: busca na rede, sem derrubar', () async {
      cache.falharLeitura = true;
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(r.valorMgM3, 0.137);
      expect(erddap.chamadasPonto, 1);
    });

    test('falha ao gravar o cache: devolve o resultado mesmo assim', () async {
      cache.falharGravacao = true;
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(r.valorMgM3, 0.137);
      expect(cache.dados, isEmpty);
    });

    test('entrada corrompida no cache é ignorada', () async {
      cache.dados[ClorofilaRepository.chaveCache(latitude: _lat, longitude: _lon)] =
          '{isso não é json';
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(r.valorMgM3, 0.137);
    });

    test('resposta inválida do endpoint não é cacheada', () async {
      erddap.respostaPonto = (_) => '<html>Service Unavailable</html>';
      await expectLater(
        repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon),
        throwsA(isA<FormatException>()),
      );
      expect(cache.dados, isEmpty);
    });

    test('erro HTTP do endpoint não é cacheado', () async {
      erddap.statusPonto = 503;
      await expectLater(
        repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon),
        throwsA(isA<Exception>()),
      );
      expect(cache.dados, isEmpty);
    });

    test('ponto sem dado: usa o pixel válido mais próximo da grade e cacheia',
        () async {
      erddap.respostaPonto = _pontoSemDado;
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(r.aproximado, isTrue);
      expect(r.valorMgM3, 0.42);
      expect(erddap.chamadasGrade, 1);

      final antes = erddap.chamadas;
      final deNovo =
          await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(erddap.chamadas, antes);
      expect(deNovo.aproximado, isTrue);
    });

    test('ponto e grade sem dado: devolve "sem dado" e não cacheia', () async {
      erddap.respostaPonto = _pontoSemDado;
      erddap.respostaGrade = (dia) => '$_cabecalho${dia}T12:00:00Z,0.0,-2.11,-38.88,NaN\n';

      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);

      expect(r.valorMgM3, isNull);
      expect(cache.dados.keys.where((k) => !k.endsWith(':produto')), isEmpty);
    });

    test('ponto sem dado e grade falhando: recupera numa nova tentativa', () async {
      erddap.respostaPonto = _pontoSemDado;
      erddap.falhaGrade = TimeoutException('grade lenta');
      final r1 = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(r1.valorMgM3, isNull);

      erddap.falhaGrade = null;
      final r2 = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(r2.valorMgM3, 0.42);
    });

    test('falha da consulta de ponto não trava a próxima tentativa', () async {
      erddap.falhaPonto = TimeoutException('ponto lento');
      await expectLater(
        repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon),
        throwsA(isA<TimeoutException>()),
      );

      erddap.falhaPonto = null;
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(r.valorMgM3, 0.137);
    });
  });

  group('concorrência', () {
    test('consultas simultâneas da mesma célula fazem uma única busca', () async {
      erddap.atraso = const Duration(milliseconds: 50);
      final resultados = await Future.wait([
        repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon),
        repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon),
        repo().buscarPontoOuAproximado(latitude: -2.108, longitude: -38.895),
      ]);

      expect(erddap.chamadasPonto, 1);
      expect(resultados.every((r) => r.valorMgM3 == 0.137), isTrue);
    });

    test('uma falha compartilhada não deixa a célula bloqueada', () async {
      erddap.atraso = const Duration(milliseconds: 20);
      erddap.falhaPonto = const SocketException('sem rede');
      final tentativas = [
        repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon),
        repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon),
      ];
      for (final t in tentativas) {
        await expectLater(t, throwsA(isA<SocketException>()));
      }

      erddap.falhaPonto = null;
      final r = await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      expect(r.valorMgM3, 0.137);
    });
  });

  group('medição (ambiente de teste, rede simulada)', () {
    test('tempo com cache válido vs. sem cache (latência de rede simulada)',
        () async {
      // Latência simulada de 300 ms por chamada — não é a do ERDDAP real
      // (que varia de ~1 s a timeout de 20–45 s); serve pra comparar os
      // dois caminhos no mesmo ambiente.
      erddap.atraso = const Duration(milliseconds: 300);
      final semCache = Stopwatch()..start();
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      semCache.stop();

      final comCache = Stopwatch()..start();
      await repo().buscarPontoOuAproximado(latitude: _lat, longitude: _lon);
      comCache.stop();

      // ignore: avoid_print
      print('[medição] sem cache: ${semCache.elapsedMilliseconds} ms, '
          '${erddap.chamadas} chamada(s) | com cache: '
          '${comCache.elapsedMilliseconds} ms, 0 chamadas');
      expect(comCache.elapsedMilliseconds, lessThan(semCache.elapsedMilliseconds));
    });
  });
}
