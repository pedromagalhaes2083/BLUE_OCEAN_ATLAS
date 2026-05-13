import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService._internal();

  // Chaves de armazenamento
  static const String _keyUser = 'user_logged';
  static const String _keyMestreNome = 'mestre_nome';
  static const String _keyEmbarcacao = 'embarcacao_id';

  // Login simples (pode ser substituído por API no futuro)
  Future<bool> login(String usuario, String senha) async {
    // Validação simples (pode mudar depois para banco ou API)
    if (usuario == "mestre" && senha == "1234") {
      await _storage.write(key: _keyUser, value: "true");
      await _storage.write(key: _keyMestreNome, value: "Mestre João");
      await _storage.write(key: _keyEmbarcacao, value: "PE-1234");
      return true;
    }
    return false;
  }

  Future<bool> isLoggedIn() async {
    final logged = await _storage.read(key: _keyUser);
    return logged == "true";
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<String?> getMestreNome() async {
    return await _storage.read(key: _keyMestreNome);
  }

  Future<String?> getEmbarcacaoId() async {
    return await _storage.read(key: _keyEmbarcacao);
  }
}
