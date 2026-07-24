/// Uma leitura de elevação/profundidade num ponto (GEBCO2020, via
/// OpenTopoData). `elevacao` negativa = abaixo do nível do mar
/// (profundidade); positiva ou zero = terra/elevação.
class LeituraProfundidade {
  final double latitude;
  final double longitude;
  final double elevacao; // metros; negativo = profundidade

  const LeituraProfundidade({
    required this.latitude,
    required this.longitude,
    required this.elevacao,
  });

  /// true se o ponto está debaixo d'água.
  bool get emAgua => elevacao < 0;

  /// Profundidade em metros (sempre positiva). Só faz sentido se [emAgua]
  /// — em terra retorna 0.
  double get profundidadeMetros => emAgua ? -elevacao : 0;

  factory LeituraProfundidade.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    return LeituraProfundidade(
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
      elevacao: (json['elevation'] as num).toDouble(),
    );
  }
}
