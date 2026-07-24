import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/chlorophyll_reading.dart';
import '../../../core/utils/proximidade.dart';
import '../../widgets/meteorology_widgets/chlorophyll_card.dart';
import '../../widgets/meteorology_widgets/current_card.dart';
import '../../widgets/posicao_atual_widget.dart';
import '../../widgets/posicao_manual_widget.dart';
import '../../widgets/previsao_tempo/previsao_tempo_widgets.dart';
import '../../widgets/wave_forecast/wave_forecast_widgets.dart';
import '../data/previsao_tempo_repository.dart';
import '../data/wave_forecast_repository.dart';

const _correntesAsset = 'assets/json/correntes.json';
const _clorofilaAsset = 'assets/json/clorofila.json';

/// Tela com as condições do mar (clorofila, temperatura da água, corrente,
/// ondas/swell e clima) na posição atual da embarcação — ou em qualquer
/// outra posição informada manualmente.
class CondicoesMarScreen extends StatefulWidget {
  const CondicoesMarScreen({super.key});

  @override
  State<CondicoesMarScreen> createState() => _CondicoesMarScreenState();
}

class _CondicoesMarScreenState extends State<CondicoesMarScreen> {
  // ── Posição em uso pra todas as buscas (GPS por padrão, ou manual) ──────
  double? _lat;
  double? _lon;

  // ── Dados locais (JSON bundled) ──────────────────────────────────────────
  List<dynamic> _correntes = [];
  List<dynamic> _clorofila = [];
  List<dynamic> _correntesExibidas = [];
  List<dynamic> _clorofilaExibida = [];
  bool _carregandoDadosLocais = true;
  String? _erroDadosLocais;

  // ── Dados via API (Open-Meteo) ───────────────────────────────────────────
  WaveForecast? _waveForecast;
  PrevisaoTempo? _previsaoTempo;
  bool _carregandoOceano = false;
  String? _erroOceano;

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
  }

  // ── Dados locais ──────────────────────────────────────────────────────────

  Future<void> _carregarDadosLocais() async {
    setState(() {
      _carregandoDadosLocais = true;
      _erroDadosLocais = null;
    });
    try {
      final correntesStr = await rootBundle.loadString(_correntesAsset);
      final clorofilaStr = await rootBundle.loadString(_clorofilaAsset);

      if (!mounted) return;
      setState(() {
        _correntes = (jsonDecode(correntesStr)['dados'] as List? ?? []);
        _clorofila = (jsonDecode(clorofilaStr)['dados'] as List? ?? []);
      });
      _aplicarFiltroLocal();
    } catch (e) {
      if (!mounted) return;
      setState(() => _erroDadosLocais = 'Erro ao carregar dados: $e');
    } finally {
      if (mounted) setState(() => _carregandoDadosLocais = false);
    }
  }

  void _aplicarFiltroLocal() {
    if (_lat == null || _lon == null) return;

    setState(() {
      _correntesExibidas = ordenarPorProximidade(
        _correntes,
        originLat: _lat!,
        originLon: _lon!,
      ).take(50).toList();

      _clorofilaExibida = ordenarPorProximidade(
        _clorofila,
        originLat: _lat!,
        originLon: _lon!,
      ).take(50).toList();
    });
  }

  double _distanciaDoPrimeiro(List<dynamic> lista) {
    if (lista.isEmpty || _lat == null || _lon == null) return 0;
    final item = lista.first;
    return calcularDistanciaNauticas(_lat!, _lon!, item['latitude'], item['longitude']);
  }

  // ── Dados via API ─────────────────────────────────────────────────────────

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

      if (!mounted) return;
      setState(() {
        _waveForecast = wave;
        _previsaoTempo = tempo;
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
    _aplicarFiltroLocal();
    _buscarDadosOceano();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Condições do Mar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregandoDadosLocais ? null : _carregarDadosLocais,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PosicaoAtualWidget(
            onPosicaoObtida: (posicao) =>
                _atualizarPosicao(posicao.latitude, posicao.longitude),
          ),
          const SizedBox(height: 12),
          PosicaoManualWidget(onBuscar: _atualizarPosicao),
          const SizedBox(height: 24),
          if (_carregandoDadosLocais)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_erroDadosLocais != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(_erroDadosLocais!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _carregarDadosLocais,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          else if (_lat == null || _lon == null)
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
          else ...[
            // Correntes já traz a temperatura da água junto.
            CurrentCard(
              dados: _correntesExibidas,
              distancia: _distanciaDoPrimeiro(_correntesExibidas),
            ),
            const SizedBox(height: 16),
            ChlorophyllCard(
              dataset: ChlorophyllDataset.fromRawList(
                _clorofilaExibida,
                originLat: _lat,
                originLon: _lon,
              ),
            ),
            const SizedBox(height: 16),

            // ── Dados via Open-Meteo ────────────────────────────────────────
            if (_carregandoOceano)
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
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              if (_previsaoTempo != null) ...[
                PrevisaoTempoAtualCard(previsao: _previsaoTempo!),
                const SizedBox(height: 12),
                PrevisaoTempoHourlyTimeline(previsao: _previsaoTempo!),
                const SizedBox(height: 16),
              ],
              if (_waveForecast != null) ...[
                WaveSummaryCard(forecast: _waveForecast!),
                if (_waveForecast!.current != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      SwellInfoRow(entry: _waveForecast!.current!),
                      OceanCurrentRow(entry: _waveForecast!.current!),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                WaveHourlyTimeline(forecast: _waveForecast!),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
