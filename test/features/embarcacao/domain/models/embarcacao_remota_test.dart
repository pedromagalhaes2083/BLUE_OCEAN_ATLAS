import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/embarcacao/domain/models/embarcacao_remota.dart';

void main() {
  group('EmbarcacaoRemota.fromJson', () {
    test('lê a resposta real de base/operacao/embarcacoes/{id} (2026-09)', () {
      // Payload observado com curl real (ver conversa) —
      // GET base/operacao/embarcacoes/9b2aac19-ad31-4e6d-baf5-fb101a976c1b.
      final embarcacao = EmbarcacaoRemota.fromJson({
        'id': '9b2aac19-ad31-4e6d-baf5-fb101a976c1b',
        'organizacaoId': '11111111-1111-1111-1111-111111111111',
        'nome': 'Blue Ocean Navy',
        'imo': 'IMO1783568207928',
        'mmsi': '1783568207928',
        'bandeira': 'Brasil',
        'imagem': 'https://example.com/vessels/18.jpg',
        'tipo': 110,
        'status': 1,
        'atuante': true,
        'codigo': null,
        'dono': null,
        'quantidadeUrnas': 1,
        'registro': null,
        'sigla': 'NA',
        'tonelagem': 0,
        'capacidade': 0,
      });

      expect(embarcacao.id, '9b2aac19-ad31-4e6d-baf5-fb101a976c1b');
      expect(embarcacao.nome, 'Blue Ocean Navy');
      expect(embarcacao.sigla, 'NA');
      expect(embarcacao.status, 1);
      expect(embarcacao.quantidadeUrnas, 1);
      expect(embarcacao.dono, isNull);
      expect(embarcacao.registro, isNull);
    });

    test('campos opcionais ausentes viram null, sem quebrar', () {
      final embarcacao = EmbarcacaoRemota.fromJson({
        'id': 'embarcacao-1',
        'nome': 'Sem detalhes',
      });

      expect(embarcacao.codigo, isNull);
      expect(embarcacao.sigla, isNull);
      expect(embarcacao.status, isNull);
      expect(embarcacao.dono, isNull);
      expect(embarcacao.quantidadeUrnas, isNull);
      expect(embarcacao.registro, isNull);
    });

    test('sem nome, usa o placeholder em vez de quebrar', () {
      final embarcacao = EmbarcacaoRemota.fromJson({'id': 'embarcacao-2'});
      expect(embarcacao.nome, '(sem nome)');
    });
  });
}
