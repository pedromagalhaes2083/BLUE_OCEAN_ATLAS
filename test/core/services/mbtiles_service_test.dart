import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atlas/core/services/mbtiles_service.dart';

/// `getApplicationDocumentsDirectory()` usa um canal de plataforma que não
/// existe em `flutter test` — aponta pra um diretório temporário real.
class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  _FakePathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

const _asset = 'assets/cartas/teste.mbtiles';

/// Uma carta MBTiles mínima de verdade (metadata + 1 tile), pra servir de
/// conteúdo do asset simulado.
Future<Uint8List> _criarCartaMinima(Directory dir) async {
  final caminho = '${dir.path}/origem.mbtiles';
  final db = await databaseFactory.openDatabase(caminho);
  await db.execute('CREATE TABLE metadata (name TEXT, value TEXT)');
  await db.execute('CREATE TABLE tiles (zoom_level INTEGER, tile_column '
      'INTEGER, tile_row INTEGER, tile_data BLOB)');
  await db.insert('metadata', {'name': 'name', 'value': 'Carta de teste'});
  await db.insert('metadata', {'name': 'scheme', 'value': 'xyz'});
  await db.insert('tiles', {
    'zoom_level': 1,
    'tile_column': 0,
    'tile_row': 0,
    'tile_data': Uint8List.fromList([1, 2, 3]),
  });
  await db.close();
  return File(caminho).readAsBytes();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory docs;
  late Uint8List conteudoAsset;
  late int leiturasDoAsset;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final base = await Directory.systemTemp.createTemp('atlas_mbtiles_test_');
    docs = await Directory('${base.path}/docs').create();
    conteudoAsset = await _criarCartaMinima(base);
    leiturasDoAsset = 0;
    PathProviderPlatform.instance = _FakePathProviderPlatform(docs.path);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (mensagem) async {
      leiturasDoAsset++;
      return ByteData.sublistView(conteudoAsset);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  File destino() => File('${docs.path}/teste.mbtiles');
  File marcador() => File('${docs.path}/teste.mbtiles.ok');

  test('primeira abertura copia a carta, marca como completa e abre',
      () async {
    final servico = MbtilesService();
    await servico.openFromAsset(_asset);

    expect(await destino().readAsBytes(), conteudoAsset);
    expect(await marcador().exists(), isTrue);
    expect(await File('${destino().path}.tmp').exists(), isFalse);
    expect(servico.name, 'Carta de teste');
    expect(await servico.getTileBytes(1, 0, 0), [1, 2, 3]);
    await servico.close();
  });

  test('com o marcador presente, não copia de novo', () async {
    await (MbtilesService()).openFromAsset(_asset);
    leiturasDoAsset = 0;

    final servico = MbtilesService();
    await servico.openFromAsset(_asset);

    expect(leiturasDoAsset, 0);
    expect(servico.name, 'Carta de teste');
    await servico.close();
  });

  test('cópia interrompida (arquivo pela metade, sem marcador) é refeita',
      () async {
    await destino()
        .writeAsBytes(conteudoAsset.sublist(0, conteudoAsset.length ~/ 2));

    final servico = MbtilesService();
    await servico.openFromAsset(_asset);

    expect(await destino().readAsBytes(), conteudoAsset);
    expect(await marcador().exists(), isTrue);
    expect(servico.name, 'Carta de teste');
    await servico.close();
  });

  test('instalação antiga com a carta já completa só ganha o marcador',
      () async {
    await destino().writeAsBytes(conteudoAsset);
    final modificadoAntes = await destino().lastModified();
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    final servico = MbtilesService();
    await servico.openFromAsset(_asset);

    expect(await marcador().exists(), isTrue);
    expect(await destino().lastModified(), modificadoAntes);
    expect(servico.name, 'Carta de teste');
    await servico.close();
  });

  test('duas aberturas simultâneas compartilham a mesma cópia', () async {
    final a = MbtilesService();
    final b = MbtilesService();

    await Future.wait([a.openFromAsset(_asset), b.openFromAsset(_asset)]);

    expect(leiturasDoAsset, 1);
    expect(await destino().readAsBytes(), conteudoAsset);
    expect(a.name, 'Carta de teste');
    expect(b.name, 'Carta de teste');
    await a.close();
    await b.close();
  });
}
