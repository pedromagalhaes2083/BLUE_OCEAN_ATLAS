/// Condições ambientais amostradas num ponto — cada campo é nulo quando a
/// fonte correspondente não respondeu (rede indisponível, fora de
/// cobertura do modelo, etc.). Nunca preenchido com valor inventado: um
/// campo nulo aqui é o que faz o [IntelligenceEngine] marcar o fator
/// correspondente como indisponível e redistribuir o peso dele.
class OceanConditions {
  final double? sst;
  final double? correnteNos;
  final int? correnteDirecaoGraus;
  final double? ondaAlturaM;
  final int? ondaDirecaoGraus;
  final double? swellAlturaM;
  final double? ventoKmh;
  final int? ventoDirecaoGraus;
  final double? mareAlturaM;
  final double? profundidadeM;
  final double? clorofilaMgM3;

  /// Data da observação de satélite da clorofila (produto diário, costuma
  /// ter alguns dias de atraso) — mostrada junto do valor.
  final DateTime? clorofilaData;

  /// A clorofila veio do cache sem confirmar que é o produto mais recente
  /// (sem rede) — ver `LeituraClorofilaPonto.desatualizada`.
  final bool clorofilaDesatualizada;

  /// Salinidade de superfície (PSU) — bóias Argo (mapa global RFROM v2.3
  /// da NOAA/PMEL, ver `RfromOceanRepository`), mesma fonte/limitação de
  /// cobertura da salinidade mostrada em `CondicoesMarScreen`: comum vir
  /// nula perto da costa (bóias não sobem a plataforma continental).
  final double? salinidadeUps;

  const OceanConditions({
    this.sst,
    this.correnteNos,
    this.correnteDirecaoGraus,
    this.ondaAlturaM,
    this.ondaDirecaoGraus,
    this.swellAlturaM,
    this.ventoKmh,
    this.ventoDirecaoGraus,
    this.mareAlturaM,
    this.profundidadeM,
    this.clorofilaMgM3,
    this.clorofilaData,
    this.clorofilaDesatualizada = false,
    this.salinidadeUps,
  });
}
