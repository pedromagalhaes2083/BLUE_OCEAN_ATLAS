/// Um ponto do perfil vertical de temperatura — profundidade (m) e
/// temperatura (°C) naquele nível. Uma `List<PerfilTemperaturaPonto>`
/// ordenada da superfície pro fundo forma o perfil inteiro mostrado no
/// gráfico da tela de Termoclina (ver `GraficoPerfilTermico`).
class PerfilTemperaturaPonto {
  final double profundidadeM;
  final double temperaturaC;

  const PerfilTemperaturaPonto({
    required this.profundidadeM,
    required this.temperaturaC,
  });

  factory PerfilTemperaturaPonto.fromJson(Map<String, dynamic> json) {
    return PerfilTemperaturaPonto(
      profundidadeM: (json['depth'] as num).toDouble(),
      temperaturaC: (json['temperature'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'depth': profundidadeM,
        'temperature': temperaturaC,
      };
}
