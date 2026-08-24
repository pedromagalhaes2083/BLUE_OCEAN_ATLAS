import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/core/utils/mare_harmonica.dart';

void main() {
  group('projetarPontoNoRumo (via ajustarModeloMareHarmonico)', () {
    test('reconstrói amplitude/fase de uma senoide M2 sintética', () {
      // Série sintética: nível médio 1.2 m + só a componente M2 (amplitude
      // 0.6 m, fase conhecida) — amostrada de hora em hora por 20 dias, o
      // suficiente pra separar M2 de S2/K1/O1 (não perfeito, mas próximo).
      final epoca = DateTime(2026, 1, 1);
      const nivelMedio = 1.2;
      const amplitudeM2 = 0.6;
      const faseM2 = 0.7; // rad
      final periodoM2 = periodosConstituintesPadrao[0]; // M2

      final horarios = <DateTime>[];
      final alturas = <double>[];
      for (var h = 0; h < 20 * 24; h++) {
        final t = epoca.add(Duration(hours: h));
        horarios.add(t);
        final omega = 2 * math.pi / periodoM2;
        alturas.add(nivelMedio + amplitudeM2 * math.cos(omega * h - faseM2));
      }

      final modelo = ajustarModeloMareHarmonico(
        horarios: horarios,
        alturas: alturas,
        epoca: epoca,
      );

      expect(modelo.nivelMedioM, closeTo(nivelMedio, 0.05));

      final m2 = modelo.constituintes.firstWhere((c) => c.nome == 'M2');
      expect(m2.amplitudeM, closeTo(amplitudeM2, 0.05));
      expect(m2.faseRad, closeTo(faseM2, 0.05));
    });

    test('altura() reproduz os pontos usados no ajuste', () {
      final epoca = DateTime(2026, 1, 1);
      final horarios = List.generate(
          15 * 24, (h) => epoca.add(Duration(hours: h)));
      final alturas = horarios
          .map((t) => 1.0 +
              0.5 *
                  math.cos(2 *
                          math.pi /
                          12.4206012 *
                          t.difference(epoca).inHours -
                      0.3))
          .toList();

      final modelo = ajustarModeloMareHarmonico(
        horarios: horarios,
        alturas: alturas,
        epoca: epoca,
      );

      for (var i = 0; i < horarios.length; i += 24) {
        expect(modelo.altura(horarios[i]), closeTo(alturas[i], 0.05));
      }
    });

    test('lança ArgumentError com listas de tamanhos diferentes', () {
      expect(
        () => ajustarModeloMareHarmonico(
          horarios: [DateTime(2026, 1, 1)],
          alturas: [1.0, 2.0],
        ),
        throwsArgumentError,
      );
    });
  });

  group('ModeloMareHarmonico.proximosEventos', () {
    test('alterna entre preamar e baixa-mar (nunca duas do mesmo tipo seguidas)', () {
      final modelo = ModeloMareHarmonico(
        nivelMedioM: 1.0,
        epoca: DateTime(2026, 1, 1),
        constituintes: [
          ConstituenteMare(
            nome: 'M2',
            periodoHoras: 12.4206012,
            amplitudeM: 0.8,
            faseRad: 0,
          ),
        ],
      );

      final eventos = modelo.proximosEventos(
        DateTime(2026, 1, 1),
        janela: const Duration(days: 3),
      );

      expect(eventos.length, greaterThan(3));
      for (var i = 1; i < eventos.length; i++) {
        expect(eventos[i].alta, isNot(eventos[i - 1].alta));
      }
    });

    test('serialização toJson/fromJson preserva o modelo', () {
      final modelo = ModeloMareHarmonico(
        nivelMedioM: 0.8,
        epoca: DateTime(2026, 3, 5, 12),
        constituintes: const [
          ConstituenteMare(
              nome: 'M2', periodoHoras: 12.4206012, amplitudeM: 0.5, faseRad: 1.1),
          ConstituenteMare(
              nome: 'S2', periodoHoras: 12.0, amplitudeM: 0.2, faseRad: -0.4),
        ],
      );

      final restaurado =
          ModeloMareHarmonico.fromJsonString(modelo.toJsonString());

      final instante = DateTime(2026, 3, 6, 8);
      expect(restaurado.altura(instante), closeTo(modelo.altura(instante), 0.0001));
    });
  });
}
