import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/termoclina/data/fonte_termoclina_mock.dart';
import 'package:atlas/features/termoclina/data/termoclina_repository.dart';

void main() {
  group('FonteTermoclinaMock', () {
    test('marca a leitura como fonte "mock"', () async {
      final leitura = await FonteTermoclinaMock()
          .buscar(latitude: -2.90, longitude: -39.65);
      expect(leitura.fonte, 'mock');
      expect(leitura.perfilEstimado, isTrue);
    });

    test('devolve um perfil com pelo menos 2 pontos, ordenado por profundidade',
        () async {
      final leitura = await FonteTermoclinaMock()
          .buscar(latitude: -2.90, longitude: -39.65);
      expect(leitura.perfil.length, greaterThanOrEqualTo(2));
      for (var i = 1; i < leitura.perfil.length; i++) {
        expect(leitura.perfil[i].profundidadeM,
            greaterThan(leitura.perfil[i - 1].profundidadeM));
      }
    });

    test('mesma coordenada sempre devolve o mesmo resultado (determinístico)',
        () async {
      final a = await FonteTermoclinaMock().buscar(latitude: -2.90, longitude: -39.65);
      final b = await FonteTermoclinaMock().buscar(latitude: -2.90, longitude: -39.65);
      expect(a.sst, b.sst);
      expect(a.profundidadeTermoclina, b.profundidadeTermoclina);
      expect(a.confianca, b.confianca);
    });

    test('confiança sempre fica entre 0 e 1', () async {
      final leitura = await FonteTermoclinaMock()
          .buscar(latitude: 10.5, longitude: -45.2);
      expect(leitura.confianca, greaterThanOrEqualTo(0));
      expect(leitura.confianca, lessThanOrEqualTo(1));
    });
  });

  group('TermoclinaRepository', () {
    test('usa a fonte injetada quando fornecida (ex.: mock, sem rede)',
        () async {
      final leitura = await TermoclinaRepository(fonte: FonteTermoclinaMock())
          .buscar(latitude: -2.90, longitude: -39.65);
      expect(leitura.fonte, 'mock');
    });
  });
}
