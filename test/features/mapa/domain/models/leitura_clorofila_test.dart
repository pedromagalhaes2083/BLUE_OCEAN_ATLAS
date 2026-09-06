import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/mapa/domain/models/leitura_clorofila.dart';

void main() {
  group('LeituraClorofila.fromJson', () {
    test('lê um ponto com valor válido', () {
      final ponto = LeituraClorofila.fromJson({
        'latitude': -2.106,
        'longitude': -38.893,
        'value': 0.42,
      });

      expect(ponto.latitude, -2.106);
      expect(ponto.longitude, -38.893);
      expect(ponto.valorMgM3, 0.42);
    });

    test('sem "value", vira null — nunca inventa um número', () {
      final ponto = LeituraClorofila.fromJson({
        'latitude': -2.1,
        'longitude': -38.9,
      });
      expect(ponto.valorMgM3, isNull);
    });

    test('value igual ao missing_value vira null, não o número bruto', () {
      final ponto = LeituraClorofila.fromJson({
        'latitude': -2.1,
        'longitude': -38.9,
        'value': -999.0,
        'missing_value': -999.0,
      });
      expect(ponto.valorMgM3, isNull);
    });

    test('aceita nomes de campo alternativos (lat/lon, chlorophyll_a)', () {
      final ponto = LeituraClorofila.fromJson({
        'lat': -2.1,
        'lon': -38.9,
        'chlorophyll_a': 1.2,
      });
      expect(ponto.latitude, -2.1);
      expect(ponto.longitude, -38.9);
      expect(ponto.valorMgM3, 1.2);
    });

    test('sem latitude/longitude, lança FormatException', () {
      expect(
        () => LeituraClorofila.fromJson({'value': 0.5}),
        throwsFormatException,
      );
    });

    test('guarda quality_index e sensor_mask quando presentes', () {
      final ponto = LeituraClorofila.fromJson({
        'latitude': -2.1,
        'longitude': -38.9,
        'value': 0.3,
        'quality_index': 87,
        'sensor_mask': 1,
      });
      expect(ponto.qualityIndex, 87);
      expect(ponto.sensorMask, 1);
    });
  });

  group('ClorofilaResposta.fromJson', () {
    test('lê o envelope completo com pontos', () {
      final resposta = ClorofilaResposta.fromJson({
        'source': 'Copernicus Marine',
        'variable': 'chlorophyll_a',
        'unit': 'mg/m3',
        'date': '2026-09-05',
        'resolution': '1 km',
        'bbox': {'north': -1, 'south': -3, 'east': -38, 'west': -40},
        'data': [
          {'latitude': -2.1, 'longitude': -38.9, 'value': 0.5},
          {'latitude': -2.2, 'longitude': -39.0},
        ],
      });

      expect(resposta.source, 'Copernicus Marine');
      expect(resposta.unit, 'mg/m3');
      expect(resposta.data, DateTime.parse('2026-09-05'));
      expect(resposta.pontos, hasLength(2));
      expect(resposta.pontos[0].valorMgM3, 0.5);
      expect(resposta.pontos[1].valorMgM3, isNull);
    });

    test('sem "date", lança FormatException — nunca assume uma data', () {
      expect(
        () => ClorofilaResposta.fromJson({'data': []}),
        throwsFormatException,
      );
    });

    test('sem "data", pontos fica vazio em vez de quebrar', () {
      final resposta = ClorofilaResposta.fromJson({'date': '2026-09-05'});
      expect(resposta.pontos, isEmpty);
    });
  });
}
