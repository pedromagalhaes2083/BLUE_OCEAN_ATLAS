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

  const LeituraClorofilaPonto({
    required this.latitude,
    required this.longitude,
    this.valorMgM3,
    required this.data,
    this.source = 'NOAA CoastWatch (ERDDAP)',
  });
}
