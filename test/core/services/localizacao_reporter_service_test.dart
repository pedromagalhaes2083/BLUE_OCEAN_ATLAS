import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atlas/core/config/config.dart';
import 'package:atlas/core/config/constantes.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/gps/amostra_gps.dart';
import 'package:atlas/core/gps/validador_posicao.dart';
import 'package:atlas/core/services/localizacao_reporter_service.dart';
import 'package:atlas/features/localizacao/domain/models/localizacao_envio.dart';

import '../gps/fonte_gps_falsa.dart';

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

final _t0 = DateTime.utc(2026, 10, 20, 12);

AmostraGps _amostra(double lat, DateTime instante, {double precisao = 10}) =>
    AmostraGps(
      latitude: lat,
      longitude: -30.0,
      instante: instante,
      precisaoMetros: precisao,
      velocidadeMs: 4,
      rumoGraus: 90,
    );

/// Graus de latitude pra uma distância em metros.
double _metros(double m) => m / 1852 / 60;

Future<List<Map<String, Object?>>> _historico() async {
  final db = await DatabaseHelper.instance.database;
  return db.query('localizacao_historico', orderBy: 'data_hora ASC');
}

/// Grava posições válidas direto no banco (como se capturadas antes).
Future<void> _gravarPendentes(int quantidade) async {
  for (var i = 0; i < quantidade; i++) {
    await DatabaseHelper.instance.insert('localizacao_historico', {
      'data_hora': _t0.add(Duration(minutes: 15 * i)).toIso8601String(),
      'latitude': -10.0 + i * 0.01,
      'longitude': -30.0,
      'sincronizado': 0,
      'validacao': 'valida',
    });
  }
}

/// API simulada: registra o que recebeu; [falharCom] faz o envio lançar.
class _ApiFalsa {
  final enviados = <LocalizacaoEnvio>[];
  Object? falharCom;
  int tentativas = 0;

  Future<void> enviar(LocalizacaoEnvio dados) async {
    tentativas++;
    final erro = falharCom;
    if (erro != null) throw erro;
    enviados.add(dados);
  }
}

Future<void> _sincronizar(_ApiFalsa api, {bool sessao = true}) =>
    LocalizacaoReporterService.sincronizarPendentes(
      garantirSessao: () async => sessao,
      resolverDispositivoId: () async => '11111111-1111-1111-1111-111111111111',
      enviar: api.enviar,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory hiveDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atlas_gps_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    await DatabaseHelper.resetForTesting();

    hiveDir = await Directory.systemTemp.createTemp('atlas_gps_hive_');
    Hive.init(hiveDir.path);
    Config.resetForTesting();
    await Config.grava(Constantes.embarcacaoId, 'embarcacao-teste');
  });

  tearDown(() async {
    await DatabaseHelper.resetForTesting();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
    await Hive.deleteFromDisk();
    if (await hiveDir.exists()) await hiveDir.delete(recursive: true);
  });

  group('captura e gravação', () {
    test('posição válida é gravada com o instante do GPS, não o da gravação',
        () async {
      final fix = _amostra(-10.0, _t0);
      final r = await LocalizacaoReporterService.registrarPosicao(
        fonte: FonteGpsFalsa(posicoes: [fix]),
        agora: _t0.add(const Duration(seconds: 40)),
      );

      expect(r?.status, StatusValidacaoGps.valida);
      final linhas = await _historico();
      expect(linhas, hasLength(1));
      expect(linhas.single['data_hora'], _t0.toIso8601String());
      expect(linhas.single['validacao'], 'valida');
      expect(linhas.single['sincronizado'], 0);
      expect(linhas.single['direcao'], 90);
    });

    test('sem sinal, usa a última posição conhecida e marca se for antiga',
        () async {
      final antiga = _amostra(-10.0, _t0.subtract(const Duration(hours: 1)));
      final r = await LocalizacaoReporterService.registrarPosicao(
        fonte: FonteGpsFalsa(ultimaConhecida: antiga),
        agora: _t0,
      );

      expect(r?.status, StatusValidacaoGps.suspeita);
      expect(r?.motivos, contains(MotivoValidacaoGps.posicaoAntiga));
      final linha = (await _historico()).single;
      expect(linha['validacao'], 'suspeita');
      expect(linha['motivos_validacao'], 'posicaoAntiga');
    });

    test('sem sinal e sem última posição: nada é gravado, nada lança',
        () async {
      final r = await LocalizacaoReporterService.registrarPosicao(
          fonte: FonteGpsFalsa(), agora: _t0);
      expect(r, isNull);
      expect(await _historico(), isEmpty);
    });

    test('coordenada inválida não é gravada', () async {
      final r = await LocalizacaoReporterService.registrarPosicao(
        fonte: FonteGpsFalsa(posicoes: [_amostra(95.0, _t0)]),
        agora: _t0,
      );
      expect(r?.status, StatusValidacaoGps.invalida);
      expect(await _historico(), isEmpty);
    });

    test('salto implausível é guardado como suspeito, distinto da válida',
        () async {
      final fonte = FonteGpsFalsa(posicoes: [
        _amostra(-10.0, _t0),
        _amostra(-10.0 + _metros(9000), _t0.add(const Duration(seconds: 30))),
      ]);
      await LocalizacaoReporterService.registrarPosicao(fonte: fonte, agora: _t0);
      final r = await LocalizacaoReporterService.registrarPosicao(
          fonte: fonte, agora: _t0.add(const Duration(seconds: 30)));

      expect(r?.motivos, [MotivoValidacaoGps.saltoImplausivel]);
      final linhas = await _historico();
      expect(linhas.map((l) => l['validacao']), ['valida', 'suspeita']);
    });

    test('velocidade máxima configurada da embarcação é respeitada', () async {
      await Config.grava(Constantes.gpsVelocidadeMaximaNos, '5');
      // 1 milha em 10 min = 6 nós: acima do limite de 5.
      final fonte = FonteGpsFalsa(posicoes: [
        _amostra(-10.0, _t0),
        _amostra(-10.0 + _metros(1852), _t0.add(const Duration(minutes: 10))),
      ]);
      await LocalizacaoReporterService.registrarPosicao(fonte: fonte, agora: _t0);
      final r = await LocalizacaoReporterService.registrarPosicao(
          fonte: fonte, agora: _t0.add(const Duration(minutes: 10)));
      expect(r?.motivos, [MotivoValidacaoGps.saltoImplausivel]);
    });

    test('erro do SQLite ao gravar é tratado, sem derrubar o serviço',
        () async {
      final db = await DatabaseHelper.instance.database;
      await db.execute('DROP TABLE localizacao_historico');

      final r = await LocalizacaoReporterService.registrarPosicao(
        fonte: FonteGpsFalsa(posicoes: [_amostra(-10.0, _t0)]),
        agora: _t0,
      );
      expect(r, isNull);
    });
  });

  group('sincronização', () {
    test('com rede: envia em ordem e só então marca como sincronizado',
        () async {
      await _gravarPendentes(3);
      final api = _ApiFalsa();

      await _sincronizar(api);

      expect(api.enviados.map((e) => e.instante), [
        _t0,
        _t0.add(const Duration(minutes: 15)),
        _t0.add(const Duration(minutes: 30)),
      ]);
      expect(api.enviados.first.instante.isUtc, isTrue);
      final linhas = await _historico();
      expect(linhas.every((l) => l['sincronizado'] == 1), isTrue);
      expect(linhas.every((l) => l['sync_reservado_em'] == null), isTrue);
    });

    test('offline: nada é perdido, a fila para no primeiro erro de rede',
        () async {
      await _gravarPendentes(3);
      final api = _ApiFalsa()..falharCom = const SocketException('sem rede');

      await _sincronizar(api);

      expect(api.tentativas, 1);
      final linhas = await _historico();
      expect(linhas, hasLength(3));
      expect(linhas.every((l) => l['sincronizado'] == 0), isTrue);
      // Reserva desfeita: o registro volta a ficar disponível.
      expect(linhas.every((l) => l['sync_reservado_em'] == null), isTrue);
    });

    test('depois de reconectar, envia todo o backlog acumulado', () async {
      await _gravarPendentes(4);
      final api = _ApiFalsa()..falharCom = TimeoutException('rede fraca');
      await _sincronizar(api);
      expect(api.enviados, isEmpty);

      api.falharCom = null;
      await _sincronizar(api);

      expect(api.enviados, hasLength(4));
      expect((await _historico()).every((l) => l['sincronizado'] == 1), isTrue);
    });

    test('erro do servidor num registro não trava os outros', () async {
      await _gravarPendentes(3);
      var chamada = 0;
      final enviados = <LocalizacaoEnvio>[];
      await LocalizacaoReporterService.sincronizarPendentes(
        garantirSessao: () async => true,
        resolverDispositivoId: () async => 'disp',
        enviar: (dados) async {
          chamada++;
          if (chamada == 1) throw Exception('A requisição falhou: 400');
          enviados.add(dados);
        },
      );

      expect(enviados, hasLength(2));
      final linhas = await _historico();
      expect(linhas.map((l) => l['sincronizado']), [0, 1, 1]);
    });

    test('sem sessão (sem rede ou credencial): adia, sem perder nem lançar',
        () async {
      await _gravarPendentes(2);
      final api = _ApiFalsa();

      await _sincronizar(api, sessao: false);

      expect(api.tentativas, 0);
      expect((await _historico()).every((l) => l['sincronizado'] == 0), isTrue);
    });

    test('posições suspeitas ficam só no aparelho, nunca vão pra API',
        () async {
      await _gravarPendentes(1);
      await DatabaseHelper.instance.insert('localizacao_historico', {
        'data_hora': _t0.add(const Duration(minutes: 1)).toIso8601String(),
        'latitude': -9.0,
        'longitude': -30.0,
        'sincronizado': 0,
        'validacao': 'suspeita',
        'motivos_validacao': 'saltoImplausivel',
      });
      final api = _ApiFalsa();

      await _sincronizar(api);

      expect(api.enviados, hasLength(1));
      final suspeita =
          (await _historico()).firstWhere((l) => l['validacao'] == 'suspeita');
      expect(suspeita['sincronizado'], 0);
    });
  });

  group('sem duplicação e recuperação', () {
    test('sincronizações simultâneas enviam cada registro uma única vez',
        () async {
      await _gravarPendentes(3);
      final api = _ApiFalsa();

      await Future.wait([_sincronizar(api), _sincronizar(api), _sincronizar(api)]);

      expect(api.enviados, hasLength(3));
    });

    test('registro reservado por outra isolate (envio em andamento) é pulado',
        () async {
      await _gravarPendentes(2);
      final db = await DatabaseHelper.instance.database;
      final primeiro = (await _historico()).first;
      await db.update(
        'localizacao_historico',
        {'sync_reservado_em': DateTime.now().toUtc().toIso8601String()},
        where: 'id = ?',
        whereArgs: [primeiro['id']],
      );
      final api = _ApiFalsa();

      await _sincronizar(api);

      expect(api.enviados, hasLength(1));
      final linhas = await _historico();
      expect(linhas.first['sincronizado'], 0);
      expect(linhas.last['sincronizado'], 1);
    });

    test('reserva abandonada (serviço morto no meio do envio) é retomada',
        () async {
      await _gravarPendentes(1);
      final db = await DatabaseHelper.instance.database;
      final expirada = DateTime.now()
          .toUtc()
          .subtract(LocalizacaoReporterService.reservaExpiraApos +
              const Duration(minutes: 1))
          .toIso8601String();
      await db.update('localizacao_historico', {'sync_reservado_em': expirada});
      final api = _ApiFalsa();

      await _sincronizar(api);

      expect(api.enviados, hasLength(1));
      expect((await _historico()).single['sincronizado'], 1);
    });

    test('registro já sincronizado nunca é reenviado', () async {
      await _gravarPendentes(2);
      final api = _ApiFalsa();
      await _sincronizar(api);
      await _sincronizar(api);

      expect(api.enviados, hasLength(2));
    });
  });

  // Visto num Galaxy A26 real (2026-10-21): na abertura do app, o serviço e
  // a tela inicial capturavam o mesmo fix, gravado duas vezes; o servidor
  // recusava a segunda ("400 Posicionamento duplicado ou inválido") e ela
  // ficava pendente pra sempre.
  group('mesmo fix do GPS capturado duas vezes', () {
    test('é gravado uma única vez', () async {
      final fix = _amostra(-10.0, _t0);
      await LocalizacaoReporterService.registrarPosicao(
          amostraConhecida: fix, agora: _t0);
      await LocalizacaoReporterService.registrarPosicao(
          amostraConhecida: fix, agora: _t0);

      expect(await _historico(), hasLength(1));
    });

    test('capturas simultâneas do mesmo fix gravam uma única linha', () async {
      final fix = _amostra(-10.0, _t0);
      await Future.wait([
        LocalizacaoReporterService.registrarPosicao(
            amostraConhecida: fix, agora: _t0),
        LocalizacaoReporterService.registrarPosicao(
            amostraConhecida: fix, agora: _t0),
      ]);

      expect(await _historico(), hasLength(1));
    });

    test('fixes diferentes no mesmo segundo continuam sendo gravados',
        () async {
      await LocalizacaoReporterService.registrarPosicao(
          amostraConhecida: _amostra(-10.0, _t0), agora: _t0);
      await LocalizacaoReporterService.registrarPosicao(
          amostraConhecida: _amostra(-10.0001, _t0), agora: _t0);

      expect(await _historico(), hasLength(2));
    });

    test('duplicata antiga já pendente: marcada como enviada sem chamar a API',
        () async {
      // Situação do aparelho: a gêmea foi enviada, a duplicata ficou presa.
      for (final sincronizado in [1, 0]) {
        await DatabaseHelper.instance.insert('localizacao_historico', {
          'data_hora': _t0.toIso8601String(),
          'latitude': -2.9,
          'longitude': -39.9,
          'sincronizado': sincronizado,
          'validacao': 'valida',
        });
      }
      final api = _ApiFalsa();

      await _sincronizar(api);

      expect(api.tentativas, 0);
      expect((await _historico()).every((l) => l['sincronizado'] == 1), isTrue);
    });

    test('duas duplicatas pendentes: envia uma, marca a outra', () async {
      for (var i = 0; i < 2; i++) {
        await DatabaseHelper.instance.insert('localizacao_historico', {
          'data_hora': _t0.toIso8601String(),
          'latitude': -2.9,
          'longitude': -39.9,
          'sincronizado': 0,
          'validacao': 'valida',
        });
      }
      final api = _ApiFalsa();

      await _sincronizar(api);

      expect(api.enviados, hasLength(1));
      expect((await _historico()).every((l) => l['sincronizado'] == 1), isTrue);
    });
  });
}
