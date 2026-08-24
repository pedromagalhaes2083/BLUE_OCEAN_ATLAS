import '../../../../core/utils/mare_harmonica.dart';

/// Um porto salvo pelo usuário pra consulta de maré offline (ex: "Itarema",
/// "Acaraú", "Camocim") — nome + coordenada + o modelo harmônico ajustado
/// da última sincronização (nulo até a 1ª sincronização bem-sucedida).
class PortoMare {
  final int? id;
  final String nome;
  final double latitude;
  final double longitude;
  final DateTime dataCriacao;
  final ModeloMareHarmonico? modelo;
  final DateTime? sincronizadoEm;

  const PortoMare({
    this.id,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.dataCriacao,
    this.modelo,
    this.sincronizadoEm,
  });

  bool get temModeloOffline => modelo != null;

  PortoMare copyWith({
    ModeloMareHarmonico? modelo,
    DateTime? sincronizadoEm,
  }) {
    return PortoMare(
      id: id,
      nome: nome,
      latitude: latitude,
      longitude: longitude,
      dataCriacao: dataCriacao,
      modelo: modelo ?? this.modelo,
      sincronizadoEm: sincronizadoEm ?? this.sincronizadoEm,
    );
  }

  factory PortoMare.fromMap(Map<String, dynamic> map) {
    final constantesJson = map['constantes_json'] as String?;
    return PortoMare(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      dataCriacao: DateTime.parse(map['data_criacao'] as String),
      modelo: constantesJson != null
          ? ModeloMareHarmonico.fromJsonString(constantesJson)
          : null,
      sincronizadoEm: map['sincronizado_em'] != null
          ? DateTime.parse(map['sincronizado_em'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'latitude': latitude,
      'longitude': longitude,
      'data_criacao': dataCriacao.toIso8601String(),
      'constantes_json': modelo?.toJsonString(),
      'sincronizado_em': sincronizadoEm?.toIso8601String(),
    };
  }
}
