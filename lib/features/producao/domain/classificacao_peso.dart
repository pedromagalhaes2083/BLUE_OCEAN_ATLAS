/// Tipo de peixe capturado, hoje limitado às duas espécies-alvo da
/// operação. Adicionar um novo tipo aqui exige também uma entrada por
/// classificação em [faixaPesoPorClassificacao].
enum TipoPeixe {
  kihada('Kihada'),
  bati('Bati');

  final String label;
  const TipoPeixe(this.label);
}

/// Faixa de classificação por peso — a mesma tabela de peso vale para
/// qualquer [TipoPeixe] (ver [faixaPesoPorClassificacao]).
enum Classificacao {
  faixa10a15('10-15'),
  faixa15a25('15-25'),
  faixa25a39('25-39'),
  faixa40mais('40+');

  final String label;
  const Classificacao(this.label);
}

/// Intervalo de peso (kg) de um peixe dentro de uma faixa de classificação.
class FaixaPeso {
  final double min;
  final double max;
  const FaixaPeso(this.min, this.max);

  /// Ponto médio do intervalo — usado só para gravar um único valor de
  /// peso/unidade no registro (histórico, mapa de calor), a UI de
  /// lançamento mostra o intervalo completo, não a média.
  double get media => (min + max) / 2;
}

/// Intervalo de peso médio (kg) por unidade, para cada faixa de
/// classificação — usado para estimar o peso total de uma captura
/// (quantidade em unidades × intervalo da faixa). Constante isolada aqui de
/// propósito, para poder ser ajustada sem mexer na tela de produção.
///
/// A faixa "40+" não tem limite superior natural, então usa um intervalo
/// estipulado à parte (45–50 kg) em vez do "40 e acima" literal.
const Map<Classificacao, FaixaPeso> faixaPesoPorClassificacao = {
  Classificacao.faixa10a15: FaixaPeso(10, 15),
  Classificacao.faixa15a25: FaixaPeso(15, 25),
  Classificacao.faixa25a39: FaixaPeso(25, 39),
  Classificacao.faixa40mais: FaixaPeso(45, 50),
};

/// Intervalo de peso (kg) para a combinação tipo/classificação. Hoje a
/// tabela é a mesma para todos os [TipoPeixe] — se um tipo passar a ter
/// peso próprio, basta ramificar aqui por [tipo] sem alterar quem chama.
FaixaPeso faixaPesoUnitario(TipoPeixe tipo, Classificacao classificacao) {
  return faixaPesoPorClassificacao[classificacao]!;
}
