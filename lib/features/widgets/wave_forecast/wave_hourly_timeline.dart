import 'package:flutter/material.dart';
import '../../../core/models/wave_forecast.dart';

/// Lista horizontal rolável com a previsão horária de ondas.
/// Uso: WaveHourlyTimeline(forecast: forecast)
class WaveHourlyTimeline extends StatelessWidget {
  final WaveForecast forecast;

  const WaveHourlyTimeline({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final entries = forecast.upcoming;
    if (entries.isEmpty) return const SizedBox.shrink();

    final current = forecast.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 15, color: Colors.grey),
              const SizedBox(width: 6),
              const Text(
                'Previsão horária',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '${entries.length}h',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _HourCard(
              entry: entries[i],
              isCurrent: current != null &&
                  entries[i].time == current.time,
            ),
          ),
        ),
      ],
    );
  }
}

class _HourCard extends StatelessWidget {
  final WaveHourEntry entry;
  final bool isCurrent;

  const _HourCard({required this.entry, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final h = entry.time.hour.toString().padLeft(2, '0');
    final m = entry.time.minute.toString().padLeft(2, '0');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 80,
      decoration: BoxDecoration(
        color: isCurrent
            ? const Color(0xFF1B3A5C)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? Colors.blueAccent
              : Colors.grey.withValues(alpha: 0.2),
          width: isCurrent ? 1.5 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hora
            Text(
              '$h:$m',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isCurrent ? Colors.white : Colors.grey[700],
              ),
            ),

            // Seta de direção
            Transform.rotate(
              angle: entry.directionRadians,
              child: Icon(
                Icons.navigation,
                size: 18,
                color: isCurrent
                    ? Colors.white70
                    : Colors.blueGrey,
              ),
            ),

            // Altura
            Column(
              children: [
                Text(
                  entry.waveHeight.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _heightColor(entry.waveHeight),
                    height: 1,
                  ),
                ),
                Text(
                  'm',
                  style: TextStyle(
                    fontSize: 10,
                    color: isCurrent ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),

            // Período
            Text(
              '${entry.wavePeriod.toStringAsFixed(1)}s',
              style: TextStyle(
                fontSize: 11,
                color: isCurrent ? Colors.white60 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _heightColor(double h) {
    if (h < 0.5) return Colors.greenAccent;
    if (h < 1.0) return const Color(0xFF80FF80);
    if (h < 2.0) return Colors.yellowAccent;
    if (h < 3.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
