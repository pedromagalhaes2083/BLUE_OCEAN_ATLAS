/// Uma leitura de clorofila-a de superfície num ponto específico —
/// resultado de [ClorofilaRepository.buscarPonto].
///
/// Fonte: NOAA CoastWatch (ERDDAP), dataset
/// `noaacwNPPN20S3ASCIDINEOF2kmDaily` (observação por satélite, DINEOF,
/// ~2km, diário) — pública, sem autenticação (ver decisão de 2026-09: usar
/// ERDDAP em vez do Copernicus Marine Toolbox, que exige credencial e um
/// processo de subset bem mais pesado pra um valor pontual como esse).
///
/// Clorofila-a é um indicador de produtividade biológica/oceanográfica —
/// NUNCA tratar [valorMgM3] como biomassa de peixe diretamente (ver
/// `BlueOceanProductivityIndex`, ainda não implementado, que futuramente vai
/// combinar isso com temperatura/profundidade/corrente/histórico pra um
/// índice próprio, sempre deixado explícito como estimativa/modelo).
class LeituraClorofilaPonto {
  final double latitude;
  final double longitude;

  /// Nulo quando o pixel não tem dado válido no dia mais recente disponível
  /// (nuvem, proximidade de terra/turbidez mascarada, falha do sensor etc.)
  /// — nunca preenchido com valor inventado; a UI mostra "sem dado" nesse
  /// caso, não um número.
  final double? valorMgM3;

  /// Data do dado usado (o ERDDAP resolve pra data mais recente disponível
  /// via `(last)`, que pode não ser hoje — produtos de cor do oceano têm
  /// alguns dias de atraso) — sempre exibida na UI junto do valor.
  final DateTime data;

  final String source;

  /// `true` quando [valorMgM3] veio do pixel mais próximo com dado válido
  /// dentro de uma pequena grade ao redor do ponto pedido (ver
  /// [ClorofilaRepository.buscarPontoOuAproximado]), não do pixel exato —
  /// [latitude]/[longitude] já refletem onde esse dado de verdade foi
  /// medido (nunca o ponto pedido), então a UI sempre pode mostrar "dado
  /// de X, Y" sem distinguir os dois casos — só precisa do aviso extra
  /// quando [aproximado] é `true`.
  final bool aproximado;

  /// `true` quando veio do cache local sem confirmar que é o produto
  /// diário mais recente (sem rede, ERDDAP fora do ar) — ou sabendo que já
  /// existe um mais novo que não deu pra baixar. [data] continua sendo a
  /// da observação original; a UI deve deixar claro que não é o dado atual.
  final bool desatualizada;

  const LeituraClorofilaPonto({
    required this.latitude,
    required this.longitude,
    this.valorMgM3,
    required this.data,
    this.source = 'NOAA CoastWatch (ERDDAP)',
    this.aproximado = false,
    this.desatualizada = false,
  });

  /// Cópia marcando como [desatualizada] — o resto (valor, data original
  /// da observação, pixel) fica exatamente como foi medido.
  LeituraClorofilaPonto comoDesatualizada() => LeituraClorofilaPonto(
        latitude: latitude,
        longitude: longitude,
        valorMgM3: valorMgM3,
        data: data,
        source: source,
        aproximado: aproximado,
        desatualizada: true,
      );
}
