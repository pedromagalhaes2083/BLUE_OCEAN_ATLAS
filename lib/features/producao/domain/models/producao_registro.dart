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

  /// Tipo do peixe capturado (Kihada/Bati). Nulo em registros antigos,
  /// salvos antes da classificação por tipo/faixa existir.
  final TipoPeixe? tipoPeixe;

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
    this.tipoPeixe,
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
      tipoPeixe: _tipoPeixeDoTexto(map['tipo_peixe'] as String?),
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
      'tipo_peixe': tipoPeixe?.name,
      'classificacao': classificacao?.name,
      'quantidade_unidades': quantidadeUnidades,
      'peso_medio_unitario': pesoMedioUnitario,
      'precisao_metros': precisaoMetros,
    };
  }

  static TipoPeixe? _tipoPeixeDoTexto(String? nome) {
    if (nome == null) return null;
    for (final tipo in TipoPeixe.values) {
      if (tipo.name == nome) return tipo;
    }
    return null;
  }

  static Classificacao? _classificacaoDoTexto(String? nome) {
    if (nome == null) return null;
    for (final classificacao in Classificacao.values) {
      if (classificacao.name == nome) return classificacao;
    }
    return null;
  }
}
