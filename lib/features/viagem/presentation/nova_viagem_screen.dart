import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'package:atlas/features/viagem/domain/models/viagem.dart';

class NovaViagemScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final String embarcacao;

  const NovaViagemScreen({
    super.key,
    required this.dbHelper,
    required this.embarcacao,
  });

  @override
  State<NovaViagemScreen> createState() => _NovaViagemScreenState();
}

class _NovaViagemScreenState extends State<NovaViagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  DateTime _dataInicio = DateTime.now();
  DateTime? _dataTermino;

  Future<void> _salvarViagem() async {
    if (!_formKey.currentState!.validate()) return;

    final viagem = Viagem(
      id: 0,
      nome: _nomeController.text.trim().isEmpty
          ? null
          : _nomeController.text.trim(),
      dataInicio: _dataInicio,
      dataTermino: _dataTermino,
      embarcacaoId: widget.embarcacao,
      status: 'em_andamento',
    );

    await widget.dbHelper.insert('viagem', viagem.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viagem iniciada com sucesso!')),
    );

    Navigator.pop(context, true); // Retorna sucesso
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Viagem')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Viagem (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Data de Início'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataInicio)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dataInicio,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _dataInicio = date);
                },
              ),
              ListTile(
                title: const Text('Data de Término (opcional)'),
                subtitle: Text(_dataTermino != null
                    ? DateFormat('dd/MM/yyyy').format(_dataTermino!)
                    : 'Não definida'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dataTermino ?? _dataInicio,
                    firstDate: _dataInicio,
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _dataTermino = date);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _salvarViagem,
                child: const Text('INICIAR VIAGEM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
