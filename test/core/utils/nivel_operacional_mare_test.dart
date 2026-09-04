import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/utils/fase_lua.dart';
import 'package:atlas/core/utils/nivel_operacional_mare.dart';

void main() {
  group('calcularNivelOperacionalMare', () {
    test('sizígia + corrente relevante = favorável', () {
      final nivel = calcularNivelOperacionalMare(
        tipoMare: TipoMareAstronomica.sizigia,
        correnteVelocidadeMs: 0.5,
      );
      expect(nivel, NivelOperacionalMare.favoravel);
    });

    test('sizígia mas sem dado de corrente = atenção (dado faltando, não zerado)', () {
      final nivel = calcularNivelOperacionalMare(
        tipoMare: TipoMareAstronomica.sizigia,
        correnteVelocidadeMs: null,
      );
      expect(nivel, NivelOperacionalMare.atencao);
    });

    test('transição = atenção, mesmo com corrente forte', () {
      final nivel = calcularNivelOperacionalMare(
        tipoMare: TipoMareAstronomica.transicao,
        correnteVelocidadeMs: 1.2,
      );
      expect(nivel, NivelOperacionalMare.atencao);
    });

    test('quadratura com corrente fraca = baixa evidência', () {
      final nivel = calcularNivelOperacionalMare(
        tipoMare: TipoMareAstronomica.quadratura,
        correnteVelocidadeMs: 0.1,
      );
      expect(nivel, NivelOperacionalMare.baixaEvidencia);
    });

    test('sizígia com corrente fraca = atenção (sinais divergentes, não '
        'baixa evidência)', () {
      final nivel = calcularNivelOperacionalMare(
        tipoMare: TipoMareAstronomica.sizigia,
        correnteVelocidadeMs: 0.1,
      );
      expect(nivel, NivelOperacionalMare.atencao);
    });

    test('quadratura com corrente forte = atenção (sinais divergentes — bug '
        'reportado: caía em baixa evidência mesmo com corrente medida real '
        'de 1.40 m/s)', () {
      final nivel = calcularNivelOperacionalMare(
        tipoMare: TipoMareAstronomica.quadratura,
        correnteVelocidadeMs: 1.4,
      );
      expect(nivel, NivelOperacionalMare.atencao);
    });

    test('corrente exatamente no limiar (0.3) já conta como sinal presente', () {
      final nivel = calcularNivelOperacionalMare(
        tipoMare: TipoMareAstronomica.sizigia,
        correnteVelocidadeMs: 0.3,
      );
      expect(nivel, NivelOperacionalMare.favoravel);
    });
  });
}
