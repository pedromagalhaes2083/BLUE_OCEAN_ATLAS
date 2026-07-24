import 'package:atlas/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:atlas/core/auth/auth_service.dart';
import 'package:atlas/core/services/location_tracking_service.dart';
import 'package:atlas/core/services/sincronizacao_service.dart';
import '../../../app_shell.dart';

class LoginScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const LoginScreen({super.key, required this.dbHelper});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController(text: 'admin@blueocean.io');
  final _senhaController = TextEditingController(text: 'SuperSecret123!');
  bool _isLoading = false;
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
      );

      try {
        await SincronizacaoService.sincronizar();
      } catch (e) {
        // Não bloqueia o login — dispositivo/recomendações são dados
        // complementares, buscados de novo depois se falharem aqui.
        debugPrint('Erro ao sincronizar dados do dispositivo: $e');
      }

      try {
        await LocationTrackingService().startEnviarLocalizacaoParaApi();
      } catch (e) {
        debugPrint('Erro ao iniciar envio periódico de localização: $e');
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
      setState(() => _erro = 'Erro ao conectar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              48,
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
                    border: OutlineInputBorder(),
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
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) => v?.isEmpty == true ? 'Informe a senha' : null,
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
