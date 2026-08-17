import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/core/models/sst_ponto.dart';

void main() {
  group('SstPonto.fromJson', () {
    test('lê latitude/longitude/temperatura de uma resposta com leitura', () {
      final ponto = SstPonto.fromJson({
        'latitude': -3.0,
        'longitude': -40.0,
        'current': {'sea_surface_temperature': 27.5},
      });

      expect(ponto.latitude, -3.0);
      expect(ponto.longitude, -40.0);
      expect(ponto.temperaturaC, 27.5);
    });

    test('temperatura fica nula quando a API não retorna "current" (ex: em terra)',
        () {
      final ponto = SstPonto.fromJson({
        'latitude': -3.0,
        'longitude': -40.0,
      });

      expect(ponto.temperaturaC, isNull);
    });

    test('temperatura fica nula quando "current" existe mas sem o campo de SST',
        () {
      final ponto = SstPonto.fromJson({
        'latitude': -3.0,
        'longitude': -40.0,
        'current': <String, dynamic>{},
      });

      expect(ponto.temperaturaC, isNull);
    });

    test('aceita latitude/longitude como int (json sem casas decimais)', () {
      final ponto = SstPonto.fromJson({
        'latitude': -3,
        'longitude': -40,
        'current': {'sea_surface_temperature': 27},
      });

      expect(ponto.latitude, -3.0);
      expect(ponto.longitude, -40.0);
      expect(ponto.temperaturaC, 27.0);
    });
  });
}
