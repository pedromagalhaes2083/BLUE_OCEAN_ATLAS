import 'package:latlong2/latlong.dart';

class RotaPlanejada {
  final int? id;
  final String nome;
  final DateTime dataCriacao;
  final List<LatLng> pontos;

  const RotaPlanejada({
    this.id,
    required this.nome,
    required this.dataCriacao,
    required this.pontos,
  });

  factory RotaPlanejada.fromMap(
    Map<String, dynamic> map, {
    required List<LatLng> pontos,
  }) {
    return RotaPlanejada(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      dataCriacao: DateTime.parse(map['data_criacao'] as String),
      pontos: pontos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'data_criacao': dataCriacao.toIso8601String(),
    };
  }
}
