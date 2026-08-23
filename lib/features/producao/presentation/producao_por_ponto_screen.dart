import 'package:flutter/material.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../mapa/domain/models/ponto_marcado.dart';
import '../domain/models/producao_registro.dart';
import '../domain/services/producao_pontos_analyzer.dart';

/// Ranking dos pontos marcados mais produtivos — cruza os registros de
/// produção (que já guardam lat/lng da captura) com os pontos marcados
/// pelo usuário, associando cada registro ao ponto mais próximo dentro
/// de [raioAssociacaoPontoNauticas].
class ProducaoPorPontoScreen extends StatefulWidget {
  const ProducaoPorPontoScreen({super.key});

  @override
  State<ProducaoPorPontoScreen> createState() =>
      _ProducaoPorPontoScreenState();
}

class _ProducaoPorPontoScreenState extends State<ProducaoPorPontoScreen> {
  bool _carregando = true;
  String? _erro;
  List<ProducaoPorPonto> _ranking = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final db = await DatabaseHelper.instance.database;
      final mapsRegistros = await db.query('producao_registro');
      final mapsPontos = await db.query('ponto_marcado');

      final registros = mapsRegistros.map(ProducaoRegistro.fromMap).toList();
      final pontos = mapsPontos.map(PontoMarcado.fromMap).toList();

      final ranking = agruparProducaoPorPonto(registros, pontos);

      if (!mounted) return;
      setState(() {
        _ranking = ranking;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Erro ao carregar: $e';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produção por Ponto')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(child: Text(_erro!))
              : _ranking.isEmpty
                  ? _buildVazio(context)
                  : RefreshIndicator(
                      onRefresh: _carregar,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _ranking.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _RankingTile(item: _ranking[index], posicao: index + 1),
                      ),
                    ),
    );
  }

  Widget _buildVazio(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.query_stats, size: 80, color: onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Nenhuma produção associada a um ponto marcado ainda',
              textAlign: TextAlign.center,
              style: TextStyle(color: onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Registre capturas com coordenada e marque pontos no mapa '
              'para ver aqui os pontos mais produtivos',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  final ProducaoPorPonto item;
  final int posicao;

  const _RankingTile({required this.item, required this.posicao});

  Color _corPosicao(BuildContext context) {
    switch (posicao) {
      case 1:
        return const Color(0xFFC9A227);
      case 2:
        return const Color(0xFF9AA5B1);
      case 3:
        return const Color(0xFFB2703A);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final cor = _corPosicao(context);
    final especieTop = item.porEspecie.entries.isEmpty
        ? null
        : (item.porEspecie.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 24,
            child: Text(
              '$posicao°',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: cor),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.ponto.nome?.isNotEmpty == true
                      ? item.ponto.nome!
                      : 'Ponto marcado',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  formatarCoordenadasDMSCompacta(
                      item.ponto.latitude, item.ponto.longitude),
                  style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.totalRegistros} registro(s)'
                  '${especieTop != null ? ' · ${especieTop.key} em destaque' : ''}',
                  style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${item.totalKg.toStringAsFixed(1)} kg',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cor),
          ),
        ],
      ),
    );
  }
}
