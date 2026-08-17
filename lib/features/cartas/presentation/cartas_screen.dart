import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../recomendacao/data/recomendacao_repository.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../../recomendacao/widgets/recomendacao_card.dart';
import '../../recomendacao/widgets/recomendacoes_list.dart';

/// Tela "Cartas Náuticas" — hoje mostra só as recomendações (a listagem de
/// cartas baixadas/PDF foi descontinuada; `dbHelper` fica reservado para
/// quando essa tela precisar de outra fonte local de dados).
class CartasScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const CartasScreen({super.key, required this.dbHelper});

  @override
  State<CartasScreen> createState() => _CartasScreenState();
}

class _CartasScreenState extends State<CartasScreen> {
  List<Recomendacao> recomendacoes = [];
  bool isLoadingRecomendacoes = true;
  String? erroRecomendacoes;

  @override
  void initState() {
    super.initState();
    _carregarRecomendacoes();
  }

  Future<void> _carregarRecomendacoes() async {
    setState(() {
      isLoadingRecomendacoes = true;
      erroRecomendacoes = null;
    });

    try {
      final lista = await RecomendacaoRepository().listar();
      if (!mounted) return;
      setState(() => recomendacoes = lista);
    } catch (e) {
      if (!mounted) return;
      setState(() => erroRecomendacoes = e.toString());
    } finally {
      if (mounted) setState(() => isLoadingRecomendacoes = false);
    }
  }

  void _abrirDetalheRecomendacao(Recomendacao recomendacao) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 44, 20),
                child: RecomendacaoCard(recomendacao: recomendacao),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartas Náuticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarRecomendacoes,
          ),
        ],
      ),
      body: _buildRecomendacoesTab(),
    );
  }

  Widget _buildRecomendacoesTab() {
    if (isLoadingRecomendacoes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erroRecomendacoes != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                erroRecomendacoes!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _carregarRecomendacoes,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarRecomendacoes,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          RecomendacoesList(
            recomendacoes: recomendacoes,
            onTap: _abrirDetalheRecomendacao,
          ),
        ],
      ),
    );
  }
}
