import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/utils/tabela_solunar.dart';
import 'package:atlas/features/metereologia/domain/models/dia_lunar.dart';

void main() {
  group('calcularPeriodosSolunares', () {
    test('sem eventos de lua suficientes, devolve lista vazia', () {
      final dias = [DiaLunar(data: DateTime(2026, 9, 3))];
      final periodos = calcularPeriodosSolunares(
        dias,
        desde: DateTime(2026, 9, 3),
      );
      expect(periodos, isEmpty);
    });

    test('gera um período menor pra cada nascer/pôr da lua dentro da janela',
        () {
      final dias = [
        DiaLunar(
          data: DateTime(2026, 9, 3),
          nascer: DateTime(2026, 9, 3, 6),
          poesta: DateTime(2026, 9, 3, 18),
        ),
      ];
      final periodos = calcularPeriodosSolunares(
        dias,
        desde: DateTime(2026, 9, 3),
        janela: const Duration(days: 1),
      );

      final menores =
          periodos.where((p) => p.tipo == TipoPeriodoSolunar.menor).toList();
      expect(menores, hasLength(2));
      // Centro do período menor bate com o horário exato do evento.
      expect(
        menores[0].inicio.add(menores[0].duracao ~/ 2),
        DateTime(2026, 9, 3, 6),
      );
    });

    test('gera um período maior no meio do caminho entre nascer e pôr '
        '(aproxima a culminação)', () {
      final dias = [
        DiaLunar(
          data: DateTime(2026, 9, 3),
          nascer: DateTime(2026, 9, 3, 6),
          poesta: DateTime(2026, 9, 3, 18),
        ),
      ];
      final periodos = calcularPeriodosSolunares(
        dias,
        desde: DateTime(2026, 9, 3),
        janela: const Duration(days: 1),
      );

      final maiores =
          periodos.where((p) => p.tipo == TipoPeriodoSolunar.maior).toList();
      expect(maiores, hasLength(1));
      final centro = maiores.first.inicio.add(maiores.first.duracao ~/ 2);
      expect(centro, DateTime(2026, 9, 3, 12)); // meio do caminho 6h-18h
    });

    test('período maior tem ~2h, período menor tem ~1h', () {
      final dias = [
        DiaLunar(
          data: DateTime(2026, 9, 3),
          nascer: DateTime(2026, 9, 3, 6),
          poesta: DateTime(2026, 9, 3, 18),
        ),
      ];
      final periodos = calcularPeriodosSolunares(
        dias,
        desde: DateTime(2026, 9, 3),
        janela: const Duration(days: 1),
      );

      for (final p in periodos) {
        final duracaoEsperada = p.tipo == TipoPeriodoSolunar.maior
            ? const Duration(hours: 2)
            : const Duration(hours: 1);
        expect(p.duracao, duracaoEsperada);
      }
    });

    test('usa eventos de dias vizinhos pra interpolar corretamente perto '
        'da virada do dia', () {
      // Pôr da lua às 23h de um dia, próximo nascer só às 3h do dia
      // seguinte — o período maior entre esses dois tem que cair por
      // volta da 1h, atravessando a meia-noite.
      final dias = [
        DiaLunar(
          data: DateTime(2026, 9, 3),
          nascer: DateTime(2026, 9, 3, 11),
          poesta: DateTime(2026, 9, 3, 23),
        ),
        DiaLunar(
          data: DateTime(2026, 9, 4),
          nascer: DateTime(2026, 9, 4, 12),
          poesta: DateTime(2026, 9, 4, 23, 30),
        ),
      ];
      final periodos = calcularPeriodosSolunares(
        dias,
        desde: DateTime(2026, 9, 3, 22),
        janela: const Duration(hours: 8),
      );

      final maiores =
          periodos.where((p) => p.tipo == TipoPeriodoSolunar.maior).toList();
      expect(maiores, isNotEmpty);
      final centro = maiores.first.inicio.add(maiores.first.duracao ~/ 2);
      // Meio do caminho entre 23h (dia 3) e 12h (dia 4) = 5h30 do dia 4.
      expect(centro, DateTime(2026, 9, 4, 5, 30));
    });

    test('períodos fora da janela pedida não aparecem', () {
      final dias = [
        DiaLunar(
          data: DateTime(2026, 9, 3),
          nascer: DateTime(2026, 9, 3, 6),
          poesta: DateTime(2026, 9, 3, 18),
        ),
        DiaLunar(
          data: DateTime(2026, 9, 10),
          nascer: DateTime(2026, 9, 10, 6),
          poesta: DateTime(2026, 9, 10, 18),
        ),
      ];
      final periodos = calcularPeriodosSolunares(
        dias,
        desde: DateTime(2026, 9, 3),
        janela: const Duration(days: 1),
      );

      for (final p in periodos) {
        expect(p.inicio.isBefore(DateTime(2026, 9, 5)), isTrue);
      }
    });
  });
}
