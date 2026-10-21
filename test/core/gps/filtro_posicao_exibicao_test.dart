import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/gps/amostra_gps.dart';
import 'package:atlas/core/gps/filtro_posicao_exibicao.dart';

final _t0 = DateTime.utc(2026, 10, 20, 12);

AmostraGps _em(double lat, Duration depois, {double precisao = 10}) =>
    AmostraGps(
      latitude: lat,
      longitude: -30.0,
      instante: _t0.add(depois),
      precisaoMetros: precisao,
    );

/// Graus de latitude correspondentes a uma distância em metros.
double _metros(double m) => m / 1852 / 60;

void main() {
  test('marcador acompanha posições válidas em sequência', () {
    final filtro = FiltroPosicaoExibicao();
    final a = _em(-10.0, Duration.zero);
    final b = _em(-10.0 + _metros(100), const Duration(seconds: 30));

    expect(filtro.aceitar(a, agora: a.instante), isTrue);
    expect(filtro.aceitar(b, agora: b.instante), isTrue);
    expect(filtro.ultimaAceita, b);
  });

  test('salto de GPS não move o marcador — fica na última posição boa', () {
    final filtro = FiltroPosicaoExibicao();
    final boa = _em(-10.0, Duration.zero);
    final salto = _em(-10.0 + _metros(8000), const Duration(seconds: 10));

    filtro.aceitar(boa, agora: boa.instante);
    expect(filtro.aceitar(salto, agora: salto.instante), isFalse);
    expect(filtro.ultimaAceita, boa);
  });

  test('posição imprecisa ou antiga não é mostrada como atual', () {
    final filtro = FiltroPosicaoExibicao();
    final imprecisa = _em(-10.0, Duration.zero, precisao: 900);
    final antiga = _em(-10.0, Duration.zero);

    expect(filtro.aceitar(imprecisa, agora: _t0), isFalse);
    expect(
      filtro.aceitar(antiga, agora: _t0.add(const Duration(hours: 2))),
      isFalse,
    );
    expect(filtro.ultimaAceita, isNull);
  });

  test('duas leituras novas que concordam entre si reancoram o marcador', () {
    // A "última boa" estava errada; as novas confirmam a posição real.
    final filtro = FiltroPosicaoExibicao();
    final errada = _em(-10.0, Duration.zero);
    final real1 = _em(-10.0 + _metros(6000), const Duration(seconds: 20));
    final real2 = _em(-10.0 + _metros(6040), const Duration(seconds: 40));

    filtro.aceitar(errada, agora: errada.instante);
    expect(filtro.aceitar(real1, agora: real1.instante), isFalse);
    expect(filtro.aceitar(real2, agora: real2.instante), isTrue);
    expect(filtro.ultimaAceita, real2);
  });

  test('reiniciar (app voltou do segundo plano) aceita a nova posição', () {
    // Pausa → a embarcação andou: comparada com a posição de antes da
    // pausa, a nova pareceria salto.
    final filtro = FiltroPosicaoExibicao();
    final antes = _em(-10.0, Duration.zero);
    final depois = _em(-10.0 + _metros(20000), const Duration(minutes: 5));

    filtro.aceitar(antes, agora: antes.instante);
    filtro.reiniciar();
    expect(filtro.aceitar(depois, agora: depois.instante), isTrue);
  });
}
