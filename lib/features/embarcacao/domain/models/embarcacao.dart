class Embarcacao {
  final int? id;
  final String nome;
  final String? dono;
  final int quantidadeUrnas;
  final String? registro;
  final DateTime dataCadastro;
  final bool ativo;
  final double? capacidadeGeloKg;
  final double? capacidadeDieselLitros;
  final int? numeroTripulantes;
  final String? mestreId;
  final String? motorUsado;
  final String? foto;

  Embarcacao({
    this.id,
    required this.nome,
    this.dono,
    required this.quantidadeUrnas,
    this.registro,
    required this.dataCadastro,
    this.ativo = true,
    this.capacidadeGeloKg,
    this.capacidadeDieselLitros,
    this.numeroTripulantes,
    this.mestreId,
    this.motorUsado,
    this.foto,
  });

  // ====================== fromMap (do banco) ======================
  factory Embarcacao.fromMap(Map<String, dynamic> map) {
    return Embarcacao(
      id: map['id'],
      nome: map['nome'],
      dono: map['dono'],
      quantidadeUrnas: map['quantidade_urnas'] ?? 1,
      registro: map['registro'],
      dataCadastro: DateTime.parse(map['data_cadastro']),
      ativo: map['ativo'] == 1 || map['ativo'] == true,
      capacidadeGeloKg: (map['capacidade_gelo_kg'] as num?)?.toDouble(),
      capacidadeDieselLitros:
          (map['capacidade_diesel_litros'] as num?)?.toDouble(),
      numeroTripulantes: map['numero_tripulantes'],
      mestreId: map['mestre_id'],
      motorUsado: map['motor_usado'],
      foto: map['foto'],
    );
  }

  // ====================== toMap (para salvar no banco) ======================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'dono': dono,
      'quantidade_urnas': quantidadeUrnas,
      'registro': registro?.toUpperCase(),
      'data_cadastro': dataCadastro.toIso8601String(),
      'ativo': ativo ? 1 : 0,
      'capacidade_gelo_kg': capacidadeGeloKg,
      'capacidade_diesel_litros': capacidadeDieselLitros,
      'numero_tripulantes': numeroTripulantes,
      'mestre_id': mestreId,
      'motor_usado': motorUsado,
      'foto': foto,
    };
  }

  // ====================== CopyWith ======================
  Embarcacao copyWith({
    int? id,
    String? nome,
    String? dono,
    int? quantidadeUrnas,
    String? registro,
    DateTime? dataCadastro,
    bool? ativo,
    double? capacidadeGeloKg,
    double? capacidadeDieselLitros,
    int? numeroTripulantes,
    String? mestreId,
    String? motorUsado,
    String? foto,
  }) {
    return Embarcacao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dono: dono ?? this.dono,
      quantidadeUrnas: quantidadeUrnas ?? this.quantidadeUrnas,
      registro: registro ?? this.registro,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ativo: ativo ?? this.ativo,
      capacidadeGeloKg: capacidadeGeloKg ?? this.capacidadeGeloKg,
      capacidadeDieselLitros:
          capacidadeDieselLitros ?? this.capacidadeDieselLitros,
      numeroTripulantes: numeroTripulantes ?? this.numeroTripulantes,
      mestreId: mestreId ?? this.mestreId,
      motorUsado: motorUsado ?? this.motorUsado,
      foto: foto ?? this.foto,
    );
  }

  @override
  String toString() {
    return 'Embarcacao(id: $id, nome: $nome, dono: $dono, urnas: $quantidadeUrnas)';
  }
}
