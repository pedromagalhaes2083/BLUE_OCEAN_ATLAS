import '../../../../core/config/calibracao_intelligence.dart';
import '../../../termoclina/domain/models/leitura_termoclina.dart';
import '../models/intelligence_factor.dart';
import '../models/intelligence_result.dart';
import '../models/ocean_conditions.dart';

/// Núcleo determinístico que transforma [OceanConditions] num
/// [IntelligenceResult] — nenhum Machine Learning nem LLM aqui (ver
/// `docs`/pedido original "Blue Ocean Intelligence"), só normalização e
/// média ponderada, sempre reproduzível pro mesmo dado de entrada.
///
/// **De propósito, só 5 fatores entram no [IntelligenceResult.score]** —
/// vento, corrente e ondas têm o mesmo formato de curva das faixas já
/// visíveis em `AlertaRotaScreen` (calmo→extremo), e SST/clorofila seguem o
/// mesmo espírito de `IndiceProdutividadeBlueOcean`/`nivelClorofila` — mas
/// cada curva agora é ancorada na "quantidade ideal" de [calibracao], não
/// mais fixa. Profundidade, maré e a estrutura térmica (termoclina)
/// aparecem na tela como condição informativa, mas **não** entram no
/// cálculo do score: o app não tem hoje nenhuma referência de "profundidade
/// boa" ou "termoclina forte é favorável" que não seria inventada na
/// hora — entrar com um peso arbitrário pra essas violaria a regra de nunca
/// fabricar precisão que não existe.
///
/// A importância relativa (peso) e a quantidade ideal de cada um dos 5
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
      _fatorSst(conditions.sst, calibracao.pesoSst, calibracao.sstIdealC),
      _fatorCorrente(conditions.correnteNos, calibracao.pesoCorrente,
          calibracao.correnteIdealNos),
      _fatorClorofila(conditions.clorofilaMgM3, calibracao.pesoClorofila,
          calibracao.clorofilaIdealMgM3),
      _fatorOndas(
          conditions.ondaAlturaM, calibracao.pesoOndas, calibracao.ondaIdealM),
      _fatorVento(
          conditions.ventoKmh, calibracao.pesoVento, calibracao.ventoIdealKmh),
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
      // Renormaliza pelos pesos só dos fatores disponíveis — o exemplo do
      // pedido original: "peso disponível = 85%, normalizar os demais pesos
      // pra 100%". Funciona igual independente de [calibracao] somar 100 ou
      // não, já que é sempre uma razão entre pesos.
      score = (somaPonderada / pesoTotalDisponivel).clamp(0, 100).toDouble();
    }

    // Confiança = fração do peso TOTAL configurado (não só dos 5 fatores
    // fixos de antes) que teve dado disponível — determinística, sem número
    // aleatório. Dados completos → confiança alta; incompletos → confiança
    // menor, proporcional ao que falta (nunca calculada a partir do score).
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

  // ── Fatores individuais ────────────────────────────────────────────────
  //
  // Cada curva abaixo tem UM único ponto calibrável (a "quantidade ideal",
  // ver [CalibracaoIntelligence]) — os demais patamares (bom/moderado/
  // desfavorável...) escalam proporcionalmente a partir dele, na mesma
  // razão que já existia quando os patamares eram fixos. Calibrar move a
  // curva inteira, não muda o formato dela.

  /// SST: quanto mais perto da temperatura ideal, melhor — temperatura
  /// muito acima OU muito abaixo é igualmente desfavorável (mesmo espírito
  /// de `IndiceProdutividadeBlueOcean.nivelTemperatura`, mas com o alvo
  /// calibrável em vez de fixo em 27°C).
  static IntelligenceFactor _fatorSst(double? sst, double peso, double idealC) {
    if (sst == null) {
      return IntelligenceFactor(
        nome: 'SST',
        pesoBase: peso,
        pontuacao: null,
        disponivel: false,
        status: IntelligenceFactorStatus.indisponivel,
      );
    }
    final distancia = (sst - idealC).abs();
    final double pontuacao;
    if (distancia <= 0.5) {
      pontuacao = 100;
    } else if (distancia <= 1.5) {
      pontuacao = 80;
    } else if (distancia <= 3.0) {
      pontuacao = 55;
    } else {
      pontuacao = 25;
    }
    return IntelligenceFactor(
      nome: 'SST',
      pesoBase: peso,
      pontuacao: pontuacao,
      disponivel: true,
      status: _statusPorPontuacao(pontuacao),
    );
  }

  /// Clorofila: quanto mais próxima ou acima da quantidade ideal, melhor —
  /// diferente de SST/vento/corrente/ondas, não existe "clorofila demais é
  /// ruim" (mesmo espírito de `nivelClorofila`, mas com o alvo calibrável
  /// em vez de fixo). Os patamares intermediários escalam como frações do
  /// ideal (40%/75%), mesma proporção que os limiares fixos originais
  /// guardavam entre si.
  static IntelligenceFactor _fatorClorofila(
      double? clorofilaMgM3, double peso, double idealMgM3) {
    if (clorofilaMgM3 == null) {
      return IntelligenceFactor(
        nome: 'Clorofila',
        pesoBase: peso,
        pontuacao: null,
        disponivel: false,
        status: IntelligenceFactorStatus.indisponivel,
      );
    }
    final double pontuacao;
    if (idealMgM3 <= 0) {
      pontuacao = 25;
    } else if (clorofilaMgM3 >= idealMgM3) {
      pontuacao = 100;
    } else if (clorofilaMgM3 >= idealMgM3 * 0.75) {
      pontuacao = 80;
    } else if (clorofilaMgM3 >= idealMgM3 * 0.4) {
      pontuacao = 55;
    } else {
      pontuacao = 25;
    }
    return IntelligenceFactor(
      nome: 'Clorofila',
      pesoBase: peso,
      pontuacao: pontuacao,
      disponivel: true,
      status: _statusPorPontuacao(pontuacao),
    );
  }

  // Vento/corrente/ondas: mar mais calmo = condição mais favorável — mesma
  // leitura de risco de navegação já usada em `AlertaRotaScreen`, com os
  // patamares (2x/3x/4x... o ideal) na mesma razão que as faixas fixas
  // originais guardavam entre si.

  static IntelligenceFactor _fatorVento(
      double? ventoKmh, double peso, double idealKmh) {
    if (ventoKmh == null) {
      return IntelligenceFactor(
        nome: 'Vento',
        pesoBase: peso,
        pontuacao: null,
        disponivel: false,
        status: IntelligenceFactorStatus.indisponivel,
      );
    }
    final double pontuacao;
    if (ventoKmh < idealKmh) {
      pontuacao = 100;
    } else if (ventoKmh < idealKmh * 2) {
      pontuacao = 80;
    } else if (ventoKmh < idealKmh * 3) {
      pontuacao = 55;
    } else if (ventoKmh < idealKmh * 4.5) {
      pontuacao = 30;
    } else {
      pontuacao = 10;
    }
    return IntelligenceFactor(
      nome: 'Vento',
      pesoBase: peso,
      pontuacao: pontuacao,
      disponivel: true,
      status: _statusPorPontuacao(pontuacao),
    );
  }

  static IntelligenceFactor _fatorCorrente(
      double? correnteNos, double peso, double idealNos) {
    if (correnteNos == null) {
      return IntelligenceFactor(
        nome: 'Corrente',
        pesoBase: peso,
        pontuacao: null,
        disponivel: false,
        status: IntelligenceFactorStatus.indisponivel,
      );
    }
    final double pontuacao;
    if (correnteNos < idealNos) {
      pontuacao = 100;
    } else if (correnteNos < idealNos * 2) {
      pontuacao = 80;
    } else if (correnteNos < idealNos * 3) {
      pontuacao = 55;
    } else if (correnteNos < idealNos * 4) {
      pontuacao = 30;
    } else {
      pontuacao = 10;
    }
    return IntelligenceFactor(
      nome: 'Corrente',
      pesoBase: peso,
      pontuacao: pontuacao,
      disponivel: true,
      status: _statusPorPontuacao(pontuacao),
    );
  }

  static IntelligenceFactor _fatorOndas(
      double? ondaAlturaM, double peso, double idealM) {
    if (ondaAlturaM == null) {
      return IntelligenceFactor(
        nome: 'Ondas',
        pesoBase: peso,
        pontuacao: null,
        disponivel: false,
        status: IntelligenceFactorStatus.indisponivel,
      );
    }
    final double pontuacao;
    if (ondaAlturaM < idealM) {
      pontuacao = 100;
    } else if (ondaAlturaM < idealM * 2) {
      pontuacao = 85;
    } else if (ondaAlturaM < idealM * 4) {
      pontuacao = 60;
    } else if (ondaAlturaM < idealM * 6) {
      pontuacao = 35;
    } else if (ondaAlturaM < idealM * 8) {
      pontuacao = 15;
    } else {
      pontuacao = 5;
    }
    return IntelligenceFactor(
      nome: 'Ondas',
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
