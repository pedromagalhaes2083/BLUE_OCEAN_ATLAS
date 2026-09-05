import 'package:atlas/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:atlas/core/auth/auth_service.dart';
import 'package:atlas/core/config/config.dart';
import 'package:atlas/core/config/constantes.dart';
import 'package:atlas/core/services/contexto_viagem_service.dart';
import 'package:atlas/core/services/location_tracking_service.dart';
import 'package:atlas/core/services/sincronizacao_service.dart';
import 'package:atlas/core/utils/erro_amigavel.dart';
import '../../../app_shell.dart';

class LoginScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const LoginScreen({super.key, required this.dbHelper});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // Sem valor pré-preenchido — uma credencial de demonstração real ficava
  // digitada por padrão aqui, então qualquer pessoa que abrisse o app e
  // tocasse "Entrar" logava numa conta administrativa de verdade
  // (auditoria de 2026-09).
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;
  bool _lembrarCredenciais = false;
  String? _erro;

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _erro = null;
    });

    try {
      await AuthService.login(
        _usuarioController.text.trim(),
        _senhaController.text.trim(),
        lembrar: _lembrarCredenciais,
      );

      // Antes de qualquer chamada que dependa da organização certa
      // (recomendações, dispositivo etc.) — sem isso, o app usava um id
      // fixo de organização de demonstração pra qualquer usuário.
      await _escolherOrganizacaoSeNecessario();
      if (!mounted) return;

      try {
        await SincronizacaoService.sincronizar();
      } catch (e) {
        // Não bloqueia o login — dispositivo/recomendações são dados
        // complementares, buscados de novo depois se falharem aqui.
        debugPrint('Erro ao sincronizar dados do dispositivo: $e');
      }

      // Fluxo login → viagem ativa → embarcação (ver ContextoViagemService):
      // busca a viagem em andamento do usuário no backend e resolve a
      // embarcação a partir dela, antes da checagem puramente local logo
      // abaixo. Best-effort — nunca lança, sem viagem ativa ou erro de
      // backend o app segue com o que já tinha localmente.
      await ContextoViagemService.resolverAoLogar(widget.dbHelper);
      if (!mounted) return;

      // O rastreamento em segundo plano só roda com uma viagem em
      // andamento (ver NovaViagemScreen/HistoricoLocalizacoesScreen) — aqui
      // só retoma se o usuário tinha saído (logout) no meio de uma viagem
      // ainda ativa (local ou, agora, recém-sincronizada do backend acima).
      try {
        final viagensAtivas = await widget.dbHelper.queryWhere(
          'viagem',
          where: 'status = ?',
          whereArgs: ['em_andamento'],
        );
        if (viagensAtivas.isNotEmpty) {
          final intervalo = int.tryParse(await Config.obtem(
                Constantes.intervaloRastreamentoMinutos,
                '$intervaloMinimoMinutos',
              )) ??
              intervaloMinimoMinutos;
          await LocationTrackingService()
              .iniciarRastreamento(intervaloMinutos: intervalo);
        }
      } catch (e) {
        debugPrint('Erro ao retomar rastreamento de localização: $e');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AppShell(dbHelper: widget.dbHelper),
        ),
      );
    } on UnauthorisedException {
      if (!mounted) return;
      setState(() => _erro = 'Usuário ou senha incorretos.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = ehErroDeConexao(e)
          ? mensagemSemConexao
          : 'Erro ao conectar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Busca as organizações do usuário logado e decide a ativa: só uma,
  /// escolhe sozinho; mais de uma, pede pro usuário escolher (diálogo sem
  /// como fechar sem escolher — deixar sem organização selecionada
  /// quebraria as chamadas seguintes). Falha ao buscar (rede etc.) não
  /// bloqueia o login — fica valendo o que já estava salvo antes.
  Future<void> _escolherOrganizacaoSeNecessario() async {
    List<Organizacao> organizacoes;
    try {
      organizacoes = await AuthService.listarMinhasOrganizacoes();
    } catch (e) {
      debugPrint('Erro ao buscar organizações do usuário: $e');
      return;
    }
    if (organizacoes.isEmpty) return;

    if (organizacoes.length == 1) {
      await AuthService.definirOrganizacaoAtiva(organizacoes.first.id);
      return;
    }

    if (!mounted) return;
    final escolhida = await showDialog<Organizacao>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Escolha a organização'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: organizacoes
                .map((org) => ListTile(
                      title: Text(org.nome),
                      onTap: () => Navigator.pop(dialogContext, org),
                    ))
                .toList(),
          ),
        ),
      ),
    );
    if (escolhida != null) {
      await AuthService.definirOrganizacaoAtiva(escolhida.id);
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          // minHeight (não height fixo) — mantém o formulário centralizado
          // verticalmente quando cabe na tela, mas deixa crescer e rolar
          // em vez de estourar quando o conteúdo não cabe (ex: com o
          // checkbox de "lembrar credenciais" em telas mais baixas).
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                48,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/blue_ocean.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Atlas Blue Ocean',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Login do Mestre', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Informe o usuário' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Informe a senha' : null,
                ),
                CheckboxListTile(
                  value: _lembrarCredenciais,
                  onChanged: (v) =>
                      setState(() => _lembrarCredenciais = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Lembrar minhas credenciais'),
                  subtitle: const Text(
                    'Entra automaticamente da próxima vez, até você sair da conta.',
                  ),
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _erro!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _fazerLogin,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ENTRAR', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
