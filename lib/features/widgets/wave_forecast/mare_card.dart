import 'package:flutter/material.dart';
import '../../../core/models/wave_forecast.dart';
import '../../../core/utils/cor_tema.dart';

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

    // Mesma técnica de `BaseMeteorologyCard._corResolvida` — sem isso, o
    // card ficava um bloco pastel bem claro fixo em cima do tema escuro,
    // destoando dos cards vizinhos (vento, ondas) que já se adaptam.
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCard = Color.alphaBlend(
      const Color(0xFFE0F2F1).withValues(alpha: escuro ? 0.18 : 1.0),
      Theme.of(context).cardColor,
    );

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      color: corCard,
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
                    style: TextStyle(color: corRotulo(context), fontSize: 12),
                  ),
              ],
            ),
            if (eventos.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 92,
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alta ? Colors.teal.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
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
                height: 1.1,
                color: alta ? Colors.teal.shade700 : Colors.blueGrey),
          ),
          Text('$h:$m',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, height: 1)),
          Text('${evento.alturaM.toStringAsFixed(2)} m',
              style: TextStyle(
                  fontSize: 10, height: 1.1, color: corRotulo(context))),
        ],
      ),
    );
  }
}
