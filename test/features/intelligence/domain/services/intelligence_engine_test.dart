import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/config/calibracao_intelligence.dart';
import 'package:atlas/features/intelligence/domain/models/intelligence_factor.dart';
import 'package:atlas/features/intelligence/domain/models/intelligence_result.dart';
import 'package:atlas/features/intelligence/domain/models/ocean_conditions.dart';
import 'package:atlas/features/intelligence/domain/services/intelligence_engine.dart';

void main() {
  group('IntelligenceEngine.avaliar — índice de favorabilidade de atum', () {
    test('condições excelentes em todos os fatores dá score 100', () {
      final resultado = IntelligenceEngine.avaliar(
        latitude: -2.9,
        longitude: -39.6,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: 27.5, // dentro de 22-30 (excelente)
          salinidadeUps: 35.4, // dentro de 34.9-35.8 (excelente)
          clorofilaMgM3: 0.11, // dentro de 0.08-0.14 (excelente)
          correnteNos: 0.6, // dentro de 0.3-1.0 (excelente)
          profundidadeM: 1800, // dentro de 100-2000 (excelente)
        ),
      );

      expect(resultado.score, 100);
      expect(resultado.confianca, 100);
      expect(resultado.classificacao, IntelligenceClassificacao.muitoFavoravel);
    });

    test('condições fora de qualquer faixa (baixa) em todos os fatores dá score baixo',
        () {
      final resultado = IntelligenceEngine.avaliar(
        latitude: -2.9,
        longitude: -39.6,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: 15.0, // bem longe de 22-30
          salinidadeUps: 20.0, // bem longe de 34.9-35.8
          clorofilaMgM3: 0.01, // bem abaixo de 0.08-0.14
          correnteNos: 5.0, // bem acima de 0.3-1.0
          profundidadeM: 5, // bem abaixo de 100-2000 (raso demais)
        ),
      );

      expect(resultado.score, 25);
      expect(resultado.confianca, 100);
      expect(resultado.classificacao, IntelligenceClassificacao.baixa);
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
          salinidadeUps: 35.4,
          clorofilaMgM3: 0.11,
          correnteNos: 0.6,
          profundidadeM: 1800,
        ),
      );
      final semClorofila = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: 27.0,
          salinidadeUps: 35.4,
          correnteNos: 0.6,
          profundidadeM: 1800,
        ),
      );

      expect(semClorofila.confianca, lessThan(completo.confianca));
      final fatorClorofila =
          semClorofila.factors.firstWhere((f) => f.nome == 'Clorofila');
      expect(fatorClorofila.disponivel, isFalse);
      expect(fatorClorofila.pontuacao, isNull);
      expect(fatorClorofila.status, IntelligenceFactorStatus.indisponivel);
    });

    test('peso é redistribuído: score reflete só o que está disponível', () {
      // Só temperatura disponível, e excelente — mesmo com os outros 4
      // fatores ausentes, o score deve refletir só o que está disponível.
      final resultado = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(sst: 27.0),
      );

      expect(resultado.score, 100);
      // Só o peso da temperatura (35 de 110 = ~31.8%).
      expect(resultado.confianca, closeTo(31.8, 0.5));
    });

    test('score nunca é menor que 0 nem maior que 100 (limites)', () {
      final extremoRuim = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(
          sst: -5,
          salinidadeUps: 0,
          clorofilaMgM3: 0,
          correnteNos: 10,
          profundidadeM: 0,
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
      expect(resultado.explicacao, contains('Salinidade'));
      expect(resultado.explicacao, contains('indisponível'));
    });

    test('calibração customizada muda o quanto cada fator pesa no score', () {
      const conditions = OceanConditions(
        sst: 27.0, // excelente (100)
        salinidadeUps: 20.0, // baixa (25)
      );

      // Peso todo em temperatura: score deve ficar perto de 100.
      final comPesoEmTemperatura = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(
          pesoTemperatura: 100,
          pesoSalinidade: 1,
          pesoClorofila: 0,
          pesoCorrente: 0,
          pesoBatimetria: 0,
        ),
      );
      // Peso todo em salinidade: score deve ficar perto de 25.
      final comPesoEmSalinidade = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(
          pesoTemperatura: 1,
          pesoSalinidade: 100,
          pesoClorofila: 0,
          pesoCorrente: 0,
          pesoBatimetria: 0,
        ),
      );

      expect(comPesoEmTemperatura.score, greaterThan(comPesoEmSalinidade.score));
      expect(comPesoEmTemperatura.score, greaterThan(90));
      expect(comPesoEmSalinidade.score, lessThan(30));
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
          pesoTemperatura: 3,
          pesoSalinidade: 3,
          pesoClorofila: 2,
          pesoCorrente: 1,
          pesoBatimetria: 1,
        ),
      );
      final pesosGrandes = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao.copyWith(
          pesoTemperatura: 30,
          pesoSalinidade: 30,
          pesoClorofila: 20,
          pesoCorrente: 10,
          pesoBatimetria: 10,
        ),
      );

      expect(pesosPequenos.score, closeTo(pesosGrandes.score, 0.01));
      expect(pesosPequenos.confianca, closeTo(pesosGrandes.confianca, 0.01));
    });

    test('faixa ideal recalibrada muda a nota de temperatura', () {
      // 32°C é "baixa" pro padrão (fora de 22-30 + margem de 1.5 = até 31.5),
      // mas vira "excelente" (100) se a faixa ideal for recalibrada.
      const conditions = OceanConditions(sst: 32.0);
      final comFaixaPadrao = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
      );
      final comFaixaRecalibrada = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao: CalibracaoIntelligence.padrao
            .copyWith(temperaturaIdealMinC: 30, temperaturaIdealMaxC: 34),
      );

      final fatorPadrao =
          comFaixaPadrao.factors.firstWhere((f) => f.nome == 'Temperatura');
      final fatorRecalibrado = comFaixaRecalibrada.factors
          .firstWhere((f) => f.nome == 'Temperatura');
      expect(fatorPadrao.pontuacao, 25);
      expect(fatorRecalibrado.pontuacao, 100);
    });

    test('margem recalibrada muda a nota de um valor logo fora da faixa ideal',
        () {
      // 31°C está a 1°C além do máximo ideal (30) — "moderada" com a margem
      // padrão (1.5), mas vira "baixa" se a margem for recalibrada pra 0.
      const conditions = OceanConditions(sst: 31.0);
      final comMargemPadrao = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
      );
      final semMargem = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: conditions,
        calibracao:
            CalibracaoIntelligence.padrao.copyWith(temperaturaMargemC: 0),
      );

      final fatorComMargem =
          comMargemPadrao.factors.firstWhere((f) => f.nome == 'Temperatura');
      final fatorSemMargem =
          semMargem.factors.firstWhere((f) => f.nome == 'Temperatura');
      expect(fatorComMargem.pontuacao, 60);
      expect(fatorSemMargem.pontuacao, 25);
    });

    test('classificacao segue as faixas do prompt original (0-30/31-60/61-80/81-100)',
        () {
      // Um único fator (temperatura) com peso 100% pra controlar o score
      // com precisão: pontuações por banda são 100/60/25 (ver
      // `IntelligenceEngine._fatorBanda`), então testamos as bordas com
      // essas pontuações possíveis, não valores arbitrários.
      CalibracaoIntelligence calibracaoSoTemperatura() =>
          CalibracaoIntelligence.padrao.copyWith(
            pesoTemperatura: 1,
            pesoSalinidade: 0,
            pesoClorofila: 0,
            pesoCorrente: 0,
            pesoBatimetria: 0,
          );

      final baixa = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(sst: 0),
        calibracao: calibracaoSoTemperatura(),
      );
      final moderada = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(sst: 31.0),
        calibracao: calibracaoSoTemperatura(),
      );
      final muitoFavoravel = IntelligenceEngine.avaliar(
        latitude: 0,
        longitude: 0,
        instante: DateTime(2026, 9, 26),
        conditions: const OceanConditions(sst: 27.0),
        calibracao: calibracaoSoTemperatura(),
      );

      expect(baixa.score, 25);
      expect(baixa.classificacao, IntelligenceClassificacao.baixa);
      expect(moderada.score, 60);
      expect(moderada.classificacao, IntelligenceClassificacao.moderada);
      expect(muitoFavoravel.score, 100);
      expect(muitoFavoravel.classificacao,
          IntelligenceClassificacao.muitoFavoravel);
    });
  });

  group('CalibracaoIntelligence', () {
    test('participacao calcula a fração de cada peso sobre o total', () {
      const calibracao = CalibracaoIntelligence.padrao;
      final total = calibracao.somaTotal;
      expect(total, 110);
      expect(calibracao.participacao(calibracao.pesoTemperatura),
          closeTo(31.8, 0.1));
      expect(calibracao.participacao(calibracao.pesoBatimetria),
          closeTo(9.1, 0.1));
    });

    test('copyWith troca só o campo pedido', () {
      const calibracao = CalibracaoIntelligence.padrao;
      final novo = calibracao.copyWith(pesoTemperatura: 50);
      expect(novo.pesoTemperatura, 50);
      expect(novo.pesoCorrente, calibracao.pesoCorrente);
    });
  });
}
