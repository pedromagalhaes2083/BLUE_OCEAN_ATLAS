import 'package:flutter/material.dart';
import 'package:atlas/core/models/chlorophyll_reading.dart';

/// Legenda com a escala de níveis de clorofila usada em toda a coleção
/// de widgets de clorofila. Útil em telas de ajuda ou abaixo do card principal.
class ChlorophyllLegend extends StatelessWidget {
  const ChlorophyllLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Escala de Clorofila',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final level in ChlorophyllLevel.values) _LegendRow(level: level),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final ChlorophyllLevel level;

  const _LegendRow({required this.level});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: level.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              level.label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              level.description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
