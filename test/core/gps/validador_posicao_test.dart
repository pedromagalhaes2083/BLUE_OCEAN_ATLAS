import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/core/gps/amostra_gps.dart';
import 'package:atlas/core/gps/validador_posicao.dart';

/// Ponto de partida fictício em mar aberto (não depende de coordenada real).
final _t0 = DateTime.utc(2026, 10, 20, 12);

AmostraGps _amostra({
  double lat = -10.0,
  double lon = -30.0,
  DateTime? instante,
  double? precisao = 10,
  bool simulada = false,
}) =>
    AmostraGps(
      latitude: lat,
      longitude: lon,
      instante: instante ?? _t0,
      precisaoMetros: precisao,
      simulada: simulada,
    );

/// Graus de latitude pra uma distância em metros (1' = 1 milha náutica).
double _grausParaMetros(double metros) => metros / 1852 / 60;

void main() {
  group('limites e valores', () {
    test('coordenada válida e recente é aceita', () {
      final r = ValidadorPosicao.validar(_amostra(), agora: _t0);
      expect(r.status, StatusValidacaoGps.valida);
      expect(r.motivos, isEmpty);
    });

    test('latitude e longitude fora da faixa são inválidas', () {
      expect(
        ValidadorPosicao.validar(_amostra(lat: 90.5), agora: _t0).motivos,
        [MotivoValidacaoGps.latitudeForaDaFaixa],
      );
      final r = ValidadorPosicao.validar(_amostra(lat: -91, lon: 181), agora: _t0);
      expect(r.status, StatusValidacaoGps.invalida);
      expect(r.motivos, [
        MotivoValidacaoGps.latitudeForaDaFaixa,
        MotivoValidacaoGps.longitudeForaDaFaixa,
      ]);
    });

    test('limites exatos (±90, ±180) ainda são válidos', () {
      for (final (lat, lon) in [(90.0, 180.0), (-90.0, -180.0)]) {
        expect(
          ValidadorPosicao.validar(_amostra(lat: lat, lon: lon), agora: _t0).valida,
          isTrue,
        );
      }
    });

    test('valores não finitos são inválidos', () {
      for (final (lat, lon) in [
        (double.nan, -30.0),
        (-10.0, double.infinity),
        (double.negativeInfinity, double.nan),
      ]) {
        final r = ValidadorPosicao.validar(_amostra(lat: lat, lon: lon), agora: _t0);
        expect(r.status, StatusValidacaoGps.invalida);
        expect(r.motivos, [MotivoValidacaoGps.coordenadaNaoFinita]);
      }
    });

    test('instante de relógio zerado (epoch) é inválido', () {
      final r = ValidadorPosicao.validar(
        _amostra(instante: DateTime.utc(1970)),
        agora: _t0,
      );
      expect(r.status, StatusValidacaoGps.invalida);
      expect(r.motivos, [MotivoValidacaoGps.instanteInvalido]);
    });

    test('(0, 0) é suspeita — típico de receptor sem fix', () {
      final r = ValidadorPosicao.validar(_amostra(lat: 0, lon: 0), agora: _t0);
      expect(r.status, StatusValidacaoGps.suspeita);
      expect(r.motivos, [MotivoValidacaoGps.ilhaNula]);
    });
  });

  group('qualidade da amostra', () {
    test('precisão insuficiente é suspeita; sem precisão informada, não', () {
      expect(
        ValidadorPosicao.validar(_amostra(precisao: 800), agora: _t0).motivos,
        [MotivoValidacaoGps.precisaoInsuficiente],
      );
      expect(ValidadorPosicao.validar(_amostra(precisao: null), agora: _t0).valida,
          isTrue);
    });

    test('limite de precisão é configurável', () {
      final r = ValidadorPosicao.validar(
        _amostra(precisao: 80),
        agora: _t0,
        config: const ConfigValidacaoGps(precisaoMaximaMetros: 50),
      );
      expect(r.motivos, [MotivoValidacaoGps.precisaoInsuficiente]);
    });

    test('posição antiga é suspeita', () {
      final r = ValidadorPosicao.validar(
        _amostra(instante: _t0.subtract(const Duration(minutes: 10))),
        agora: _t0,
      );
      expect(r.status, StatusValidacaoGps.suspeita);
      expect(r.motivos, [MotivoValidacaoGps.posicaoAntiga]);
    });

    test('posição no futuro além da tolerância do relógio é suspeita', () {
      expect(
        ValidadorPosicao.validar(
          _amostra(instante: _t0.add(const Duration(minutes: 1))),
          agora: _t0,
        ).valida,
        isTrue,
      );
      expect(
        ValidadorPosicao.validar(
          _amostra(instante: _t0.add(const Duration(minutes: 10))),
          agora: _t0,
        ).motivos,
        [MotivoValidacaoGps.instanteNoFuturo],
      );
    });

    test('localização simulada é suspeita', () {
      expect(
        ValidadorPosicao.validar(_amostra(simulada: true), agora: _t0).motivos,
        [MotivoValidacaoGps.origemSimulada],
      );
    });
  });

  group('salto de posição', () {
    final anterior = _amostra();

    test('deslocamento compatível com a velocidade é válido', () {
      // 1 milha em 10 min = 6 nós.
      final nova = _amostra(
        lat: -10.0 + _grausParaMetros(1852),
        instante: _t0.add(const Duration(minutes: 10)),
      );
      final r = ValidadorPosicao.validar(nova,
          agora: nova.instante, anteriorValida: anterior);
      expect(r.valida, isTrue);
    });

    test('salto impossível pro intervalo é suspeito', () {
      // 5 km em 30 s ≈ 324 nós.
      final nova = _amostra(
        lat: -10.0 + _grausParaMetros(5000),
        instante: _t0.add(const Duration(seconds: 30)),
      );
      final r = ValidadorPosicao.validar(nova,
          agora: nova.instante, anteriorValida: anterior);
      expect(r.status, StatusValidacaoGps.suspeita);
      expect(r.motivos, [MotivoValidacaoGps.saltoImplausivel]);
    });

    test('mesma distância depois de um intervalo longo sem sinal é válida', () {
      // 40 milhas depois de 4 h sem posição = 10 nós.
      final nova = _amostra(
        lat: -10.0 + _grausParaMetros(40 * 1852),
        instante: _t0.add(const Duration(hours: 4)),
      );
      final r = ValidadorPosicao.validar(nova,
          agora: nova.instante, anteriorValida: anterior);
      expect(r.valida, isTrue);
    });

    test('ruído dentro da precisão reportada não vira salto', () {
      // 150 m em 5 s, mas cada leitura com ±80 m de incerteza.
      final ant = _amostra(precisao: 80);
      final nova = _amostra(
        lat: -10.0 + _grausParaMetros(150),
        precisao: 80,
        instante: _t0.add(const Duration(seconds: 5)),
      );
      expect(
        ValidadorPosicao.validar(nova, agora: nova.instante, anteriorValida: ant)
            .valida,
        isTrue,
      );
    });

    test('velocidade máxima da embarcação é configurável', () {
      // 1 milha em 10 min = 6 nós: válido no padrão, salto pra um limite de 5.
      final nova = _amostra(
        lat: -10.0 + _grausParaMetros(1852),
        instante: _t0.add(const Duration(minutes: 10)),
      );
      final r = ValidadorPosicao.validar(nova,
          agora: nova.instante,
          anteriorValida: anterior,
          config: const ConfigValidacaoGps(velocidadeMaximaNos: 5));
      expect(r.motivos, [MotivoValidacaoGps.saltoImplausivel]);
    });

    test('nova posição que confirma a suspeita anterior reancora', () {
      // A "anterior válida" era o ponto ruim: as duas amostras novas
      // concordam entre si e destoam dela.
      final suspeita = _amostra(
        lat: -10.0 + _grausParaMetros(5000),
        instante: _t0.add(const Duration(seconds: 30)),
      );
      final nova = _amostra(
        lat: -10.0 + _grausParaMetros(5050),
        instante: _t0.add(const Duration(seconds: 60)),
      );
      final r = ValidadorPosicao.validar(nova,
          agora: nova.instante,
          anteriorValida: anterior,
          ultimaSuspeitaPorSalto: suspeita);
      expect(r.status, StatusValidacaoGps.valida);
      expect(r.motivos, [MotivoValidacaoGps.reancorada]);
    });

    test('suspeitaSoPorSalto só quando o salto é o único problema', () {
      const salto = ResultadoValidacaoGps(StatusValidacaoGps.suspeita,
          [MotivoValidacaoGps.saltoImplausivel]);
      const saltoEImpreciso = ResultadoValidacaoGps(StatusValidacaoGps.suspeita, [
        MotivoValidacaoGps.precisaoInsuficiente,
        MotivoValidacaoGps.saltoImplausivel,
      ]);
      expect(salto.suspeitaSoPorSalto, isTrue);
      expect(saltoEImpreciso.suspeitaSoPorSalto, isFalse);
    });
  });
}
