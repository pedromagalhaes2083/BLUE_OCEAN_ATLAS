import 'package:flutter/material.dart';
import 'package:atlas/core/models/chlorophyll_reading.dart';

/// Lista horizontal rolável com os pontos de clorofila mais próximos.
/// Uso: ChlorophyllNearbyList(dataset: dataset)
class ChlorophyllNearbyList extends StatelessWidget {
  final ChlorophyllDataset dataset;

  const ChlorophyllNearbyList({super.key, required this.dataset});

  @override
  Widget build(BuildContext context) {
    if (dataset.readings.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Icon(Icons.eco_outlined, size: 15, color: Colors.grey),
              const SizedBox(width: 6),
              const Text(
                'Pontos próximos',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey),
              ),
              const Spacer(),
              Text(
                '${dataset.readings.length}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dataset.readings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _PointCard(
              reading: dataset.readings[i],
              isNearest: i == 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PointCard extends StatelessWidget {
  final ChlorophyllReading reading;
  final bool isNearest;

  const _PointCard({required this.reading, required this.isNearest});

  @override
  Widget build(BuildContext context) {
    final level = reading.level;

    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: isNearest
            ? level.color.withValues(alpha: 0.12)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNearest ? level.color : Colors.grey.withValues(alpha: 0.2),
          width: isNearest ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            reading.distanceNm != null
                ? '${reading.distanceNm!.toStringAsFixed(1)} mn'
                : '—',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Icon(Icons.eco, color: level.color, size: 20),
          Text(
            reading.concentration.toStringAsFixed(2),
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: level.color),
          ),
          Text(
            level.label,
            style: TextStyle(fontSize: 10, color: level.color),
          ),
        ],
      ),
    );
  }
}
