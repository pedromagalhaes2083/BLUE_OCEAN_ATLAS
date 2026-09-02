/// Espécie como ela existe no catálogo do backend
/// (`base/resultado/especies`) — cadastrada pela plataforma online, não
/// pelo app (mesmo padrão de `EmbarcacaoRemota`).
class EspecieRemota {
  final String id;
  final String nome;
  final String? nomeCientifico;

  EspecieRemota({
    required this.id,
    required this.nome,
    this.nomeCientifico,
  });

  factory EspecieRemota.fromJson(Map<String, dynamic> json) {
    return EspecieRemota(
      id: json['id'] as String,
      nome: json['nome'] as String? ?? '(sem nome)',
      nomeCientifico: json['nomeCientifico'] as String?,
    );
  }
}
