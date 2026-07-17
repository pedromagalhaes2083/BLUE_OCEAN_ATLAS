import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../embarcacao/domain/models/embarcacao.dart';

class EmbarcacaoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Embarcacao? embarcacao;

  const EmbarcacaoScreen({
    super.key,
    required this.dbHelper,
    this.embarcacao,
  });

  @override
  State<EmbarcacaoScreen> createState() => _EmbarcacaoScreenState();
}

class _EmbarcacaoScreenState extends State<EmbarcacaoScreen> {
  List<Map<String, dynamic>> _embarcacoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarEmbarcacoes();
  }

  Future<void> _carregarEmbarcacoes() async {
    setState(() => _isLoading = true);

    try {
      final db = await widget.dbHelper.database;

      List<Map<String, dynamic>> result;

      if (widget.embarcacao != null) {
        result = await db.query(
          'embarcacao',
          where: 'id = ?',
          whereArgs: [widget.embarcacao!.id],
        );
      } else {
        result = await db.query('embarcacao');
      }

      if (!mounted) return;
      setState(() {
        _embarcacoes = result;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar embarcações: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_boat,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nome'] ?? 'Sem Nome',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['dono'] ?? 'Sem proprietário',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    item['registro'] ?? '--',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _buildInfoItem(
                    Icons.inventory_2,
                    'Quantidade de Urnas',
                    '${item['quantidade_urnas'] ?? 0}',
                  ),
                  const SizedBox(height: 14),
                  _buildInfoItem(
                    Icons.speed,
                    'Potência do Motor',
                    '${item['potencia_motor'] ?? '--'} HP',
                  ),
                  const SizedBox(height: 14),
                  _buildInfoItem(
                    Icons.straighten,
                    'Comprimento',
                    '${item['comprimento'] ?? '--'} m',
                  ),
                  const SizedBox(height: 14),
                  _buildInfoItem(
                    Icons.local_gas_station,
                    'Capacidade Combustível',
                    '${item['capacidade_combustivel'] ?? '--'} L',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.map),
                    label: const Text('Rastrear'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          'Minhas Embarcações',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _carregarEmbarcacoes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _embarcacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sailing,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nenhuma embarcação encontrada',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Cadastre uma embarcação para começar',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarEmbarcacoes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _embarcacoes.length,
                    itemBuilder: (context, index) {
                      return _buildCard(
                        _embarcacoes[index],
                      );
                    },
                  ),
                ),
    );
  }
}
