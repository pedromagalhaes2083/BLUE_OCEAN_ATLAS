import 'package:flutter/material.dart';
import 'package:atlas/features/widgets/base_meteorology_card.dart';
import '../../metereologia/domain/models/previsao_tempo.dart';

/// Card único com o vento atual (destaque), temperatura (secundária) e a
/// previsão horária de clima — tudo no mesmo container (substitui as
/// antigas PrevisaoTempoAtualCard + PrevisaoTempoHourlyTimeline).
/// Uso: CondicoesVentoCard(previsao: previsao)
class CondicoesVentoCard extends BaseMeteorologyCard {
  final PrevisaoTempo previsao;

  const CondicoesVentoCard({super.key, required this.previsao})
      : super(
          cardColor: const Color(0xFFEDF1F3),
          borderRadius: 24,
        );

  @override
  bool get isLoading => previsao.atual == null;

  @override
  String get loadingMessage => 'Carregando previsão do tempo...';

  @override
  Widget buildContent(BuildContext context) {
    final atual = previsao.atual!;
    final proximas = previsao.proximasHoras;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(atual),
        const Divider(height: 28),
        SizedBox(width: double.infinity, child: _buildVentoPrincipal(atual)),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),
        _buildTemperaturaSecundaria(atual),
        if (proximas.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildTimeline(proximas),
        ],
      ],
    );
  }

  Widget _buildHeader(PrevisaoTempoAtual atual) {
    final d = atual.horario.day.toString().padLeft(2, '0');
    final mo = atual.horario.month.toString().padLeft(2, '0');
    return Row(
      children: [
        const Icon(Icons.cloud_outlined, color: Colors.blueGrey, size: 26),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Clima Atual',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text('$d/$mo', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }

  Widget _buildVentoPrincipal(PrevisaoTempoAtual atual) {
    final velocidade = atual.velocidadeVento;
    return Column(
      children: [
        Text(
          'VELOCIDADE DO VENTO',
          style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                velocidade.toStringAsFixed(0),
                style: const TextStyle(
                    fontSize: 48, fontWeight: FontWeight.bold, height: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text('km/h',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _buildBarraIntensidade(velocidade),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Direção: ${atual.direcaoVento}°',
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            Transform.rotate(
              angle: atual.direcaoVento * 3.14159265 / 180.0,
              child: const Icon(Icons.navigation, size: 16, color: Colors.blueGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarraIntensidade(double velocidade) {
    final cor = _corIntensidade(velocidade);
    final fracao = (velocidade / 60).clamp(0.0, 1.0);
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fracao,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(cor),
            ),
          ),
          const SizedBox(height: 4),
          Text(_labelIntensidade(velocidade),
              style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTemperaturaSecundaria(PrevisaoTempoAtual atual) {
    return Row(
      children: [
        Icon(Icons.thermostat, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('Temperatura', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text('${atual.temperatura.toStringAsFixed(1)} °C',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTimeline(List<PrevisaoTempoHoraria> proximas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 15, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text('Previsão horária',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            const Spacer(),
            Text('${proximas.length}h',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: proximas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _HourChip(entry: proximas[i]),
          ),
        ),
      ],
    );
  }

  Color _corIntensidade(double kmh) {
    if (kmh < 10) return Colors.green.shade600;
    if (kmh < 20) return Colors.lightGreen.shade700;
    if (kmh < 30) return Colors.amber.shade800;
    if (kmh < 45) return Colors.orange;
    return Colors.redAccent;
  }

  String _labelIntensidade(double kmh) {
    if (kmh < 10) return 'Calmo';
    if (kmh < 20) return 'Leve';
    if (kmh < 30) return 'Moderado';
    if (kmh < 45) return 'Forte';
    return 'Muito forte';
  }
}

class _HourChip extends StatelessWidget {
  final PrevisaoTempoHoraria entry;

  const _HourChip({required this.entry});

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
