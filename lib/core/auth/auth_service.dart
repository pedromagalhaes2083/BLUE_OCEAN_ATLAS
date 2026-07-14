import 'dart:convert';

import '../config/config.dart';
import '../config/constantes.dart';
import '../network/api_service.dart';
import 'models/usuario.dart';

export '../network/excecoes.dart';
export 'models/usuario.dart';

class AuthService {
  static Future<void> login(String usuario, String senha) async {
    await ApiService.login(usuario, senha);
  }

  static Future<bool> isLoggedIn() async {
    final token = await Config.obtem(Constantes.authToken);
    return token.isNotEmpty;
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
