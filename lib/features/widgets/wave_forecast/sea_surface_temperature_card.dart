import 'package:flutter/material.dart';
import 'package:atlas/features/widgets/base_meteorology_card.dart';
import '../../../core/models/wave_forecast.dart';

/// Card com a temperatura da superfície do mar (SST) — Open-Meteo Marine
/// (`sea_surface_temperature`). Some/mostra loading se a posição não
/// tiver esse dado (fora de cobertura do modelo marinho).
/// Uso: SeaSurfaceTemperatureCard(forecast: forecast)
class SeaSurfaceTemperatureCard extends BaseMeteorologyCard {
  final WaveForecast forecast;

  const SeaSurfaceTemperatureCard({super.key, required this.forecast})
      : super(
          cardColor: const Color(0xFFE3F2FD),
          borderRadius: 24,
        );

  @override
  bool get isLoading => forecast.current?.seaSurfaceTemperature == null;

  @override
  String get loadingMessage => 'Carregando temperatura da água...';

  @override
  Widget buildContent(BuildContext context) {
    final temperatura = forecast.current!.seaSurfaceTemperature!;

    return Column(
      children: [
        BaseMeteorologyCard.buildHeader(
          icon: Icons.thermostat,
          title: 'Temperatura da Água (SST)',
          color: Colors.blue,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              temperatura.toStringAsFixed(1),
              style: const TextStyle(fontSize: 62, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10, left: 4),
              child: Text('°C', style: TextStyle(fontSize: 22)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Superfície do mar · ${forecast.latitude.toStringAsFixed(2)}°, ${forecast.longitude.toStringAsFixed(2)}°',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
