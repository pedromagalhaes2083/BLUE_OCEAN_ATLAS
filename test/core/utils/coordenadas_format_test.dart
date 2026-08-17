import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/core/utils/coordenadas_format.dart';

void main() {
  group('formatarCoordenadaDMS', () {
    test('latitude positiva vira N', () {
      final texto = formatarCoordenadaDMS(23.5505, isLatitude: true);
      expect(texto, endsWith('N'));
      expect(texto, startsWith('23°'));
    });

    test('latitude negativa vira S', () {
      final texto = formatarCoordenadaDMS(-23.5505, isLatitude: true);
      expect(texto, endsWith('S'));
      expect(texto, startsWith('23°'));
    });

    test('longitude positiva vira E, negativa vira W', () {
      expect(formatarCoordenadaDMS(46.6333, isLatitude: false), endsWith('E'));
      expect(
          formatarCoordenadaDMS(-46.6333, isLatitude: false), endsWith('W'));
    });

    test('zero grau não quebra (fronteira N/S ou E/W)', () {
      expect(() => formatarCoordenadaDMS(0, isLatitude: true), returnsNormally);
    });
  });

  group('formatarCoordenadasDMS', () {
    test('junta latitude e longitude em duas linhas', () {
      final texto = formatarCoordenadasDMS(-23.5505, -46.6333);
      final linhas = texto.split('\n');
      expect(linhas, hasLength(2));
      expect(linhas[0], endsWith('S'));
      expect(linhas[1], endsWith('W'));
    });
  });

  group('formatarCoordenadasDMSCompacta', () {
    test('junta latitude e longitude numa linha só, separadas por vírgula',
        () {
      final texto = formatarCoordenadasDMSCompacta(-23.5505, -46.6333);
      expect(texto.split('\n'), hasLength(1));
      expect(texto, contains(', '));
      expect(texto, endsWith('W'));
    });
  });
}
