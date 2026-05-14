import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/location_service.dart';

class HistoricoLocalizacoesScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final int? viagemId; // opcional: filtrar por viagem específica

  const HistoricoLocalizacoesScreen({
    super.key,
    required this.dbHelper,
    this.viagemId,
  });

  @override
  State<HistoricoLocalizacoesScreen> createState() =>
      _HistoricoLocalizacoesScreenState();
}

class _HistoricoLocalizacoesScreenState
    extends State<HistoricoLocalizacoesScreen> {
  List<Map<String, dynamic>> _historico = [];
  bool _isLoading = true;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    setState(() => _isLoading = true);
    try {
      final db = await widget.dbHelper.database;

      final List<Map<String, dynamic>> result = await db.query(
        'localizacao_historico',
        where: widget.viagemId != null ? 'viagem_id = ?' : null,
        whereArgs: widget.viagemId != null ? [widget.viagemId] : null,
        orderBy: 'data_hora DESC',
      );

      setState(() {
        _historico = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar histórico: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatarDataHora(String dataIso) {
    final date = DateTime.parse(dataIso);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  String _formatarCoordenadaDMS(double lat, double lon) {
    String formatDMS(double value, bool isLat) {
      String dir = isLat ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
      value = value.abs();
      int deg = value.floor();
      double minDec = (value - deg) * 60;
      int min = minDec.floor();
      double sec = (minDec - min) * 60;
      return '$deg° ${min.toString().padLeft(2, '0')}\' ${sec.toStringAsFixed(1)}" $dir';
    }

    return '${formatDMS(lat, true)}\n${formatDMS(lon, false)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Localizações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarHistorico,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historico.isEmpty
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
                  onRefresh: _carregarHistorico,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _historico.length,
                    itemBuilder: (context, index) {
                      final item = _historico[index];
                      final DateTime data = DateTime.parse(item['data_hora']);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.location_on, color: Colors.white),
                          ),
                          title: Text(
                            _formatarDataHora(item['data_hora']),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            _formatarCoordenadaDMS(
                              item['latitude'],
                              item['longitude'],
                            ),
                            style: const TextStyle(fontSize: 15),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (item['velocidade'] != null)
                                Text(
                                  '${(item['velocidade'] * 3.6).toStringAsFixed(1)} km/h',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              Text(
                                'Prec: ${(item['precisao'] as num?)?.toStringAsFixed(0)}m',
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
