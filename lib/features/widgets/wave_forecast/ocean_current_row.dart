import 'package:flutter/material.dart';
import '../../../core/models/wave_forecast.dart';

/// Linha compacta com a corrente oceânica de uma entrada horária — some
/// se a entrada não tiver esse dado (URL não pediu esses parâmetros).
/// Uso: OceanCurrentRow(entry: forecast.current)
class OceanCurrentRow extends StatelessWidget {
  final WaveHourEntry entry;

  const OceanCurrentRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final velocidade = entry.oceanCurrentVelocity;
    if (velocidade == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.water, size: 16, color: Colors.teal),
        const SizedBox(width: 6),
        Text(
          'Corrente ${velocidade.toStringAsFixed(1)} km/h'
          '${entry.oceanCurrentDirection != null ? ' · ${entry.oceanCurrentDirection}°' : ''}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
