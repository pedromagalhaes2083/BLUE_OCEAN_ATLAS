import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/core/services/producao_reporter_service.dart';

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
    tempDir = await Directory.systemTemp.createTemp('atlas_producao_sync_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    await DatabaseHelper.resetForTesting();
  });

  tearDown(() async {
    await DatabaseHelper.resetForTesting();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
      'sincronizacaoHabilitada fica desligada até o backend ter o endpoint real',
      () {
    expect(ProducaoReporterService.sincronizacaoHabilitada, isFalse);
  });

  test(
      'sincronizarPendentes não faz nenhuma chamada de rede nem marca '
      'registros como sincronizados enquanto a flag estiver desligada',
      () async {
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

    // Não deve lançar nem tentar rede — a flag desligada retorna cedo.
    await ProducaoReporterService.sincronizarPendentes();

    final pendentes = await helper.queryWhere(
      'producao_registro',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    expect(pendentes, hasLength(1));
  });
}
