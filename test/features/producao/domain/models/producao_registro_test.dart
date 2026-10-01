import 'package:flutter_test/flutter_test.dart';
import 'package:atlas/features/producao/domain/classificacao_peso.dart';
import 'package:atlas/features/producao/domain/models/producao_registro.dart';

void main() {
  group('ProducaoRegistro.toMap / fromMap', () {
    test('round-trip preserva todos os campos de um registro novo', () {
      final original = ProducaoRegistro(
        id: 1,
        embarcacaoId: 'PE-1234',
        dataHora: DateTime(2026, 8, 17, 10, 30),
        especie: 'Kihada',
        quantidadeKg: 570.0,
        latitude: -2.9177781,
        longitude: -39.9324554,
        precisaoMetros: 20.9,
        cartaCodigo: null,
        observacao: 'primeira captura do dia',
        viagemId: 42,
        sincronizado: false,
        especieId: 'especie-uuid-123',
        classificacao: Classificacao.faixa40mais,
        quantidadeUnidades: 12,
        pesoMedioUnitario: 47.5,
      );

      final mapa = original.toMap();
      // O mapa vai pro `insert()` do sqflite — o id não faz parte dele
      // (é AUTOINCREMENT), mas fromMap precisa dele de volta pra reconstruir.
      mapa['id'] = original.id;

      final reconstruido = ProducaoRegistro.fromMap(mapa);

      expect(reconstruido.embarcacaoId, original.embarcacaoId);
      expect(reconstruido.especie, original.especie);
      expect(reconstruido.quantidadeKg, original.quantidadeKg);
      expect(reconstruido.latitude, original.latitude);
      expect(reconstruido.longitude, original.longitude);
      expect(reconstruido.precisaoMetros, original.precisaoMetros);
      expect(reconstruido.observacao, original.observacao);
      expect(reconstruido.viagemId, original.viagemId);
      expect(reconstruido.sincronizado, original.sincronizado);
      expect(reconstruido.especieId, 'especie-uuid-123');
      expect(reconstruido.classificacao, Classificacao.faixa40mais);
      expect(reconstruido.quantidadeUnidades, 12);
      expect(reconstruido.pesoMedioUnitario, 47.5);
    });

    test(
        'fromMap lê registros antigos (sem especie_id/classificacao) sem quebrar',
        () {
      final mapaAntigo = {
        'id': 1,
        'embarcacao_id': 'PE-1234',
        'data_hora': DateTime(2026, 1, 1).toIso8601String(),
        'especie': 'Tainha',
        'quantidade_kg': 12.5,
        'latitude': null,
        'longitude': null,
        'carta_codigo': null,
        'observacao': null,
        'viagem_id': null,
        'sincronizado': 0,
        // colunas novas (v11/v17) ausentes — como num registro salvo antes
        // dessas migrações.
      };

      final registro = ProducaoRegistro.fromMap(mapaAntigo);

      expect(registro.especie, 'Tainha');
      expect(registro.especieId, isNull);
      expect(registro.classificacao, isNull);
      expect(registro.quantidadeUnidades, isNull);
      expect(registro.pesoMedioUnitario, isNull);
      expect(registro.precisaoMetros, isNull);
    });

    test('sincronizado é lido a partir de 0/1 (inteiro do SQLite)', () {
      final mapaBase = {
        'id': 1,
        'embarcacao_id': 'PE-1234',
        'data_hora': DateTime(2026, 1, 1).toIso8601String(),
        'especie': 'Tainha',
        'quantidade_kg': 1.0,
      };

      expect(
          ProducaoRegistro.fromMap({...mapaBase, 'sincronizado': 0})
              .sincronizado,
          isFalse);
      expect(
          ProducaoRegistro.fromMap({...mapaBase, 'sincronizado': 1})
              .sincronizado,
          isTrue);
    });

    test('toMap grava especie_id direto e classificacao pelo .name do enum',
        () {
      final registro = ProducaoRegistro(
        id: 0,
        embarcacaoId: 'PE-1234',
        dataHora: DateTime(2026, 1, 1),
        especie: 'Bati',
        quantidadeKg: 100,
        especieId: 'especie-uuid-atum',
        classificacao: Classificacao.faixa10a15,
      );

      final mapa = registro.toMap();

      expect(mapa['especie_id'], 'especie-uuid-atum');
      expect(mapa['classificacao'], 'faixa10a15');
    });

    test('especieId nulo quando a espécie foi digitada livremente', () {
      final registro = ProducaoRegistro(
        id: 0,
        embarcacaoId: 'PE-1234',
        dataHora: DateTime(2026, 1, 1),
        especie: 'Carapitanga',
        quantidadeKg: 100,
        classificacao: Classificacao.faixa10a15,
      );

      final mapa = registro.toMap();

      expect(mapa['especie_id'], isNull);
      expect(mapa['especie'], 'Carapitanga');
    });
  });
}
