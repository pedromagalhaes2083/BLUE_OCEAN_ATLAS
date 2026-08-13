class PontoMarcado {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime dataCriacao;
  final String? nome;

  const PontoMarcado({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.dataCriacao,
    this.nome,
  });

  factory PontoMarcado.fromMap(Map<String, dynamic> map) {
    return PontoMarcado(
      id: map['id'] as int?,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      dataCriacao: DateTime.parse(map['data_criacao'] as String),
      nome: map['nome'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'data_criacao': dataCriacao.toIso8601String(),
      'nome': nome,
    };
  }
}
