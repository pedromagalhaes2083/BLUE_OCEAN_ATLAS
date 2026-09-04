/// Índice de Influência da Maré — usado na tela "Maré e Pesca de Atum"
/// (ver [MareEPescaAtumScreen]).
///
/// IMPORTANTE (não é chance de pegar peixe): esse número NÃO representa
/// "chance de pegar atum" nem qualquer previsão de captura. Ele representa
/// só o quanto as condições de maré/lua/corrente observadas *hoje* tendem,
/// pela geometria Sol-Terra-Lua e pela força da corrente medida, a
/// contribuir para mais movimentação/mistura da água — um fator
/// oceanográfico entre vários (temperatura, clorofila, frentes, vento...),
/// não uma nota de pesca. O texto da tela reforça isso; aqui só documentamos
/// a conta.
///
/// Cada fator vira uma pontuação 0-100 só quando o dado real existe — nunca
/// inventamos um valor pra um fator sem dado (ver auditoria/instrução do
/// usuário sobre não fabricar correlação: "DADO / INTERPRETAÇÃO /
/// RECOMENDAÇÃO", nunca inventar o DADO). Fator sem dado fica de fora da
/// média e aparece na lista de indisponíveis pra UI mostrar
/// "Dado indisponível" em vez de um número inventado.
///
/// Fatores hoje incorporados à pontuação (dado real, disponível no app):
/// - proximidade da fase lunar a um ponto de sizígia (geometria pura, local);
/// - amplitude de maré prevista nas próximas 24h (Open-Meteo Marine);
/// - velocidade da corrente oceânica agora (Open-Meteo Marine).
///
/// Fatores citados no pedido original que ficam só como dado
/// informativo/complementar na tela, sem entrar nessa pontuação — porque
/// combiná-los num único número exigiria uma suposição sobre direção
/// "boa" ou "ruim" que não temos como validar (ex: vento forte pode tanto
/// ajudar quanto atrapalhar a mistura, dependendo da região):
/// direção da corrente, vento, diferença de temperatura, proximidade de
/// frentes térmicas e clorofila. Clorofila e frentes térmicas, além disso,
/// nem têm fonte de dado no app ainda.
library;

import 'fase_lua.dart';

/// Amplitude de maré (m) acima da qual o fator conta pontuação máxima —
/// referência grosseira (marés de sizígia bem marcadas no litoral
/// brasileiro costumam ficar entre 1,5 e 3m; acima disso já é "bem alta"
/// pra fins desse índice).
const double _amplitudeReferenciaM = 3.0;

/// Velocidade de corrente (m/s) acima da qual o fator conta pontuação
/// máxima — ~1,5 m/s (quase 3 nós) já é uma corrente de maré forte pra a
/// maioria das regiões costeiras.
const double _correnteReferenciaMs = 1.5;

/// Um fator individual do índice — [pontuacao] é 0-100, ou `null` quando o
/// dado de origem não estava disponível (a UI deve mostrar
/// "Dado indisponível", nunca um valor inventado).
class FatorIndiceMare {
  final String nome;
  final double? pontuacao;

  /// Valor bruto legível (ex: "1.8 m", "0.42 m/s"), pra mostrar ao lado da
  /// pontuação — transparência sobre o DADO que gerou a INTERPRETAÇÃO.
  final String? detalhe;

  const FatorIndiceMare({required this.nome, this.pontuacao, this.detalhe});

  bool get disponivel => pontuacao != null;
}

/// Classificação textual do [IndiceInfluenciaMare.valor] — mesma ideia do
/// número, só que em 3 faixas pra quem prefere ler "Alta" a fazer conta de
/// porcentagem de cabeça. Faixas iguais às cores já usadas no card
/// (`IndiceInfluenciaCard._corIndice`): <34 baixa, <67 moderada, resto alta.
enum ClassificacaoIndiceMare {
  baixa('Baixo'),
  moderada('Moderado'),
  alta('Alto');

  /// Concorda com "potencial" (masculino) — mesmo padrão de
  /// "Potencial de influência: ALTO/MODERADO" já usado no card de
  /// comparação sizígia × quadratura.
  final String label;
  const ClassificacaoIndiceMare(this.label);
}

/// Resultado do cálculo — [valor] é `null` quando nenhum fator tinha dado
/// disponível (nesse caso a UI mostra o card inteiro como indisponível, sem
/// inventar um número).
class IndiceInfluenciaMare {
  final double? valor;
  final List<FatorIndiceMare> fatoresPontuados;

  /// Fatores citados no pedido original que este índice não pontua (ver
  /// motivo na doc do arquivo) — listados por transparência, pra tela
  /// mostrar quais entradas foram consideradas e quais não.
  final List<String> fatoresInformativos;

  const IndiceInfluenciaMare({
    required this.valor,
    required this.fatoresPontuados,
    required this.fatoresInformativos,
  });

  /// `null` junto com [valor] nulo — sem dado, sem classificação inventada.
  ClassificacaoIndiceMare? get classificacao {
    final v = valor;
    if (v == null) return null;
    if (v < 34) return ClassificacaoIndiceMare.baixa;
    if (v < 67) return ClassificacaoIndiceMare.moderada;
    return ClassificacaoIndiceMare.alta;
  }
}

double _clamp0a100(double v) => v < 0 ? 0 : (v > 100 ? 100 : v);

/// Calcula o Índice de Influência da Maré a partir dos dados que estiverem
/// disponíveis. Passe `null` pra qualquer parâmetro cujo dado não veio da
/// API — o fator correspondente fica marcado como indisponível, não
/// pontuado com um valor arbitrário.
IndiceInfluenciaMare calcularIndiceInfluenciaMare({
  required FaseLua fase,
  double? amplitudeMareM,
  double? correnteVelocidadeMs,
}) {
  final pontuacaoFase = pontuacaoProximidadeSizigia(fase);
  final fatores = <FatorIndiceMare>[
    FatorIndiceMare(
      nome: 'Fase lunar (proximidade da sizígia)',
      pontuacao: pontuacaoFase,
      detalhe: '${fase.tipo.label} · dia ${fase.idadeDias.round()} do ciclo',
    ),
    FatorIndiceMare(
      nome: 'Amplitude de maré prevista',
      pontuacao: amplitudeMareM == null
          ? null
          : _clamp0a100(100 * amplitudeMareM / _amplitudeReferenciaM),
      detalhe: amplitudeMareM == null
          ? null
          : '${amplitudeMareM.toStringAsFixed(2)} m nas próximas 24h',
    ),
    FatorIndiceMare(
      nome: 'Velocidade da corrente',
      pontuacao: correnteVelocidadeMs == null
          ? null
          : _clamp0a100(100 * correnteVelocidadeMs / _correnteReferenciaMs),
      detalhe: correnteVelocidadeMs == null
          ? null
          : '${correnteVelocidadeMs.toStringAsFixed(2)} m/s agora',
    ),
  ];

  final disponiveis = fatores.where((f) => f.disponivel).toList();
  final valor = disponiveis.isEmpty
      ? null
      : disponiveis.map((f) => f.pontuacao!).reduce((a, b) => a + b) /
          disponiveis.length;

  return IndiceInfluenciaMare(
    valor: valor,
    fatoresPontuados: fatores,
    fatoresInformativos: const [
      'Direção da corrente',
      'Vento',
      'Diferença de temperatura',
      'Proximidade de frentes térmicas',
      'Clorofila',
    ],
  );
}
