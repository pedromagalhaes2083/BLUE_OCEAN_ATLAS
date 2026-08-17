import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart'; // para carregar assets
import '../../../core/database/database_helper.dart';
import '../domain/models/carta_nautica.dart';
import 'pdf_viewer_screen.dart';
import '../../recomendacao/data/recomendacao_repository.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../../recomendacao/widgets/recomendacao_card.dart';
import '../../recomendacao/widgets/recomendacoes_list.dart';

class CartasScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const CartasScreen({super.key, required this.dbHelper});

  @override
  State<CartasScreen> createState() => _CartasScreenState();
}

class _CartasScreenState extends State<CartasScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _tabIndex = 0;

  // ── Cartas ───────────────────────────────────────────────────────────────
  List<CartaNautica> cartas = [];
  bool isLoading = true;
  String searchQuery = '';

  // ── Recomendações ────────────────────────────────────────────────────────
  List<Recomendacao> recomendacoes = [];
  bool isLoadingRecomendacoes = true;
  String? erroRecomendacoes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() => _tabIndex = _tabController.index);
    });
    _carregarCartas();
    _carregarRecomendacoes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarCartas() async {
    setState(() => isLoading = true);

    final maps = await widget.dbHelper.query('carta_nautica');
    final lista = maps.map((map) => CartaNautica.fromMap(map)).toList();

    if (!mounted) return;
    setState(() {
      cartas = lista;
      isLoading = false;
    });
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

  // Adiciona uma carta de teste (PDF de exemplo)
  Future<void> _adicionarCartaTeste() async {
    // Carrega o PDF dos assets e salva no diretório do app
    final byteData =
        await rootBundle.load('assets/cartas/Carta_Navegacao_Nordeste.pdf');
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/Carta_Navegacao_Nordeste.pdf');

    await file.writeAsBytes(byteData.buffer.asUint8List());

    final cartaTeste = CartaNautica(
      id: 0,
      codigo: "TEST-001",
      nome: "Carta Náutica de Exemplo - Costa Nordeste",
      urlS3: "",
      caminhoLocal: file.path,
      dataPublicacao: DateTime.now(),
      dataAtualizacao: DateTime.now(),
      estaBaixada: true,
    );

    await widget.dbHelper.insert('carta_nautica', cartaTeste.toMap());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carta de teste adicionada!')),
    );

    _carregarCartas(); // Atualiza a lista
  }

  List<CartaNautica> get cartasFiltradas {
    if (searchQuery.isEmpty) return cartas;
    return cartas.where((carta) {
      return carta.nome.toLowerCase().contains(searchQuery.toLowerCase()) ||
          carta.codigo.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _abrirCarta(CartaNautica carta) async {
    if (carta.caminhoLocal == null || carta.caminhoLocal!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carta ainda não foi baixada')),
      );
      return;
    }

    final file = File(carta.caminhoLocal!);
    final existe = await file.exists();
    if (!mounted) return;

    if (existe) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(pdfFile: file, titulo: carta.nome),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo PDF não encontrado')),
      );
    }
  }

  void _cartaNaoBaixada() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Esta carta ainda não foi baixada. Peça em "Solicitar Carta", no menu.',
        ),
      ),
    );
  }

  void _abrirDetalheRecomendacao(Recomendacao recomendacao) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: RecomendacaoCard(recomendacao: recomendacao),
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
          if (_tabIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _adicionarCartaTeste,
              tooltip: 'Adicionar carta de teste',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _tabIndex == 0 ? _carregarCartas : _carregarRecomendacoes,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cartas', icon: Icon(Icons.map)),
            Tab(text: 'Recomendações', icon: Icon(Icons.tips_and_updates)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCartasTab(),
          _buildRecomendacoesTab(),
        ],
      ),
    );
  }

  // ── Aba Cartas ───────────────────────────────────────────────────────────

  Widget _buildCartasTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (value) => setState(() => searchQuery = value),
            decoration: const InputDecoration(
              hintText: 'Buscar por nome ou código...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : cartasFiltradas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Nenhuma carta encontrada'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _adicionarCartaTeste,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Carta de Teste'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: cartasFiltradas.length,
                      itemBuilder: (context, index) {
                        final carta = cartasFiltradas[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              carta.estaBaixada
                                  ? Icons.check_circle
                                  : Icons.map,
                              color: carta.estaBaixada
                                  ? Colors.green
                                  : Colors.grey,
                              size: 40,
                            ),
                            title: Text(carta.nome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text('Código: ${carta.codigo}'),
                            trailing: carta.estaBaixada
                                ? const Icon(Icons.open_in_new,
                                    color: Colors.green)
                                : const Icon(Icons.download,
                                    color: Colors.blue),
                            onTap: carta.estaBaixada
                                ? () => _abrirCarta(carta)
                                : _cartaNaoBaixada,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ── Aba Recomendações ───────────────────────────────────────────────────

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
