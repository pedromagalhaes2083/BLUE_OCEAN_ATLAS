import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:atlas/features/rotas/domain/models/rota_planejada.dart';

void main() {
  group('RotaPlanejada', () {
    test('fromMap reconstrói uma rota desenhada à mão (sem embarcação/viagem)',
        () {
      final mapa = {
        'id': 1,
        'nome': 'Pesqueiro do Camurupim',
        'data_criacao': DateTime(2026, 8, 17).toIso8601String(),
      };
      final pontos = [const LatLng(-3.0, -40.0), const LatLng(-3.1, -40.1)];

      final rota = RotaPlanejada.fromMap(mapa, pontos: pontos);

      expect(rota.nome, 'Pesqueiro do Camurupim');
      expect(rota.pontos, pontos);
      expect(rota.embarcacaoId, isNull);
      expect(rota.viagemId, isNull);
    });

    test('fromMap reconstrói uma rota gerada de registros de produção', () {
      final mapa = {
        'id': 2,
        'nome': 'Produção · PE-1234 · 17/08/2026',
        'data_criacao': DateTime(2026, 8, 17).toIso8601String(),
        'embarcacao_id': 'PE-1234',
        'viagem_id': 42,
      };

      final rota = RotaPlanejada.fromMap(mapa, pontos: const [
        LatLng(-3.0, -40.0),
        LatLng(-3.1, -40.1),
        LatLng(-3.2, -40.2),
      ]);

      expect(rota.embarcacaoId, 'PE-1234');
      expect(rota.viagemId, 42);
      expect(rota.pontos, hasLength(3));
    });

    test('toMap não inclui os pontos (gravados à parte)', () {
      final rota = RotaPlanejada(
        id: 1,
        nome: 'Teste',
        dataCriacao: DateTime(2026, 1, 1),
        pontos: const [LatLng(0, 0)],
      );

      expect(rota.toMap().containsKey('pontos'), isFalse);
    });

    test('toMap grava embarcacaoId/viagemId nulos quando é uma rota manual',
        () {
      final rota = RotaPlanejada(
        nome: 'Rota manual',
        dataCriacao: DateTime(2026, 1, 1),
        pontos: const [LatLng(0, 0), LatLng(1, 1)],
      );

      final mapa = rota.toMap();

      expect(mapa['embarcacao_id'], isNull);
      expect(mapa['viagem_id'], isNull);
    });
  });
}
