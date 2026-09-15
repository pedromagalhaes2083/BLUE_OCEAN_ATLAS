import 'package:flutter/material.dart';

import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../widgets/offline_dados_banner.dart';
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

  /// `true` quando pelo menos um dos três dados acima veio do cache local
  /// (sem rede agora) em vez da API ao vivo — ver `DadosPontoCacheService`.
  bool _dadosOffline = false;
  DateTime? _dadosOfflineEm;

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
      final waveRepo = WaveForecastRepository();
      final tempoRepo = PrevisaoTempoRepository();
      final profundidadeRepo = ProfundidadeRepository();

      final wave = await waveRepo.buscar(
          latitude: widget.latitude, longitude: widget.longitude);
      final tempo = await tempoRepo.buscar(
          latitude: widget.latitude, longitude: widget.longitude);
      final profundidade = await profundidadeRepo.buscarPonto(
          latitude: widget.latitude, longitude: widget.longitude);

      if (!mounted) return;
      final offlines = [
        if (waveRepo.ultimoResultadoOffline) waveRepo.ultimaAtualizacaoCache,
        if (tempoRepo.ultimoResultadoOffline) tempoRepo.ultimaAtualizacaoCache,
        if (profundidadeRepo.ultimoResultadoOffline)
          profundidadeRepo.ultimaAtualizacaoCache,
      ];
      setState(() {
        _waveForecast = wave;
        _previsaoTempo = tempo;
        _profundidade = profundidade;
        _dadosOffline = offlines.isNotEmpty;
        _dadosOfflineEm = offlines.isEmpty
            ? null
            : offlines.whereType<DateTime>().fold<DateTime?>(
                null,
                (maisAntigo, em) =>
                    maisAntigo == null || em.isBefore(maisAntigo)
                        ? em
                        : maisAntigo,
              );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = mensagemErroAmigavel(e,
          prefixo: AppLocalizations.of(context).erroBuscarPrevisaoPrefixo));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final escuroTelaPonto = Theme.of(context).brightness == Brightness.dark;
    final corPinPonto =
        escuroTelaPonto ? Colors.blue.shade200 : Colors.blue.shade900;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.nome?.isNotEmpty == true
              ? widget.nome!
              : l10n.condicoesPontoTituloFallback,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.viagemAtualizarTooltip,
            onPressed: _carregando ? null : _buscarDadosOceano,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: escuroTelaPonto
                ? Colors.blue.withValues(alpha: 0.18)
                : Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.push_pin, color: corPinPonto),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatarCoordenadasDMSCompacta(
                          widget.latitude, widget.longitude),
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: corPinPonto),
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
                    Icon(
                        _erro == mensagemSemConexao
                            ? Icons.wifi_off_outlined
                            : Icons.error_outline,
                        color: Colors.red),
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
            if (_dadosOffline) ...[
              OfflineDadosBanner(em: _dadosOfflineEm),
              const SizedBox(height: 16),
            ],
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
