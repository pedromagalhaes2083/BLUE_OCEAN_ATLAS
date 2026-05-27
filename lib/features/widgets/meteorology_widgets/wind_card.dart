import 'package:flutter/material.dart';
import 'package:atlas/features/widgets/base_meteorology_card.dart';
import 'package:atlas/features/widgets/info_column.dart';

class WindCard extends BaseMeteorologyCard {
  final List<dynamic> dados;
  final double distancia;

  const WindCard({
    super.key,
    required this.dados,
    required this.distancia,
  }) : super(
          cardColor: const Color(0xFFEDF1F3),
          borderRadius: 24,
        );

  @override
  bool get isLoading => dados.isEmpty;

  @override
  String get loadingMessage => 'Carregando dados de vento...';

  @override
  Widget buildContent(BuildContext context) {
    final item = dados.first;
    final double velocidade = (item['velocidade'] ?? 0).toDouble();
    final double direcao = (item['direcao'] ?? 0).toDouble();
    // Kelvin → Celsius
    final double tmp2m = (item['tmp2m'] ?? 0).toDouble() - 273.15;

    return Column(
      children: [
        BaseMeteorologyCard.buildHeader(
          icon: Icons.air,
          title: 'Rajadas de Vento',
          color: const Color(0xFF3ECFF3),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              velocidade.toStringAsFixed(1),
              style: const TextStyle(fontSize: 62, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const Text('nós', style: TextStyle(fontSize: 24)),
          ],
        ),
        Text(
          '${direcao.toStringAsFixed(0)}°',
          style: const TextStyle(fontSize: 22, color: Colors.red),
        ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InfoColumn(
              icon: Icons.thermostat,
              label: 'Temperatura',
              value: '${tmp2m.toStringAsFixed(1)}°C',
            ),
            InfoColumn(
              icon: Icons.location_on,
              label: 'Distância',
              value: '${distancia.toStringAsFixed(1)} mn',
            ),
            InfoColumn(
              icon: Icons.place,
              label: 'Coordenadas',
              value:
                  '${item['latitude'].toStringAsFixed(2)}°,\n${item['longitude'].toStringAsFixed(2)}°',
            ),
          ],
        ),
      ],
    );
  }
}
