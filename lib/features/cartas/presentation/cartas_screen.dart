import 'package:flutter/material.dart';
import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/utils/erro_amigavel.dart';
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
  bool _ocultarExpiradas = false;
  bool _offline = false;
  DateTime? _cacheEm;

  List<Recomendacao> get _recomendacoesExibidas => _ocultarExpiradas
      ? recomendacoes.where((r) => !r.expirada).toList()
      : recomendacoes;

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

    // Lida junto com a lista — a tela é recriada toda vez que o usuário
    // volta pra essa aba (ver AppShell), então isso já basta pra refletir
    // uma mudança feita em Configurações sem precisar de um listener.
    final ocultarExpiradas = await Config.obtem(
      Constantes.ocultarRecomendacoesExpiradas,
      'false',
    );

    try {
      final repositorio = RecomendacaoRepository();
      final lista = await repositorio.listar();
      if (!mounted) return;
      setState(() {
        recomendacoes = lista;
        _ocultarExpiradas = ocultarExpiradas == 'true';
        _offline = repositorio.ultimoResultadoOffline;
        _cacheEm = repositorio.ultimaAtualizacaoCache;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => erroRecomendacoes = mensagemErroAmigavel(e));
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              Icon(
                  erroRecomendacoes == mensagemSemConexao
                      ? Icons.wifi_off_outlined
                      : Icons.error_outline,
                  size: 48,
                  color: Colors.red),
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
          if (_offline) ...[
            _buildBannerOffline(),
            const SizedBox(height: 12),
          ],
          RecomendacoesList(
            recomendacoes: _recomendacoesExibidas,
            onTap: _abrirDetalheRecomendacao,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerOffline() {
    final horario = _cacheEm != null
        ? '${_cacheEm!.day.toString().padLeft(2, '0')}/${_cacheEm!.month.toString().padLeft(2, '0')} '
            '${_cacheEm!.hour.toString().padLeft(2, '0')}:${_cacheEm!.minute.toString().padLeft(2, '0')}'
        : 'data desconhecida';
    return Card(
      color: Colors.amber.withValues(alpha: 0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: Colors.amber.shade800),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sem conexão — mostrando a última lista sincronizada em $horario',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
