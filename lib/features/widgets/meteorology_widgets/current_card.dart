import 'package:flutter/material.dart';
import 'package:atlas/features/widgets/base_meteorology_card.dart';
import 'package:atlas/features/widgets/info_column.dart';

class CurrentCard extends BaseMeteorologyCard {
  final List<dynamic> dados;
  final double distancia;

  const CurrentCard({
    super.key,
    required this.dados,
    required this.distancia,
  }) : super(
          cardColor: const Color(0xFFEAF4FF),
          borderRadius: 28,
        );

  @override
  bool get isLoading => dados.isEmpty;

  @override
  String get loadingMessage => 'Carregando correntes marítimas...';

  @override
  Widget buildContent(BuildContext context) {
    final item = dados.first;
    final double velocidade = (item['velocidade'] ?? 0).toDouble();
    final double direcao = (item['direcao'] ?? 0).toDouble();
    final double temperatura = (item['temperatura_agua'] ?? 0).toDouble();
    final double salinidade = (item['salinidade'] ?? 0).toDouble();
    final double u = (item['u_corrente'] ?? 0).toDouble();
    final double v = (item['v_corrente'] ?? 0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseMeteorologyCard.buildHeader(
          icon: Icons.waves,
          title: 'Correntes Marítimas',
          color: Colors.blue,
          iconSize: 34,
        ),
        const SizedBox(height: 24),
        // Velocidade principal
        Center(
          child: Column(
            children: [
              Text(
                velocidade.toStringAsFixed(2),
                style:
                    const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
              ),
              const Text('nós',
                  style: TextStyle(fontSize: 24, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.navigation, color: Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    '${direcao.toStringAsFixed(0)}°',
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InfoColumn(
                icon: Icons.thermostat,
                label: 'Água',
                value: '${temperatura.toStringAsFixed(1)}°C'),
            InfoColumn(
                icon: Icons.opacity,
                label: 'Salinidade',
                value: '${salinidade.toStringAsFixed(1)} PSU'),
            InfoColumn(
                icon: Icons.location_on,
                label: 'Distância',
                value: '${distancia.toStringAsFixed(1)} mn'),
          ],
        ),
        const SizedBox(height: 24),
        // Componentes vetoriais
        BaseMeteorologyCard.buildWhiteContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const Text('Componentes Vetoriais',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    const Text('U',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 4),
                    Text(u.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 18)),
                  ]),
                  Column(children: [
                    const Text('V',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 4),
                    Text(v.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 18)),
                  ]),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Coordenadas
        BaseMeteorologyCard.buildWhiteContainer(
          child: Column(
            children: [
              const Text('Coordenadas',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '${item['latitude'].toStringAsFixed(2)}°, '
                '${item['longitude'].toStringAsFixed(2)}°',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
