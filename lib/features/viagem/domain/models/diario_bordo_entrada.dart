/// Tipo de uma entrada do diário de bordo — texto digitado ou áudio
/// gravado (ver [DiarioBordoEntrada]).
enum TipoDiarioBordo {
  texto,
  audio;

  String get valor => name;

  static TipoDiarioBordo fromValor(String valor) =>
      TipoDiarioBordo.values.firstWhere((t) => t.valor == valor);
}

/// Uma entrada do diário de bordo de uma viagem — nota de texto ou nota de
/// áudio, nunca as duas ao mesmo tempo (ver [tipo]). Fica só no aparelho,
/// nunca sincronizada com o backend (mesmo tratamento de
/// `embarcacao.foto`/`FotoEmbarcacaoService`).
class DiarioBordoEntrada {
  final int? id;
  final int viagemId;
  final TipoDiarioBordo tipo;

  /// Texto da nota — só quando [tipo] é [TipoDiarioBordo.texto].
  final String? conteudo;

  /// Caminho do arquivo .m4a gravado (ver `DiarioBordoAudioService`) — só
  /// quando [tipo] é [TipoDiarioBordo.audio].
  final String? caminhoAudio;

  /// Duração da gravação em segundos — guardada no banco pra mostrar na
  /// lista sem precisar abrir/decodificar o arquivo de áudio.
  final int? duracaoAudioS;

  /// Amplitude real capturada durante a gravação (ver
  /// `DiarioBordoScreen._iniciarGravacao`), já reamostrada pro número fixo
  /// de barras do desenho da forma de onda (ver `FormaDeOnda`) — valores
  /// normalizados de 0.0 a 1.0, nunca inventados. `null` em notas de áudio
  /// gravadas antes desse recurso existir (banco migrado sem o dado) ou
  /// quando a captura de amplitude falhou — nesses casos a UI mostra um
  /// desenho genérico em vez de uma forma de onda que não foi medida.
  final List<double>? amplitudes;

  final DateTime criadoEm;

  const DiarioBordoEntrada({
    this.id,
    required this.viagemId,
    required this.tipo,
    this.conteudo,
    this.caminhoAudio,
    this.duracaoAudioS,
    this.amplitudes,
    required this.criadoEm,
  });

  factory DiarioBordoEntrada.fromMap(Map<String, dynamic> map) {
    final amplitudesTexto = map['amplitudes'] as String?;
    return DiarioBordoEntrada(
      id: map['id'] as int?,
      viagemId: map['viagem_id'] as int,
      tipo: TipoDiarioBordo.fromValor(map['tipo'] as String),
      conteudo: map['conteudo'] as String?,
      caminhoAudio: map['caminho_audio'] as String?,
      duracaoAudioS: map['duracao_audio_s'] as int?,
      amplitudes: (amplitudesTexto == null || amplitudesTexto.isEmpty)
          ? null
          : amplitudesTexto.split(',').map(double.parse).toList(),
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'viagem_id': viagemId,
      'tipo': tipo.valor,
      'conteudo': conteudo,
      'caminho_audio': caminhoAudio,
      'duracao_audio_s': duracaoAudioS,
      'amplitudes':
          amplitudes?.map((a) => a.toStringAsFixed(3)).join(','),
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  DiarioBordoEntrada copyWith({String? conteudo}) {
    return DiarioBordoEntrada(
      id: id,
      viagemId: viagemId,
      tipo: tipo,
      conteudo: conteudo ?? this.conteudo,
      caminhoAudio: caminhoAudio,
      duracaoAudioS: duracaoAudioS,
      amplitudes: amplitudes,
      criadoEm: criadoEm,
    );
  }
}
