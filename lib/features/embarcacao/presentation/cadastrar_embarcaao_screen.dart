import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';

class CadastrarEmbarcacaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  const CadastrarEmbarcacaoScreen({super.key, required this.dbHelper});

  @override
  State<CadastrarEmbarcacaoScreen> createState() =>
      _CadastrarEmbarcacaoScreenState();
}

class _CadastrarEmbarcacaoScreenState extends State<CadastrarEmbarcacaoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _donoController = TextEditingController();
  final _quantidadeUrnasController = TextEditingController(text: '1');
  final _placaController = TextEditingController();

  bool _isLoading = false;

  Future<void> _salvarEmbarcacao() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> data = {
        'nome': _nomeController.text.trim(),
        'dono': _donoController.text.trim().isEmpty
            ? null
            : _donoController.text.trim(),
        'quantidade_urnas': int.parse(_quantidadeUrnasController.text),
        'registro': _placaController.text.trim().isEmpty
            ? null
            : _placaController.text.trim().toUpperCase(),
        'data_cadastro': DateTime.now().toIso8601String(),
        'ativo': 1,
      };

      final id = await widget.dbHelper.insert('embarcacao', data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Embarcação "$id" cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retorna sucesso
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _donoController.dispose();
    _quantidadeUrnasController.dispose();
    _placaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Embarcação'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dados da Embarcação',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Nome da Embarcação
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Embarcação *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_boat),
                ),
                validator: (value) => value?.trim().isEmpty ?? true
                    ? 'Nome da embarcação é obrigatório'
                    : null,
              ),
              const SizedBox(height: 16),

              // Dono
              TextFormField(
                controller: _donoController,
                decoration: const InputDecoration(
                  labelText: 'Dono / Proprietário',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Quantidade de Urnas
              TextFormField(
                controller: _quantidadeUrnasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantidade de Urnas *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true)
                    return 'Informe a quantidade';
                  if (int.tryParse(value!) == null)
                    return 'Informe um número válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Placa (opcional)
              TextFormField(
                controller: _placaController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Registro',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _salvarEmbarcacao,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[800],
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'CADASTRAR EMBARCAÇÃO',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
