/// Embarcação como ela existe no catálogo do backend (`base/operacao/embarcacoes`)
/// — cadastrada pela plataforma online, não pelo app. Usado tanto pra listar
/// o catálogo (escolha antiga, hoje só diagnóstico) quanto pra resolver a
/// embarcação da viagem ativa por id (ver [EmbarcacaoRepository.buscarPorId]
/// e `ContextoViagemService`); não confundir com [Embarcacao] (linha local
/// espelhada na tabela `embarcacao`, que é o que as telas leem).
class EmbarcacaoRemota {
  final String id;
  final String nome;
  final String? codigo;
  final String? sigla;
  final int? status;
  final String? dono;
  final int? quantidadeUrnas;
  final String? registro;

  EmbarcacaoRemota({
    required this.id,
    required this.nome,
    this.codigo,
    this.sigla,
    this.status,
    this.dono,
    this.quantidadeUrnas,
    this.registro,
  });

  factory EmbarcacaoRemota.fromJson(Map<String, dynamic> json) {
    return EmbarcacaoRemota(
      id: json['id'] as String,
      nome: json['nome'] as String? ?? '(sem nome)',
      codigo: json['codigo'] as String?,
      sigla: json['sigla'] as String?,
      status: (json['status'] as num?)?.toInt(),
      dono: json['dono'] as String?,
      quantidadeUrnas: (json['quantidadeUrnas'] as num?)?.toInt(),
      registro: json['registro'] as String?,
    );
  }
}
