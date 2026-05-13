class CartaNautica {
  final int id;
  final String codigo;
  final String nome;
  final String urlS3;
  final String? caminhoLocal;
  final DateTime dataPublicacao;
  final DateTime dataAtualizacao;
  final bool estaBaixada;

  CartaNautica({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.urlS3,
    this.caminhoLocal,
    required this.dataPublicacao,
    required this.dataAtualizacao,
    this.estaBaixada = false,
  });

  // Converte do Map (do banco) para objeto
  factory CartaNautica.fromMap(Map<String, dynamic> map) {
    return CartaNautica(
      id: map['id'],
      codigo: map['codigo'],
      nome: map['nome'],
      urlS3: map['url_s3'],
      caminhoLocal: map['caminho_local'],
      dataPublicacao: DateTime.parse(map['data_publicacao']),
      dataAtualizacao: DateTime.parse(map['data_atualizacao']),
      estaBaixada: map['esta_baixada'] == 1,
    );
  }

  // Converte objeto para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'nome': nome,
      'url_s3': urlS3,
      'caminho_local': caminhoLocal,
      'data_publicacao': dataPublicacao.toIso8601String(),
      'data_atualizacao': dataAtualizacao.toIso8601String(),
      'esta_baixada': estaBaixada ? 1 : 0,
    };
  }
}
