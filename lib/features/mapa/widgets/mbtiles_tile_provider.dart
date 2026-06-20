import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../core/services/mbtiles_service.dart';

class MbtilesTileProvider extends TileProvider {
  final MbtilesService service;

  MbtilesTileProvider(this.service);

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _MbtilesImageProvider(
      service: service,
      z: coordinates.z,
      x: coordinates.x,
      y: coordinates.y,
    );
  }
}

class _MbtilesImageProvider extends ImageProvider<_MbtilesImageProvider> {
  final MbtilesService service;
  final int z, x, y;

  // Cache de tile vazio para não gerar a cada requisição
  static Uint8List? _emptyTileBytes;

  const _MbtilesImageProvider({
    required this.service,
    required this.z,
    required this.x,
    required this.y,
  });

  @override
  Future<_MbtilesImageProvider> obtainKey(ImageConfiguration config) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _MbtilesImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadCodec(decode),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadCodec(ImageDecoderCallback decode) async {
    try {
      final bytes = await service.getTileBytes(z, x, y);
      if (bytes != null && bytes.isNotEmpty) {
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return decode(buffer);
      }
    } catch (_) {}

    // Tile ausente → retorna pixel transparente
    final empty = await _getEmptyTileBytes();
    return decode(await ui.ImmutableBuffer.fromUint8List(empty));
  }

  static Future<Uint8List> _getEmptyTileBytes() async {
    if (_emptyTileBytes != null) return _emptyTileBytes!;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 1, 1),
      ui.Paint()..color = const ui.Color(0x00000000),
    );
    final image = await recorder.endRecording().toImage(1, 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    _emptyTileBytes = data!.buffer.asUint8List();
    return _emptyTileBytes!;
  }

  @override
  bool operator ==(Object other) =>
      other is _MbtilesImageProvider &&
      service == other.service &&
      z == other.z &&
      x == other.x &&
      y == other.y;

  @override
  int get hashCode => Object.hash(service, z, x, y);
}
