import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class GeotiffResult {
  final double north;
  final double south;
  final double east;
  final double west;
  final Uint8List imageBytes; // PNG decodificado

  const GeotiffResult({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    required this.imageBytes,
  });
}

class GeotiffService {
  Future<GeotiffResult> load(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final bounds = _parseBounds(bytes);

    // Decodifica pixels em isolate para não travar a UI
    final imageBytes = await compute(_decodeToPNG, bytes);

    return GeotiffResult(
      north: bounds[0],
      south: bounds[1],
      east: bounds[2],
      west: bounds[3],
      imageBytes: imageBytes,
    );
  }

  // Extrai bounds geográficos da cabeçalha TIFF (tags GeoTIFF)
  List<double> _parseBounds(Uint8List bytes) {
    if (bytes.length < 8) throw Exception('Arquivo muito pequeno');

    final data = ByteData.sublistView(bytes);
    // "II" = little-endian, "MM" = big-endian
    final endian = bytes[0] == 0x49 ? Endian.little : Endian.big;

    final magic = data.getUint16(2, endian);
    if (magic != 42) throw Exception('Não é um arquivo TIFF válido');

    final ifdOffset = data.getUint32(4, endian);
    final numEntries = data.getUint16(ifdOffset, endian);

    int? width, height;
    List<double>? pixelScale; // tag 33550: [scaleX, scaleY, scaleZ]
    List<double>? tiepoints;  // tag 33922: [rasterX, rasterY, rasterZ, geoX, geoY, geoZ, ...]
    List<double>? transform;  // tag 34264: matriz afim 4x4 (16 doubles)

    for (int i = 0; i < numEntries; i++) {
      final base = ifdOffset + 2 + i * 12;
      final tag = data.getUint16(base, endian);
      final type = data.getUint16(base + 2, endian);
      final count = data.getUint32(base + 4, endian);

      switch (tag) {
        case 256: // ImageWidth
          width = _readInt(data, base + 8, type, endian);
        case 257: // ImageLength
          height = _readInt(data, base + 8, type, endian);
        case 33550: // ModelPixelScaleTag
          pixelScale = _readDoubles(data, base + 8, count, endian);
        case 33922: // ModelTiepointTag
          tiepoints = _readDoubles(data, base + 8, count, endian);
        case 34264: // ModelTransformationTag
          transform = _readDoubles(data, base + 8, count, endian);
      }
    }

    if (width == null || height == null) {
      throw Exception('Não foi possível ler as dimensões do GeoTIFF');
    }

    double north, south, east, west;

    if (tiepoints != null && pixelScale != null) {
      // Método mais comum: ponto de ancoragem + escala por pixel
      // tiepoints = [rasterI, rasterJ, rasterK, geoX, geoY, geoZ]
      final rI = tiepoints[0];
      final rJ = tiepoints[1];
      final lon = tiepoints[3]; // origem X geográfica
      final lat = tiepoints[4]; // origem Y geográfica
      final sx = pixelScale[0]; // graus por pixel em X
      final sy = pixelScale[1]; // graus por pixel em Y (positivo, subtrai para Y)

      west = lon - rI * sx;
      north = lat + rJ * sy;
      east = west + width * sx;
      south = north - height * sy;
    } else if (transform != null && transform.length >= 16) {
      // Matriz afim 4x4 (row-major):
      // | sx  0   0  ox |
      // | 0   sy  0  oy |   (sy geralmente negativo para imagens "north-up")
      // | 0   0   1   0 |
      // | 0   0   0   1 |
      final sx = transform[0];  // escala X
      final sy = transform[5];  // escala Y (negativa em north-up)
      final ox = transform[3];  // origem X (oeste)
      final oy = transform[7];  // origem Y (norte)

      west = ox;
      north = oy;
      east = ox + width * sx;
      south = oy + height * sy;

      if (south > north) {
        final tmp = south;
        south = north;
        north = tmp;
      }
    } else {
      throw Exception(
        'GeoTIFF sem georreferenciamento.\n'
        'Tags ModelTiepoint e ModelPixelScale não encontradas.',
      );
    }

    // Valida se está em WGS84 (coordenadas em graus)
    if (west < -180 || east > 180 || south < -90 || north > 90) {
      throw Exception(
        'Projeção não suportada (coordenadas fora do intervalo WGS84).\n'
        'Converta para EPSG:4326 usando QGIS ou GDAL:\n'
        'gdal_warp -t_srs EPSG:4326 entrada.tif saida.tif',
      );
    }

    return [north, south, east, west];
  }

  int _readInt(ByteData data, int offset, int type, Endian endian) {
    return switch (type) {
      3 => data.getUint16(offset, endian), // SHORT (2 bytes)
      4 => data.getUint32(offset, endian), // LONG  (4 bytes)
      _ => data.getUint32(offset, endian),
    };
  }

  // Doubles têm 8 bytes cada → o campo de 4 bytes é sempre um offset
  List<double> _readDoubles(
      ByteData data, int offsetField, int count, Endian endian) {
    final ptr = data.getUint32(offsetField, endian);
    return List.generate(count, (i) => data.getFloat64(ptr + i * 8, endian));
  }
}

// Função top-level para rodar em compute() (isolate separado)
Uint8List _decodeToPNG(Uint8List bytes) {
  final image = img.TiffDecoder().decode(bytes);
  if (image == null) throw Exception('Falha ao decodificar a imagem TIFF');

  // Redimensiona para no máximo 4096px para não esgotar memória em dispositivos móveis
  const maxDim = 4096;
  final img.Image output;
  if (image.width > maxDim || image.height > maxDim) {
    output = image.width >= image.height
        ? img.copyResize(image,
            width: maxDim, interpolation: img.Interpolation.linear)
        : img.copyResize(image,
            height: maxDim, interpolation: img.Interpolation.linear);
  } else {
    output = image;
  }

  return Uint8List.fromList(img.encodePng(output));
}
