/// Uma organização que o usuário logado participa — resposta de
/// `GET autenticacao/eu/organizacoes`:
/// ```json
/// {"organizacoes": [{"id": "...", "nome": "...", "documento": null}]}
/// ```
class Organizacao {
  final String id;
  final String nome;
  final String? documento;

  const Organizacao({
    required this.id,
    required this.nome,
    this.documento,
  });

  factory Organizacao.fromJson(Map<String, dynamic> json) {
    return Organizacao(
      id: json['id'] as String,
      nome: json['nome'] as String? ?? '',
      documento: json['documento'] as String?,
    );
  }
}
