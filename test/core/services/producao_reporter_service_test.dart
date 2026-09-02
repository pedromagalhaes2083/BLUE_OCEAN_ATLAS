import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atlas/core/config/config.dart';
import 'package:atlas/core/config/constantes.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/services/producao_reporter_service.dart';

class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

/// Token sem 3 partes separadas por ponto — `decodeJwtPayload` devolve
/// `{}` pra ele (sem lançar), então `exp` fica nulo e `AuthService
/// .isLoggedIn()` "assume válido" (ver doc lá). Basta pra passar a
/// checagem de sessão sem precisar de um JWT de verdade — os testes aqui
/// nunca chegam a fazer chamada de rede de qualquer forma (todos os casos
/// cobertos são pulados/adiados antes disso).
const _tokenFalsoValido = 'token-de-teste-sem-jwt-de-verdade';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory hiveDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atlas_producao_sync_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    await DatabaseHelper.resetForTesting();

    hiveDir = await Directory.systemTemp.createTemp('atlas_producao_sync_hive_');
    Hive.init(hiveDir.path);
    Config.resetForTesting();
  });

  tearDown(() async {
    await DatabaseHelper.resetForTesting();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    await Hive.deleteFromDisk();
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
  });

  test('sincronizacaoHabilitada está ligada — endpoint real confirmado', () {
    expect(ProducaoReporterService.sincronizacaoHabilitada, isTrue);
  });

  test('sem sessão logada, não mexe na fila (nem tenta rede)', () async {
    final helper = DatabaseHelper.instance;
    await helper.insert('producao_registro', {
      'embarcacao_id': 'PE-1234',
      'data_hora': DateTime(2026, 8, 17).toIso8601String(),
      'especie': 'Kihada',
      'quantidade_kg': 570.0,
      'tipo_peixe': 'kihada',
      'classificacao': 'faixa40mais',
      'quantidade_unidades': 12,
      'peso_medio_unitario': 47.5,
      'sincronizado': 0,
    });

    await ProducaoReporterService.sincronizarPendentes();

    final pendentes = await helper.queryWhere(
      'producao_registro',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    expect(pendentes, hasLength(1));
  });

  test(
      'registro sem tipo_peixe/classificacao (pré-v11) fica pendente, sem '
      'derrubar o restante da fila nem tentar rede', () async {
    await Config.grava(Constantes.authToken, _tokenFalsoValido);

    final helper = DatabaseHelper.instance;
    await helper.insert('producao_registro', {
      'embarcacao_id': 'PE-1234',
      'data_hora': DateTime(2026, 8, 17).toIso8601String(),
      'especie': 'Kihada',
      'quantidade_kg': 500.0,
      'sincronizado': 0,
      // tipo_peixe/classificacao/quantidade_unidades ausentes — registro
      // antigo, sem como virar o payload de captura.
    });

    await ProducaoReporterService.sincronizarPendentes();

    final pendentes = await helper.queryWhere(
      'producao_registro',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    expect(pendentes, hasLength(1));
  });

  test(
      'registro sem viagem vinculada fica pendente (viagemId é obrigatório '
      'no backend), sem tentar rede', () async {
    await Config.grava(Constantes.authToken, _tokenFalsoValido);

    final helper = DatabaseHelper.instance;
    await helper.insert('producao_registro', {
      'embarcacao_id': 'PE-1234',
      'data_hora': DateTime(2026, 8, 17).toIso8601String(),
      'especie': 'Kihada',
      'quantidade_kg': 570.0,
      'tipo_peixe': 'kihada',
      'classificacao': 'faixa40mais',
      'quantidade_unidades': 12,
      'peso_medio_unitario': 47.5,
      'sincronizado': 0,
      'viagem_id': null,
    });

    await ProducaoReporterService.sincronizarPendentes();

    final pendentes = await helper.queryWhere(
      'producao_registro',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    expect(pendentes, hasLength(1));
  });

  test(
      'registro com viagem vinculada, mas cuja viagem local ainda não tem '
      'remoto_id, fica adiado — sem tentar rede', () async {
    await Config.grava(Constantes.authToken, _tokenFalsoValido);

    final helper = DatabaseHelper.instance;
    final viagemId = await helper.insert('viagem', {
      'data_inicio': DateTime(2026, 8, 17).toIso8601String(),
      'embarcacao_id': 'embarcacao-uuid',
      'status': 'em_andamento',
      // remoto_id ausente — POST de criação da viagem ainda não terminou
      // (ou falhou) do lado de fora.
    });

    await helper.insert('producao_registro', {
      'embarcacao_id': 'PE-1234',
      'data_hora': DateTime(2026, 8, 17).toIso8601String(),
      'especie': 'Kihada',
      'quantidade_kg': 570.0,
      'tipo_peixe': 'kihada',
      'classificacao': 'faixa40mais',
      'quantidade_unidades': 12,
      'peso_medio_unitario': 47.5,
      'sincronizado': 0,
      'viagem_id': viagemId,
    });

    await ProducaoReporterService.sincronizarPendentes();

    final pendentes = await helper.queryWhere(
      'producao_registro',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    expect(pendentes, hasLength(1));
  });
}
