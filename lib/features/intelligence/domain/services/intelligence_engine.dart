import '../../../../core/config/calibracao_intelligence.dart';
import '../../../termoclina/domain/models/leitura_termoclina.dart';
import '../models/intelligence_factor.dart';
import '../models/intelligence_result.dart';
import '../models/ocean_conditions.dart';

/// Núcleo determinístico que transforma [OceanConditions] num
/// [IntelligenceResult] — nenhum Machine Learning nem LLM aqui, só
/// normalização e média ponderada, sempre reproduzível pro mesmo dado de
/// entrada.
///
/// **Índice de favorabilidade para presença de atum**, a partir de um
/// prompt de especialista em oceanografia pesqueira e habitat de atuns no
/// Atlântico Tropical (2026-09): 5 fatores — temperatura, salinidade,
/// clorofila, corrente, batimetria — cada um classificado em
/// Excelente/Moderada/Baixa dentro de faixas oceanográficas específicas
/// (ver [CalibracaoIntelligence]), não um formato genérico de "condição de
/// mar calmo". Vento e ondas (do formato anterior desta tela) não entram
/// mais no score — não fazem parte da correlação com habitat de atum do
/// prompt original — mas continuam aparecendo na tela como condição
/// informativa (navegação/conforto), só não pontuam.
///
/// Profundidade (via batimetria) e maré continuam informativas à parte
/// disso: maré não tem nenhuma correlação com habitat de atum no prompt
/// original, então não entra no score; profundidade agora SIM entra (como
/// aproximação de "proximidade da quebra da plataforma continental" — ver
/// [CalibracaoIntelligence]).
///
/// A importância relativa (peso) e a faixa ideal + margem de cada um dos 5
/// fatores vêm de [CalibracaoIntelligence] (padrão
/// [CalibracaoIntelligence.padrao] quando não informada) — configuráveis
/// na tela "Calibrar Inteligência", sem precisar mexer neste arquivo.
class IntelligenceEngine {
  static IntelligenceResult avaliar({
    required double latitude,
    required double longitude,
    required DateTime instante,
    required OceanConditions conditions,
    LeituraTermoclina? thermocline,
    CalibracaoIntelligence calibracao = CalibracaoIntelligence.padrao,
  }) {
    final fatores = <IntelligenceFactor>[
      _fatorBanda(
        nome: 'Temperatura',
        valor: conditions.sst,
        peso: calibracao.pesoTemperatura,
        idealMin: calibracao.temperaturaIdealMinC,
        idealMax: calibracao.temperaturaIdealMaxC,
        margem: calibracao.temperaturaMargemC,
      ),
      _fatorBanda(
        nome: 'Salinidade',
        valor: conditions.salinidadeUps,
        peso: calibracao.pesoSalinidade,
        idealMin: calibracao.salinidadeIdealMinUps,
        idealMax: calibracao.salinidadeIdealMaxUps,
        margem: calibracao.salinidadeMargemUps,
      ),
      _fatorBanda(
        nome: 'Clorofila',
        valor: conditions.clorofilaMgM3,
        peso: calibracao.pesoClorofila,
        idealMin: calibracao.clorofilaIdealMinMgM3,
        idealMax: calibracao.clorofilaIdealMaxMgM3,
        margem: calibracao.clorofilaMargemMgM3,
      ),
      _fatorBanda(
        nome: 'Corrente',
        valor: conditions.correnteNos,
        peso: calibracao.pesoCorrente,
        idealMin: calibracao.correnteIdealMinNos,
        idealMax: calibracao.correnteIdealMaxNos,
        margem: calibracao.correnteMargemNos,
      ),
      _fatorBanda(
        nome: 'Batimetria',
        valor: conditions.profundidadeM,
        peso: calibracao.pesoBatimetria,
        idealMin: calibracao.batimetriaIdealMinM,
        idealMax: calibracao.batimetriaIdealMaxM,
        margem: calibracao.batimetriaMargemM,
      ),
    ];

    final disponiveis = fatores.where((f) => f.disponivel).toList();
    final pesoTotalDisponivel =
        disponiveis.fold<double>(0, (soma, f) => soma + f.pesoBase);
    final pesoTotalConfigurado =
        fatores.fold<double>(0, (soma, f) => soma + f.pesoBase);

    final double score;
    if (disponiveis.isEmpty || pesoTotalDisponivel <= 0) {
      score = 0;
    } else {
      final somaPonderada = disponiveis.fold<double>(
        0,
        (soma, f) => soma + (f.pontuacao! * f.pesoBase),
      );
      // Renormaliza pelos pesos só dos fatores disponíveis — funciona igual
      // independente de [calibracao] somar 100 ou não (os padrões do prompt
      // original, 35/35/20/10/10, somam 110), já que é sempre uma razão
      // entre pesos.
      score = (somaPonderada / pesoTotalDisponivel).clamp(0, 100).toDouble();
    }

    // Confiança = fração do peso TOTAL configurado que teve dado
    // disponível — determinística, sem número aleatório. Dados completos →
    // confiança alta; incompletos → confiança menor, proporcional ao que
    // falta (nunca calculada a partir do score).
    final confianca = pesoTotalConfigurado <= 0
        ? 0.0
        : (pesoTotalDisponivel / pesoTotalConfigurado * 100)
            .clamp(0, 100)
            .toDouble();

    return IntelligenceResult(
      latitude: latitude,
      longitude: longitude,
      instante: instante,
      score: score,
      confianca: confianca,
      conditions: conditions,
      factors: fatores,
      thermocline: thermocline,
      explicacao: _explicar(fatores, thermocline),
    );
  }

  // ── Fator "banda" (Excelente/Moderada/Baixa) ────────────────────────────
  //
  // Mesmo formato pros 5 fatores — dentro de [idealMin, idealMax] nota
  // máxima (100, "Excelente" no prompt original); até [margem] além de
  // cada ponta, nota parcial (60, "Moderada"); mais longe que isso, nota
  // baixa (25, "Baixa probabilidade"). [margem] é simétrica pros dois
  // lados por simplicidade da tela de calibração (ver doc de
  // [CalibracaoIntelligence] pra onde isso já é uma aproximação do prompt
  // original, que tinha margens assimétricas).

  static const _pontuacaoExcelente = 100.0;
  static const _pontuacaoModerada = 60.0;
  static const _pontuacaoBaixa = 25.0;

  static IntelligenceFactor _fatorBanda({
    required String nome,
    required double? valor,
    required double peso,
    required double idealMin,
    required double idealMax,
    required double margem,
  }) {
    if (valor == null) {
      return IntelligenceFactor(
        nome: nome,
        pesoBase: peso,
        pontuacao: null,
        disponivel: false,
        status: IntelligenceFactorStatus.indisponivel,
      );
    }
    final double pontuacao;
    if (valor >= idealMin && valor <= idealMax) {
      pontuacao = _pontuacaoExcelente;
    } else if (valor >= idealMin - margem && valor <= idealMax + margem) {
      pontuacao = _pontuacaoModerada;
    } else {
      pontuacao = _pontuacaoBaixa;
    }
    return IntelligenceFactor(
      nome: nome,
      pesoBase: peso,
      pontuacao: pontuacao,
      disponivel: true,
      status: _statusPorPontuacao(pontuacao),
    );
  }

  static IntelligenceFactorStatus _statusPorPontuacao(double pontuacao) {
    if (pontuacao >= 70) return IntelligenceFactorStatus.favoravel;
    if (pontuacao >= 40) return IntelligenceFactorStatus.neutro;
    return IntelligenceFactorStatus.desfavoravel;
  }

  static String _explicar(
      List<IntelligenceFactor> fatores, LeituraTermoclina? thermocline) {
    final disponiveis = fatores.where((f) => f.disponivel).map((f) => f.nome);
    final indisponiveis =
        fatores.where((f) => !f.disponivel).map((f) => f.nome);

    if (disponiveis.isEmpty) {
      return 'Nenhuma condição ambiental disponível agora pra formar um índice.';
    }

    final base =
        'A avaliação atual considera: ${disponiveis.join(', ')}.';
    if (indisponiveis.isEmpty) {
      return base;
    }
    return '$base ${indisponiveis.join(', ')} indisponível(is) no momento — '
        'peso redistribuído entre as demais.';
  }
}
