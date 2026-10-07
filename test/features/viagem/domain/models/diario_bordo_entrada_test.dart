import 'package:flutter_test/flutter_test.dart';

import 'package:atlas/features/viagem/domain/models/diario_bordo_entrada.dart';

void main() {
  group('DiarioBordoEntrada', () {
    test('toMap/fromMap fazem round-trip fiel pra uma nota de texto', () {
      final original = DiarioBordoEntrada(
        id: 1,
        viagemId: 42,
        tipo: TipoDiarioBordo.texto,
        conteudo: 'Vento mudou pra sudeste, mar ficou mais agitado.',
        criadoEm: DateTime.parse('2026-10-05T14:32:00'),
      );

      final map = original.toMap();
      // fromMap espera o id vindo do próprio banco (query), não do toMap
      // (que nunca inclui id — é AUTOINCREMENT).
      map['id'] = original.id;
      final reconstruida = DiarioBordoEntrada.fromMap(map);

      expect(reconstruida.viagemId, original.viagemId);
      expect(reconstruida.tipo, TipoDiarioBordo.texto);
      expect(reconstruida.conteudo, original.conteudo);
      expect(reconstruida.caminhoAudio, isNull);
      expect(reconstruida.duracaoAudioS, isNull);
      expect(reconstruida.criadoEm, original.criadoEm);
    });

    test('toMap/fromMap fazem round-trip fiel pra uma nota de áudio', () {
      final original = DiarioBordoEntrada(
        id: 2,
        viagemId: 42,
        tipo: TipoDiarioBordo.audio,
        caminhoAudio: '/dados/diario_bordo_audio/viagem_42/123.m4a',
        duracaoAudioS: 37,
        criadoEm: DateTime.parse('2026-10-05T15:00:00'),
      );

      final map = original.toMap();
      map['id'] = original.id;
      final reconstruida = DiarioBordoEntrada.fromMap(map);

      expect(reconstruida.tipo, TipoDiarioBordo.audio);
      expect(reconstruida.conteudo, isNull);
      expect(reconstruida.caminhoAudio, original.caminhoAudio);
      expect(reconstruida.duracaoAudioS, 37);
      expect(reconstruida.amplitudes, isNull);
    });

    test('toMap/fromMap preserva as amplitudes da forma de onda real', () {
      final original = DiarioBordoEntrada(
        id: 3,
        viagemId: 42,
        tipo: TipoDiarioBordo.audio,
        caminhoAudio: '/dados/diario_bordo_audio/viagem_42/456.m4a',
        duracaoAudioS: 12,
        amplitudes: const [0.1, 0.573, 0.982, 0.0, 1.0],
        criadoEm: DateTime.parse('2026-10-05T16:00:00'),
      );

      final map = original.toMap();
      map['id'] = original.id;
      final reconstruida = DiarioBordoEntrada.fromMap(map);

      expect(reconstruida.amplitudes, isNotNull);
      expect(reconstruida.amplitudes!.length, 5);
      for (var i = 0; i < 5; i++) {
        expect(reconstruida.amplitudes![i], closeTo(original.amplitudes![i], 0.001));
      }
    });

    test('fromMap trata amplitudes nula/vazia como lista ausente, não vazia',
        () {
      final semAmplitude = DiarioBordoEntrada.fromMap({
        'id': 4,
        'viagem_id': 42,
        'tipo': 'audio',
        'caminho_audio': '/x.m4a',
        'duracao_audio_s': 5,
        'amplitudes': null,
        'criado_em': '2026-10-05T16:00:00',
      });
      final amplitudeVazia = DiarioBordoEntrada.fromMap({
        'id': 5,
        'viagem_id': 42,
        'tipo': 'audio',
        'caminho_audio': '/x.m4a',
        'duracao_audio_s': 5,
        'amplitudes': '',
        'criado_em': '2026-10-05T16:00:00',
      });

      expect(semAmplitude.amplitudes, isNull);
      expect(amplitudeVazia.amplitudes, isNull);
    });

    test('copyWith troca só o conteúdo, mantendo o resto igual', () {
      final original = DiarioBordoEntrada(
        id: 1,
        viagemId: 42,
        tipo: TipoDiarioBordo.texto,
        conteudo: 'texto original',
        criadoEm: DateTime(2026, 10, 5),
      );

      final editada = original.copyWith(conteudo: 'texto corrigido');

      expect(editada.conteudo, 'texto corrigido');
      expect(editada.id, original.id);
      expect(editada.viagemId, original.viagemId);
      expect(editada.criadoEm, original.criadoEm);
    });

    test('TipoDiarioBordo.fromValor reconhece os dois valores salvos no banco',
        () {
      expect(TipoDiarioBordo.fromValor('texto'), TipoDiarioBordo.texto);
      expect(TipoDiarioBordo.fromValor('audio'), TipoDiarioBordo.audio);
    });
  });
}
