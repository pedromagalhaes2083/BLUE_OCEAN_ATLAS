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
  });
}
