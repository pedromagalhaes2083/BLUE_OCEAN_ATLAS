import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/config/calibracao_intelligence.dart';
import 'package:atlas/features/intelligence/domain/models/intelligence_factor.dart';
import 'package:atlas/features/intelligence/domain/models/ocean_conditions.dart';
import 'package:atlas/features/intelligence/domain/services/intelligence_engine.dart';

void main() {
  group('IntelligenceEngine.avaliar', () {
    test('condições ótimas em todos os fatores dá score alto (perto de 100)',
        () {
      final resultado = IntelligenceEngine.avaliar(
        latitude: -2.9,
        longitude: -39.6,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: 27.0, // exatamente a ideal
          correnteNos: 0.2, // fraca
          ondaAlturaM: 0.3, // calmo
          ventoKmh: 5, // calmo
          clorofilaMgM3: 0.22, // ótimo/excelente
        ),
      );

      expect(resultado.score, greaterThan(90));
      expect(resultado.confianca, 100);
    });

    test(
        'condições ruins em todos os fatores dá score baixo (perto de 0)',
        () {
      final resultado = IntelligenceEngine.avaliar(
        latitude: -2.9,
        longitude: -39.6,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: 15.0, // longe da ideal
          correnteNos: 3.0, // extrema
          ondaAlturaM: 5.0, // tempestuoso
          ventoKmh: 60, // muito forte
          clorofilaMgM3: 0.01, // ruim
        ),
      );

      expect(resultado.score, lessThan(30));
      expect(resultado.confianca, 100);
    });

    test('nenhum dado disponível: score e confiança ficam em 0, sem lançar',
        () {
      final resultado = IntelligenceEngine.avaliar(
        latitude: -2.9,
        longitude: -39.6,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(),
      );

      expect(resultado.score, 0);
      expect(resultado.confianca, 0);
      expect(resultado.factors.every((f) => !f.disponivel), isTrue);
    });

    test('fator ausente reduz a confiança e é marcado indisponível', () {
      final completo = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: 27.0,
          correnteNos: 0.2,
          ondaAlturaM: 0.3,
          ventoKmh: 5,
          clorofilaMgM3: 0.22,
        ),
      );
      final semClorofila = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: 27.0,
          correnteNos: 0.2,
          ondaAlturaM: 0.3,
          ventoKmh: 5,
        ),
      );

      expect(semClorofila.confianca, lessThan(completo.confianca));
      final fatorClorofila = semClorofila.factors
          .firstWhere((f) => f.nome == 'Clorofila');
      expect(fatorClorofila.disponivel, isFalse);
      expect(fatorClorofila.pontuacao, isNull);
      expect(fatorClorofila.status, IntelligenceFactorStatus.indisponivel);
    });

    test('peso é redistribuído: score não cai só por faltar um fator neutro',
        () {
      // Só SST disponível, e ótima — mesmo com os outros 4 fatores
      // ausentes, o score deve refletir só o que está disponível (SST alta),
      // não ser arrastado pra baixo por "faltar" nota nos outros.
      final resultado = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(sst: 27.0),
      );

      expect(resultado.score, greaterThan(90));
      expect(resultado.confianca, closeTo(25, 1)); // só o peso da SST (25%)
    });

    test('score nunca é menor que 0 nem maior que 100 (limites)', () {
      final extremoRuim = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: -5,
          correnteNos: 10,
          ondaAlturaM: 20,
          ventoKmh: 200,
          clorofilaMgM3: 0,
        ),
      );
      expect(extremoRuim.score, greaterThanOrEqualTo(0));
      expect(extremoRuim.score, lessThanOrEqualTo(100));
    });

    test('confiança nunca é menor que 0 nem maior que 100 (limites)', () {
      final resultado = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(sst: 27.0),
      );
      expect(resultado.confianca, greaterThanOrEqualTo(0));
      expect(resultado.confianca, lessThanOrEqualTo(100));
    });

    test('explicação cita os fatores indisponíveis quando há algum', () {
      final resultado = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(sst: 27.0),
      );
      expect(resultado.explicacao, contains('Corrente'));
      expect(resultado.explicacao, contains('indisponível'));
    });

    test('calibração customizada muda o quanto cada fator pesa no score', () {
      const conditions = OceanConditions(
        sst: 27.0, // excelente (100)
        correnteNos: 3.0, // extrema (10)
      );

      // Peso todo em SST: score deve ficar perto de 100 (domina o cálculo).
      final comPesoEmSst = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(
          pesoSst: 100,
          pesoCorrente: 1,
          pesoClorofila: 0,
          pesoOndas: 0,
          pesoVento: 0,
        ),
      );
      // Peso todo em corrente: score deve ficar perto de 10 (domina o cálculo).
      final comPesoEmCorrente = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(
          pesoSst: 1,
          pesoCorrente: 100,
          pesoClorofila: 0,
          pesoOndas: 0,
          pesoVento: 0,
        ),
      );

      expect(comPesoEmSst.score, greaterThan(comPesoEmCorrente.score));
      expect(comPesoEmSst.score, greaterThan(90));
      expect(comPesoEmCorrente.score, lessThan(20));
    });

    test('pesos de calibração não precisam somar 100 — só a razão importa',
        () {
      const conditions = OceanConditions(sst: 27.0);
      final pesosPequenos = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(
          pesoSst: 3,
          pesoCorrente: 3,
          pesoClorofila: 3,
          pesoOndas: 2,
          pesoVento: 1,
        ),
      );
      final pesosGrandes = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(
          pesoSst: 30,
          pesoCorrente: 30,
          pesoClorofila: 30,
          pesoOndas: 20,
          pesoVento: 10,
        ),
      );

      expect(pesosPequenos.score, closeTo(pesosGrandes.score, 0.01));
      expect(pesosPequenos.confianca, closeTo(pesosGrandes.confianca, 0.01));
    });

    test('quantidade ideal calibrada desloca a curva de SST', () {
      // 30°C é ótimo pro padrão (ideal 27°C, distância 3 → "bom" = 55),
      // mas vira excelente (100) se o usuário recalibrar o ideal pra 30°C.
      const conditions = OceanConditions(sst: 30.0);
      final comIdealPadrao = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
      );
      final comIdealRecalibrado = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(sstIdealC: 30.0),
      );

      expect(comIdealRecalibrado.score, greaterThan(comIdealPadrao.score));
      final fatorRecalibrado =
          comIdealRecalibrado.factors.firstWhere((f) => f.nome == 'SST');
      expect(fatorRecalibrado.pontuacao, 100);
    });

    test('quantidade ideal calibrada desloca a curva de vento', () {
      // 25 km/h é "moderado" (55) pro padrão (ideal 10 km/h → 25 está entre
      // 2x e 3x o ideal), mas vira "calmo" (100) se o ideal for recalibrado
      // pra acima de 25 km/h.
      const conditions = OceanConditions(ventoKmh: 25);
      final comIdealPadrao = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
      );
      final comIdealRecalibrado = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(ventoIdealKmh: 30),
      );

      final fatorPadrao =
          comIdealPadrao.factors.firstWhere((f) => f.nome == 'Vento');
      final fatorRecalibrado =
          comIdealRecalibrado.factors.firstWhere((f) => f.nome == 'Vento');
      expect(fatorRecalibrado.pontuacao, greaterThan(fatorPadrao.pontuacao!));
      expect(fatorRecalibrado.pontuacao, 100);
    });

    test('quantidade ideal de clorofila é monotônica (mais é sempre >= nota)',
        () {
      final baixo = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(clorofilaMgM3: 0.05),
      );
      final alto = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(clorofilaMgM3: 0.5),
      );
      final fatorBaixo = baixo.factors.firstWhere((f) => f.nome == 'Clorofila');
      final fatorAlto = alto.factors.firstWhere((f) => f.nome == 'Clorofila');
      expect(fatorAlto.pontuacao, greaterThan(fatorBaixo.pontuacao!));
    });
  });

  group('CalibracaoIntelligence', () {
    test('participacao calcula a fração de cada peso sobre o total', () {
      const calibracao = CalibracaoIntelligence.padrao;
      final total = calibracao.somaTotal;
      expect(total, 120);
      expect(calibracao.participacao(calibracao.pesoSst), closeTo(25, 0.01));
      expect(calibracao.participacao(calibracao.pesoVento),
          closeTo(8.33, 0.1));
    });

    test('copyWith troca só o campo pedido', () {
      const calibracao = CalibracaoIntelligence.padrao;
      final novo = calibracao.copyWith(pesoSst: 50);
      expect(novo.pesoSst, 50);
      expect(novo.pesoCorrente, calibracao.pesoCorrente);
    });
  });
}
