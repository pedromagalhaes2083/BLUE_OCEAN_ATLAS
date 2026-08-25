import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/utils/severidade_condicoes.dart';

void main() {
  group('ventoSevero', () {
    test('abaixo do limiar não é severo', () {
      expect(ventoSevero(44.9, 45), isFalse);
    });

    test('exatamente no limiar já é severo (>=)', () {
      expect(ventoSevero(45, 45), isTrue);
    });

    test('acima do limiar é severo', () {
      expect(ventoSevero(60, 45), isTrue);
    });

    test('respeita um limiar configurado diferente do padrão', () {
      expect(ventoSevero(30, 25), isTrue);
      expect(ventoSevero(20, 25), isFalse);
    });
  });

  group('correnteSevera', () {
    test('abaixo do limiar não é severa', () {
      expect(correnteSevera(1.4, 1.5), isFalse);
    });

    test('no limiar ou acima é severa', () {
      expect(correnteSevera(1.5, 1.5), isTrue);
      expect(correnteSevera(2.0, 1.5), isTrue);
    });
  });

  group('alturaSevera', () {
    test('serve tanto pra onda quanto pra swell (mesma unidade)', () {
      expect(alturaSevera(2.9, 3.0), isFalse);
      expect(alturaSevera(3.0, 3.0), isTrue);
      expect(alturaSevera(4.5, 3.0), isTrue);
    });
  });

  group('temperaturaSevera', () {
    test('dispara acima ou no limiar (água quente), não abaixo', () {
      expect(temperaturaSevera(27.3, 27.4), isFalse);
      expect(temperaturaSevera(27.4, 27.4), isTrue);
      expect(temperaturaSevera(28.0, 27.4), isTrue);
    });
  });
}
