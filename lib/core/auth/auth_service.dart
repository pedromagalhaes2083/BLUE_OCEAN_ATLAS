import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/config.dart';
import '../config/constantes.dart';
import '../network/api_service.dart';
import 'jwt_utils.dart';
import 'models/usuario.dart';

export '../network/excecoes.dart';
export 'models/usuario.dart';

class AuthService {
  static const _secureStorage = FlutterSecureStorage();
  static const _chaveUsuarioLembrado = 'credencial_usuario';
  static const _chaveSenhaLembrada = 'credencial_senha';

  /// Se [lembrar] for true, salva usuário/senha de forma segura (Keychain/
  /// Keystore via `flutter_secure_storage`) para permitir login automático
  /// depois — ver [tentarLoginAutomatico]. Se false, garante que nenhuma
  /// credencial antiga tenha ficado salva.
  static Future<void> login(
    String usuario,
    String senha, {
    bool lembrar = false,
  }) async {
    await ApiService.login(usuario, senha);
    if (lembrar) {
      await _secureStorage.write(key: _chaveUsuarioLembrado, value: usuario);
      await _secureStorage.write(key: _chaveSenhaLembrada, value: senha);
      await Config.grava(Constantes.lembrarCredenciais, 'true');
    } else {
      await _limparCredenciaisLembradas();
    }
  }

  static Future<bool> lembrarCredenciaisAtivo() async {
    return (await Config.obtem(Constantes.lembrarCredenciais)) == 'true';
  }

  /// Tenta logar de novo com a credencial salva (quando "lembrar" estava
  /// marcado), sem exigir que o usuário digite usuário/senha de novo — usado
  /// no boot do app quando o token salvo já expirou. Retorna se conseguiu.
  static Future<bool> tentarLoginAutomatico() async {
    if (!await lembrarCredenciaisAtivo()) return false;

    final usuario = await _secureStorage.read(key: _chaveUsuarioLembrado);
    final senha = await _secureStorage.read(key: _chaveSenhaLembrada);
    if (usuario == null || senha == null) return false;

    try {
      await login(usuario, senha, lembrar: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _limparCredenciaisLembradas() async {
    await _secureStorage.delete(key: _chaveUsuarioLembrado);
    await _secureStorage.delete(key: _chaveSenhaLembrada);
    await Config.limpa(Constantes.lembrarCredenciais);
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
    await _limparCredenciaisLembradas();
  }
}
