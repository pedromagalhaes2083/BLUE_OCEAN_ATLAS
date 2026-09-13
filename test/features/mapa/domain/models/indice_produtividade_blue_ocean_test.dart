import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/mapa/domain/models/indice_produtividade_blue_ocean.dart';
import 'package:atlas/features/mapa/domain/models/nivel_produtividade.dart';

void main() {
  group('IndiceProdutividadeBlueOcean.calcular', () {
    test('clorofila e temperatura excelentes → índice excelente', () {
      final indice = IndiceProdutividadeBlueOcean.calcular(
        latitude: -2.9,
        longitude: -39.9,
        clorofilaMgM3: 0.25, // acima do ótimo (0.22) → excelente
        clorofilaData: DateTime(2026, 9, 1),
        temperaturaC: 27.0, // exatamente a temperatura ideal → excelente
      );

      expect(indice.nivel, NivelProdutividade.excelente);
      expect(indice.explicacao, contains('Clorofila-a: Excelente'));
      expect(indice.explicacao, contains('Temperatura: Excelente'));
    });

    test('um fator ruim derruba o índice mesmo com o outro excelente', () {
      final indice = IndiceProdutividadeBlueOcean.calcular(
        latitude: -2.9,
        longitude: -39.9,
        clorofilaMgM3: 0.25, // excelente
        clorofilaData: DateTime(2026, 9, 1),
        temperaturaC: 20.0, // bem longe do ideal (27°) → ruim
      );

      expect(indice.nivel, NivelProdutividade.ruim);
      expect(indice.explicacao, contains('Clorofila-a: Excelente'));
      expect(indice.explicacao, contains('Temperatura: Ruim'));
    });

    test('só clorofila disponível (temperatura nula) usa só esse fator', () {
      final indice = IndiceProdutividadeBlueOcean.calcular(
        latitude: -2.9,
        longitude: -39.9,
        clorofilaMgM3: 0.05, // abaixo do mínimo (0.094) → ruim
        clorofilaData: DateTime(2026, 9, 1),
        temperaturaC: null,
      );

      expect(indice.nivel, NivelProdutividade.ruim);
      expect(indice.explicacao, contains('Clorofila-a: Ruim'));
      expect(indice.explicacao, isNot(contains('Temperatura')));
    });

    test('só temperatura disponível (clorofila nula) usa só esse fator', () {
      final indice = IndiceProdutividadeBlueOcean.calcular(
        latitude: -2.9,
        longitude: -39.9,
        clorofilaMgM3: null,
        clorofilaData: null,
        temperaturaC: 27.2, // bem perto do ideal → excelente
      );

      expect(indice.nivel, NivelProdutividade.excelente);
      expect(indice.explicacao, contains('Temperatura: Excelente'));
      expect(indice.explicacao, isNot(contains('Clorofila-a')));
    });

    test('nenhum dos dois disponível → sem dado, nível ruim por padrão', () {
      final indice = IndiceProdutividadeBlueOcean.calcular(
        latitude: -2.9,
        longitude: -39.9,
        clorofilaMgM3: null,
        clorofilaData: null,
        temperaturaC: null,
      );

      expect(indice.nivel, NivelProdutividade.ruim);
      expect(indice.explicacao, contains('Sem dado'));
    });
  });
}
