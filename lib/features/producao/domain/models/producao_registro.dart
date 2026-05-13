class ProducaoRegistro {
  final int id;
  final String embarcacaoId;
  final DateTime dataHora;
  final String especie;
  final double quantidadeKg;
  final double? latitude;
  final double? longitude;
  final String? cartaCodigo;
  final String? observacao;
  final bool sincronizado;

  ProducaoRegistro({
    required this.id,
    required this.embarcacaoId,
    required this.dataHora,
    required this.especie,
    required this.quantidadeKg,
    this.latitude,
    this.longitude,
    this.cartaCodigo,
    this.observacao,
    this.sincronizado = false,
  });

  factory ProducaoRegistro.fromMap(Map<String, dynamic> map) {
    return ProducaoRegistro(
      id: map['id'],
      embarcacaoId: map['embarcacao_id'],
      dataHora: DateTime.parse(map['data_hora']),
      especie: map['especie'],
      quantidadeKg: map['quantidade_kg'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      cartaCodigo: map['carta_codigo'],
      observacao: map['observacao'],
      sincronizado: map['sincronizado'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'embarcacao_id': embarcacaoId,
      'data_hora': dataHora.toIso8601String(),
      'especie': especie,
      'quantidade_kg': quantidadeKg,
      'latitude': latitude,
      'longitude': longitude,
      'carta_codigo': cartaCodigo,
      'observacao': observacao,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }
}
