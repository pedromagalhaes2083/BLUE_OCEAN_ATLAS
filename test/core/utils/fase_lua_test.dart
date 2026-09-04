import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/utils/fase_lua.dart';

void main() {
  group('calcularFaseLua', () {
    test('lua nova de referência tem idade 0 e fração iluminada 0', () {
      // A própria lua nova usada como época — idade tem que dar exatamente
      // 0 (ou infinitesimalmente próximo, por causa de arredondamento de
      // ponto flutuante).
      final fase = calcularFaseLua(DateTime.utc(2000, 1, 6, 18, 14));
      expect(fase.idadeDias, closeTo(0, 0.001));
      expect(fase.fracaoIluminada, closeTo(0, 0.001));
      expect(fase.tipo, FaseLuaTipo.novaLua);
    });

    test('meio caminho do mês sinódico é lua cheia, fração iluminada 1', () {
      final meioMes = DateTime.utc(2000, 1, 6, 18, 14).add(
        Duration(minutes: (diasMesSinodico / 2 * 24 * 60).round()),
      );
      final fase = calcularFaseLua(meioMes);
      expect(fase.idadeDias, closeTo(diasMesSinodico / 2, 0.01));
      expect(fase.fracaoIluminada, closeTo(1, 0.01));
      expect(fase.tipo, FaseLuaTipo.cheia);
    });

    test('idade nunca é negativa nem maior que o mês sinódico', () {
      // Datas bem antes e bem depois da época de referência — testa o
      // módulo (%) em ambas as direções.
      for (final data in [
        DateTime.utc(1950, 3, 12),
        DateTime.utc(2000, 1, 6, 18, 14), // a própria época
        DateTime.utc(2026, 9, 3),
        DateTime.utc(2099, 12, 31),
      ]) {
        final fase = calcularFaseLua(data);
        expect(fase.idadeDias, greaterThanOrEqualTo(0));
        expect(fase.idadeDias, lessThan(diasMesSinodico));
      }
    });

    test('bate com a fração de fase que a Open-Meteo devolveu em 2026-09-03',
        () {
      // Valor real de referência (curl direto na API, ver histórico) —
      // moon_phase=0.724 pra 2026-09-03T12:00 UTC em Fortaleza. Uma
      // fórmula sinódica simples não bate exato com uma efeméride de
      // verdade; a tolerância aqui é a diferença observada (~1 dia de
      // idade lunar), não um valor arbitrário.
      final fase = calcularFaseLua(DateTime.utc(2026, 9, 3, 12));
      final fracaoEsperada = 0.724;
      final fracaoCalculada = fase.idadeDias / diasMesSinodico;
      expect(fracaoCalculada, closeTo(fracaoEsperada, 0.03));
    });

    test('fases se sucedem na ordem certa ao longo do mês, e voltam pra '
        'lua nova no ciclo seguinte', () {
      // Cada fase nomeada é uma faixa de ~3.69 dias, centralizada nela
      // mesma (ver `_tipoFasePorIdade`) — a última faixa ("minguante")
      // termina meia faixa antes do fim do mês sinódico, quando já vira
      // "lua nova" de novo (correto: é um ciclo). Varrendo o mês inteiro,
      // a sequência tem que ser as 8 fases em ordem e fechar voltando pra
      // lua nova.
      final epoca = DateTime.utc(2000, 1, 6, 18, 14);
      final tiposEncontrados = <FaseLuaTipo>[];
      for (var dia = 0.0; dia < diasMesSinodico; dia += 0.5) {
        final instante =
            epoca.add(Duration(minutes: (dia * 24 * 60).round()));
        final tipo = calcularFaseLua(instante).tipo;
        if (tiposEncontrados.isEmpty || tiposEncontrados.last != tipo) {
          tiposEncontrados.add(tipo);
        }
      }
      expect(tiposEncontrados, [...FaseLuaTipo.values, FaseLuaTipo.novaLua]);
    });
  });

  group('proximasFasesPrincipais', () {
    test('devolve as 4 fases principais, todas no futuro, em ordem', () {
      final agora = DateTime.utc(2026, 9, 3, 12);
      final proximas = proximasFasesPrincipais(agora);

      expect(proximas, hasLength(4));
      expect(
        proximas.map((p) => p.tipo).toSet(),
        fasesPrincipais.toSet(),
      );
      for (final p in proximas) {
        expect(p.instante.isAfter(agora), isTrue);
      }
      for (var i = 1; i < proximas.length; i++) {
        expect(
          proximas[i].instante.isAfter(proximas[i - 1].instante),
          isTrue,
        );
      }
    });

    test('a fase mais próxima nunca está a mais de um mês sinódico de distância',
        () {
      final agora = DateTime.now();
      final proximas = proximasFasesPrincipais(agora);
      final diasAteAPrimeira =
          proximas.first.instante.difference(agora).inHours / 24.0;
      expect(diasAteAPrimeira, lessThanOrEqualTo(diasMesSinodico));
      expect(diasAteAPrimeira, greaterThan(0));
    });

    test('logo depois de uma lua nova, a próxima fase é o quarto crescente',
        () {
      // Referência + 1 dia: acabou de passar a lua nova, a próxima fase
      // principal tem que ser o quarto crescente, não a lua nova de novo.
      final logoDepoisDaNova =
          DateTime.utc(2000, 1, 6, 18, 14).add(const Duration(days: 1));
      final proximas = proximasFasesPrincipais(logoDepoisDaNova);
      expect(proximas.first.tipo, FaseLuaTipo.quartoCrescente);
    });
  });

  group('calcularTipoMareAstronomica', () {
    TipoMareAstronomica tipoNaIdade(double idadeDias) {
      final epoca = DateTime.utc(2000, 1, 6, 18, 14);
      final instante =
          epoca.add(Duration(minutes: (idadeDias * 24 * 60).round()));
      return calcularTipoMareAstronomica(calcularFaseLua(instante));
    }

    test('lua nova (idade 0) é sizígia', () {
      expect(tipoNaIdade(0), TipoMareAstronomica.sizigia);
    });

    test('lua cheia (meio do mês sinódico) é sizígia', () {
      expect(tipoNaIdade(diasMesSinodico / 2), TipoMareAstronomica.sizigia);
    });

    test('quarto crescente é quadratura', () {
      expect(
          tipoNaIdade(diasMesSinodico / 4), TipoMareAstronomica.quadratura);
    });

    test('quarto minguante é quadratura', () {
      expect(tipoNaIdade(diasMesSinodico * 3 / 4),
          TipoMareAstronomica.quadratura);
    });

    test('bem no meio do caminho entre um ponto e outro é transição', () {
      // Entre lua nova (0) e quarto crescente (~7.38) — bem no meio,
      // ~3.7 dias de qualquer um dos dois, fora da janela de 2 dias.
      final meioDoCaminho = diasMesSinodico / 8;
      expect(tipoNaIdade(meioDoCaminho), TipoMareAstronomica.transicao);
    });

    test('perto (mas não exatamente) da lua cheia ainda conta como sizígia',
        () {
      expect(tipoNaIdade(diasMesSinodico / 2 - 1.5),
          TipoMareAstronomica.sizigia);
      expect(tipoNaIdade(diasMesSinodico / 2 + 1.5),
          TipoMareAstronomica.sizigia);
    });

    test('a distância circular funciona perto do fim do ciclo (idade ~29, '
        'perto da lua nova do ciclo seguinte, não do meio do mês)', () {
      // idade = diasMesSinodico - 1: 1 dia antes de fechar o ciclo, ou
      // seja, 1 dia antes da PRÓXIMA lua nova — tem que dar sizígia, não
      // "longe de tudo" por não considerar o wrap-around.
      expect(
          tipoNaIdade(diasMesSinodico - 1), TipoMareAstronomica.sizigia);
    });
  });
}
