/// Como um fator individual (vento, corrente, SST...) se comportou no
/// cálculo do [IntelligenceResult.score] — a UI usa isso pra colorir/rotular
/// cada linha em vez de reinterpretar o número (ver `IntelligenceFactors`).
enum IntelligenceFactorStatus { favoravel, neutro, desfavoravel, indisponivel }

/// Um fator individual que compõe (ou não) o score geral — sempre criado
/// pelo [IntelligenceEngine], nunca montado à mão fora dele, pra pontuação
/// e status ficarem sempre coerentes com a mesma regra.
class IntelligenceFactor {
  final String nome;

  /// Peso ORIGINAL desse fator na composição (0–1), antes de qualquer
  /// redistribuição por dado ausente — só informativo pra UI/depuração; o
  /// peso realmente usado no cálculo já foi aplicado dentro de [pontuacao].
  final double pesoBase;

  /// Pontuação individual desse fator (0–100), ou nulo quando
  /// [disponivel] é falso.
  final double? pontuacao;

  final bool disponivel;
  final IntelligenceFactorStatus status;

  const IntelligenceFactor({
    required this.nome,
    required this.pesoBase,
    required this.pontuacao,
    required this.disponivel,
    required this.status,
  });
}
