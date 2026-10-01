import '../../../termoclina/domain/models/leitura_termoclina.dart';
import 'intelligence_factor.dart';
import 'ocean_conditions.dart';

/// Resultado completo de uma avaliação de "Inteligência Oceânica" num
/// ponto — sempre montado pelo [IntelligenceEngine], nunca calculado direto
/// na UI. **Não é uma probabilidade de pesca** — é um índice de 0 a 100 que
/// resume as condições ambientais disponíveis; ver `IntelligenceScreen`.
class IntelligenceResult {
  final double latitude;
  final double longitude;
  final DateTime instante;

  /// Índice de 0 a 100 — "Inteligência Oceânica"/"Índice de Condição
  /// Oceânica". Nunca tratar como chance de captura.
  final double score;

  /// Confiança de 0 a 100 na qualidade/completude do [score] — diferente
  /// do score em si (ver doc de [IntelligenceEngine.avaliar]).
  final double confianca;

  final OceanConditions conditions;
  final List<IntelligenceFactor> factors;

  /// Estrutura térmica no ponto — `null` só quando nem a SST (via
  /// `TermoclinaRepository`) respondeu; ver `ThermoclineCard`, que trata
  /// "perfil vertical indisponível" como estado próprio, nunca inventado.
  final LeituraTermoclina? thermocline;

  /// Frase determinística explicando quais fatores formaram o [score] —
  /// ver [IntelligenceEngine._explicar]. Nunca gerada por LLM nesta versão.
  final String explicacao;

  const IntelligenceResult({
    required this.latitude,
    required this.longitude,
    required this.instante,
    required this.score,
    required this.confianca,
    required this.conditions,
    required this.factors,
    required this.thermocline,
    required this.explicacao,
  });

  /// Classificação do [score] — faixas literais do prompt original
  /// ("especialista em oceanografia pesqueira... índice de favorabilidade
  /// para presença de atum"): 0–30 baixa, 31–60 moderada, 61–80 favorável,
  /// 81–100 muito favorável. Só o discriminador — o texto exibido vem de
  /// `AppLocalizations` na tela (ver `IntelligenceScreen`), nunca fixo em
  /// português aqui.
  IntelligenceClassificacao get classificacao {
    if (score <= 30) return IntelligenceClassificacao.baixa;
    if (score <= 60) return IntelligenceClassificacao.moderada;
    if (score <= 80) return IntelligenceClassificacao.favoravel;
    return IntelligenceClassificacao.muitoFavoravel;
  }
}

/// Faixas de classificação do [IntelligenceResult.score] — ver doc do
/// getter `classificacao`.
enum IntelligenceClassificacao { baixa, moderada, favoravel, muitoFavoravel }
