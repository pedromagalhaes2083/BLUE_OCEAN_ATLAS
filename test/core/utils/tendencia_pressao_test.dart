import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/utils/tendencia_pressao.dart';

typedef _Ponto = ({DateTime horario, double pressaoHpa});

List<_Ponto> _serieHoraria(DateTime inicio, List<double> pressoes) {
  return List.generate(
    pressoes.length,
    (i) => (horario: inicio.add(Duration(hours: i)), pressaoHpa: pressoes[i]),
  );
}

void main() {
  group('calcularTendenciaPressao', () {
    test('série vazia devolve null', () {
      expect(calcularTendenciaPressao([]), isNull);
    });

    test('sem 3h de histórico antes de "agora" devolve null', () {
      final inicio = DateTime(2026, 9, 3, 12);
      // só 1h de dado, "agora" pedido nem existe na série
      final serie = _serieHoraria(inicio, [1013.0]);
      final resultado = calcularTendenciaPressao(
        serie,
        agora: inicio.add(const Duration(hours: 5)),
      );
      expect(resultado, isNull);
    });

    test('pressão caindo mais de 0.5 hPa em 3h é classificada como caindo',
        () {
      final inicio = DateTime(2026, 9, 3, 0);
      // 0h:1015, 1h:1014.3, 2h:1013.6, 3h:1012.9 → queda de 2.1 hPa em 3h
      final serie = _serieHoraria(inicio, [1015.0, 1014.3, 1013.6, 1012.9]);
      final resultado = calcularTendenciaPressao(
        serie,
        agora: inicio.add(const Duration(hours: 3)),
      );

      expect(resultado, isNotNull);
      expect(resultado!.tipo, TendenciaPressaoTipo.caindo);
      expect(resultado.variacaoHpa, closeTo(-2.1, 0.01));
      expect(resultado.pressaoAtualHpa, closeTo(1012.9, 0.01));
    });

    test('pressão subindo mais de 0.5 hPa em 3h é classificada como subindo',
        () {
      final inicio = DateTime(2026, 9, 3, 0);
      final serie = _serieHoraria(inicio, [1010.0, 1010.7, 1011.4, 1012.1]);
      final resultado = calcularTendenciaPressao(
        serie,
        agora: inicio.add(const Duration(hours: 3)),
      );

      expect(resultado!.tipo, TendenciaPressaoTipo.subindo);
      expect(resultado.variacaoHpa, closeTo(2.1, 0.01));
    });

    test('variação pequena (dentro do limiar) é classificada como estável',
        () {
      final inicio = DateTime(2026, 9, 3, 0);
      final serie = _serieHoraria(inicio, [1013.0, 1013.1, 1013.2, 1013.3]);
      final resultado = calcularTendenciaPressao(
        serie,
        agora: inicio.add(const Duration(hours: 3)),
      );

      expect(resultado!.tipo, TendenciaPressaoTipo.estavel);
      expect(resultado.variacaoHpa, closeTo(0.3, 0.01));
    });

    test('exatamente no limiar (0.5 hPa) já conta como tendência, não estável',
        () {
      final inicio = DateTime(2026, 9, 3, 0);
      final serie = _serieHoraria(inicio, [1013.0, 1013.0, 1013.0, 1013.5]);
      final resultado = calcularTendenciaPressao(
        serie,
        agora: inicio.add(const Duration(hours: 3)),
      );

      expect(resultado!.tipo, TendenciaPressaoTipo.subindo);
    });

    test('usa o ponto mais próximo de "agora" quando não há exata', () {
      final inicio = DateTime(2026, 9, 3, 0);
      final serie = _serieHoraria(inicio, [1013.0, 1012.0, 1011.0, 1010.0]);
      // "agora" pedido é 2h30 — mais próximo é a entrada de 2h (índice 2)
      final resultado = calcularTendenciaPressao(
        serie,
        agora: inicio.add(const Duration(hours: 2, minutes: 30)),
      );

      expect(resultado!.pressaoAtualHpa, closeTo(1011.0, 0.01));
    });
  });
}
