import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Faixas de referência para concentração de clorofila-a (mg/m³),
/// usadas como indicativo de produtividade biológica da água.
enum ChlorophyllLevel {
  baixa(
    max: 0.3,
    label: 'Baixa',
    description: 'Água pobre em nutrientes',
    color: Color(0xFF64B5F6),
  ),
  moderada(
    max: 1.0,
    label: 'Moderada',
    description: 'Produtividade biológica moderada',
    color: Color(0xFF66BB6A),
  ),
  alta(
    max: 5.0,
    label: 'Alta',
    description: 'Boa concentração de plâncton — potencial de cardumes',
    color: Color(0xFFFFA726),
  ),
  muitoAlta(
    max: double.infinity,
    label: 'Muito alta',
    description: 'Possível floração de algas',
    color: Color(0xFFE53935),
  );

  final double max;
  final String label;
  final String description;
  final Color color;

  const ChlorophyllLevel({
    required this.max,
    required this.label,
    required this.description,
    required this.color,
  });

  static ChlorophyllLevel fromConcentration(double value) {
    for (final level in ChlorophyllLevel.values) {
      if (value <= level.max) return level;
    }
    return ChlorophyllLevel.muitoAlta;
  }
}

/// Uma leitura pontual de clorofila-a em uma coordenada.
class ChlorophyllReading {
  final double latitude;
  final double longitude;
  final double concentration; // mg/m³
  final double? distanceNm;

  const ChlorophyllReading({
    required this.latitude,
    required this.longitude,
    required this.concentration,
    this.distanceNm,
  });

  ChlorophyllLevel get level => ChlorophyllLevel.fromConcentration(concentration);

  factory ChlorophyllReading.fromMap(
    Map<String, dynamic> map, {
    double? distanceNm,
  }) {
    return ChlorophyllReading(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      concentration: (map['chlor_a'] as num? ?? 0).toDouble(),
      distanceNm: distanceNm,
    );
  }
}

/// Coleção de leituras de clorofila, tipicamente ordenadas por proximidade.
class ChlorophyllDataset {
  final List<ChlorophyllReading> readings;

  const ChlorophyllDataset(this.readings);

  bool get isEmpty => readings.isEmpty;

  /// Leitura mais próxima (assume a lista já ordenada por distância).
  ChlorophyllReading? get nearest => readings.isEmpty ? null : readings.first;

  /// Constrói o dataset a partir de uma lista bruta (ex: JSON decodificado),
  /// calculando e ordenando por distância quando uma origem é informada.
  factory ChlorophyllDataset.fromRawList(
    List<dynamic> raw, {
    double? originLat,
    double? originLon,
  }) {
    final readings = raw.map((e) {
      final map = Map<String, dynamic>.from(e);
      final lat = (map['latitude'] as num).toDouble();
      final lon = (map['longitude'] as num).toDouble();
      final distance = (originLat != null && originLon != null)
          ? _nauticalMiles(originLat, originLon, lat, lon)
          : null;
      return ChlorophyllReading.fromMap(map, distanceNm: distance);
    }).toList();

    if (originLat != null && originLon != null) {
      readings.sort((a, b) => (a.distanceNm ?? 0).compareTo(b.distanceNm ?? 0));
    }

    return ChlorophyllDataset(readings);
  }

  static double _nauticalMiles(
      double lat1, double lon1, double lat2, double lon2) {
    const double raioTerraMilhasNauticas = 3440.065; // 6371 km ÷ 1.852
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return raioTerraMilhasNauticas * c;
  }
}
