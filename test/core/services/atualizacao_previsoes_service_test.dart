import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/services/atualizacao_previsoes_service.dart';

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

final _t0 = DateTime.utc(2026, 10, 21, 12);

/// Fontes simuladas: registram a posição recebida e podem falhar.
class _Fontes {
  final chamadas = <String, List<(double, double)>>{};
  final falhando = <String>{};
  Duration atraso = Duration.zero;

  Map<String, FontePrevisao> get mapa => {
        for (final nome in ['ondas', 'tempo', 'clorofila'])
          nome: (lat, lon) async {
            if (atraso > Duration.zero) await Future<void>.delayed(atraso);
            chamadas.putIfAbsent(nome, () => []).add((lat, lon));
            if (falhando.contains(nome)) throw Exception('sem rede (simulado)');
          },
      };

  int get rodadas => chamadas['ondas']?.length ?? 0;
}

Future<void> _gravarPosicao(double lat, DateTime quando,
    {String validacao = 'valida'}) async {
  await DatabaseHelper.instance.insert('localizacao_historico', {
    'data_hora': quando.toIso8601String(),
    'latitude': lat,
    'longitude': -39.9,
    'validacao': validacao,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late _Fontes fontes;

  Future<bool> atualizar(DateTime agora) =>
      AtualizacaoPrevisoesService.atualizarSeNecessario(
          agora: agora, fontes: fontes.mapa);

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atlas_previsoes_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    await DatabaseHelper.resetForTesting();
    fontes = _Fontes();
  });

  tearDown(() async {
    await DatabaseHelper.resetForTesting();
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('sem posição da embarcação ainda: não atualiza', () async {
    expect(await atualizar(_t0), isFalse);
    expect(fontes.rodadas, 0);
  });

  test('atualiza todas as fontes na última posição VÁLIDA', () async {
    await _gravarPosicao(-2.9, _t0.subtract(const Duration(minutes: 10)));
    // Mais recente, mas suspeita (salto de GPS): não deve ser usada.
    await _gravarPosicao(-8.0, _t0.subtract(const Duration(minutes: 1)),
        validacao: 'suspeita');

    expect(await atualizar(_t0), isTrue);

    for (final nome in ['ondas', 'tempo', 'clorofila']) {
      expect(fontes.chamadas[nome], [(-2.9, -39.9)]);
    }
    expect(await AtualizacaoPrevisoesService.ultimaAtualizacao(), _t0);
  });

  test('dentro do intervalo não atualiza de novo; depois dele, sim', () async {
    await _gravarPosicao(-2.9, _t0);
    await atualizar(_t0); // padrão: 60 min

    expect(await atualizar(_t0.add(const Duration(minutes: 59))), isFalse);
    expect(fontes.rodadas, 1);

    expect(await atualizar(_t0.add(const Duration(minutes: 61))), isTrue);
    expect(fontes.rodadas, 2);
  });

  test('intervalo configurável (30 min, 1, 2, 3, 4 h)', () async {
    expect(AtualizacaoPrevisoesService.opcoesMinutos, [30, 60, 120, 180, 240]);
    await _gravarPosicao(-2.9, _t0);

    await AtualizacaoPrevisoesService.definirIntervaloMinutos(30);
    expect(await AtualizacaoPrevisoesService.intervaloMinutos(), 30);
    await atualizar(_t0);
    expect(await atualizar(_t0.add(const Duration(minutes: 31))), isTrue);

    await AtualizacaoPrevisoesService.definirIntervaloMinutos(240);
    expect(
        await atualizar(_t0.add(const Duration(minutes: 31 + 239))), isFalse);
    expect(
        await atualizar(_t0.add(const Duration(minutes: 31 + 241))), isTrue);
  });

  test('intervalo fora das opções é recusado; sem preferência, vale 1 h',
      () async {
    expect(await AtualizacaoPrevisoesService.intervaloMinutos(), 60);
    expect(() => AtualizacaoPrevisoesService.definirIntervaloMinutos(45),
        throwsArgumentError);
  });

  test('falha parcial ainda conta como atualizada', () async {
    await _gravarPosicao(-2.9, _t0);
    fontes.falhando.add('clorofila');

    expect(await atualizar(_t0), isTrue);
    expect(await AtualizacaoPrevisoesService.ultimaAtualizacao(), _t0);
  });

  test('sem rede nenhuma: não marca como atualizada e espera antes de tentar de novo',
      () async {
    await _gravarPosicao(-2.9, _t0);
    fontes.falhando.addAll(['ondas', 'tempo', 'clorofila']);

    await atualizar(_t0);
    expect(await AtualizacaoPrevisoesService.ultimaAtualizacao(), isNull);

    // Dentro da espera após falha (15 min): não tenta.
    expect(await atualizar(_t0.add(const Duration(minutes: 10))), isFalse);
    expect(fontes.rodadas, 1);

    // Depois dela, com a rede de volta: atualiza.
    fontes.falhando.clear();
    expect(await atualizar(_t0.add(const Duration(minutes: 16))), isTrue);
    expect(await AtualizacaoPrevisoesService.ultimaAtualizacao(),
        _t0.add(const Duration(minutes: 16)));
  });

  test('chamadas simultâneas fazem uma única atualização', () async {
    await _gravarPosicao(-2.9, _t0);
    fontes.atraso = const Duration(milliseconds: 30);

    await Future.wait([atualizar(_t0), atualizar(_t0), atualizar(_t0)]);

    expect(fontes.rodadas, 1);
  });

  test('outro isolate já está atualizando (tentativa recente): não repete',
      () async {
    await _gravarPosicao(-2.9, _t0);
    fontes.falhando.addAll(['ondas', 'tempo', 'clorofila']);
    await atualizar(_t0); // deixa a marca de tentativa no SQLite

    fontes.falhando.clear();
    expect(await atualizar(_t0.add(const Duration(minutes: 1))), isFalse);
  });

  test('relógio do aparelho voltou no tempo: não trava a atualização',
      () async {
    await _gravarPosicao(-2.9, _t0);
    await atualizar(_t0);

    expect(await atualizar(_t0.subtract(const Duration(days: 1))), isTrue);
  });

  test('uma fonte travada não derruba a rotina (nunca lança)', () async {
    await _gravarPosicao(-2.9, _t0);
    final r = await AtualizacaoPrevisoesService.atualizarSeNecessario(
      agora: _t0,
      fontes: {'quebrada': (lat, lon) async => throw StateError('bug')},
    );
    expect(r, isTrue);
    expect(await AtualizacaoPrevisoesService.ultimaAtualizacao(), isNull);
  });
}
