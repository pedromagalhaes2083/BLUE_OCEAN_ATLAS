/// Tendência da pressão atmosférica — variação nas últimas
/// [_janelaHoras] horas, um dos preditores mais citados por pescadores:
/// pressão caindo costuma preceder frente chegando (peixe mais ativo);
/// pressão alta e estável costuma ser o cenário mais fraco.
///
/// Não é nenhuma fonte nova: usa a mesma série horária de `pressao` que a
/// Open-Meteo já devolve pra `CondicoesVentoCard` — só compara o valor de
/// agora com o de [_janelaHoras] atrás.
library;

const int _janelaHoras = 3;

/// Limiar (hPa em [_janelaHoras]h) acima do qual a variação já conta como
/// tendência, não ruído — abaixo disso, "estável". Não é um valor
/// oficial de nenhum órgão meteorológico, é só grande o bastante pra não
/// marcar como "subindo"/"caindo" uma flutuação de décimos de hPa.
const double _limiarHpa = 0.5;

enum TendenciaPressaoTipo {
  caindo('Caindo', 'Pressão em queda — costuma anteceder mudança de tempo; peixe tende a ficar mais ativo.'),
  estavel('Estável', 'Pressão estável — sem indício de mudança de tempo pelo barômetro.'),
  subindo('Subindo', 'Pressão subindo — tempo tende a firmar; atividade de pesca costuma cair.');

  final String label;
  final String nota;
  const TendenciaPressaoTipo(this.label, this.nota);
}

class TendenciaPressao {
  final double pressaoAtualHpa;
  final double variacaoHpa;
  final TendenciaPressaoTipo tipo;

  const TendenciaPressao({
    required this.pressaoAtualHpa,
    required this.variacaoHpa,
    required this.tipo,
  });
}

/// Calcula a tendência a partir de uma série `(horario, pressaoHpa)` —
/// aceita qualquer fonte nesse formato, não só `PrevisaoTempoHoraria`,
/// pra não acoplar esse cálculo puro ao modelo de domínio da meteorologia.
///
/// Devolve `null` quando não há [_janelaHoras] horas de histórico
/// suficiente pra comparar (ex: logo depois de abrir o app, antes da
/// janela de dados cobrir 3h) — nesse caso é melhor não mostrar nada do
/// que mostrar uma tendência calculada sobre pouca coisa.
TendenciaPressao? calcularTendenciaPressao(
  List<({DateTime horario, double pressaoHpa})> serie, {
  DateTime? agora,
}) {
  if (serie.isEmpty) return null;
  final referencia = agora ?? DateTime.now();

  // Ponto mais próximo de "agora" e mais próximo de "agora - janela".
  ({DateTime horario, double pressaoHpa})? maisProximo(DateTime alvo) {
    ({DateTime horario, double pressaoHpa})? melhor;
    Duration? menorDiferenca;
    for (final ponto in serie) {
      final diferenca = ponto.horario.difference(alvo).abs();
      if (menorDiferenca == null || diferenca < menorDiferenca) {
        menorDiferenca = diferenca;
        melhor = ponto;
      }
    }
    return melhor;
  }

  final pontoAtual = maisProximo(referencia);
  final pontoAnterior =
      maisProximo(referencia.subtract(const Duration(hours: _janelaHoras)));
  if (pontoAtual == null || pontoAnterior == null) return null;

  // Sem dado de verdade perto o bastante de "agora - 3h" (ex: só temos
  // previsão a partir de agora pra frente, nenhum histórico) — comparar
  // contra um ponto distante demais não é uma tendência de 3h de verdade.
  final distanciaAnterior = pontoAnterior.horario
      .difference(referencia.subtract(const Duration(hours: _janelaHoras)))
      .abs();
  if (distanciaAnterior > const Duration(hours: 1)) return null;

  final variacao = pontoAtual.pressaoHpa - pontoAnterior.pressaoHpa;
  final tipo = variacao <= -_limiarHpa
      ? TendenciaPressaoTipo.caindo
      : variacao >= _limiarHpa
          ? TendenciaPressaoTipo.subindo
          : TendenciaPressaoTipo.estavel;

  return TendenciaPressao(
    pressaoAtualHpa: pontoAtual.pressaoHpa,
    variacaoHpa: variacao,
    tipo: tipo,
  );
}
