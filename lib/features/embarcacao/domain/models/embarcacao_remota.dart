/// Embarcação como ela existe no catálogo do backend (`base/operacao/embarcacoes`)
/// — cadastrada pela plataforma online, não pelo app. Usado só pra escolher
/// qual embarcação (já existente) fica vinculada a este dispositivo/mestre;
/// não confundir com [Embarcacao] (config local de capacidade/tripulação).
class EmbarcacaoRemota {
  final String id;
  final String nome;
  final String? codigo;
  final String? sigla;
  final int? status;

  EmbarcacaoRemota({
    required this.id,
    required this.nome,
    this.codigo,
    this.sigla,
    this.status,
  });

  factory EmbarcacaoRemota.fromJson(Map<String, dynamic> json) {
    return EmbarcacaoRemota(
      id: json['id'] as String,
      nome: json['nome'] as String? ?? '(sem nome)',
      codigo: json['codigo'] as String?,
      sigla: json['sigla'] as String?,
      status: (json['status'] as num?)?.toInt(),
    );
  }
}
