import 'config.dart';
import 'constantes.dart';

/// Calibração do cálculo do "Índice de Inteligência Oceânica" — hoje um
/// índice de favorabilidade para presença de atum no Atlântico Tropical
/// (temperatura, salinidade, clorofila, corrente, batimetria), a partir de
/// um prompt de especialista em oceanografia pesqueira. Configurável pelo
/// usuário na tela "Calibrar Inteligência" e persistida via [Config]. Dois
/// eixos independentes por fator:
///
/// - **Peso** (`pesoTemperatura`, `pesoSalinidade`...): importância relativa
///   do fator no score final. **Não precisam somar 100** — o engine sempre
///   normaliza pelo peso total dos fatores disponíveis na hora do cálculo,
///   então esses números são só a razão entre um fator e os outros. Os
///   padrões (35/35/20/10/10) vêm literalmente do prompt original e somam
///   110 — mantidos como estão, a normalização do engine já lida com isso.
/// - **Faixa ideal + margem** (`temperaturaIdealMinC`/`MaxC` + `MargemC`...):
///   dentro de [idealMin, idealMax] o fator tira nota máxima ("Excelente" no
///   prompt original); até [margem] além de cada ponta, nota parcial
///   ("Moderada"); mais longe que isso, nota baixa. Simplificação da faixa
///   "moderada" do prompt original, que era assimétrica (ex: temperatura
///   2°C abaixo do mínimo ideal mas só 1°C acima do máximo) — aqui a mesma
///   margem vale pros dois lados, pra manter a tela de calibração com um
///   controle a menos por fator; onde o prompt já era simétrico (salinidade)
///   o padrão é fiel ao valor original.
///
/// **Corrente** e **batimetria** não tinham faixas numéricas no prompt
/// original (só orientação qualitativa: "valorizar encontros de correntes
/// ou gradientes", "priorizar áreas próximas à quebra da plataforma
/// continental, montes submarinos") — os padrões abaixo são uma
/// aproximação: corrente usa a magnitude da velocidade (não a direção nem
/// gradiente espacial, que precisariam de leituras em vários pontos ao
/// mesmo tempo, fora do escopo de uma consulta pontual) como indício de
/// atividade de frente oceanográfica; batimetria usa a profundidade local
/// (não a distância até a quebra da plataforma nem detecção de montes
/// submarinos, que precisariam de um dataset batimétrico de alta resolução
/// não conectado hoje) como indício de proximidade da plataforma/talude.
class CalibracaoIntelligence {
  final double pesoTemperatura;
  final double pesoSalinidade;
  final double pesoClorofila;
  final double pesoCorrente;
  final double pesoBatimetria;

  final double temperaturaIdealMinC;
  final double temperaturaIdealMaxC;
  final double temperaturaMargemC;

  final double salinidadeIdealMinUps;
  final double salinidadeIdealMaxUps;
  final double salinidadeMargemUps;

  final double clorofilaIdealMinMgM3;
  final double clorofilaIdealMaxMgM3;
  final double clorofilaMargemMgM3;

  final double correnteIdealMinNos;
  final double correnteIdealMaxNos;
  final double correnteMargemNos;

  final double batimetriaIdealMinM;
  final double batimetriaIdealMaxM;
  final double batimetriaMargemM;

  const CalibracaoIntelligence({
    required this.pesoTemperatura,
    required this.pesoSalinidade,
    required this.pesoClorofila,
    required this.pesoCorrente,
    required this.pesoBatimetria,
    required this.temperaturaIdealMinC,
    required this.temperaturaIdealMaxC,
    required this.temperaturaMargemC,
    required this.salinidadeIdealMinUps,
    required this.salinidadeIdealMaxUps,
    required this.salinidadeMargemUps,
    required this.clorofilaIdealMinMgM3,
    required this.clorofilaIdealMaxMgM3,
    required this.clorofilaMargemMgM3,
    required this.correnteIdealMinNos,
    required this.correnteIdealMaxNos,
    required this.correnteMargemNos,
    required this.batimetriaIdealMinM,
    required this.batimetriaIdealMaxM,
    required this.batimetriaMargemM,
  });

  /// Padrões do prompt "especialista em oceanografia pesqueira e análise de
  /// habitat de atuns no Oceano Atlântico Tropical" (2026-09): faixas
  /// "Excelente" de temperatura/salinidade/clorofila literais do prompt;
  /// pesos 35/35/20/10/10 literais; corrente/batimetria são aproximação
  /// (ver doc da classe).
  static const padrao = CalibracaoIntelligence(
    pesoTemperatura: 35,
    pesoSalinidade: 35,
    pesoClorofila: 20,
    pesoCorrente: 10,
    pesoBatimetria: 10,
    temperaturaIdealMinC: 22,
    temperaturaIdealMaxC: 30,
    temperaturaMargemC: 1.5,
    salinidadeIdealMinUps: 34.9,
    salinidadeIdealMaxUps: 35.8,
    salinidadeMargemUps: 0.4,
    clorofilaIdealMinMgM3: 0.08,
    clorofilaIdealMaxMgM3: 0.14,
    clorofilaMargemMgM3: 0.05,
    // Corrente/batimetria: margem sempre menor que o mínimo ideal — as
    // duas variáveis nunca são negativas de verdade, então uma margem
    // maior que o mínimo faria o piso da faixa "moderada" cair abaixo de
    // zero e, na prática, qualquer valor positivo (incluindo água parada
    // ou fundo rasíssimo) passar a contar como "moderada" em vez de
    // "baixa".
    correnteIdealMinNos: 0.3,
    correnteIdealMaxNos: 1.0,
    correnteMargemNos: 0.25,
    batimetriaIdealMinM: 100,
    batimetriaIdealMaxM: 2000,
    batimetriaMargemM: 80,
  );

  double get somaTotal =>
      pesoTemperatura + pesoSalinidade + pesoClorofila + pesoCorrente + pesoBatimetria;

  /// Participação de [peso] no total configurado (0–100) — só pra exibição
  /// ("Temperatura corresponde a 30% do peso total"), o cálculo em si usa
  /// os pesos crus (ver doc da classe).
  double participacao(double peso) => somaTotal <= 0 ? 0 : peso / somaTotal * 100;

  CalibracaoIntelligence copyWith({
    double? pesoTemperatura,
    double? pesoSalinidade,
    double? pesoClorofila,
    double? pesoCorrente,
    double? pesoBatimetria,
    double? temperaturaIdealMinC,
    double? temperaturaIdealMaxC,
    double? temperaturaMargemC,
    double? salinidadeIdealMinUps,
    double? salinidadeIdealMaxUps,
    double? salinidadeMargemUps,
    double? clorofilaIdealMinMgM3,
    double? clorofilaIdealMaxMgM3,
    double? clorofilaMargemMgM3,
    double? correnteIdealMinNos,
    double? correnteIdealMaxNos,
    double? correnteMargemNos,
    double? batimetriaIdealMinM,
    double? batimetriaIdealMaxM,
    double? batimetriaMargemM,
  }) {
    return CalibracaoIntelligence(
      pesoTemperatura: pesoTemperatura ?? this.pesoTemperatura,
      pesoSalinidade: pesoSalinidade ?? this.pesoSalinidade,
      pesoClorofila: pesoClorofila ?? this.pesoClorofila,
      pesoCorrente: pesoCorrente ?? this.pesoCorrente,
      pesoBatimetria: pesoBatimetria ?? this.pesoBatimetria,
      temperaturaIdealMinC: temperaturaIdealMinC ?? this.temperaturaIdealMinC,
      temperaturaIdealMaxC: temperaturaIdealMaxC ?? this.temperaturaIdealMaxC,
      temperaturaMargemC: temperaturaMargemC ?? this.temperaturaMargemC,
      salinidadeIdealMinUps: salinidadeIdealMinUps ?? this.salinidadeIdealMinUps,
      salinidadeIdealMaxUps: salinidadeIdealMaxUps ?? this.salinidadeIdealMaxUps,
      salinidadeMargemUps: salinidadeMargemUps ?? this.salinidadeMargemUps,
      clorofilaIdealMinMgM3: clorofilaIdealMinMgM3 ?? this.clorofilaIdealMinMgM3,
      clorofilaIdealMaxMgM3: clorofilaIdealMaxMgM3 ?? this.clorofilaIdealMaxMgM3,
      clorofilaMargemMgM3: clorofilaMargemMgM3 ?? this.clorofilaMargemMgM3,
      correnteIdealMinNos: correnteIdealMinNos ?? this.correnteIdealMinNos,
      correnteIdealMaxNos: correnteIdealMaxNos ?? this.correnteIdealMaxNos,
      correnteMargemNos: correnteMargemNos ?? this.correnteMargemNos,
      batimetriaIdealMinM: batimetriaIdealMinM ?? this.batimetriaIdealMinM,
      batimetriaIdealMaxM: batimetriaIdealMaxM ?? this.batimetriaIdealMaxM,
      batimetriaMargemM: batimetriaMargemM ?? this.batimetriaMargemM,
    );
  }

  static Future<CalibracaoIntelligence> carregar() async {
    return CalibracaoIntelligence(
      pesoTemperatura: await _obterDouble(
          Constantes.intelligencePesoTemperatura, padrao.pesoTemperatura),
      pesoSalinidade: await _obterDouble(
          Constantes.intelligencePesoSalinidade, padrao.pesoSalinidade),
      pesoClorofila: await _obterDouble(
          Constantes.intelligencePesoClorofila, padrao.pesoClorofila),
      pesoCorrente: await _obterDouble(
          Constantes.intelligencePesoCorrente, padrao.pesoCorrente),
      pesoBatimetria: await _obterDouble(
          Constantes.intelligencePesoBatimetria, padrao.pesoBatimetria),
      temperaturaIdealMinC: await _obterDouble(
          Constantes.intelligenceTemperaturaIdealMinC, padrao.temperaturaIdealMinC),
      temperaturaIdealMaxC: await _obterDouble(
          Constantes.intelligenceTemperaturaIdealMaxC, padrao.temperaturaIdealMaxC),
      temperaturaMargemC: await _obterDouble(
          Constantes.intelligenceTemperaturaMargemC, padrao.temperaturaMargemC),
      salinidadeIdealMinUps: await _obterDouble(
          Constantes.intelligenceSalinidadeIdealMinUps, padrao.salinidadeIdealMinUps),
      salinidadeIdealMaxUps: await _obterDouble(
          Constantes.intelligenceSalinidadeIdealMaxUps, padrao.salinidadeIdealMaxUps),
      salinidadeMargemUps: await _obterDouble(
          Constantes.intelligenceSalinidadeMargemUps, padrao.salinidadeMargemUps),
      clorofilaIdealMinMgM3: await _obterDouble(
          Constantes.intelligenceClorofilaIdealMinMgM3, padrao.clorofilaIdealMinMgM3),
      clorofilaIdealMaxMgM3: await _obterDouble(
          Constantes.intelligenceClorofilaIdealMaxMgM3, padrao.clorofilaIdealMaxMgM3),
      clorofilaMargemMgM3: await _obterDouble(
          Constantes.intelligenceClorofilaMargemMgM3, padrao.clorofilaMargemMgM3),
      correnteIdealMinNos: await _obterDouble(
          Constantes.intelligenceCorrenteIdealMinNos, padrao.correnteIdealMinNos),
      correnteIdealMaxNos: await _obterDouble(
          Constantes.intelligenceCorrenteIdealMaxNos, padrao.correnteIdealMaxNos),
      correnteMargemNos: await _obterDouble(
          Constantes.intelligenceCorrenteMargemNos, padrao.correnteMargemNos),
      batimetriaIdealMinM: await _obterDouble(
          Constantes.intelligenceBatimetriaIdealMinM, padrao.batimetriaIdealMinM),
      batimetriaIdealMaxM: await _obterDouble(
          Constantes.intelligenceBatimetriaIdealMaxM, padrao.batimetriaIdealMaxM),
      batimetriaMargemM: await _obterDouble(
          Constantes.intelligenceBatimetriaMargemM, padrao.batimetriaMargemM),
    );
  }

  Future<void> salvar() async {
    await Config.grava(
        Constantes.intelligencePesoTemperatura, pesoTemperatura.toString());
    await Config.grava(
        Constantes.intelligencePesoSalinidade, pesoSalinidade.toString());
    await Config.grava(
        Constantes.intelligencePesoClorofila, pesoClorofila.toString());
    await Config.grava(
        Constantes.intelligencePesoCorrente, pesoCorrente.toString());
    await Config.grava(
        Constantes.intelligencePesoBatimetria, pesoBatimetria.toString());
    await Config.grava(Constantes.intelligenceTemperaturaIdealMinC,
        temperaturaIdealMinC.toString());
    await Config.grava(Constantes.intelligenceTemperaturaIdealMaxC,
        temperaturaIdealMaxC.toString());
    await Config.grava(
        Constantes.intelligenceTemperaturaMargemC, temperaturaMargemC.toString());
    await Config.grava(Constantes.intelligenceSalinidadeIdealMinUps,
        salinidadeIdealMinUps.toString());
    await Config.grava(Constantes.intelligenceSalinidadeIdealMaxUps,
        salinidadeIdealMaxUps.toString());
    await Config.grava(
        Constantes.intelligenceSalinidadeMargemUps, salinidadeMargemUps.toString());
    await Config.grava(Constantes.intelligenceClorofilaIdealMinMgM3,
        clorofilaIdealMinMgM3.toString());
    await Config.grava(Constantes.intelligenceClorofilaIdealMaxMgM3,
        clorofilaIdealMaxMgM3.toString());
    await Config.grava(
        Constantes.intelligenceClorofilaMargemMgM3, clorofilaMargemMgM3.toString());
    await Config.grava(Constantes.intelligenceCorrenteIdealMinNos,
        correnteIdealMinNos.toString());
    await Config.grava(Constantes.intelligenceCorrenteIdealMaxNos,
        correnteIdealMaxNos.toString());
    await Config.grava(
        Constantes.intelligenceCorrenteMargemNos, correnteMargemNos.toString());
    await Config.grava(
        Constantes.intelligenceBatimetriaIdealMinM, batimetriaIdealMinM.toString());
    await Config.grava(
        Constantes.intelligenceBatimetriaIdealMaxM, batimetriaIdealMaxM.toString());
    await Config.grava(
        Constantes.intelligenceBatimetriaMargemM, batimetriaMargemM.toString());
  }

  static Future<double> _obterDouble(String chave, double padrao) async {
    final valor = await Config.obtem(chave);
    return double.tryParse(valor) ?? padrao;
  }
}
