import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart'; // para carregar assets
import '../../../core/database/database_helper.dart';
import '../domain/models/carta_nautica.dart';
import 'pdf_viewer_screen.dart';

class CartasScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const CartasScreen({super.key, required this.dbHelper});

  @override
  State<CartasScreen> createState() => _CartasScreenState();
}

class _CartasScreenState extends State<CartasScreen> {
  List<CartaNautica> cartas = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _carregarCartas();
  }

  Future<void> _carregarCartas() async {
    setState(() => isLoading = true);

    final maps = await widget.dbHelper.query('carta_nautica');
    final lista = maps.map((map) => CartaNautica.fromMap(map)).toList();

    setState(() {
      cartas = lista;
      isLoading = false;
    });
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
    if (await file.exists()) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartas Náuticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _adicionarCartaTeste,
            tooltip: 'Adicionar carta de teste',
          ),
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _carregarCartas),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou código...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
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
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
