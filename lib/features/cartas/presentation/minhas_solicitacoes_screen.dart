import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Lista os pedidos de carta náutica já feitos pelo mestre — hoje só
/// registrados localmente, já que não existe (ainda) integração com um
/// backend de cartas que processe o pedido automaticamente.
class MinhasSolicitacoesScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const MinhasSolicitacoesScreen({super.key, required this.dbHelper});

  @override
  State<MinhasSolicitacoesScreen> createState() =>
      _MinhasSolicitacoesScreenState();
}

class _MinhasSolicitacoesScreenState extends State<MinhasSolicitacoesScreen> {
  List<Map<String, dynamic>> _solicitacoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    try {
      final db = await widget.dbHelper.database;
      final result = await db.query(
        'solicitacao_carta',
        orderBy: 'data_solicitacao DESC',
      );
      if (!mounted) return;
      setState(() => _solicitacoes = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).minhasSolicitacoesErro('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.minhasSolicitacoesTitulo),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _solicitacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list_alt, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(l10n.minhasSolicitacoesVazio),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _solicitacoes.length,
                    itemBuilder: (context, index) {
                      final item = _solicitacoes[index];
                      final data =
                          DateTime.parse(item['data_solicitacao'] as String);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.map_outlined, color: Colors.white),
                          ),
                          title: Text(
                            '${item['latitude_texto']}\n${item['longitude_texto']}',
                          ),
                          subtitle: Text(
                            l10n.minhasSolicitacoesPedidoEm(
                                DateFormat('dd/MM/yyyy HH:mm').format(data)),
                          ),
                          isThreeLine: true,
                          trailing: Chip(
                            label: Text(l10n.minhasSolicitacoesPendente),
                            backgroundColor: Colors.orange.withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.orange.shade200
                                  : Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
