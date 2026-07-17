import 'package:flutter/material.dart';

/// Taxonomia das variáveis ambientais amostradas nos pontos de uma
/// recomendação, confirmada com o backend.
enum VariavelAmbiental {
  vento(1, 'Vento', Icons.air, 'nós'),
  corrente(2, 'Corrente', Icons.water, 'nós'),
  clorofila(3, 'Clorofila', Icons.eco, 'mg/m³'),
  onda(4, 'Onda', Icons.waves, 'm'),
  temperatura(5, 'Temperatura', Icons.thermostat, '°C');

  final int codigo;
  final String label;
  final IconData icone;
  final String unidade;

  const VariavelAmbiental(this.codigo, this.label, this.icone, this.unidade);

  static VariavelAmbiental? fromCodigo(int codigo) {
    for (final v in VariavelAmbiental.values) {
      if (v.codigo == codigo) return v;
    }
    return null;
  }
}

/// Uma variável ambiental amostrada em um ponto da recomendação.
class VariavelValor {
  final double valor;
  final int variavel;

  const VariavelValor({required this.valor, required this.variavel});

  VariavelAmbiental? get tipo => VariavelAmbiental.fromCodigo(variavel);

  factory VariavelValor.fromJson(Map<String, dynamic> json) {
    return VariavelValor(
      valor: (json['valor'] as num).toDouble(),
      variavel: (json['variavel'] as num).toInt(),
    );
  }
}

class PontoRecomendacao {
  final double latitude;
  final double longitude;
  final List<VariavelValor> variaveis;

  const PontoRecomendacao({
    required this.latitude,
    required this.longitude,
    required this.variaveis,
  });

  factory PontoRecomendacao.fromJson(Map<String, dynamic> json) {
    return PontoRecomendacao(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      variaveis: (json['variaveis'] as List? ?? [])
          .map((e) => VariavelValor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Centroide {
  final double latitude;
  final double longitude;

  const Centroide({required this.latitude, required this.longitude});

  factory Centroide.fromJson(Map<String, dynamic> json) {
    return Centroide(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

/// Recomendação de pesca/navegação retornada pela API, vinda de
/// `base/inteligencia/recomendacoes`.
class Recomendacao {
  final String id;
  final String organizacaoId;
  final int tipo;
  final String titulo;
  final String? descricao;
  final num score;
  final int confianca;
  final int status;
  final Centroide? centroide;
  final num? estimativaCapturaKg;
  final DateTime? criadoEm;
  final DateTime? validoAte;
  final String? motivoRejeicao;
  final String? cartaNauticaUrl;
  final List<PontoRecomendacao>? pontos;

  const Recomendacao({
    required this.id,
    required this.organizacaoId,
    required this.tipo,
    required this.titulo,
    this.descricao,
    required this.score,
    required this.confianca,
    required this.status,
    this.centroide,
    this.estimativaCapturaKg,
    this.criadoEm,
    this.validoAte,
    this.motivoRejeicao,
    this.cartaNauticaUrl,
    this.pontos,
  });

  factory Recomendacao.fromJson(Map<String, dynamic> json) {
    return Recomendacao(
      id: json['id'] as String,
      organizacaoId: json['organizacaoId'] as String,
      tipo: (json['tipo'] as num?)?.toInt() ?? 0,
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String?,
      score: (json['score'] as num?) ?? 0,
      confianca: (json['confianca'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      centroide: json['centroide'] != null
          ? Centroide.fromJson(json['centroide'] as Map<String, dynamic>)
          : null,
      estimativaCapturaKg: json['estimativaCapturaKg'] as num?,
      criadoEm: json['criadoEm'] != null
          ? DateTime.tryParse(json['criadoEm'] as String)
          : null,
      validoAte: json['validoAte'] != null
          ? DateTime.tryParse(json['validoAte'] as String)
          : null,
      motivoRejeicao: json['motivoRejeicao'] as String?,
      cartaNauticaUrl: json['cartaNauticaUrl'] as String?,
      pontos: json['pontos'] != null
          ? (json['pontos'] as List)
              .map((e) => PontoRecomendacao.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Se há coordenadas para exibir num mapa (pontos amostrados ou, na
  /// falta deles, o centroide).
  bool get temCoordenadas =>
      (pontos != null && pontos!.isNotEmpty) || centroide != null;
}
