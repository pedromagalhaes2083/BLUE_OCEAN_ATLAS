import '../classificacao_peso.dart';

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
  final int? viagemId;
  final bool sincronizado;

  /// ID da espécie no catálogo remoto (`base/resultado/especies`, ver
  /// `EspecieRepository`), quando o usuário escolheu uma sugestão do
  /// catálogo em vez de digitar um nome livre — evita ter que resolver por
  /// nome de novo na hora de sincronizar (ver `ProducaoReporterService`).
  /// Nulo em registros com nome digitado livremente ou salvos antes desta
  /// coluna existir; nesses casos a sincronização ainda resolve pelo nome
  /// em [especie].
  final String? especieId;

  /// Faixa de classificação por peso usada para estimar [quantidadeKg]
  /// automaticamente (ver [classificacao_peso.dart]).
  final Classificacao? classificacao;

  /// Quantidade de peixes capturados (unidades), usada junto com
  /// [pesoMedioUnitario] para calcular [quantidadeKg].
  final int? quantidadeUnidades;

  /// Peso médio (kg) por unidade no momento do registro — guardado junto
  /// com o registro para não mudar retroativamente se a tabela de pesos
  /// médios for ajustada depois.
  final double? pesoMedioUnitario;

  /// Acurácia do GPS em metros no momento da captura, quando disponível.
  final double? precisaoMetros;

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
    this.viagemId,
    this.sincronizado = false,
    this.especieId,
    this.classificacao,
    this.quantidadeUnidades,
    this.pesoMedioUnitario,
    this.precisaoMetros,
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
      viagemId: map['viagem_id'],
      sincronizado: map['sincronizado'] == 1,
      especieId: map['especie_id'] as String?,
      classificacao: _classificacaoDoTexto(map['classificacao'] as String?),
      quantidadeUnidades: map['quantidade_unidades'],
      pesoMedioUnitario: map['peso_medio_unitario'],
      precisaoMetros: map['precisao_metros'],
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
      'viagem_id': viagemId,
      'sincronizado': sincronizado ? 1 : 0,
      'especie_id': especieId,
      'classificacao': classificacao?.name,
      'quantidade_unidades': quantidadeUnidades,
      'peso_medio_unitario': pesoMedioUnitario,
      'precisao_metros': precisaoMetros,
    };
  }

  static Classificacao? _classificacaoDoTexto(String? nome) {
    if (nome == null) return null;
    for (final classificacao in Classificacao.values) {
      if (classificacao.name == nome) return classificacao;
    }
    return null;
  }
}
