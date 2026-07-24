import 'package:flutter/material.dart';
import '../../metereologia/domain/models/previsao_tempo.dart';

/// Lista horizontal rolável com a previsão horária de clima (vento,
/// temperatura, chuva). Uso: PrevisaoTempoHourlyTimeline(previsao: previsao)
class PrevisaoTempoHourlyTimeline extends StatelessWidget {
  final PrevisaoTempo previsao;

  const PrevisaoTempoHourlyTimeline({super.key, required this.previsao});

  @override
  Widget build(BuildContext context) {
    final entries = previsao.proximasHoras;
    if (entries.isEmpty) return const SizedBox.shrink();

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
            itemBuilder: (_, i) => _HourCard(entry: entries[i]),
          ),
        ),
      ],
    );
  }
}

class _HourCard extends StatelessWidget {
  final PrevisaoTempoHoraria entry;

  const _HourCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final h = entry.horario.hour.toString().padLeft(2, '0');
    final m = entry.horario.minute.toString().padLeft(2, '0');

    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$h:$m',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Transform.rotate(
              angle: entry.direcaoRadianos,
              child: const Icon(Icons.navigation, size: 18, color: Colors.blueGrey),
            ),
            Column(
              children: [
                Text(
                  entry.temperatura.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, height: 1),
                ),
                Text('°C', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
            Text(
              '${entry.velocidadeVento.toStringAsFixed(0)} km/h',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            if (entry.precipitacao > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop, size: 10, color: Colors.blue),
                  const SizedBox(width: 2),
                  Text(
                    '${entry.precipitacao.toStringAsFixed(1)}mm',
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
