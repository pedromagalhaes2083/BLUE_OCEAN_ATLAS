import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../metereologia/data/wave_forecast_repository.dart';
import '../../producao/domain/models/producao_registro.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../../rotas/domain/models/rota_planejada.dart';
import 'mapa_widget.dart';

class MapaScreen extends StatelessWidget {
  /// Se informada, os pontos dessa recomendação são exibidos como
  /// marcadores sobre a carta, com o mapa centralizado neles.
  final Recomendacao? recomendacao;

  /// Se informada, os pontos são ligados por uma linha sobre a carta —
  /// usado para exibir uma rota de histórico de GPS.
  final List<LatLng>? rota;

  /// Se true, abre o mapa em modo de planejamento de rota — ver
  /// [MapaWidget.modoPlanejarRota].
  final bool modoPlanejarRota;

  /// Se informada, cada registro vira um marcador e, havendo 2+, uma linha
  /// os liga em ordem cronológica — ver [MapaWidget.producaoPontos].
  final List<ProducaoRegistro>? producaoPontos;

  /// Se informada (junto com [modoPlanejarRota]), abre em modo de edição
  /// dessa rota já salva, em vez de criar uma nova — ver
  /// [MapaWidget.rotaParaEditar].
  final RotaPlanejada? rotaParaEditar;

  const MapaScreen({
    super.key,
    this.recomendacao,
    this.rota,
    this.modoPlanejarRota = false,
    this.producaoPontos,
    this.rotaParaEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          modoPlanejarRota
              ? (rotaParaEditar != null ? 'Editar Rota' : 'Nova Rota Planejada')
              : recomendacao != null
                  ? recomendacao!.titulo.isEmpty
                      ? 'Recomendação'
                      : recomendacao!.titulo
                  : producaoPontos != null
                      ? 'Rota de Produção'
                      : rota != null
                          ? 'Rota do histórico'
                          : 'Mapa',
        ),
      ),
      body: Stack(
        children: [
          MapaWidget(
            recomendacao: recomendacao,
            rota: rota,
            margemZoom: 4,
            modoPlanejarRota: modoPlanejarRota,
            producaoPontos: producaoPontos,
            rotaParaEditar: rotaParaEditar,
          ),
          if (!modoPlanejarRota && producaoPontos == null)
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
