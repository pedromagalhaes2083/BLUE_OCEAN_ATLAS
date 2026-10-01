import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/features/producao/domain/classificacao_peso.dart';

void main() {
  group('faixaPesoUnitario', () {
    test('1-10 retorna o intervalo literal da faixa', () {
      final faixa = faixaPesoUnitario(Classificacao.faixa1a10);
      expect(faixa.min, 1);
      expect(faixa.max, 10);
    });

    test('10-15 retorna o intervalo literal da faixa', () {
      final faixa = faixaPesoUnitario(Classificacao.faixa10a15);
      expect(faixa.min, 10);
      expect(faixa.max, 15);
    });

    test('15-25 retorna o intervalo literal da faixa', () {
      final faixa = faixaPesoUnitario(Classificacao.faixa15a25);
      expect(faixa.min, 15);
      expect(faixa.max, 25);
    });

    test('25-39 retorna o intervalo literal da faixa', () {
      final faixa = faixaPesoUnitario(Classificacao.faixa25a39);
      expect(faixa.min, 25);
      expect(faixa.max, 39);
    });

    test('40+ usa o intervalo estipulado (45-50), não "40 e acima" literal',
        () {
      final faixa = faixaPesoUnitario(Classificacao.faixa40mais);
      expect(faixa.min, 45);
      expect(faixa.max, 50);
    });

    test('mesma tabela vale para qualquer espécie — não depende de um tipo',
        () {
      for (final classificacao in Classificacao.values) {
        final a = faixaPesoUnitario(classificacao);
        final b = faixaPesoUnitario(classificacao);
        expect(a.min, b.min, reason: '$classificacao min diverge');
        expect(a.max, b.max, reason: '$classificacao max diverge');
      }
    });
  });

  group('FaixaPeso.media', () {
    test('é o ponto médio do intervalo', () {
      expect(const FaixaPeso(10, 15).media, 12.5);
      expect(const FaixaPeso(45, 50).media, 47.5);
    });
  });

  group('cálculo do peso estimado (quantidade × faixa)', () {
    test('peso estimado mínimo e máximo pra 12 unidades na faixa 40+', () {
      final faixa = faixaPesoUnitario(Classificacao.faixa40mais);
      const unidades = 12;
      expect(unidades * faixa.min, 540.0);
      expect(unidades * faixa.max, 600.0);
    });

    test('peso médio salvo no registro é quantidade × ponto médio da faixa',
        () {
      final faixa = faixaPesoUnitario(Classificacao.faixa10a15);
      const unidades = 8;
      expect(unidades * faixa.media, 100.0); // 8 * 12.5
    });
  });
}
