import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../domain/models/producao_registro.dart';

/// Histórico de registros de produção (capturas) já salvos, com totais
/// gerais e por espécie — complementa a tela de registro (só formulário)
/// dando ao mestre uma visão do que já foi pescado.
class ProducaoHistoricoScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const ProducaoHistoricoScreen({super.key, required this.dbHelper});

  @override
  State<ProducaoHistoricoScreen> createState() =>
      _ProducaoHistoricoScreenState();
}

class _ProducaoHistoricoScreenState extends State<ProducaoHistoricoScreen> {
  List<ProducaoRegistro> _registros = [];
  bool _isLoading = true;

  double _totalKg = 0;
  List<MapEntry<String, double>> _totalPorEspecie = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    try {
      final db = await widget.dbHelper.database;
      final maps = await db.query('producao_registro', orderBy: 'data_hora DESC');
      final registros = maps.map(ProducaoRegistro.fromMap).toList();

      final porEspecie = <String, double>{};
      var total = 0.0;
      for (final r in registros) {
        total += r.quantidadeKg;
        porEspecie.update(r.especie, (v) => v + r.quantidadeKg,
            ifAbsent: () => r.quantidadeKg);
      }
      final ordenado = porEspecie.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (!mounted) return;
      setState(() {
        _registros = registros;
        _totalKg = total;
        _totalPorEspecie = ordenado;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar produção: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatarDataHora(DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm').format(dt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Produção'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registros.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.set_meal_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhum registro de produção ainda'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _buildCardTotais(),
                      const SizedBox(height: 4),
                      ..._registros.map(_buildItem),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCardTotais() {
    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.set_meal, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Total: ${_totalKg.toStringAsFixed(1)} kg em ${_registros.length} registro(s)',
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            if (_totalPorEspecie.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _totalPorEspecie
                    .map((e) => Chip(
                          backgroundColor: Colors.white,
                          label: Text(
                              '${e.key}: ${e.value.toStringAsFixed(1)} kg'),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(ProducaoRegistro r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.set_meal, color: Colors.white),
        ),
        title: Text(r.especie, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatarDataHora(r.dataHora)),
            if (r.observacao != null)
              Text(
                r.observacao!,
                style: const TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          '${r.quantidadeKg.toStringAsFixed(1)} kg',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        isThreeLine: r.observacao != null,
      ),
    );
  }
}
