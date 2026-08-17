import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/features/producao/domain/classificacao_peso.dart';

void main() {
  group('faixaPesoUnitario', () {
    test('10-15 retorna o intervalo literal da faixa', () {
      final faixa =
          faixaPesoUnitario(TipoPeixe.kihada, Classificacao.faixa10a15);
      expect(faixa.min, 10);
      expect(faixa.max, 15);
    });

    test('15-25 retorna o intervalo literal da faixa', () {
      final faixa =
          faixaPesoUnitario(TipoPeixe.kihada, Classificacao.faixa15a25);
      expect(faixa.min, 15);
      expect(faixa.max, 25);
    });

    test('25-39 retorna o intervalo literal da faixa', () {
      final faixa =
          faixaPesoUnitario(TipoPeixe.bati, Classificacao.faixa25a39);
      expect(faixa.min, 25);
      expect(faixa.max, 39);
    });

    test('40+ usa o intervalo estipulado (45-50), não "40 e acima" literal',
        () {
      final faixa =
          faixaPesoUnitario(TipoPeixe.kihada, Classificacao.faixa40mais);
      expect(faixa.min, 45);
      expect(faixa.max, 50);
    });

    test('a mesma tabela vale para Kihada e Bati', () {
      for (final classificacao in Classificacao.values) {
        final kihada = faixaPesoUnitario(TipoPeixe.kihada, classificacao);
        final bati = faixaPesoUnitario(TipoPeixe.bati, classificacao);
        expect(kihada.min, bati.min, reason: '$classificacao min diverge');
        expect(kihada.max, bati.max, reason: '$classificacao max diverge');
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
      final faixa =
          faixaPesoUnitario(TipoPeixe.kihada, Classificacao.faixa40mais);
      const unidades = 12;
      expect(unidades * faixa.min, 540.0);
      expect(unidades * faixa.max, 600.0);
    });

    test('peso médio salvo no registro é quantidade × ponto médio da faixa',
        () {
      final faixa =
          faixaPesoUnitario(TipoPeixe.bati, Classificacao.faixa10a15);
      const unidades = 8;
      expect(unidades * faixa.media, 100.0); // 8 * 12.5
    });
  });
}
