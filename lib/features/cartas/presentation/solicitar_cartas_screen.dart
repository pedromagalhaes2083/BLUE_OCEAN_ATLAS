import 'package:flutter/material.dart';
import 'package:atlas/core/database/database_helper.dart';
import '../../widgets/seletor_coordenada_widget.dart';
import 'minhas_solicitacoes_screen.dart';

class SolicitarCartaScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  /// Se informadas, as coordenadas já vêm preenchidas (ex: pedido feito a
  /// partir de um ponto marcado no mapa) em vez de começar em 0°/0'.
  final double? latitudeInicial;
  final double? longitudeInicial;

  const SolicitarCartaScreen({
    super.key,
    required this.dbHelper,
    this.latitudeInicial,
    this.longitudeInicial,
  });

  @override
  State<SolicitarCartaScreen> createState() => _SolicitarCartaScreenState();
}

class _SolicitarCartaScreenState extends State<SolicitarCartaScreen> {
  double _latitude = 0;
  double _longitude = 0;

  String _formatarCoordenada(double decimal, {required bool isLatitude}) {
    final hemisferio =
        isLatitude ? (decimal >= 0 ? 'N' : 'S') : (decimal >= 0 ? 'E' : 'W');
    final abs = decimal.abs();
    final deg = abs.floor();
    final min = ((abs - deg) * 60).round().clamp(0, 59);
    return '$deg° $min\' $hemisferio';
  }

  Future<void> _solicitarCarta() async {
    try {
      await widget.dbHelper.insert('solicitacao_carta', {
        'latitude_texto': _formatarCoordenada(_latitude, isLatitude: true),
        'longitude_texto': _formatarCoordenada(_longitude, isLatitude: false),
        'data_solicitacao': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação registrada! Veja em "Minhas Solicitações".'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retorna sucesso
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao solicitar carta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Carta Náutica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Minhas solicitações',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MinhasSolicitacoesScreen(dbHelper: widget.dbHelper),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Coordenada Geográfica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gire os seletores como no relógio para ajustar graus e minutos',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SeletorCoordenadaWidget(
              latitudeInicial: widget.latitudeInicial,
              longitudeInicial: widget.longitudeInicial,
              onAlterado: (lat, lon) {
                _latitude = lat;
                _longitude = lon;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _solicitarCarta,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'SOLICITAR CARTA NÁUTICA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
