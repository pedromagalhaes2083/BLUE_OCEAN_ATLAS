import 'package:flutter/material.dart';
import 'package:atlas/core/models/chlorophyll_reading.dart';

/// Selo compacto com o nível de clorofila — para uso em listas, dashboard,
/// tooltips de mapa ou qualquer lugar que precise de um resumo rápido.
class ChlorophyllChip extends StatelessWidget {
  final ChlorophyllLevel level;
  final double? concentration;

  const ChlorophyllChip({
    super.key,
    required this.level,
    this.concentration,
  });

  factory ChlorophyllChip.fromReading(ChlorophyllReading reading, {Key? key}) {
    return ChlorophyllChip(
      key: key,
      level: reading.level,
      concentration: reading.concentration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = concentration != null
        ? '${level.label} · ${concentration!.toStringAsFixed(2)} mg/m³'
        : level.label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: level.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.eco, size: 14, color: level.color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: level.color,
            ),
          ),
        ],
      ),
    );
  }
}
