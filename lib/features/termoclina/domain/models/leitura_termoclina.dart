import 'perfil_temperatura_ponto.dart';

/// Uma leitura de termoclina num ponto — profundidade estimada onde a
/// temperatura cai de forma acentuada com a profundidade, mais o perfil
/// vertical completo que embasa essa estimativa e um nível de confiança.
///
/// **Nunca é derivada só da SST dentro do app** — a leitura completa
/// (profundidade da termoclina + confiança) vem sempre pronta de
/// [TermoclinaRepository]/[FonteTermoclina] (hoje um MOCK, ver
/// `fonte_termoclina_mock.dart`; futuramente uma fonte real, ver
/// `fonte_termoclina.dart`), nunca calculada aqui a partir de um único
/// valor de superfície.
///
/// Formato pensado já compatível com uma futura resposta de API real
/// (ver `docs/ANALISE_ADERENCIA_PLANO_COMERCIAL.md`-style contrato em
/// `fonte_termoclina.dart` §10 do pedido que criou esta tela):
/// ```json
/// {
///   "latitude": -2.90, "longitude": -39.65,
///   "timestamp": "2026-09-26T14:32:00",
///   "sst": 28.6, "thermoclineDepth": 48, "confidence": 0.82,
///   "temperatureProfile": [{"depth": 0, "temperature": 28.6}, ...],
///   "source": "mock"
/// }
/// ```
class LeituraTermoclina {
  final double latitude;
  final double longitude;
  final DateTime instante;

  /// Temperatura da superfície do mar (°C) — só o primeiro ponto do
  /// perfil, aqui à parte por conveniência de exibição (card de destaque).
  final double sst;

  /// Profundidade estimada da termoclina, em metros.
  final double profundidadeTermoclina;

  /// Confiança da estimativa, de 0 a 1 — campo fornecido pela fonte de
  /// dados (mock ou, futuramente, o serviço oceanográfico real). Não há
  /// metodologia de cálculo própria do app pra esse número.
  final double confianca;

  /// Perfil vertical completo (profundidade × temperatura), da superfície
  /// pro fundo — usado tanto pro gráfico quanto pra qualquer refinamento
  /// futuro (ex: recalcular a termoclina com um método diferente sem
  /// precisar de uma nova consulta).
  final List<PerfilTemperaturaPonto> perfil;

  /// De onde veio o dado — `'estimado_sst_open_meteo'` hoje (SST real,
  /// perfil/profundidade modelados; ver `FonteTermoclinaEstimada`),
  /// `'mock'` quando totalmente sintético (testes), ou o nome da fonte
  /// real com perfil vertical medido (ex: `'copernicus_marine'`) quando
  /// existir. A UI usa isso pra deixar claro quando o perfil/profundidade
  /// ainda são estimados (ver `TermoclinaScreen`, `perfilEstimado`).
  final String fonte;

  /// Profundidade real do fundo (batimetria, ver `ProfundidadeRepository`)
  /// nesta coordenada, em metros — quando disponível. Usada por
  /// [FonteTermoclinaEstimada] pra nunca estimar uma termoclina ou um
  /// ponto do perfil abaixo do fundo do mar (senão o app mostra, por
  /// exemplo, termoclina a 45m numa área de 13m de profundidade). Nula
  /// quando a consulta de batimetria falhou — nesse caso a estimativa
  /// segue sem esse limite, como antes.
  final double? profundidadeLocalM;

  /// `true` quando [profundidadeTermoclina] foi calculada a partir de um
  /// gradiente real (pontos medidos de [perfil], ver `RfromOceanRepository`)
  /// em vez do modelo estimado de [FonteTermoclinaEstimada]. Independente
  /// de [perfilEstimado]: mesmo com essa profundidade medida, partes do
  /// perfil abaixo do último ponto real continuam estimadas.
  final bool profundidadeTermoclinaMedida;

  const LeituraTermoclina({
    required this.latitude,
    required this.longitude,
    required this.instante,
    required this.sst,
    required this.profundidadeTermoclina,
    required this.confianca,
    required this.perfil,
    required this.fonte,
    this.profundidadeLocalM,
    this.profundidadeTermoclinaMedida = false,
  });

  /// `true` enquanto o perfil vertical/profundidade da termoclina forem
  /// modelados em vez de medidos — ou seja, sempre, até existir uma fonte
  /// com perfil real conectada (`fonte == 'copernicus_marine'` ou
  /// equivalente). Continua `true` mesmo quando a SST de superfície já é
  /// real (ver `FonteTermoclinaEstimada`), porque só ela é medida.
  bool get perfilEstimado => fonte != 'copernicus_marine';

  /// Temperatura interpolada linearmente no nível de [profundidadeTermoclina]
  /// — o "temperatura em profundidade" mostrado no card compacto (diferente
  /// da SST, que é o primeiro ponto do perfil). **Não** é a temperatura do
  /// ponto mais profundo do perfil (esse pode estar bem além da termoclina,
  /// principalmente quando ela vem do modelo estimado) — é a temperatura
  /// exatamente onde a termoclina está, interpolada entre os dois pontos
  /// do perfil mais próximos dessa profundidade (ou o valor do extremo mais
  /// próximo, se [profundidadeTermoclina] cair fora do alcance do perfil).
  double? get temperaturaNaTermoclina {
    if (perfil.isEmpty) return null;
    final ordenado = [...perfil]
      ..sort((a, b) => a.profundidadeM.compareTo(b.profundidadeM));
    final alvo = profundidadeTermoclina;

    if (alvo <= ordenado.first.profundidadeM) return ordenado.first.temperaturaC;
    if (alvo >= ordenado.last.profundidadeM) return ordenado.last.temperaturaC;

    for (var i = 0; i < ordenado.length - 1; i++) {
      final a = ordenado[i];
      final b = ordenado[i + 1];
      if (alvo >= a.profundidadeM && alvo <= b.profundidadeM) {
        final fracao = (b.profundidadeM - a.profundidadeM) == 0
            ? 0.0
            : (alvo - a.profundidadeM) / (b.profundidadeM - a.profundidadeM);
        return a.temperaturaC + (b.temperaturaC - a.temperaturaC) * fracao;
      }
    }
    return ordenado.last.temperaturaC; // inatingível (alvo já foi limitado acima)
  }

  factory LeituraTermoclina.fromJson(Map<String, dynamic> json) {
    return LeituraTermoclina(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      instante: DateTime.parse(json['timestamp'] as String),
      sst: (json['sst'] as num).toDouble(),
      profundidadeTermoclina: (json['thermoclineDepth'] as num).toDouble(),
      confianca: (json['confidence'] as num).toDouble(),
      perfil: (json['temperatureProfile'] as List)
          .map((e) => PerfilTemperaturaPonto.fromJson(e as Map<String, dynamic>))
          .toList(),
      fonte: json['source'] as String? ?? 'mock',
      profundidadeLocalM: (json['localDepth'] as num?)?.toDouble(),
      profundidadeTermoclinaMedida:
          json['thermoclineDepthMedida'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': instante.toIso8601String(),
        'sst': sst,
        'thermoclineDepth': profundidadeTermoclina,
        'confidence': confianca,
        'temperatureProfile': perfil.map((p) => p.toJson()).toList(),
        'source': fonte,
        if (profundidadeLocalM != null) 'localDepth': profundidadeLocalM,
        'thermoclineDepthMedida': profundidadeTermoclinaMedida,
      };
}
