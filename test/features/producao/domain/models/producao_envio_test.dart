import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/producao/domain/classificacao_peso.dart';
import 'package:atlas/features/producao/domain/models/producao_envio.dart';

void main() {
  group('ProducaoEnvio', () {
    test('guarda todos os campos obrigatórios e opcionais', () {
      final envio = ProducaoEnvio(
        embarcacaoId: 'PE-1234',
        dispositivoId: 'device-uuid',
        instante: DateTime(2026, 8, 17, 10, 30),
        tipoPeixe: TipoPeixe.kihada,
        classificacao: Classificacao.faixa40mais,
        quantidadeUnidades: 12,
        pesoMedioUnitario: 47.5,
        quantidadeKg: 570.0,
        latitude: -3.5,
        longitude: -40.2,
        precisaoMetros: 8.0,
        viagemId: 7,
        observacao: 'Cardume próximo à boia',
      );

      expect(envio.embarcacaoId, 'PE-1234');
      expect(envio.tipoPeixe, TipoPeixe.kihada);
      expect(envio.classificacao, Classificacao.faixa40mais);
      expect(envio.quantidadeKg, 12 * 47.5);
      expect(envio.viagemId, 7);
    });

    test('campos opcionais podem ficar nulos (registro sem GPS/viagem)', () {
      final envio = ProducaoEnvio(
        embarcacaoId: 'PE-1234',
        dispositivoId: 'device-uuid',
        instante: DateTime(2026, 8, 17),
        tipoPeixe: TipoPeixe.bati,
        classificacao: Classificacao.faixa10a15,
        quantidadeUnidades: 3,
        pesoMedioUnitario: 12.5,
        quantidadeKg: 37.5,
      );

      expect(envio.latitude, isNull);
      expect(envio.longitude, isNull);
      expect(envio.precisaoMetros, isNull);
      expect(envio.viagemId, isNull);
      expect(envio.observacao, isNull);
    });
  });
}
