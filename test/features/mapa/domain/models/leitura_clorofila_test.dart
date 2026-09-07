import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/mapa/domain/models/leitura_clorofila.dart';

void main() {
  group('LeituraClorofilaPonto', () {
    test('guarda latitude/longitude/valor/data/fonte', () {
      final ponto = LeituraClorofilaPonto(
        latitude: -2.1145885,
        longitude: -38.88541,
        valorMgM3: 0.1367,
        data: DateTime.parse('2026-08-26T12:00:00Z'),
      );

      expect(ponto.latitude, -2.1145885);
      expect(ponto.longitude, -38.88541);
      expect(ponto.valorMgM3, 0.1367);
      expect(ponto.data, DateTime.parse('2026-08-26T12:00:00Z'));
      expect(ponto.source, 'NOAA CoastWatch (ERDDAP)');
    });

    test('valorMgM3 nulo representa "sem dado" — nunca um número inventado', () {
      final ponto = LeituraClorofilaPonto(
        latitude: -2.9,
        longitude: -39.9,
        data: DateTime.parse('2026-08-26T12:00:00Z'),
      );
      expect(ponto.valorMgM3, isNull);
    });
  });
}
