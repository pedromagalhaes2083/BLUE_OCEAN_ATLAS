import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../embarcacao/domain/models/embarcacao.dart';
import '../../../core/database/database_helper.dart';

class EmbarcacaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Embarcacao? embarcaoId; // opcional: filtrar por viagem específica

  const EmbarcacaoScreen({super.key, required this.dbHelper, this.embarcaoId});

  @override
  State<EmbarcacaoScreen> createState() => _EmbarcacaoScreenState();
}

class _EmbarcacaoScreenState extends State<EmbarcacaoScreen> {
  List<Map<String, dynamic>> _embarcacao = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarEmbarcacao();
  }

  Future<void> _carregarEmbarcacao() async {
    setState(() => _isLoading = true);
    try {
      final db = await widget.dbHelper.database;

      final List<Map<String, dynamic>> result = await db.query('Embarcacao');

      setState(() {
        _embarcacao = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro ao carregar dados: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Localizações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarEmbarcacao,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _embarcacao.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhum registro encontrado'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarEmbarcacao,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _embarcacao.length,
                    itemBuilder: (context, index) {
                      final item = _embarcacao[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.location_on, color: Colors.white),
                          ),
                          title: Text(
                            item['nome'],
                          ),
                          subtitle: Text(
                            item['dono'],
                            style: const TextStyle(fontSize: 15),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (item['quantidade_urnas'] != null)
                                Text(
                                  '${(item['quantidade_urnas'])}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              Text(
                                'Registro: ${(item['registro'])}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
