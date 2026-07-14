import '../jwt_utils.dart';

/// Usuário autenticado, montado a partir da resposta de login
/// (`{accessToken, usuario: {id, email, nome}}`) combinada com as claims
/// do próprio JWT (organizacaoId, empresaId), que não vêm no corpo.
class Usuario {
  final String id;
  final String email;
  final String nome;
  final String? organizacaoId;
  final String? empresaId;

  const Usuario({
    required this.id,
    required this.email,
    required this.nome,
    this.organizacaoId,
    this.empresaId,
  });

  factory Usuario.fromLoginResponse(Map<String, dynamic> json) {
    final dados = json['usuario'] as Map<String, dynamic>? ?? const {};
    final claims = decodeJwtPayload(json['accessToken'] as String? ?? '');

    return Usuario(
      id: (dados['id'] ?? claims['usuarioId'] ?? '') as String,
      email: (dados['email'] ?? '') as String,
      nome: (dados['nome'] ?? '') as String,
      organizacaoId: claims['organizacaoId'] as String?,
      empresaId: claims['empresaId'] as String?,
    );
  }

  @override
  String toString() => 'Usuario(id: $id, email: $email, nome: $nome)';
}
