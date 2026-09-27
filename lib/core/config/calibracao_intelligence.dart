import 'config.dart';
import 'constantes.dart';

/// Calibração do cálculo do "Índice de Inteligência Oceânica" (ver
/// `IntelligenceEngine`) — configurável pelo usuário na tela "Calibrar
/// Inteligência" e persistida via [Config]. Dois eixos independentes por
/// fator:
///
/// - **Peso** (`pesoSst`, `pesoCorrente`...): importância relativa do fator
///   no score final. **Não precisam somar 100** — o engine sempre
///   normaliza pelo peso total dos fatores disponíveis na hora do cálculo,
///   então esses números são só a razão entre um fator e os outros.
/// - **Quantidade ideal** (`sstIdealC`, `correnteIdealNos`...): o valor da
///   variável que dá a nota máxima (100) daquele fator — ex: qual
///   temperatura de SST é considerada ideal, ou até que velocidade de vento
///   ainda é "calmo". Os demais patamares da curva de cada fator (bom/
///   moderado/desfavorável...) escalam proporcionalmente a partir desse
///   valor (ver `IntelligenceEngine`), então calibrar só a quantidade ideal
///   já desloca a curva inteira, sem precisar expor cada patamar.
class CalibracaoIntelligence {
  final double pesoSst;
  final double pesoCorrente;
  final double pesoClorofila;
  final double pesoOndas;
  final double pesoVento;

  final double sstIdealC;
  final double correnteIdealNos;
  final double clorofilaIdealMgM3;
  final double ondaIdealM;
  final double ventoIdealKmh;

  const CalibracaoIntelligence({
    required this.pesoSst,
    required this.pesoCorrente,
    required this.pesoClorofila,
    required this.pesoOndas,
    required this.pesoVento,
    required this.sstIdealC,
    required this.correnteIdealNos,
    required this.clorofilaIdealMgM3,
    required this.ondaIdealM,
    required this.ventoIdealKmh,
  });

  /// Pesos na mesma proporção usada no `IntelligenceEngine` antes desta
  /// tela existir (SST/Corrente/Clorofila com o mesmo peso, Ondas o dobro
  /// do Vento). Quantidades ideais nos mesmos valores que já eram fixos no
  /// engine (SST: `IndiceProdutividadeBlueOcean.temperaturaIdealC`;
  /// Clorofila: `clorofilaOtimo`; Corrente/Ondas/Vento: primeiro patamar
  /// "calmo" das faixas de `AlertaRotaScreen`).
  static const padrao = CalibracaoIntelligence(
    pesoSst: 30,
    pesoCorrente: 30,
    pesoClorofila: 30,
    pesoOndas: 20,
    pesoVento: 10,
    sstIdealC: 27.0,
    correnteIdealNos: 0.5,
    clorofilaIdealMgM3: 0.22,
    ondaIdealM: 0.5,
    ventoIdealKmh: 10,
  );

  double get somaTotal =>
      pesoSst + pesoCorrente + pesoClorofila + pesoOndas + pesoVento;

  /// Participação de [peso] no total configurado (0–100) — só pra exibição
  /// ("SST corresponde a 25% do peso total"), o cálculo em si usa os pesos
  /// crus (ver doc da classe).
  double participacao(double peso) => somaTotal <= 0 ? 0 : peso / somaTotal * 100;

  CalibracaoIntelligence copyWith({
    double? pesoSst,
    double? pesoCorrente,
    double? pesoClorofila,
    double? pesoOndas,
    double? pesoVento,
    double? sstIdealC,
    double? correnteIdealNos,
    double? clorofilaIdealMgM3,
    double? ondaIdealM,
    double? ventoIdealKmh,
  }) {
    return CalibracaoIntelligence(
      pesoSst: pesoSst ?? this.pesoSst,
      pesoCorrente: pesoCorrente ?? this.pesoCorrente,
      pesoClorofila: pesoClorofila ?? this.pesoClorofila,
      pesoOndas: pesoOndas ?? this.pesoOndas,
      pesoVento: pesoVento ?? this.pesoVento,
      sstIdealC: sstIdealC ?? this.sstIdealC,
      correnteIdealNos: correnteIdealNos ?? this.correnteIdealNos,
      clorofilaIdealMgM3: clorofilaIdealMgM3 ?? this.clorofilaIdealMgM3,
      ondaIdealM: ondaIdealM ?? this.ondaIdealM,
      ventoIdealKmh: ventoIdealKmh ?? this.ventoIdealKmh,
    );
  }

  static Future<CalibracaoIntelligence> carregar() async {
    return CalibracaoIntelligence(
      pesoSst:
          await _obterDouble(Constantes.intelligencePesoSst, padrao.pesoSst),
      pesoCorrente: await _obterDouble(
          Constantes.intelligencePesoCorrente, padrao.pesoCorrente),
      pesoClorofila: await _obterDouble(
          Constantes.intelligencePesoClorofila, padrao.pesoClorofila),
      pesoOndas: await _obterDouble(
          Constantes.intelligencePesoOndas, padrao.pesoOndas),
      pesoVento: await _obterDouble(
          Constantes.intelligencePesoVento, padrao.pesoVento),
      sstIdealC: await _obterDouble(
          Constantes.intelligenceIdealSstC, padrao.sstIdealC),
      correnteIdealNos: await _obterDouble(
          Constantes.intelligenceIdealCorrenteNos, padrao.correnteIdealNos),
      clorofilaIdealMgM3: await _obterDouble(
          Constantes.intelligenceIdealClorofilaMgM3, padrao.clorofilaIdealMgM3),
      ondaIdealM: await _obterDouble(
          Constantes.intelligenceIdealOndaM, padrao.ondaIdealM),
      ventoIdealKmh: await _obterDouble(
          Constantes.intelligenceIdealVentoKmh, padrao.ventoIdealKmh),
    );
  }

  Future<void> salvar() async {
    await Config.grava(Constantes.intelligencePesoSst, pesoSst.toString());
    await Config.grava(
        Constantes.intelligencePesoCorrente, pesoCorrente.toString());
    await Config.grava(
        Constantes.intelligencePesoClorofila, pesoClorofila.toString());
    await Config.grava(Constantes.intelligencePesoOndas, pesoOndas.toString());
    await Config.grava(Constantes.intelligencePesoVento, pesoVento.toString());
    await Config.grava(Constantes.intelligenceIdealSstC, sstIdealC.toString());
    await Config.grava(
        Constantes.intelligenceIdealCorrenteNos, correnteIdealNos.toString());
    await Config.grava(Constantes.intelligenceIdealClorofilaMgM3,
        clorofilaIdealMgM3.toString());
    await Config.grava(Constantes.intelligenceIdealOndaM, ondaIdealM.toString());
    await Config.grava(
        Constantes.intelligenceIdealVentoKmh, ventoIdealKmh.toString());
  }

  static Future<double> _obterDouble(String chave, double padrao) async {
    final valor = await Config.obtem(chave);
    return double.tryParse(valor) ?? padrao;
  }
}
