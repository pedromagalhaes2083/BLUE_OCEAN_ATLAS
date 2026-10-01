import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/termoclina/domain/models/leitura_termoclina.dart';
import 'package:atlas/features/termoclina/domain/models/perfil_temperatura_ponto.dart';

void main() {
  group('LeituraTermoclina', () {
    LeituraTermoclina construir({
      String fonte = 'mock',
      bool profundidadeTermoclinaMedida = false,
    }) =>
        LeituraTermoclina(
          latitude: -2.90,
          longitude: -39.65,
          instante: DateTime.parse('2026-09-26T14:32:00'),
          sst: 28.6,
          profundidadeTermoclina: 48,
          confianca: 0.82,
          perfil: const [
            PerfilTemperaturaPonto(
                profundidadeM: 0, temperaturaC: 28.6, medido: true),
            PerfilTemperaturaPonto(profundidadeM: 10, temperaturaC: 28.4),
            PerfilTemperaturaPonto(profundidadeM: 20, temperaturaC: 28.1),
          ],
          fonte: fonte,
          profundidadeTermoclinaMedida: profundidadeTermoclinaMedida,
        );

    test('perfilEstimado é true enquanto não há fonte com perfil real', () {
      expect(construir().perfilEstimado, isTrue);
      expect(construir(fonte: 'estimado_sst_open_meteo').perfilEstimado, isTrue);
      expect(construir(fonte: 'copernicus_marine').perfilEstimado, isFalse);
    });

    test(
        'temperaturaNaTermoclina interpola entre os dois pontos do perfil '
        'mais próximos da profundidade da termoclina', () {
      final leitura = LeituraTermoclina(
        latitude: -2.90,
        longitude: -39.65,
        instante: DateTime.now(),
        sst: 28.6,
        profundidadeTermoclina: 15, // meio do caminho entre 10m e 20m
        confianca: 0.82,
        perfil: const [
          PerfilTemperaturaPonto(profundidadeM: 0, temperaturaC: 28.6),
          PerfilTemperaturaPonto(profundidadeM: 10, temperaturaC: 28.4),
          PerfilTemperaturaPonto(profundidadeM: 20, temperaturaC: 28.0),
        ],
        fonte: 'mock',
      );
      // Interpolação linear entre 28.4 (10m) e 28.0 (20m) na metade: 28.2.
      expect(leitura.temperaturaNaTermoclina, closeTo(28.2, 0.001));
    });

    test(
        'temperaturaNaTermoclina usa o extremo mais próximo quando a '
        'profundidade da termoclina cai fora do alcance do perfil', () {
      // Mesmo dado de `construir()`: perfil só vai até 20m, termoclina a 48m.
      expect(construir().temperaturaNaTermoclina, 28.1);
    });

    test('temperaturaNaTermoclina é nulo com perfil vazio', () {
      final leitura = LeituraTermoclina(
        latitude: 0,
        longitude: 0,
        instante: DateTime.now(),
        sst: 0,
        profundidadeTermoclina: 0,
        confianca: 0,
        perfil: const [],
        fonte: 'mock',
      );
      expect(leitura.temperaturaNaTermoclina, isNull);
    });

    test('toJson/fromJson fazem round-trip fiel', () {
      final original = construir(profundidadeTermoclinaMedida: true);
      final json = original.toJson();
      final reconstruida = LeituraTermoclina.fromJson(json);

      expect(reconstruida.latitude, original.latitude);
      expect(reconstruida.longitude, original.longitude);
      expect(reconstruida.instante, original.instante);
      expect(reconstruida.sst, original.sst);
      expect(reconstruida.profundidadeTermoclina, original.profundidadeTermoclina);
      expect(reconstruida.confianca, original.confianca);
      expect(reconstruida.fonte, original.fonte);
      expect(reconstruida.profundidadeTermoclinaMedida,
          original.profundidadeTermoclinaMedida);
      expect(reconstruida.perfil.length, original.perfil.length);
      expect(reconstruida.perfil.first.profundidadeM, original.perfil.first.profundidadeM);
      expect(reconstruida.perfil.first.temperaturaC, original.perfil.first.temperaturaC);
      expect(reconstruida.perfil.first.medido, original.perfil.first.medido);
    });

    test('fromJson entende o formato de exemplo do contrato de API futuro', () {
      // Mesmo formato descrito em fonte_termoclina.dart / pedido original —
      // confirma que o model já está pronto pra uma resposta real.
      final leitura = LeituraTermoclina.fromJson({
        'latitude': -2.90,
        'longitude': -39.65,
        'timestamp': '2026-09-26T14:32:00',
        'sst': 28.6,
        'thermoclineDepth': 48,
        'confidence': 0.82,
        'temperatureProfile': [
          {'depth': 0, 'temperature': 28.6},
          {'depth': 10, 'temperature': 28.4},
          {'depth': 20, 'temperature': 28.1},
        ],
        'source': 'mock',
      });

      expect(leitura.sst, 28.6);
      expect(leitura.profundidadeTermoclina, 48);
      expect(leitura.confianca, 0.82);
      expect(leitura.perfil, hasLength(3));
      expect(leitura.perfil[1].profundidadeM, 10);
      expect(leitura.perfil[1].temperaturaC, 28.4);
    });
  });
}
