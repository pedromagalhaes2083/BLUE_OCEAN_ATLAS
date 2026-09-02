import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/config.dart';
import '../config/constantes.dart';
import '../database/database_helper.dart';
import '../network/api_service.dart';
import '../network/endpoints.dart';
import '../services/location_tracking_service.dart';
import 'jwt_utils.dart';
import 'models/organizacao.dart';
import 'models/usuario.dart';

export '../network/excecoes.dart';
export 'models/organizacao.dart';
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
    await _tratarTrocaDeUsuario();
    if (lembrar) {
      await _secureStorage.write(key: _chaveUsuarioLembrado, value: usuario);
      await _secureStorage.write(key: _chaveSenhaLembrada, value: senha);
      await Config.grava(Constantes.lembrarCredenciais, 'true');
    } else {
      await _limparCredenciaisLembradas();
    }
  }

  /// Compara o usuário que acabou de logar com o do último login salvo —
  /// diferente, apaga os dados locais do usuário anterior (pontos
  /// marcados, rotas planejadas, produção, viagens e a configuração de
  /// embarcação): o app é local-first e nada dessas tabelas tem coluna de
  /// usuário/organização, então sem essa limpeza um segundo mestre
  /// logando no mesmo aparelho herdaria os dados do primeiro. Primeiro
  /// login do aparelho (nada salvo ainda) não limpa nada, só grava.
  static Future<void> _tratarTrocaDeUsuario() async {
    final usuarioAtual = await usuarioLogado();
    final novoId = usuarioAtual?.id ?? '';
    if (novoId.isEmpty) return;

    final idAnterior = await Config.obtem(Constantes.ultimoUsuarioId);
    if (deveLimparAoTrocarUsuario(idAnterior, novoId)) {
      await _limparDadosLocaisDoUsuarioAnterior();
    }
    await Config.grava(Constantes.ultimoUsuarioId, novoId);
  }

  /// Decisão pura (sem I/O) usada por [_tratarTrocaDeUsuario] — separada
  /// só pra dar pra testar sem precisar simular login/Config/SQLite.
  /// `idAnterior` vazio (primeiro login do aparelho, nada salvo ainda)
  /// nunca limpa; `novoId` vazio (resposta de login sem id extraível)
  /// também nunca limpa, pra não apagar dados por engano num caso
  /// inesperado da API.
  @visibleForTesting
  static bool deveLimparAoTrocarUsuario(String idAnterior, String novoId) {
    if (novoId.isEmpty || idAnterior.isEmpty) return false;
    return idAnterior != novoId;
  }

  static Future<void> _limparDadosLocaisDoUsuarioAnterior() async {
    debugPrint('🔄 Usuário diferente do último login — limpando dados locais');
    try {
      await LocationTrackingService().pararRastreamento();
    } catch (e) {
      debugPrint('❌ Erro ao parar rastreamento na troca de usuário: $e');
    }

    const tabelas = [
      'rota_planejada_ponto',
      'rota_planejada',
      'producao_registro',
      'localizacao_historico',
      'viagem',
      'ponto_marcado',
      'embarcacao',
    ];
    for (final tabela in tabelas) {
      try {
        await DatabaseHelper.instance.deleteWhere(tabela, where: '1 = 1');
      } catch (e) {
        debugPrint('❌ Erro ao limpar "$tabela" na troca de usuário: $e');
      }
    }

    await Config.limpa(Constantes.embarcacaoId);
    await Config.limpa(Constantes.cacheRecomendacoes);
    await Config.limpa(Constantes.cacheRecomendacoesEm);
    await Config.limpa(Constantes.ultimaVerificacaoRecomendacoes);
  }

  static Future<bool> lembrarCredenciaisAtivo() async {
    return (await Config.obtem(Constantes.lembrarCredenciais)) == 'true';
  }

  /// Organizações que o usuário logado participa — chamado logo após o
  /// login pra decidir qual fica ativa (ver [Constantes.organizacaoId]).
  /// Sem essa escolha, [ApiService] usava um id fixo de organização de
  /// demonstração pra qualquer usuário, então quem participasse de outra
  /// organização tinha as chamadas da API todas apontando pro lugar errado.
  static Future<List<Organizacao>> listarMinhasOrganizacoes() async {
    final json = await ApiService.get(Endpoints.euOrganizacoes);
    final lista = (json as Map<String, dynamic>)['organizacoes'] as List? ?? [];
    return lista
        .map((e) => Organizacao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Grava qual organização fica ativa pro resto da sessão — é o que
  /// [ApiService] manda no header `x-organization-id` de toda chamada
  /// autenticada a partir de agora.
  static Future<void> definirOrganizacaoAtiva(String organizacaoId) async {
    await Config.grava(Constantes.organizacaoId, organizacaoId);
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

      // Só derruba a sessão (token/credencial), não a credencial "lembrada"
      // — se fosse `logout()` aqui, apagaria usuário/senha do
      // flutter_secure_storage um instante antes de quem chamou
      // [isLoggedIn] tentar [tentarLoginAutomatico] com ela (ver
      // SplashScreen), fazendo o login automático falhar sempre, mesmo
      // com internet. O mesmo valia pra retentativa de 401 em
      // [ApiService._comRetentativaDeAutenticacao] no meio de qualquer
      // chamada — qualquer token expirado por perto derrubava a
      // credencial lembrada antes dela poder ser reusada.
      if (!valido) await _limparSessao();
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

  /// Só a sessão atual (token/credencial/organização) — mantém a
  /// credencial "lembrada" intacta, pra login automático continuar
  /// funcionando depois. Ver [isLoggedIn].
  static Future<void> _limparSessao() async {
    await Config.limpa(Constantes.authToken);
    await Config.limpa(Constantes.authCredencial);
    await Config.limpa(Constantes.organizacaoId);
  }

  /// Logout explícito (botão "Sair") — sessão + credencial lembrada.
  static Future<void> logout() async {
    await _limparSessao();
    await _limparCredenciaisLembradas();
  }
}
