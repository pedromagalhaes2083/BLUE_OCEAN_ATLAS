import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/viagem/domain/models/viagem_atual_remota.dart';

void main() {
  group('ViagemAtualRemota.fromJson', () {
    test('le o formato principal (id, embarcacaoId, inicioPrevisto/fimPrevisto)', () {
      final viagem = ViagemAtualRemota.fromJson({
        'id': 'viagem-1',
        'embarcacaoId': 'embarcacao-1',
        'nome': 'Viagem de teste',
        'portoOrigemId': 'porto-1',
        'portoDestinoId': 'porto-2',
        'inicioPrevisto': '2026-09-01T10:00:00.000Z',
        'fimPrevisto': '2026-09-05T10:00:00.000Z',
      });

      expect(viagem.id, 'viagem-1');
      expect(viagem.embarcacaoId, 'embarcacao-1');
      expect(viagem.nome, 'Viagem de teste');
      expect(viagem.portoOrigemId, 'porto-1');
      expect(viagem.portoDestinoId, 'porto-2');
      expect(viagem.dataInicio, DateTime.parse('2026-09-01T10:00:00.000Z'));
      expect(viagem.dataTermino, DateTime.parse('2026-09-05T10:00:00.000Z'));
    });

    test('aceita nomes de campo alternativos (viagemId, dataInicio/dataTermino)', () {
      final viagem = ViagemAtualRemota.fromJson({
        'viagemId': 'viagem-2',
        'embarcacao_id': 'embarcacao-2',
        'dataInicio': '2026-09-01T10:00:00.000Z',
        'dataTermino': '2026-09-05T10:00:00.000Z',
      });

      expect(viagem.id, 'viagem-2');
      expect(viagem.embarcacaoId, 'embarcacao-2');
      expect(viagem.dataInicio, DateTime.parse('2026-09-01T10:00:00.000Z'));
    });

    test('campos opcionais ausentes viram null, sem quebrar', () {
      final viagem = ViagemAtualRemota.fromJson({
        'id': 'viagem-3',
        'embarcacaoId': 'embarcacao-3',
      });

      expect(viagem.nome, isNull);
      expect(viagem.portoOrigemId, isNull);
      expect(viagem.dataInicio, isNull);
      expect(viagem.dataTermino, isNull);
    });

    test('sem id nem embarcacaoId, lança FormatException', () {
      expect(
        () => ViagemAtualRemota.fromJson({'nome': 'Sem ids'}),
        throwsFormatException,
      );
    });

    test('data em formato inválido vira null em vez de lançar', () {
      final viagem = ViagemAtualRemota.fromJson({
        'id': 'viagem-4',
        'embarcacaoId': 'embarcacao-4',
        'inicioPrevisto': 'não é uma data',
      });
      expect(viagem.dataInicio, isNull);
    });

    test('desembrulha o formato real confirmado em 2026-09 ({"viagem": {...}})', () {
      // Payload observado com curl real (ver conversa) — GET
      // base/operacao/viagens/eu/atual, depois do 422 anterior corrigido.
      final viagem = ViagemAtualRemota.fromJson({
        'viagem': {
          'id': '70c7b636-4345-439d-b042-8f9ee985fc1d',
          'organizacaoId': '11111111-1111-1111-1111-111111111111',
          'embarcacaoId': '9b2aac19-ad31-4e6d-baf5-fb101a976c1b',
          'nome': null,
          'portoOrigemId': null,
          'portoDestinoId': null,
          'status': 2,
          'atuante': true,
          'inicioPrevisto': '2026-09-18T02:28:00.000Z',
          'inicioReal': '2026-09-04T04:26:33.541Z',
          'fimPrevisto': null,
          'tripulantes': [],
        },
      });

      expect(viagem.id, '70c7b636-4345-439d-b042-8f9ee985fc1d');
      expect(viagem.embarcacaoId, '9b2aac19-ad31-4e6d-baf5-fb101a976c1b');
      expect(viagem.dataInicio, DateTime.parse('2026-09-18T02:28:00.000Z'));
      expect(viagem.dataTermino, isNull);
    });
  });
}
