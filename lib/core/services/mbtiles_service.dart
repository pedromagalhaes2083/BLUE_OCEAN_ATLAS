import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class MbtilesService {
  Database? _db;
  String? _filePath;
  String? _name;

  // null = ainda não detectado, true = TMS (flipa Y), false = XYZ (não flipa)
  bool? _isTms;

  bool get isOpen => _db != null;
  String? get filePath => _filePath;
  String? get name => _name;

  // Copia o asset para o armazenamento interno (apenas na primeira vez)
  // e abre o arquivo resultante.
  Future<void> openFromAsset(String assetPath) async {
    final fileName = assetPath.split('/').last;
    final dir = await getApplicationDocumentsDirectory();
    final localFile = File('${dir.path}/$fileName');

    if (!await localFile.exists()) {
      final data = await rootBundle.load(assetPath);
      await localFile.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }

    await open(localFile.path);
  }

  Future<void> open(String filePath) async {
    await close();
    _db = await openDatabase(filePath, readOnly: true);
    _filePath = filePath;
    _isTms = null;
    final meta = await getMetadata();
    _name = meta['name'];

    final scheme = meta['scheme']?.toLowerCase();
    if (scheme == 'xyz') {
      _isTms = false;
    } else if (scheme == 'tms') {
      _isTms = true;
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _filePath = null;
    _name = null;
    _isTms = null;
  }

  Future<Map<String, String>> getMetadata() async {
    if (_db == null) return {};
    final rows = await _db!.query('metadata');
    return {
      for (final row in rows)
        row['name'] as String: row['value'] as String,
    };
  }

  Future<Uint8List?> getTileBytes(int z, int x, int y) async {
    if (_db == null) return null;

    if (_isTms != null) {
      final tileY = _isTms! ? (1 << z) - 1 - y : y;
      return _query(z, x, tileY);
    }

    // Auto-detecção: tenta TMS primeiro, depois XYZ
    final withFlip = await _query(z, x, (1 << z) - 1 - y);
    if (withFlip != null) {
      _isTms = true;
      return withFlip;
    }
    final withoutFlip = await _query(z, x, y);
    if (withoutFlip != null) {
      _isTms = false;
      return withoutFlip;
    }
    return null;
  }

  Future<Uint8List?> _query(int z, int x, int y) async {
    final result = await _db!.query(
      'tiles',
      columns: ['tile_data'],
      where: 'zoom_level = ? AND tile_column = ? AND tile_row = ?',
      whereArgs: [z, x, y],
    );
    if (result.isEmpty) return null;
    return result.first['tile_data'] as Uint8List;
  }
}
