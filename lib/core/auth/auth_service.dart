import 'dart:convert';

import '../config/config.dart';
import '../config/constantes.dart';
import '../network/api_service.dart';
import 'jwt_utils.dart';
import 'models/usuario.dart';

export '../network/excecoes.dart';
export 'models/usuario.dart';

class AuthService {
  static Future<void> login(String usuario, String senha) async {
    await ApiService.login(usuario, senha);
  }

  /// Considera o usuário logado apenas enquanto o token salvo ainda for
  /// válido — usa a claim `exp` do próprio JWT (definida pelo servidor),
  /// então o tempo de sessão do app fica sincronizado com a validade real
  /// do token, sem depender de um cálculo local separado.
  static Future<bool> isLoggedIn() async {
    final token = await Config.obtem(Constantes.authToken);
    if (token.isEmpty) return false;

    try {
      final claims = decodeJwtPayload(token);
      final exp = (claims['exp'] as num?)?.toInt();
      if (exp == null) return true; // sem claim de expiração, assume válido

      final expiraEm = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final valido = DateTime.now().isBefore(expiraEm);

      if (!valido) await logout();
      return valido;
    } catch (_) {
      // Token ilegível/corrompido — mais seguro tratar como não logado.
      return false;
    }
  }

  /// Usuário autenticado no momento, montado a partir da resposta de login
  /// salva localmente. Retorna null se não houver ninguém logado.
  static Future<Usuario?> usuarioLogado() async {
    final bruto = await Config.obtem(Constantes.authCredencial);
    if (bruto.isEmpty) return null;
    return Usuario.fromLoginResponse(jsonDecode(bruto));
  }

  static Future<void> logout() async {
    await Config.limpa(Constantes.authToken);
    await Config.limpa(Constantes.authCredencial);
    await Config.limpa(Constantes.organizacaoId);
  }
}
