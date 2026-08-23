import 'package:flutter/material.dart';

import '../../../core/utils/coordenadas_format.dart';
import '../../widgets/previsao_tempo/previsao_tempo_widgets.dart';
import '../../widgets/profundidade_card.dart';
import '../../widgets/wave_forecast/wave_forecast_widgets.dart';
import '../data/previsao_tempo_repository.dart';
import '../data/profundidade_repository.dart';
import '../data/wave_forecast_repository.dart';
import '../domain/models/leitura_profundidade.dart';

/// Condições do mar travadas num único ponto de referência — diferente de
/// [CondicoesMarScreen], não tem GPS nem campo de posição manual, então não
/// tem como o usuário trocar sem querer pra outra posição no meio da
/// consulta. Usada a partir de "Consultar aqui" no diálogo de um ponto
/// marcado no mapa (ver `MapaWidget`).
class CondicoesPontoScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  /// Nome do ponto marcado, se tiver — vira o título da tela.
  final String? nome;

  const CondicoesPontoScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.nome,
  });

  @override
  State<CondicoesPontoScreen> createState() => _CondicoesPontoScreenState();
}

class _CondicoesPontoScreenState extends State<CondicoesPontoScreen> {
  WaveForecast? _waveForecast;
  PrevisaoTempo? _previsaoTempo;
  LeituraProfundidade? _profundidade;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _buscarDadosOceano();
  }

  Future<void> _buscarDadosOceano() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final wave = await WaveForecastRepository()
          .buscar(latitude: widget.latitude, longitude: widget.longitude);
      final tempo = await PrevisaoTempoRepository()
          .buscar(latitude: widget.latitude, longitude: widget.longitude);
      final profundidade = await ProfundidadeRepository().buscarPonto(
          latitude: widget.latitude, longitude: widget.longitude);

      if (!mounted) return;
      setState(() {
        _waveForecast = wave;
        _previsaoTempo = tempo;
        _profundidade = profundidade;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = 'Erro ao buscar previsão: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nome?.isNotEmpty == true ? widget.nome! : 'Condições do Ponto',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _carregando ? null : _buscarDadosOceano,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.push_pin, color: Colors.blue[900]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatarCoordenadasDMSCompacta(
                          widget.latitude, widget.longitude),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_carregando)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_erro != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_erro!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (_profundidade != null || _waveForecast != null) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_profundidade != null)
                      Expanded(child: ProfundidadeCard(leitura: _profundidade!)),
                    if (_profundidade != null && _waveForecast != null)
                      const SizedBox(width: 12),
                    if (_waveForecast != null)
                      Expanded(
                          child:
                              SeaSurfaceTemperatureCard(forecast: _waveForecast!)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_previsaoTempo != null) ...[
              CondicoesVentoCard(previsao: _previsaoTempo!),
              const SizedBox(height: 16),
            ],
            if (_waveForecast != null) ...[
              CondicoesAtuaisCard(forecast: _waveForecast!),
              const SizedBox(height: 16),
              MareCard(forecast: _waveForecast!),
            ],
          ],
        ],
      ),
    );
  }
}
