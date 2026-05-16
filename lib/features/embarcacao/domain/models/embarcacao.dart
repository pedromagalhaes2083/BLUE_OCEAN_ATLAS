class Embarcacao {
  final int? id;
  final String nome;
  final String? dono;
  final int quantidadeUrnas;
  final String? registro;
  final DateTime dataCadastro;
  final bool ativo;

  Embarcacao({
    this.id,
    required this.nome,
    this.dono,
    required this.quantidadeUrnas,
    this.registro,
    required this.dataCadastro,
    this.ativo = true,
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
  }) {
    return Embarcacao(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dono: dono ?? this.dono,
      quantidadeUrnas: quantidadeUrnas ?? this.quantidadeUrnas,
      registro: registro ?? this.registro,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ativo: ativo ?? this.ativo,
    );
  }

  @override
  String toString() {
    return 'Embarcacao(id: $id, nome: $nome, dono: $dono, urnas: $quantidadeUrnas)';
  }
}
