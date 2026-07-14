import 'package:flutter/material.dart';
import '../domain/models/recomendacao.dart';
import 'recomendacao_variavel_chip.dart';

/// Card com um ponto amostrado de uma recomendação: data de recebimento
/// do dado, coordenada geográfica e as variáveis ambientais medidas ali.
class RecomendacaoPontoCard extends StatelessWidget {
  final PontoRecomendacao ponto;
  final DateTime? dataRecebimento;

  const RecomendacaoPontoCard({
    super.key,
    required this.ponto,
    this.dataRecebimento,
  });

  String _formatarData(DateTime d) {
    final data =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final hora =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$data $hora';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${ponto.latitude.toStringAsFixed(3)}°, ${ponto.longitude.toStringAsFixed(3)}°',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              if (dataRecebimento != null) ...[
                const SizedBox(width: 10),
                const Icon(Icons.schedule, size: 12, color: Colors.grey),
                const SizedBox(width: 3),
                Text(
                  _formatarData(dataRecebimento!),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
          if (ponto.variaveis.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ponto.variaveis
                  .map((v) => RecomendacaoVariavelChip(variavel: v))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
