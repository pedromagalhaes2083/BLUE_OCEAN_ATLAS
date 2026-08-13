import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Identifica o app nas requisições — exigido pela política de uso de
/// tiles do OpenStreetMap (requisições sem identificação podem ser
/// bloqueadas). https://operations.osmfoundation.org/policies/tiles/
const _userAgent = 'AtlasBlueOcean/1.0 (blueoceanorientation@gmail.com)';

const _tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

/// Progresso de um download de região: [feitos] tiles já baixados (ou já
/// em cache) de um total de [total].
class ProgressoDownload {
  final int feitos;
  final int total;
  const ProgressoDownload(this.feitos, this.total);

  double get fracao => total == 0 ? 0 : feitos / total;
}

/// Permite cancelar um download de região em andamento.
class CancelToken {
  bool cancelado = false;
  void cancelar() => cancelado = true;
}

/// Cache de tiles do mapa de ruas em disco — implementação própria (HTTP +
/// arquivo), sem depender de bibliotecas de terceiros para isso: a opção
/// mais usada do mercado (flutter_map_tile_caching) é licenciada em GPLv3,
/// incompatível com um app proprietário sem comprar licença comercial do
/// autor.
///
/// Cada tile vira um PNG em `<documentos>/street_cache/{z}/{x}/{y}.png`.
/// Ao pedir um tile: serve do disco se já existir; senão busca da rede e
/// grava, ficando disponível offline da próxima vez. [baixarRegiao] só
/// adianta esse processo pra uma área inteira de uma vez, antes de sair
/// do sinal.
class StreetMapCacheService {
  static final StreetMapCacheService _instance =
      StreetMapCacheService._internal();
  factory StreetMapCacheService() => _instance;
  StreetMapCacheService._internal();

  Directory? _cacheDir;

  Future<Directory> _diretorioCache() async {
    if (_cacheDir != null) return _cacheDir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/street_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  File _arquivoTile(Directory dir, int z, int x, int y) =>
      File('${dir.path}/$z/$x/$y.png');

  String _url(int z, int x, int y) => _tileUrlTemplate
      .replaceAll('{z}', '$z')
      .replaceAll('{x}', '$x')
      .replaceAll('{y}', '$y');

  /// Bytes do tile — do cache em disco se existir, senão baixa e grava.
  /// Retorna null se não estiver em cache e não houver como buscar (ex:
  /// offline).
  Future<Uint8List?> obterTile(int z, int x, int y) async {
    final dir = await _diretorioCache();
    final arquivo = _arquivoTile(dir, z, x, y);
    if (await arquivo.exists()) {
      return arquivo.readAsBytes();
    }

    try {
      final resposta = await http
          .get(Uri.parse(_url(z, x, y)), headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 12));
      if (resposta.statusCode != 200) return null;

      await arquivo.parent.create(recursive: true);
      await arquivo.writeAsBytes(resposta.bodyBytes, flush: true);
      return resposta.bodyBytes;
    } catch (_) {
      return null;
    }
  }

  /// Todas as coordenadas de tile (z, x, y) que cobrem o retângulo
  /// [swLat],[swLon] a [neLat],[neLon], para cada zoom entre [zoomMin] e
  /// [zoomMax] (inclusive).
  List<(int, int, int)> tilesDaRegiao({
    required double swLat,
    required double swLon,
    required double neLat,
    required double neLon,
    required int zoomMin,
    required int zoomMax,
  }) {
    final tiles = <(int, int, int)>[];
    for (var z = zoomMin; z <= zoomMax; z++) {
      final xMin = _lonParaTileX(swLon, z);
      final xMax = _lonParaTileX(neLon, z);
      final yMin = _latParaTileY(neLat, z); // norte → y menor
      final yMax = _latParaTileY(swLat, z); // sul → y maior
      for (var x = xMin; x <= xMax; x++) {
        for (var y = yMin; y <= yMax; y++) {
          tiles.add((z, x, y));
        }
      }
    }
    return tiles;
  }

  int _lonParaTileX(double lon, int z) {
    final n = 1 << z;
    return ((lon + 180.0) / 360.0 * n).floor().clamp(0, n - 1);
  }

  int _latParaTileY(double lat, int z) {
    final n = 1 << z;
    final latRad = lat * math.pi / 180.0;
    final y = (1 -
            math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
        2 *
        n;
    return y.floor().clamp(0, n - 1);
  }

  /// Baixa (ou confirma em cache) todos os tiles da região, emitindo o
  /// progresso a cada tile. Interrompe se [cancelToken] for cancelado.
  Stream<ProgressoDownload> baixarRegiao({
    required double swLat,
    required double swLon,
    required double neLat,
    required double neLon,
    required int zoomMin,
    required int zoomMax,
    CancelToken? cancelToken,
  }) async* {
    final tiles = tilesDaRegiao(
      swLat: swLat,
      swLon: swLon,
      neLat: neLat,
      neLon: neLon,
      zoomMin: zoomMin,
      zoomMax: zoomMax,
    );

    var feitos = 0;
    yield ProgressoDownload(feitos, tiles.length);
    for (final (z, x, y) in tiles) {
      if (cancelToken?.cancelado == true) return;
      await obterTile(z, x, y);
      feitos++;
      yield ProgressoDownload(feitos, tiles.length);
    }
  }
}
