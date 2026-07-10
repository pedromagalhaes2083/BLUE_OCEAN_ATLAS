import 'package:flutter/material.dart';
import '../../../core/models/wave_forecast.dart';

/// Card com as condições de onda do momento atual.
/// Uso: WaveSummaryCard(forecast: forecast)
class WaveSummaryCard extends StatelessWidget {
  final WaveForecast forecast;

  const WaveSummaryCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final entry = forecast.current;
    if (entry == null) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [const Color(0xFF0A2A4A), const Color(0xFF1B5E8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(entry),
            const SizedBox(height: 20),
            _buildMetrics(entry),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(WaveHourEntry entry) {
    final h = entry.time.hour.toString().padLeft(2, '0');
    final m = entry.time.minute.toString().padLeft(2, '0');
    final d = entry.time.day.toString().padLeft(2, '0');
    final mo = entry.time.month.toString().padLeft(2, '0');

    return Row(
      children: [
        const Icon(Icons.waves, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        const Text(
          'Condições Atuais',
          style: TextStyle(
              color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          '$d/$mo  $h:$m',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMetrics(WaveHourEntry entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Altura — destaque principal
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.waveHeight.toStringAsFixed(2),
                  style: TextStyle(
                    color: _heightColor(entry.waveHeight),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8, left: 4),
                  child: Text('m',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            Text(
              _heightLabel(entry.waveHeight),
              style: TextStyle(
                  color: _heightColor(entry.waveHeight),
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),

        const Spacer(),

        // Direção + período
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _MetricItem(
              icon: _buildDirectionArrow(entry.directionRadians),
              label: entry.directionLabel,
              value: '${entry.waveDirection}°',
            ),
            const SizedBox(height: 12),
            _MetricItem(
              icon: const Icon(Icons.timer_outlined,
                  color: Colors.white70, size: 20),
              label: 'Período',
              value: '${entry.wavePeriod.toStringAsFixed(1)} s',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionArrow(double radians) {
    return Transform.rotate(
      angle: radians,
      child: const Icon(Icons.navigation, color: Colors.white70, size: 20),
    );
  }

  Color _heightColor(double h) {
    if (h < 0.5) return Colors.greenAccent;
    if (h < 1.0) return const Color(0xFF80FF80);
    if (h < 2.0) return Colors.yellowAccent;
    if (h < 3.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _heightLabel(double h) {
    if (h < 0.5) return 'Calmo';
    if (h < 1.0) return 'Leve';
    if (h < 2.0) return 'Moderado';
    if (h < 3.0) return 'Agitado';
    if (h < 4.0) return 'Muito agitado';
    return 'Tempestuoso';
  }
}

class _MetricItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
