import 'package:flutter/material.dart';
import '../../../core/models/wave_forecast.dart';

/// Linha compacta com os dados de swell de uma entrada horária — some se
/// a entrada não tiver dados de swell (URL não pediu esses parâmetros).
/// Uso: SwellInfoRow(entry: forecast.current)
class SwellInfoRow extends StatelessWidget {
  final WaveHourEntry entry;

  const SwellInfoRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final altura = entry.swellWaveHeight;
    if (altura == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.waves, size: 16, color: Colors.indigo),
        const SizedBox(width: 6),
        Text(
          'Swell ${altura.toStringAsFixed(2)} m'
          '${entry.swellWavePeriod != null ? ' · ${entry.swellWavePeriod!.toStringAsFixed(1)} s' : ''}'
          '${entry.swellWaveDirection != null ? ' · ${entry.swellWaveDirection}°' : ''}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
