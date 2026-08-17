import 'package:flutter_test/flutter_test.dart';
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
}
