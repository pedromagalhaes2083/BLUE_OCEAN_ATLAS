import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class ApiEntry {
  final String url;
  final String method;
  final int statusCode;
  final int elapsedMs;
  final String responseBody;
  final double? latitude;
  final double? longitude;
  final DateTime savedAt;

  ApiEntry({
    required this.url,
    required this.method,
    required this.statusCode,
    required this.elapsedMs,
    required this.responseBody,
    this.latitude,
    this.longitude,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() => {
        'url': url,
        'method': method,
        'statusCode': statusCode,
        'elapsedMs': elapsedMs,
        'responseBody': responseBody,
        'latitude': latitude,
        'longitude': longitude,
        'savedAt': savedAt.toIso8601String(),
      };

  factory ApiEntry.fromMap(Map map) => ApiEntry(
        url: map['url'] as String,
        method: map['method'] as String,
        statusCode: map['statusCode'] as int,
        elapsedMs: map['elapsedMs'] as int,
        responseBody: map['responseBody'] as String,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        savedAt: DateTime.parse(map['savedAt'] as String),
      );

  // Tenta parsear o body como JSON; retorna null se não for JSON válido
  Map<String, dynamic>? get parsedBody {
    try {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

class ApiStorageService {
  static const _boxName = 'api_responses';

  Box get _box => Hive.box(_boxName);

  void save(ApiEntry entry) {
    _box.add(entry.toMap());
  }

  List<ApiEntry> getAll() {
    return _box.values
        .whereType<Map>()
        .map(ApiEntry.fromMap)
        .toList()
        .reversed
        .toList(); // mais recente primeiro
  }

  void delete(int hiveIndex) {
    _box.deleteAt(hiveIndex);
  }

  void clear() {
    _box.clear();
  }

  int get count => _box.length;
}
