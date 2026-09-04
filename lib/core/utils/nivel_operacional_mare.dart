/// Classificação operacional (🟢/🟡/🔴) de quanto os indicadores
/// oceanográficos disponíveis "convergem" hoje — usado na seção "Como
/// interpretar a maré na operação" da tela Maré e Pesca de Atum.
///
/// Isto NÃO é uma previsão de captura nem uma nota de pesca — é só uma
/// leitura de quantos sinais reais (maré astronômica + corrente medida)
/// apontam na mesma direção, pra orientar se vale a pena olhar os outros
/// indicadores (temperatura, frente, alimento) com mais atenção, ou se a
/// maré sozinha já não é motivo suficiente pra nada. O texto de cada nível
/// (ver [NivelOperacionalMare.textoOperacional]) é literal ao pedido
/// original — nunca promete presença de atum.
library;

import 'fase_lua.dart';

enum NivelOperacionalMare {
  favoravel(
    'Condição potencialmente favorável',
    'Quando vários indicadores oceanográficos convergem, a influência da '
        'maré pode reforçar uma condição já favorável.',
  ),
  atencao(
    'Condição de atenção',
    'A maré isoladamente não é suficiente para indicar uma boa área de '
        'pesca.',
  ),
  baixaEvidencia(
    'Baixa evidência',
    'Não utilizar a fase da maré como único motivo para deslocar a '
        'embarcação.',
  );

  final String titulo;
  final String textoOperacional;
  const NivelOperacionalMare(this.titulo, this.textoOperacional);
}

/// Corrente (m/s) acima da qual ela conta como "sinal presente" pra esse
/// classificador — mesma ordem de grandeza usada como referência em
/// [calcularIndiceInfluenciaMare] (ver `indice_influencia_mare.dart`), só
/// que aqui como um corte binário, não uma escala contínua.
const double _correnteSinalMs = 0.3;

/// Classifica o nível operacional a partir só do que o app realmente sabe
/// hoje: a maré astronômica (sizígia/quadratura/transição, geometria pura)
/// e a velocidade de corrente medida, quando disponível. Corrente
/// indisponível não é tratada como "corrente fraca" — é tratada como sinal
/// que falta, o que já rebaixa a classificação pra "atenção" no máximo
/// (não dá pra dizer que os indicadores "convergem" sem esse dado).
///
/// Os 3 níveis são sobre CONVERGÊNCIA dos dois sinais, não sobre a força
/// de um sinal isolado:
/// - favorável: os dois apontam pra amplitude forte (sizígia + corrente
///   com sinal presente);
/// - baixa evidência: os dois apontam pra amplitude fraca (quadratura +
///   corrente sem sinal presente);
/// - atenção: qualquer outro caso — inclusive quando os sinais
///   DIVERGEM (ex: quadratura mas com corrente medida forte, ou sizígia
///   mas com corrente fraca). Divergência não é "nenhuma evidência", é
///   "sinal real que não bate com o esperado pela geometria lunar" — por
///   isso não pode cair em "baixa evidência" junto com o caso de fato sem
///   sinal nenhum (bug corrigido: antes, quadratura com corrente forte
///   caía errado em "baixa evidência", como se a corrente medida não
///   contasse nada).
NivelOperacionalMare calcularNivelOperacionalMare({
  required TipoMareAstronomica tipoMare,
  double? correnteVelocidadeMs,
}) {
  if (correnteVelocidadeMs == null || tipoMare == TipoMareAstronomica.transicao) {
    return NivelOperacionalMare.atencao;
  }

  final temSinalCorrente = correnteVelocidadeMs >= _correnteSinalMs;
  final sizigia = tipoMare == TipoMareAstronomica.sizigia;

  if (sizigia && temSinalCorrente) return NivelOperacionalMare.favoravel;
  if (!sizigia && !temSinalCorrente) return NivelOperacionalMare.baixaEvidencia;
  // sizígia + corrente fraca, ou quadratura + corrente forte: sinais
  // divergentes, não convergência nenhuma nem ausência de sinal.
  return NivelOperacionalMare.atencao;
}
