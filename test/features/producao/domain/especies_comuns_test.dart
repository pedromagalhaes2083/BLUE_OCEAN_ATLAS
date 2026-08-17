import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/features/producao/domain/especies_comuns.dart';

void main() {
  group('normalizarEspecie', () {
    test('capitaliza a primeira letra de cada palavra', () {
      expect(normalizarEspecie('tainha'), 'Tainha');
      expect(normalizarEspecie('pescada amarela'), 'Pescada Amarela');
    });

    test('reduz variações de grafia (maiúsculas/minúsculas) ao mesmo valor',
        () {
      expect(normalizarEspecie('TAINHA'), normalizarEspecie('tainha'));
      expect(normalizarEspecie('Tainha'), normalizarEspecie('tAiNhA'));
    });

    test('remove espaços nas pontas', () {
      expect(normalizarEspecie('  tainha  '), 'Tainha');
    });

    test('string vazia continua vazia', () {
      expect(normalizarEspecie(''), '');
      expect(normalizarEspecie('   '), '');
    });

    test('aceita texto fora da lista de espécies comuns (não é fechada)', () {
      expect(normalizarEspecie('peixe desconhecido xyz'),
          'Peixe Desconhecido Xyz');
    });
  });

  test('especiesComuns não está vazia e não tem duplicatas', () {
    expect(especiesComuns, isNotEmpty);
    expect(especiesComuns.toSet().length, especiesComuns.length);
  });
}
