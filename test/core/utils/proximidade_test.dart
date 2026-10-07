import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:atlas/core/utils/proximidade.dart';

void main() {
  group('calcularDistanciaNauticas', () {
    test('distância de um ponto a ele mesmo é zero', () {
      expect(calcularDistanciaNauticas(-3.0, -40.0, -3.0, -40.0), 0);
    });

    test('1 grau de latitude ≈ 60 milhas náuticas', () {
      final distancia = calcularDistanciaNauticas(0, 0, 1, 0);
      expect(distancia, closeTo(60, 1));
    });

    test('é simétrica (A→B == B→A)', () {
      final aB = calcularDistanciaNauticas(-3.0, -40.0, -2.5, -39.5);
      final bA = calcularDistanciaNauticas(-2.5, -39.5, -3.0, -40.0);
      expect(aB, closeTo(bA, 0.0001));
    });
  });

  group('ordenarPorProximidade', () {
    test('ordena do mais perto pro mais longe da origem', () {
      final pontos = [
        {'nome': 'longe', 'latitude': -5.0, 'longitude': -40.0},
        {'nome': 'perto', 'latitude': -3.01, 'longitude': -40.0},
        {'nome': 'médio', 'latitude': -3.5, 'longitude': -40.0},
      ];

      final ordenado =
          ordenarPorProximidade(pontos, originLat: -3.0, originLon: -40.0);

      expect(ordenado.map((p) => p['nome']),
          ['perto', 'médio', 'longe']);
    });

    test('não modifica a lista original (retorna uma cópia)', () {
      final pontos = [
        {'nome': 'B', 'latitude': -5.0, 'longitude': -40.0},
        {'nome': 'A', 'latitude': -3.0, 'longitude': -40.0},
      ];
      final original = List.of(pontos);

      ordenarPorProximidade(pontos, originLat: -3.0, originLon: -40.0);

      expect(pontos.map((p) => p['nome']), original.map((p) => p['nome']));
    });

    test('lista vazia retorna lista vazia', () {
      expect(
          ordenarPorProximidade([], originLat: 0, originLon: 0), isEmpty);
    });
  });

  group('projetarNaRota', () {
    // Rota reta sobre o equador (lat 0), rumo leste — cada grau de
    // longitude vale ~60 mn aqui (cos(0°) = 1), o que deixa as contas
    // previsíveis sem precisar de uma rota real.
    final rota = [
      const LatLng(0, 0),
      const LatLng(0, 1),
      const LatLng(0, 2),
    ];

    test('rota com menos de 2 pontos retorna null', () {
      expect(projetarNaRota(const LatLng(0, 0), [const LatLng(0, 0)]), isNull);
      expect(projetarNaRota(const LatLng(0, 0), []), isNull);
    });

    test('posição em cima do meio da rota: desvio ~0, metade percorrida', () {
      final projecao = projetarNaRota(const LatLng(0, 1), rota)!;
      expect(projecao.desvioNauticas, closeTo(0, 0.01));
      expect(projecao.distanciaPercorridaNauticas, closeTo(60, 0.5));
      expect(projecao.distanciaTotalNauticas, closeTo(120, 0.5));
      expect(projecao.progresso, closeTo(0.5, 0.01));
    });

    test('posição deslocada lateralmente mede o desvio perpendicular', () {
      // 0.1° de latitude ao norte do segmento ≈ 6 mn de desvio.
      final projecao = projetarNaRota(const LatLng(0.1, 0.5), rota)!;
      expect(projecao.desvioNauticas, closeTo(6.0, 0.3));
      expect(projecao.indiceSegmento, 0);
    });

    test('posição antes do início da rota grudada no primeiro ponto (sem percorrer)', () {
      final projecao = projetarNaRota(const LatLng(0, -1), rota)!;
      expect(projecao.indiceSegmento, 0);
      expect(projecao.distanciaPercorridaNauticas, closeTo(0, 0.01));
      expect(projecao.proximoWaypoint, rota[1]);
    });

    test('posição depois do fim da rota gruda no último ponto (100% percorrido)', () {
      final projecao = projetarNaRota(const LatLng(0, 3), rota)!;
      expect(projecao.indiceSegmento, rota.length - 2);
      expect(projecao.progresso, closeTo(1.0, 0.01));
      expect(projecao.proximoWaypoint, rota.last);
    });

    test('rota de comprimento zero (ponto repetido) não divide por zero', () {
      final rotaParada = [const LatLng(0, 0), const LatLng(0, 0)];
      final projecao = projetarNaRota(const LatLng(1, 1), rotaParada)!;
      expect(projecao.distanciaTotalNauticas, closeTo(0, 0.0001));
      expect(projecao.progresso, isNull);
    });
  });
}
