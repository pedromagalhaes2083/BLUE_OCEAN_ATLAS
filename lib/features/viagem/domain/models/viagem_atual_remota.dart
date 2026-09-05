/// Viagem ativa do usuário logado, como o backend devolve em
/// `GET base/operacao/viagens/eu/atual` (ver [ViagemRepository.buscarAtual]).
///
/// Formato confirmado com resposta real em 2026-09 (curl com token válido,
/// depois do 422 anterior ter sido corrigido no backend): o objeto da
/// viagem vem *dentro* de uma chave `viagem` (`{"viagem": {...}}`), não solto
/// na raiz — [fromJson] desembrulha isso automaticamente se presente. Os
/// nomes de campo internos batem com o que `ViagemRepository.criar()` já
/// manda (`embarcacaoId`, `inicioPrevisto`, `fimPrevisto`); mantém as
/// variações alternativas (`dataInicio`, `viagemId` etc.) como tolerância
/// extra, sem depender delas. Só [id] e [embarcacaoId] são obrigatórios pra
/// esse objeto fazer sentido pro fluxo login → viagem ativa → embarcação —
/// os outros campos são só pra popular o registro local (ver
/// `ContextoViagemService`).
class ViagemAtualRemota {
  final String id;
  final String embarcacaoId;
  final String? nome;
  final String? portoOrigemId;
  final String? portoDestinoId;
  final DateTime? dataInicio;
  final DateTime? dataTermino;

  const ViagemAtualRemota({
    required this.id,
    required this.embarcacaoId,
    this.nome,
    this.portoOrigemId,
    this.portoDestinoId,
    this.dataInicio,
    this.dataTermino,
  });

  factory ViagemAtualRemota.fromJson(Map<String, dynamic> json) {
    // A resposta real vem como {"viagem": {...}} — desembrulha antes de
    // procurar os campos abaixo (ver nota da classe).
    final envelope = json['viagem'];
    final corpo = envelope is Map<String, dynamic> ? envelope : json;

    final id = corpo['id'] ?? corpo['viagemId'];
    final embarcacaoId = corpo['embarcacaoId'] ?? corpo['embarcacao_id'];
    if (id == null || embarcacaoId == null) {
      throw FormatException(
          'Resposta de viagem atual sem id ou embarcacaoId: $json');
    }

    DateTime? tentarData(dynamic valor) {
      if (valor is! String || valor.isEmpty) return null;
      return DateTime.tryParse(valor);
    }

    return ViagemAtualRemota(
      id: id as String,
      embarcacaoId: embarcacaoId as String,
      nome: corpo['nome'] as String?,
      portoOrigemId: corpo['portoOrigemId'] as String?,
      portoDestinoId: corpo['portoDestinoId'] as String?,
      dataInicio: tentarData(corpo['dataInicio'] ?? corpo['inicioPrevisto']),
      dataTermino: tentarData(corpo['dataTermino'] ?? corpo['fimPrevisto']),
    );
  }
}
