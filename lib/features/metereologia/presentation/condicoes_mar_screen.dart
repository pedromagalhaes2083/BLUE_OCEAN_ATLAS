import 'package:flutter/material.dart';

import '../../widgets/posicao_atual_widget.dart';
import '../../widgets/previsao_tempo/previsao_tempo_widgets.dart';
import '../../widgets/profundidade_card.dart';
import '../../widgets/wave_forecast/wave_forecast_widgets.dart';
import '../data/previsao_tempo_repository.dart';
import '../data/profundidade_repository.dart';
import '../data/wave_forecast_repository.dart';
import '../domain/models/leitura_profundidade.dart';

/// Tela com as condições do mar (temperatura da água, corrente, ondas/swell
/// e clima) na posição atual da embarcação — ou em qualquer outra posição
/// informada manualmente.
///
/// Pra consultar um ponto fixo (ex: um ponto marcado no mapa), sem GPS nem
/// campo de posição manual, ver [CondicoesPontoScreen].
class CondicoesMarScreen extends StatefulWidget {
  const CondicoesMarScreen({super.key});

  @override
  State<CondicoesMarScreen> createState() => _CondicoesMarScreenState();
}

class _CondicoesMarScreenState extends State<CondicoesMarScreen> {
  // ── Posição em uso pra todas as buscas (GPS por padrão, ou manual) ──────
  double? _lat;
  double? _lon;

  // ── Dados via API (Open-Meteo) ───────────────────────────────────────────
  WaveForecast? _waveForecast;
  PrevisaoTempo? _previsaoTempo;
  LeituraProfundidade? _profundidade;
  bool _carregandoOceano = false;
  String? _erroOceano;

  Future<void> _buscarDadosOceano() async {
    if (_lat == null || _lon == null) return;

    setState(() {
      _carregandoOceano = true;
      _erroOceano = null;
    });
    try {
      final wave = await WaveForecastRepository()
          .buscar(latitude: _lat!, longitude: _lon!);
      final tempo = await PrevisaoTempoRepository()
          .buscar(latitude: _lat!, longitude: _lon!);
      final profundidade = await ProfundidadeRepository()
          .buscarPonto(latitude: _lat!, longitude: _lon!);

      if (!mounted) return;
      setState(() {
        _waveForecast = wave;
        _previsaoTempo = tempo;
        _profundidade = profundidade;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroOceano = 'Erro ao buscar previsão: $e');
    } finally {
      if (mounted) setState(() => _carregandoOceano = false);
    }
  }

  // ── Posição ──────────────────────────────────────────────────────────────

  void _atualizarPosicao(double lat, double lon) {
    setState(() {
      _lat = lat;
      _lon = lon;
    });
    _buscarDadosOceano();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Condições do Mar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PosicaoAtualWidget(
            onPosicaoObtida: (posicao) =>
                _atualizarPosicao(posicao.latitude, posicao.longitude),
          ),
          const SizedBox(height: 24),
          if (_lat == null || _lon == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aguardando posição atual da embarcação...',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_carregandoOceano)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_erroOceano != null)
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_erroOceano!,
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
