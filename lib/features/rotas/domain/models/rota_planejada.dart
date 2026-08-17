import 'package:latlong2/latlong.dart';

class RotaPlanejada {
  final int? id;
  final String nome;
  final DateTime dataCriacao;
  final List<LatLng> pontos;

  /// Embarcação/viagem de origem, quando a rota vem de registros de
  /// produção (ver `MapaWidget._salvarRotaDeProducao`) em vez de ter sido
  /// desenhada à mão — nulos numa rota desenhada manualmente.
  final String? embarcacaoId;
  final int? viagemId;

  const RotaPlanejada({
    this.id,
    required this.nome,
    required this.dataCriacao,
    required this.pontos,
    this.embarcacaoId,
    this.viagemId,
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
      embarcacaoId: map['embarcacao_id'] as String?,
      viagemId: map['viagem_id'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'data_criacao': dataCriacao.toIso8601String(),
      'embarcacao_id': embarcacaoId,
      'viagem_id': viagemId,
    };
  }
}
