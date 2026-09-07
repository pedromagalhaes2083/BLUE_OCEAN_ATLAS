import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/mapa/data/clorofila_repository.dart';

void main() {
  group('ClorofilaRepository.parseRespostaCsv', () {
    test('lê um valor válido — resposta real do ERDDAP (2026-09)', () {
      // curl real em coastwatch.noaa.gov/erddap/griddap/..., ponto de
      // teste combinado (-2.10600, -38.89306) — ver conversa.
      const corpo = 'time,altitude,latitude,longitude,chlor_a\n'
          'UTC,m,degrees_north,degrees_east,mg m^-3\n'
          '2026-08-26T12:00:00Z,0.0,-2.1145885,-38.88541,0.13666269\n';

      final ponto = ClorofilaRepository.parseRespostaCsv(corpo);

      expect(ponto.latitude, -2.1145885);
      expect(ponto.longitude, -38.88541);
      expect(ponto.valorMgM3, 0.13666269);
      expect(ponto.data, DateTime.parse('2026-08-26T12:00:00Z'));
    });

    test('"NaN" vira null — nunca um número inventado', () {
      const corpo = 'time,altitude,latitude,longitude,chlor_a\n'
          'UTC,m,degrees_north,degrees_east,mg m^-3\n'
          '2026-08-20T12:00:00Z,0.0,-2.9895885,-40.01041,NaN\n';

      final ponto = ClorofilaRepository.parseRespostaCsv(corpo);
      expect(ponto.valorMgM3, isNull);
      expect(ponto.latitude, -2.9895885);
    });

    test('resposta sem linha de dado lança FormatException', () {
      const corpo = 'time,altitude,latitude,longitude,chlor_a\n'
          'UTC,m,degrees_north,degrees_east,mg m^-3\n';
      expect(() => ClorofilaRepository.parseRespostaCsv(corpo),
          throwsFormatException);
    });

    test('linha de dado incompleta lança FormatException', () {
      const corpo = 'time,altitude,latitude,longitude,chlor_a\n'
          'UTC,m,degrees_north,degrees_east,mg m^-3\n'
          '2026-08-26T12:00:00Z,0.0\n';
      expect(() => ClorofilaRepository.parseRespostaCsv(corpo),
          throwsFormatException);
    });
  });
}
