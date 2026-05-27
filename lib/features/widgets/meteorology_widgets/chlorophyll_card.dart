import 'package:flutter/material.dart';
import 'package:atlas/features/widgets/base_meteorology_card.dart';
import 'package:atlas/features/widgets/info_column.dart';

class ChlorophyllCard extends BaseMeteorologyCard {
  final List<dynamic> dados;
  final double distancia;

  const ChlorophyllCard({
    super.key,
    required this.dados,
    required this.distancia,
  }) : super(
          cardColor: const Color(0xFFE0F2E9),
          borderRadius: 28,
        );

  @override
  bool get isLoading => dados.isEmpty;

  @override
  String get loadingMessage => 'Carregando clorofila...';

  @override
  Widget buildContent(BuildContext context) {
    final item = dados.first;
    final double chl = (item['chlor_a'] ?? 0).toDouble();

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
            chl.toStringAsFixed(2),
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
        ),
        const Center(
          child:
              Text('mg/m³', style: TextStyle(fontSize: 20, color: Colors.grey)),
        ),
        const SizedBox(height: 24),
        BaseMeteorologyCard.buildWhiteContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InfoColumn(
                  icon: Icons.location_on,
                  label: 'Distância',
                  value: '${distancia.toStringAsFixed(1)} mn'),
              InfoColumn(
                  icon: Icons.place,
                  label: 'Coordenadas',
                  value:
                      '${item['latitude'].toStringAsFixed(2)}°,\n${item['longitude'].toStringAsFixed(2)}°'),
            ],
          ),
        ),
      ],
    );
  }
}
