import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../metereologia/data/wave_forecast_repository.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import 'mapa_widget.dart';

class MapaScreen extends StatelessWidget {
  /// Se informada, os pontos dessa recomendação são exibidos como
  /// marcadores sobre a carta, com o mapa centralizado neles.
  final Recomendacao? recomendacao;

  const MapaScreen({super.key, this.recomendacao});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recomendacao != null
              ? recomendacao!.titulo.isEmpty
                  ? 'Recomendação'
                  : recomendacao!.titulo
              : 'Mapa',
        ),
      ),
      body: Stack(
        children: [
          MapaWidget(recomendacao: recomendacao, margemZoom: 4),
          const Positioned(
            left: 12,
            bottom: 12,
            child: _SstFlutuante(),
          ),
        ],
      ),
    );
  }
}

/// Mini widget flutuante com a temperatura da superfície do mar (SST) na
/// posição atual — sobreposto ao mapa, no canto inferior esquerdo.
class _SstFlutuante extends StatefulWidget {
  const _SstFlutuante();

  @override
  State<_SstFlutuante> createState() => _SstFlutuanteState();
}

class _SstFlutuanteState extends State<_SstFlutuante> {
  bool _carregando = true;
  double? _temperatura;

  @override
  void initState() {
    super.initState();
    _carregarTemperatura();
  }

  Future<void> _carregarTemperatura() async {
    try {
      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 20));

      final forecast = await WaveForecastRepository().buscar(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
      );

      if (!mounted) return;
      setState(() {
        _temperatura = forecast.current?.seaSurfaceTemperature;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sem dado (posição em terra, sem GPS ou erro na API) — não mostra nada.
    if (!_carregando && _temperatura == null) return const SizedBox.shrink();

    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: _carregando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.thermostat, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${_temperatura!.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'SST',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }
}
