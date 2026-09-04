import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/utils/fase_lua.dart';
import 'package:atlas/core/utils/indice_influencia_mare.dart';

void main() {
  group('calcularIndiceInfluenciaMare', () {
    final faseNova = calcularFaseLua(DateTime.utc(2000, 1, 6, 18, 14)); // idade 0

    test('sem nenhum dado extra, pontua só a fase lunar (sizígia = 100)', () {
      final resultado = calcularIndiceInfluenciaMare(fase: faseNova);
      expect(resultado.valor, closeTo(100, 0.5));
      final corrente =
          resultado.fatoresPontuados.firstWhere((f) => f.nome.contains('corrente'));
      expect(corrente.disponivel, isFalse);
      expect(corrente.pontuacao, isNull);
    });

    test('amplitude e corrente indisponíveis aparecem marcadas, não zeradas', () {
      final resultado = calcularIndiceInfluenciaMare(fase: faseNova);
      final amplitude = resultado.fatoresPontuados
          .firstWhere((f) => f.nome.contains('Amplitude'));
      expect(amplitude.disponivel, isFalse);
      expect(amplitude.detalhe, isNull);
    });

    test('quadratura pontua baixo na fase lunar', () {
      final faseQuadratura =
          calcularFaseLua(DateTime.utc(2000, 1, 6, 18, 14)
              .add(Duration(minutes: (diasMesSinodico / 4 * 24 * 60).round())));
      final resultado = calcularIndiceInfluenciaMare(fase: faseQuadratura);
      final fatorFase =
          resultado.fatoresPontuados.firstWhere((f) => f.nome.contains('Fase lunar'));
      expect(fatorFase.pontuacao, closeTo(0, 1));
    });

    test('amplitude e corrente disponíveis entram na média', () {
      final resultado = calcularIndiceInfluenciaMare(
        fase: faseNova, // pontuação 100
        amplitudeMareM: 3.0, // pontuação 100 (referência máxima)
        correnteVelocidadeMs: 1.5, // pontuação 100 (referência máxima)
      );
      expect(resultado.valor, closeTo(100, 0.5));
    });

    test('amplitude parcial gera pontuação proporcional', () {
      final resultado = calcularIndiceInfluenciaMare(
        fase: faseNova,
        amplitudeMareM: 1.5, // metade da referência de 3.0m
      );
      final amplitude = resultado.fatoresPontuados
          .firstWhere((f) => f.nome.contains('Amplitude'));
      expect(amplitude.pontuacao, closeTo(50, 0.5));
    });

    test('valores acima da referência ficam limitados a 100 (clamp)', () {
      final resultado = calcularIndiceInfluenciaMare(
        fase: faseNova,
        amplitudeMareM: 10.0,
        correnteVelocidadeMs: 5.0,
      );
      for (final f in resultado.fatoresPontuados) {
        expect(f.pontuacao! <= 100, isTrue);
      }
    });

    test('lista fatores informativos que não entram na pontuação', () {
      final resultado = calcularIndiceInfluenciaMare(fase: faseNova);
      expect(resultado.fatoresInformativos, contains('Clorofila'));
      expect(resultado.fatoresInformativos, contains('Vento'));
    });
  });

  group('IndiceInfluenciaMare.classificacao', () {
    final faseNova = calcularFaseLua(DateTime.utc(2000, 1, 6, 18, 14));

    test('sem valor, classificação é null (nunca inventada)', () {
      final resultado = IndiceInfluenciaMare(
        valor: null,
        fatoresPontuados: const [],
        fatoresInformativos: const [],
      );
      expect(resultado.classificacao, isNull);
    });

    test('valor abaixo de 34 é baixa', () {
      final resultado = calcularIndiceInfluenciaMare(
        fase: faseNova,
        amplitudeMareM: 0,
        correnteVelocidadeMs: 0,
      );
      // Fase nova pontua 100, mas amplitude e corrente pontuam 0 — média
      // dos 3 fica bem abaixo de 34.
      expect(resultado.classificacao, ClassificacaoIndiceMare.baixa);
    });

    test('valor no meio da faixa é moderada', () {
      final resultado = IndiceInfluenciaMare(
        valor: 50,
        fatoresPontuados: const [],
        fatoresInformativos: const [],
      );
      expect(resultado.classificacao, ClassificacaoIndiceMare.moderada);
    });

    test('valor alto é alta', () {
      final resultado = IndiceInfluenciaMare(
        valor: 90,
        fatoresPontuados: const [],
        fatoresInformativos: const [],
      );
      expect(resultado.classificacao, ClassificacaoIndiceMare.alta);
    });

    test('limiares exatos: 34 já é moderada, 67 já é alta', () {
      expect(
        const IndiceInfluenciaMare(valor: 34, fatoresPontuados: [], fatoresInformativos: [])
            .classificacao,
        ClassificacaoIndiceMare.moderada,
      );
      expect(
        const IndiceInfluenciaMare(valor: 67, fatoresPontuados: [], fatoresInformativos: [])
            .classificacao,
        ClassificacaoIndiceMare.alta,
      );
    });
  });
}
