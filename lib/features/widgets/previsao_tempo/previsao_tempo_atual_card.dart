import 'package:flutter/material.dart';
import 'package:atlas/features/widgets/base_meteorology_card.dart';
import 'package:atlas/features/widgets/info_column.dart';
import '../../metereologia/domain/models/previsao_tempo.dart';

/// Card com a condição climática atual (Open-Meteo `current_weather`).
/// Uso: PrevisaoTempoAtualCard(previsao: previsao)
class PrevisaoTempoAtualCard extends BaseMeteorologyCard {
  final PrevisaoTempo previsao;

  const PrevisaoTempoAtualCard({super.key, required this.previsao})
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

    return Column(
      children: [
        BaseMeteorologyCard.buildHeader(
          icon: Icons.cloud_outlined,
          title: 'Clima Atual',
          color: Colors.blueGrey,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              atual.temperatura.toStringAsFixed(1),
              style: const TextStyle(fontSize: 62, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10, left: 4),
              child: Text('°C', style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InfoColumn(
              icon: Icons.air,
              label: 'Vento',
              value: '${atual.velocidadeVento.toStringAsFixed(0)} km/h',
            ),
            InfoColumn(
              icon: Icons.navigation,
              label: 'Direção',
              value: '${atual.direcaoVento}°',
            ),
            InfoColumn(
              icon: Icons.schedule,
              label: 'Atualizado',
              value:
                  '${atual.horario.hour.toString().padLeft(2, '0')}:${atual.horario.minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
      ],
    );
  }
}
