import 'package:atlas/core/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:atlas/core/auth/auth_service.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const LoginScreen({super.key, required this.dbHelper});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController(text: "mestre");
  final _senhaController = TextEditingController(text: "1234");
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = AuthService.instance;
    final success = await auth.login(
      _usuarioController.text.trim(),
      _senhaController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(dbHelper: widget.dbHelper),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha incorretos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_boat, size: 100, color: Colors.blue),
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
                validator: (value) =>
                    value?.isEmpty == true ? 'Informe o usuário' : null,
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
                validator: (value) =>
                    value?.isEmpty == true ? 'Informe a senha' : null,
              ),
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
    );
  }
}
