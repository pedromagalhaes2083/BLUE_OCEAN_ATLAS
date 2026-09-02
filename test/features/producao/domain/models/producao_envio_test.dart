import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/producao/domain/models/producao_envio.dart';

void main() {
  group('ProducaoEnvio', () {
    test('guarda todos os campos (corpo de POST base/resultado/capturas)',
        () {
      final envio = ProducaoEnvio(
        viagemId: '550e8400-e29b-41d4-a716-446655440000',
        especieId: '550e8400-e29b-41d4-a716-446655440001',
        pesoKg: 570.0,
        quantidade: 12,
        instante: DateTime(2026, 8, 17, 10, 30),
      );

      expect(envio.viagemId, '550e8400-e29b-41d4-a716-446655440000');
      expect(envio.especieId, '550e8400-e29b-41d4-a716-446655440001');
      expect(envio.pesoKg, 570.0);
      expect(envio.quantidade, 12);
      expect(envio.instante, DateTime(2026, 8, 17, 10, 30));
    });
  });
}
