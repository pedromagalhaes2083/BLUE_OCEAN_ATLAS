import '../config/config.dart';
import '../config/constantes.dart';
import '../network/api_service.dart';

export '../network/excecoes.dart';

class AuthService {
  static Future<void> login(String usuario, String senha) async {
    await ApiService.login(usuario, senha);
  }

  static Future<bool> isLoggedIn() async {
    final token = await Config.obtem(Constantes.authToken);
    return token.isNotEmpty;
  }

  static Future<void> logout() async {
    await Config.limpa(Constantes.authToken);
    await Config.limpa(Constantes.authCredencial);
  }
}
