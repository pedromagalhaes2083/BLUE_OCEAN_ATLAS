/// Uma leitura de clorofila-a de superfície num ponto — parte de uma
/// [ClorofilaResposta]. Vem do produto Copernicus Marine
/// `OCEANCOLOUR_ATL_BGC_L4_NRT_009_116` (Ocean Colour do Atlântico,
/// observação por satélite, ~1km, atualização diária), variável `CHL`
/// ("Mass concentration of chlorophyll a in sea water"), em mg/m³.
///
/// Clorofila-a é um indicador de produtividade biológica/oceanográfica —
/// NUNCA tratar [valorMgM3] como biomassa de peixe diretamente (ver
/// `BlueOceanProductivityIndex`, ainda não implementado, que futuramente vai
/// combinar isso com temperatura/profundidade/corrente/histórico pra um
/// índice próprio, sempre deixado explícito como estimativa/modelo).
class LeituraClorofila {
  final double latitude;
  final double longitude;

  /// Nulo quando o pixel não tem dado válido pro dia pedido (nuvem, terra,
  /// falha do sensor etc.) — nunca preenchido com valor inventado; a UI
  /// deve mostrar "sem dado" nesse caso, não um número (ver
  /// `ClorofilaLayer`).
  final double? valorMgM3;

  /// Índice de qualidade do dado, quando o dataset expõe um (0-100 ou
  /// escala própria do produto — o backend repassa o valor bruto, sem
  /// normalizar). Reservado pra filtrar leituras de baixa qualidade no
  /// futuro; não usado pra nada ainda.
  final num? qualityIndex;

  /// Máscara de sensor/qualidade bruta do produto Copernicus (quando
  /// exposta), reservada pro mesmo propósito de [qualityIndex].
  final int? sensorMask;

  const LeituraClorofila({
    required this.latitude,
    required this.longitude,
    this.valorMgM3,
    this.qualityIndex,
    this.sensorMask,
  });

  factory LeituraClorofila.fromJson(Map<String, dynamic> json) {
    // Tolerante a nome de campo — lat/lon vs latitude/longitude — mesmo
    // padrão de tolerância usado em outros modelos remotos deste app (ver
    // ViagemAtualRemota) até o contrato do endpoint ser fechado de vez.
    final lat = json['latitude'] ?? json['lat'];
    final lon = json['longitude'] ?? json['lon'] ?? json['lng'];
    if (lat == null || lon == null) {
      throw FormatException(
          'Leitura de clorofila sem latitude/longitude: $json');
    }

    // `missing_value`/`null`/campo ausente tratados todos como "sem
    // dado" — nunca um número inventado (ver doc do campo).
    final valorBruto = json['value'] ?? json['chlorophyll_a'] ?? json['chl'];
    final missingValue = json['missing_value'];
    final valor = (valorBruto is num &&
            (missingValue == null || valorBruto != missingValue))
        ? valorBruto.toDouble()
        : null;

    return LeituraClorofila(
      latitude: (lat as num).toDouble(),
      longitude: (lon as num).toDouble(),
      valorMgM3: valor,
      qualityIndex: json['quality_index'] as num?,
      sensorMask: (json['sensor_mask'] as num?)?.toInt(),
    );
  }
}

/// Envelope da resposta de `GET base/oceano/clorofila` (ver
/// [Endpoints.oceanoClorofila] / `ClorofilaRepository.buscar`) — formato
/// alinhado com a especificação combinada em 2026-09 (fonte, variável,
/// unidade, data do dado, resolução, bbox pedida e os pontos).
class ClorofilaResposta {
  final String source;
  final String variable;
  final String unit;

  /// Data do dado usado (não da consulta) — sempre exibida na UI junto do
  /// valor, nunca omitida (ver spec: "o aplicativo deve mostrar a
  /// data/hora do dado utilizado").
  final DateTime data;

  final String? resolution;
  final List<LeituraClorofila> pontos;

  const ClorofilaResposta({
    required this.source,
    required this.variable,
    required this.unit,
    required this.data,
    this.resolution,
    required this.pontos,
  });

  factory ClorofilaResposta.fromJson(Map<String, dynamic> json) {
    final dataStr = json['date'] as String?;
    if (dataStr == null) {
      throw const FormatException('Resposta de clorofila sem "date".');
    }
    final lista = json['data'] as List? ?? [];
    return ClorofilaResposta(
      source: json['source'] as String? ?? 'Copernicus Marine',
      variable: json['variable'] as String? ?? 'chlorophyll_a',
      unit: json['unit'] as String? ?? 'mg/m3',
      data: DateTime.parse(dataStr),
      resolution: json['resolution'] as String?,
      pontos: lista
          .map((e) => LeituraClorofila.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
