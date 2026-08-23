import 'package:flutter/material.dart';
import '../../../core/models/wave_forecast.dart';

/// Card de tábua de marés — nível do mar atual e as próximas preamares/
/// baixa-mares, calculadas a partir da série horária de nível do mar da
/// Open-Meteo Marine (`sea_level_height_msl`, ver [WaveForecast.eventosMare]).
/// Uso: MareCard(forecast: forecast)
class MareCard extends StatelessWidget {
  final WaveForecast forecast;

  const MareCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final nivelAtual = forecast.current?.seaLevelHeightMsl;
    final eventos = forecast.eventosMare;

    if (nivelAtual == null && eventos.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFFE0F2F1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.waves, color: Colors.teal, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Maré',
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (nivelAtual != null)
                  Text(
                    '${nivelAtual.toStringAsFixed(2)} m agora',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            if (eventos.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 78,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: eventos.length > 6 ? 6 : eventos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _EventoMareChip(evento: eventos[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventoMareChip extends StatelessWidget {
  final MareEvento evento;

  const _EventoMareChip({required this.evento});

  @override
  Widget build(BuildContext context) {
    final alta = evento.tipo == TipoMare.alta;
    final h = evento.time.hour.toString().padLeft(2, '0');
    final m = evento.time.minute.toString().padLeft(2, '0');

    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alta ? Colors.teal.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            alta ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: alta ? Colors.teal.shade700 : Colors.blueGrey,
          ),
          Text(
            alta ? 'Preamar' : 'Baixa-mar',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: alta ? Colors.teal.shade700 : Colors.blueGrey),
          ),
          Text('$h:$m',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, height: 1)),
          Text('${evento.alturaM.toStringAsFixed(2)} m',
              style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
