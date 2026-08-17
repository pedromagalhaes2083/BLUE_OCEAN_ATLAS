import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/database/database_helper.dart';
import '../../mapa/presentation/mapa_screen.dart';
import '../domain/models/rota_planejada.dart';

/// Lista as rotas planejadas manualmente pelo mestre (sequência de pontos
/// marcados no mapa antes de sair) — diferente do histórico de GPS, que é
/// o trajeto já percorrido durante uma viagem.
class MinhasRotasScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  const MinhasRotasScreen({super.key, required this.dbHelper});

  @override
  State<MinhasRotasScreen> createState() => _MinhasRotasScreenState();
}

class _MinhasRotasScreenState extends State<MinhasRotasScreen> {
  List<RotaPlanejada> _rotas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    try {
      final rotasMap = await widget.dbHelper.query('rota_planejada');
      final rotas = <RotaPlanejada>[];
      for (final map in rotasMap) {
        final pontosMap = await widget.dbHelper.queryWhere(
          'rota_planejada_ponto',
          where: 'rota_planejada_id = ?',
          whereArgs: [map['id']],
          orderBy: 'ordem ASC',
        );
        rotas.add(RotaPlanejada.fromMap(
          map,
          pontos: pontosMap
              .map((p) => LatLng(
                    (p['latitude'] as num).toDouble(),
                    (p['longitude'] as num).toDouble(),
                  ))
              .toList(),
        ));
      }
      rotas.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
      if (!mounted) return;
      setState(() => _rotas = rotas);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar rotas: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _criarNovaRota() async {
    final salvou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const MapaScreen(modoPlanejarRota: true),
      ),
    );
    if (salvou == true) _carregar();
  }

  void _abrirRota(RotaPlanejada rota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaScreen(rota: rota.pontos),
      ),
    );
  }

  Future<void> _apagarRota(RotaPlanejada rota) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apagar rota?'),
        content: Text('"${rota.nome}" será removida permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await widget.dbHelper.deleteWhere(
      'rota_planejada_ponto',
      where: 'rota_planejada_id = ?',
      whereArgs: [rota.id],
    );
    await widget.dbHelper.delete('rota_planejada', id: rota.id!);
    if (!mounted) return;
    setState(() => _rotas.remove(rota));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Rotas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarNovaRota,
        icon: const Icon(Icons.add),
        label: const Text('Nova rota'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rotas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.route, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Nenhuma rota planejada ainda'),
                      const SizedBox(height: 8),
                      Text(
                        'Toque em "Nova rota" para marcar pontos no mapa',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregar,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                    itemCount: _rotas.length,
                    itemBuilder: (context, index) {
                      final rota = _rotas[index];
                      final deProducao = rota.embarcacaoId != null;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                deProducao ? Colors.deepOrange : Colors.purple,
                            child: Icon(
                              deProducao ? Icons.set_meal : Icons.route,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(rota.nome),
                          subtitle: Text(
                            '${rota.pontos.length} pontos · '
                            '${DateFormat('dd/MM/yyyy HH:mm').format(rota.dataCriacao)}',
                          ),
                          onTap: () => _abrirRota(rota),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Apagar rota',
                            onPressed: () => _apagarRota(rota),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
