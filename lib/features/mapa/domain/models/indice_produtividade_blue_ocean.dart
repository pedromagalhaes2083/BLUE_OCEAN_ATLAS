import 'nivel_produtividade.dart';

/// Índice de produtividade Blue Ocean — combina clorofila-a e temperatura
/// da superfície do mar (SST) num único indicador (Ruim/Bom/Ótimo/
/// Excelente) pra um ponto específico. É o índice mencionado desde a
/// integração da clorofila (ver doc de `LeituraClorofilaPonto`), que na
/// época ainda não existia: "futuramente combinar isso com temperatura/
/// profundidade/corrente/histórico pra um índice próprio, sempre deixado
/// explícito como estimativa/modelo".
///
/// **Sempre uma estimativa heurística** — nunca lê isso como garantia de
/// cardume. Cada camada (clorofila, SST) já é só um indicador indireto de
/// produtividade biológica/ambiental; combinar os dois não vira uma medição
/// direta de peixe, só um palpite um pouco mais informado.
///
/// Extensível: profundidade/corrente/histórico de produção podem entrar
/// como mais um fator no futuro (ver [calcular]) sem quebrar quem já
/// consome esse modelo — os campos novos viriam opcionais, como
/// [temperaturaC] e [clorofilaMgM3] já são.
class IndiceProdutividadeBlueOcean {
  final double latitude;
  final double longitude;

  final double? clorofilaMgM3;
  final DateTime? clorofilaData;
  final double? temperaturaC;

  final NivelProdutividade nivel;

  /// Frase curta explicando os fatores que formaram [nivel] — ex:
  /// "Clorofila-a: Ótimo (0,19 mg/m³) · Temperatura: Bom (24,8 °C)".
  /// Sempre mostrada junto do índice, pra nunca virar um número opaco.
  final String explicacao;

  const IndiceProdutividadeBlueOcean({
    required this.latitude,
    required this.longitude,
    required this.clorofilaMgM3,
    required this.clorofilaData,
    required this.temperaturaC,
    required this.nivel,
    required this.explicacao,
  });

  /// Faixa de SST considerada mais favorável pra cardumes de superfície no
  /// litoral cearense (atum/bonito) — heurística simples baseada na
  /// distância até [_temperaturaIdealC], não um modelo oceanográfico
  /// validado. Fácil de recalibrar depois com dado real de captura x SST
  /// (ver `producao_pontos_analyzer.dart`, que já cruza produção com
  /// posição — um passo natural seguinte seria cruzar com SST também).
  static const _temperaturaIdealC = 27.0;

  static NivelProdutividade _nivelTemperatura(double temperaturaC) {
    final distancia = (temperaturaC - _temperaturaIdealC).abs();
    if (distancia <= 0.5) return NivelProdutividade.excelente;
    if (distancia <= 1.5) return NivelProdutividade.otimo;
    if (distancia <= 3.0) return NivelProdutividade.bom;
    return NivelProdutividade.ruim;
  }

  /// Combina os níveis já calculados de cada fator presente. Quando os dois
  /// existem, o índice final é o **pior dos dois** — um só fator ruim já é
  /// motivo pra não chamar o ponto de "excelente", mesmo que o outro fator
  /// esteja ótimo (ex: água rica em nutrientes mas fria demais pra atum de
  /// superfície não é um ponto excelente, é um ponto misto). Com um fator
  /// só (o outro sem dado — nuvem, fora de cobertura, erro de rede), o
  /// índice usa o que tiver, nunca inventa o que falta.
  factory IndiceProdutividadeBlueOcean.calcular({
    required double latitude,
    required double longitude,
    double? clorofilaMgM3,
    DateTime? clorofilaData,
    double? temperaturaC,
  }) {
    final nivelClorofilaCalculado =
        clorofilaMgM3 != null ? nivelClorofila(clorofilaMgM3) : null;
    final nivelTemperaturaCalculado =
        temperaturaC != null ? _nivelTemperatura(temperaturaC) : null;

    final niveis = [nivelClorofilaCalculado, nivelTemperaturaCalculado]
        .whereType<NivelProdutividade>()
        .toList();

    final nivelFinal = niveis.isEmpty
        ? NivelProdutividade.ruim
        : niveis.reduce((a, b) => a.index < b.index ? a : b);

    final partes = <String>[];
    if (nivelClorofilaCalculado != null) {
      partes.add('Clorofila-a: ${nivelClorofilaCalculado.rotulo} '
          '(${clorofilaMgM3!.toStringAsFixed(2)} mg/m³)');
    }
    if (nivelTemperaturaCalculado != null) {
      partes.add('Temperatura: ${nivelTemperaturaCalculado.rotulo} '
          '(${temperaturaC!.toStringAsFixed(1)} °C, ideal ~'
          '${_temperaturaIdealC.toStringAsFixed(0)} °C)');
    }
    final explicacao = partes.isEmpty
        ? 'Sem dado de clorofila-a nem de temperatura pra esse ponto agora'
        : partes.join(' · ');

    return IndiceProdutividadeBlueOcean(
      latitude: latitude,
      longitude: longitude,
      clorofilaMgM3: clorofilaMgM3,
      clorofilaData: clorofilaData,
      temperaturaC: temperaturaC,
      nivel: nivelFinal,
      explicacao: explicacao,
    );
  }
}
