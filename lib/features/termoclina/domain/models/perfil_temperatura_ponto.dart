/// Um ponto do perfil vertical de temperatura — profundidade (m) e
/// temperatura (°C) naquele nível. Uma `List<PerfilTemperaturaPonto>`
/// ordenada da superfície pro fundo forma o perfil inteiro mostrado no
/// gráfico da tela de Termoclina (ver `GraficoPerfilTermico`).
class PerfilTemperaturaPonto {
  final double profundidadeM;
  final double temperaturaC;

  /// `true` quando este ponto veio de uma medição/reanálise real (hoje: o
  /// mapa global RFROM v2.3 da NOAA/PMEL, derivado de bóias Argo — ver
  /// `RfromOceanRepository`), em vez de estimado pelo modelo interno de
  /// [FonteTermoclinaEstimada]. Usado pra diferenciar visualmente pontos
  /// reais dos estimados no gráfico (ver `GraficoPerfilTermico`).
  final bool medido;

  const PerfilTemperaturaPonto({
    required this.profundidadeM,
    required this.temperaturaC,
    this.medido = false,
  });

  factory PerfilTemperaturaPonto.fromJson(Map<String, dynamic> json) {
    return PerfilTemperaturaPonto(
      profundidadeM: (json['depth'] as num).toDouble(),
      temperaturaC: (json['temperature'] as num).toDouble(),
      medido: json['medido'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'depth': profundidadeM,
        'temperature': temperaturaC,
        'medido': medido,
      };
}
