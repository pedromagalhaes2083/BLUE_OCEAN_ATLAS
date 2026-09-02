import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atlas/core/database/database_helper.dart';

/// `getApplicationDocumentsDirectory()` usa um canal de plataforma que não
/// existe em `flutter test` — aponta pra um diretório temporário real em
/// vez de precisar de um dispositivo/emulador.
class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

Future<List<String>> _colunas(dynamic db, String tabela) async {
  final info = await db.rawQuery('PRAGMA table_info($tabela)');
  return info.map<String>((linha) => linha['name'] as String).toList();
}

Future<bool> _tabelaExiste(dynamic db, String tabela) async {
  final resultado = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
    [tabela],
  );
  return resultado.isNotEmpty;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('atlas_db_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    await DatabaseHelper.resetForTesting();
  });

  tearDown(() async {
    await DatabaseHelper.resetForTesting();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('schema — instalação nova (onCreate, versão atual)', () {
    test('cria todas as tabelas esperadas', () async {
      final db = await DatabaseHelper.instance.database;

      for (final tabela in [
        'embarcacao',
        'viagem',
        'localizacao_historico',
        'producao_registro',
        'ponto_marcado',
        'solicitacao_carta',
        'rota_planejada',
        'rota_planejada_ponto',
      ]) {
        expect(await _tabelaExiste(db, tabela), isTrue,
            reason: 'tabela "$tabela" deveria existir');
      }
    });

    test('producao_registro tem as colunas da classificação por peso (v11)',
        () async {
      final db = await DatabaseHelper.instance.database;
      final colunas = await _colunas(db, 'producao_registro');

      expect(
        colunas,
        containsAll([
          'tipo_peixe',
          'classificacao',
          'quantidade_unidades',
          'peso_medio_unitario',
          'precisao_metros',
        ]),
      );
    });

    test('rota_planejada tem embarcacao_id/viagem_id (v12)', () async {
      final db = await DatabaseHelper.instance.database;
      final colunas = await _colunas(db, 'rota_planejada');

      expect(colunas, containsAll(['embarcacao_id', 'viagem_id']));
    });

    test('ponto_marcado tem a coluna nome (v8)', () async {
      final db = await DatabaseHelper.instance.database;
      final colunas = await _colunas(db, 'ponto_marcado');

      expect(colunas, contains('nome'));
    });
  });

  group('CRUD genérico do DatabaseHelper', () {
    test('insert + query devolvem o registro salvo', () async {
      final helper = DatabaseHelper.instance;

      final id = await helper.insert('embarcacao', {
        'nome': 'ORCA BP',
        'quantidade_urnas': 4,
        'data_cadastro': DateTime(2026, 1, 1).toIso8601String(),
        'ativo': 1,
      });

      final linhas = await helper.query('embarcacao');

      expect(id, greaterThan(0));
      expect(linhas, hasLength(1));
      expect(linhas.first['nome'], 'ORCA BP');
    });

    test('insert de producao_registro grava os campos de classificação',
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

      final linhas = await helper.query('producao_registro');

      expect(linhas, hasLength(1));
      expect(linhas.first['classificacao'], 'faixa40mais');
      expect(linhas.first['quantidade_unidades'], 12);
    });

    test('update altera só o registro pelo id', () async {
      final helper = DatabaseHelper.instance;
      final id1 = await helper.insert('embarcacao', {
        'nome': 'Barco A',
        'quantidade_urnas': 1,
        'data_cadastro': DateTime(2026, 1, 1).toIso8601String(),
        'ativo': 1,
      });
      await helper.insert('embarcacao', {
        'nome': 'Barco B',
        'quantidade_urnas': 1,
        'data_cadastro': DateTime(2026, 1, 1).toIso8601String(),
        'ativo': 1,
      });

      await helper.update('embarcacao', {'nome': 'Barco A Renomeado'}, id: id1);

      final linhas = await helper.query('embarcacao');
      final nomes = linhas.map((l) => l['nome']).toSet();

      expect(nomes, {'Barco A Renomeado', 'Barco B'});
    });

    test('delete remove só o registro pelo id', () async {
      final helper = DatabaseHelper.instance;
      final id = await helper.insert('ponto_marcado', {
        'latitude': -3.0,
        'longitude': -40.0,
        'data_criacao': DateTime(2026, 1, 1).toIso8601String(),
      });

      await helper.delete('ponto_marcado', id: id);

      expect(await helper.query('ponto_marcado'), isEmpty);
    });

    test('queryWhere e deleteWhere filtram por condição arbitrária', () async {
      final helper = DatabaseHelper.instance;
      final rotaId = await helper.insert('rota_planejada', {
        'nome': 'Rota de teste',
        'data_criacao': DateTime(2026, 1, 1).toIso8601String(),
      });
      await helper.insert('rota_planejada_ponto', {
        'rota_planejada_id': rotaId,
        'latitude': -3.0,
        'longitude': -40.0,
        'ordem': 0,
      });
      await helper.insert('rota_planejada_ponto', {
        'rota_planejada_id': rotaId,
        'latitude': -3.1,
        'longitude': -40.1,
        'ordem': 1,
      });

      final pontos = await helper.queryWhere(
        'rota_planejada_ponto',
        where: 'rota_planejada_id = ?',
        whereArgs: [rotaId],
        orderBy: 'ordem ASC',
      );
      expect(pontos, hasLength(2));
      expect(pontos.first['ordem'], 0);

      await helper.deleteWhere(
        'rota_planejada_ponto',
        where: 'rota_planejada_id = ?',
        whereArgs: [rotaId],
      );
      expect(
        await helper.queryWhere(
          'rota_planejada_ponto',
          where: 'rota_planejada_id = ?',
          whereArgs: [rotaId],
        ),
        isEmpty,
      );
    });
  });

  group('viagem — no máximo uma em andamento (v15)', () {
    test(
        'índice único impede uma segunda linha com status = em_andamento',
        () async {
      final helper = DatabaseHelper.instance;
      await helper.insert('viagem', {
        'data_inicio': DateTime(2026, 1, 1).toIso8601String(),
        'embarcacao_id': 'embarcacao-uuid-1',
        'status': 'em_andamento',
      });

      expect(
        () => helper.insert('viagem', {
          'data_inicio': DateTime(2026, 1, 2).toIso8601String(),
          'embarcacao_id': 'embarcacao-uuid-1',
          'status': 'em_andamento',
        }),
        throwsA(anything),
      );

      final ativas = await helper.queryWhere(
        'viagem',
        where: 'status = ?',
        whereArgs: ['em_andamento'],
      );
      expect(ativas, hasLength(1));
    });

    test('viagens com outros status não são afetadas pelo índice', () async {
      final helper = DatabaseHelper.instance;
      await helper.insert('viagem', {
        'data_inicio': DateTime(2026, 1, 1).toIso8601String(),
        'embarcacao_id': 'embarcacao-uuid-1',
        'status': 'concluida',
      });
      await helper.insert('viagem', {
        'data_inicio': DateTime(2026, 1, 2).toIso8601String(),
        'embarcacao_id': 'embarcacao-uuid-1',
        'status': 'concluida',
      });
      await helper.insert('viagem', {
        'data_inicio': DateTime(2026, 1, 3).toIso8601String(),
        'embarcacao_id': 'embarcacao-uuid-1',
        'status': 'em_andamento',
      });

      final todas = await helper.query('viagem');
      expect(todas, hasLength(3));
    });

    test(
        'upgrade de uma instalação antiga (v14) com duas viagens em '
        'andamento finaliza todas menos a mais recente antes de criar o '
        'índice — sem isso, o CREATE UNIQUE INDEX quebraria a migração',
        () async {
      // Recria o schema como ele era na v14 (sem o índice), com estado
      // inválido que só existia por causa do bug corrigido nesta versão —
      // NovaViagemScreen agora impede isso na origem.
      final caminho = await DatabaseHelper.instance.caminhoArquivo();
      final dbAntigo = await databaseFactory.openDatabase(
        caminho,
        options: OpenDatabaseOptions(
          version: 14,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE viagem (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nome TEXT,
                data_inicio TEXT NOT NULL,
                data_termino TEXT,
                embarcacao_id TEXT,
                status TEXT NOT NULL,
                remoto_id TEXT
              )
            ''');
          },
        ),
      );
      final idAntiga = await dbAntigo.insert('viagem', {
        'data_inicio': DateTime(2026, 1, 1).toIso8601String(),
        'embarcacao_id': 'embarcacao-uuid-1',
        'status': 'em_andamento',
      });
      final idRecente = await dbAntigo.insert('viagem', {
        'data_inicio': DateTime(2026, 1, 5).toIso8601String(),
        'embarcacao_id': 'embarcacao-uuid-1',
        'status': 'em_andamento',
      });
      await dbAntigo.close();

      // Reabre pelo DatabaseHelper de verdade — dispara onUpgrade 14 → 15.
      final db = await DatabaseHelper.instance.database;

      final ativas = await db.query(
        'viagem',
        where: 'status = ?',
        whereArgs: ['em_andamento'],
      );
      expect(ativas, hasLength(1));
      expect(ativas.first['id'], idRecente);

      final finalizada = await db.query(
        'viagem',
        where: 'id = ?',
        whereArgs: [idAntiga],
      );
      expect(finalizada.single['status'], 'concluida');
      expect(finalizada.single['data_termino'], isNotNull);

      // O índice existe e continua funcionando depois da migração.
      expect(
        () => db.insert('viagem', {
          'data_inicio': DateTime(2026, 1, 6).toIso8601String(),
          'embarcacao_id': 'embarcacao-uuid-1',
          'status': 'em_andamento',
        }),
        throwsA(anything),
      );
    });
  });
}
