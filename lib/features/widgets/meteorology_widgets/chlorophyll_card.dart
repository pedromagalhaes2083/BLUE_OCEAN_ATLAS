import 'package:flutter/material.dart';
import 'package:atlas/core/models/chlorophyll_reading.dart';
import 'package:atlas/features/widgets/base_meteorology_card.dart';
import 'package:atlas/features/widgets/info_column.dart';
import 'package:atlas/features/widgets/meteorology_widgets/chlorophyll_chip.dart';

/// Card de detalhe com a leitura de clorofila mais próxima do dataset.
/// Uso: ChlorophyllCard(dataset: dataset)
class ChlorophyllCard extends BaseMeteorologyCard {
  final ChlorophyllDataset dataset;

  const ChlorophyllCard({
    super.key,
    required this.dataset,
  }) : super(
          cardColor: const Color(0xFFE0F2E9),
          borderRadius: 28,
        );

  @override
  bool get isLoading => dataset.isEmpty;

  @override
  String get loadingMessage => 'Carregando clorofila...';

  @override
  Widget buildContent(BuildContext context) {
    final reading = dataset.nearest!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseMeteorologyCard.buildHeader(
          icon: Icons.eco,
          title: 'Clorofila/Fitoplâncton',
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            reading.concentration.toStringAsFixed(2),
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child:
              Text('mg/m³', style: TextStyle(fontSize: 20, color: Colors.grey)),
        ),
        const SizedBox(height: 12),
        Center(child: ChlorophyllChip.fromReading(reading)),
        const SizedBox(height: 24),
        BaseMeteorologyCard.buildWhiteContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InfoColumn(
                icon: Icons.location_on,
                label: 'Distância',
                value: reading.distanceNm != null
                    ? '${reading.distanceNm!.toStringAsFixed(1)} mn'
                    : '—',
              ),
              InfoColumn(
                icon: Icons.place,
                label: 'Coordenadas',
                value:
                    '${reading.latitude.toStringAsFixed(2)}°,\n${reading.longitude.toStringAsFixed(2)}°',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
