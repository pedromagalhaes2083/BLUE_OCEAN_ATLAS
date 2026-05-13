class Viagem {
  final int id;
  final String? nome;
  final DateTime dataInicio;
  final DateTime? dataTermino;
  final String embarcacaoId;
  final String status; // 'em_andamento' ou 'finalizada'

  Viagem({
    required this.id,
    this.nome,
    required this.dataInicio,
    this.dataTermino,
    required this.embarcacaoId,
    required this.status,
  });

  factory Viagem.fromMap(Map<String, dynamic> map) {
    return Viagem(
      id: map['id'],
      nome: map['nome'],
      dataInicio: DateTime.parse(map['data_inicio']),
      dataTermino: map['data_termino'] != null
          ? DateTime.parse(map['data_termino'])
          : null,
      embarcacaoId: map['embarcacao_id'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'data_inicio': dataInicio.toIso8601String(),
      'data_termino': dataTermino?.toIso8601String(),
      'embarcacao_id': embarcacaoId,
      'status': status,
    };
  }

  bool get isFinalizada => status == 'finalizada';
}
