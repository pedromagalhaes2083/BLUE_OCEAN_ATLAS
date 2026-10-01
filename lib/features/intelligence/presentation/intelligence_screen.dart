import 'package:flutter/material.dart';

import '../../../core/planos/plano_service.dart';
import '../../../core/planos/recurso_atlas.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../mapa/presentation/meus_pontos_screen.dart';
import '../../recomendacao/widgets/recomendacao_score_badge.dart';
import '../../widgets/posicao_atual_widget.dart';
import '../../widgets/recurso_protegido.dart';
import '../../widgets/termoclina/grafico_perfil_termico.dart';
import '../data/intelligence_repository.dart';
import '../domain/models/intelligence_factor.dart';
import '../domain/models/intelligence_result.dart';
import 'intelligence_calibracao_screen.dart';

/// Tela "Inteligência" (Blue Ocean Intelligence) — um índice de 0 a 100
/// ("Inteligência Oceânica") que resume as condições ambientais
/// disponíveis num ponto, mais um indicador de confiança separado (ver
/// `IntelligenceEngine`). **Não é uma probabilidade de pesca** — nenhum
/// dado de produção/captura/CPUE entra aqui.
///
/// Mesmo padrão de ponto fixo opcional de `TermoclinaScreen`/
/// `MareEPescaAtumScreen`: com [latitude]/[longitude] informados (vindo de
/// um ponto marcado ou de uma recomendação no mapa), consulta direto essa
/// coordenada, sem GPS; sem eles (entrada pelo menu), usa a posição atual
/// da embarcação como sempre.
///
/// Reaproveita os mesmos repositories já usados em outras telas
/// (`WaveForecastRepository`, `PrevisaoTempoRepository`,
/// `ProfundidadeRepository`, `ClorofilaRepository`, `TermoclinaRepository`
/// — ver `IntelligenceRepository`) e o mesmo gráfico de perfil térmico da
/// Termoclina — nenhum sistema de mapa/gráfico novo.
class IntelligenceScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? nomePonto;

  const IntelligenceScreen({super.key, this.latitude, this.longitude, this.nomePonto});

  bool get _pontoFixo => latitude != null && longitude != null;

  @override
  State<IntelligenceScreen> createState() => _IntelligenceScreenState();
}

class _IntelligenceScreenState extends State<IntelligenceScreen> {
  final _repository = IntelligenceRepository();

  double? _lat;
  double? _lon;

  IntelligenceResult? _resultado;
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    if (widget._pontoFixo) {
      _lat = widget.latitude;
      _lon = widget.longitude;
      _buscarDados();
    }
  }

  Future<void> _buscarDados() async {
    if (_lat == null || _lon == null) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultado =
          await _repository.avaliarPonto(latitude: _lat!, longitude: _lon!);
      if (!mounted) return;
      setState(() => _resultado = resultado);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erro = mensagemErroAmigavel(e,
          prefixo: AppLocalizations.of(context).intelligenceErroMensagem));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _atualizarPosicao(double lat, double lon) {
    setState(() {
      _lat = lat;
      _lon = lon;
    });
    _buscarDados();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._pontoFixo
            ? (widget.nomePonto?.isNotEmpty == true
                ? widget.nomePonto!
                : l10n.intelligenceTelaTitulo)
            : l10n.intelligenceTelaTitulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: l10n.intelligenceCalibracaoTooltip,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const IntelligenceCalibracaoScreen()),
            ),
          ),
          if (widget._pontoFixo)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.viagemAtualizarTooltip,
              onPressed: _carregando ? null : _buscarDados,
            )
          else
            IconButton(
              icon: const Icon(Icons.pin_drop),
              tooltip: l10n.mapaMeusPontosTooltip,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeusPontosScreen()),
              ),
            ),
        ],
      ),
      body: !PlanoService.possui(RecursoAtlas.intelligenceOceanica)
          ? CardUpgradePlano.telaCheia(context, RecursoAtlas.intelligenceOceanica)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.intelligenceSubtitulo,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                if (widget._pontoFixo)
                  _cardPontoFixo(context)
                else
                  PosicaoAtualWidget(
                    onPosicaoObtida: (posicao) =>
                        _atualizarPosicao(posicao.latitude, posicao.longitude),
                  ),
                const SizedBox(height: 16),
                if (_lat == null || _lon == null)
                  _mensagemCentral(l10n.intelligenceAguardandoPosicao)
                else if (_carregando && _resultado == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_erro != null && _resultado == null)
                  _cardErro(context)
                else if (_resultado == null)
                  _mensagemCentral(l10n.intelligenceSemDadosMensagem)
                else ...[
                  if (_erro != null) ...[
                    _cardErro(context),
                    const SizedBox(height: 12),
                  ],
                  if (_resultado!.factors.any((f) => !f.disponivel)) ...[
                    _cardParcial(context),
                    const SizedBox(height: 12),
                  ],
                  _CardScoreConfianca(resultado: _resultado!),
                  const SizedBox(height: 16),
                  _CondicoesAtuais(resultado: _resultado!),
                  const SizedBox(height: 20),
                  _EstruturaTermica(resultado: _resultado!),
                  const SizedBox(height: 20),
                  _CardFatores(resultado: _resultado!),
                  const SizedBox(height: 16),
                  _CardExplicacao(resultado: _resultado!),
                  const SizedBox(height: 16),
                  const _CardBlueOceanAi(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _carregando ? null : _buscarDados,
                      icon: _carregando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(l10n.intelligenceAtualizarBotao),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _cardPontoFixo(BuildContext context) {
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final cor = escuro ? Colors.blue.shade200 : Colors.blue.shade900;
    return Card(
      color: escuro ? Colors.blue.withValues(alpha: 0.18) : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.push_pin, color: cor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${widget.latitude!.toStringAsFixed(4)}, '
                '${widget.longitude!.toStringAsFixed(4)}',
                style: TextStyle(fontWeight: FontWeight.w600, color: cor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mensagemCentral(String texto) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
        ),
      );

  Widget _cardErro(BuildContext context) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    _erro == mensagemSemConexao
                        ? Icons.wifi_off_outlined
                        : Icons.error_outline,
                    color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      Text(_erro!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _carregando ? null : _buscarDados,
                child: Text(AppLocalizations.of(context).dashboardTentarNovamente),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardParcial(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      color: Colors.amber.withValues(alpha: 0.15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.amber.shade800),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.intelligenceParcialAviso,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _rotuloClassificacao(
    AppLocalizations l10n, IntelligenceClassificacao classificacao) =>
    switch (classificacao) {
      IntelligenceClassificacao.baixa => l10n.intelligenceClassificacaoBaixa,
      IntelligenceClassificacao.moderada =>
        l10n.intelligenceClassificacaoModerada,
      IntelligenceClassificacao.favoravel =>
        l10n.intelligenceClassificacaoFavoravel,
      IntelligenceClassificacao.muitoFavoravel =>
        l10n.intelligenceClassificacaoMuitoFavoravel,
    };

class _CardScoreConfianca extends StatelessWidget {
  final IntelligenceResult resultado;
  const _CardScoreConfianca({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hora = '${resultado.instante.hour.toString().padLeft(2, '0')}:'
        '${resultado.instante.minute.toString().padLeft(2, '0')}';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            RecomendacaoScoreBadge(score: resultado.score, tamanho: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.intelligenceScoreLabel,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('${resultado.score.round()}/100',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(_rotuloClassificacao(l10n, resultado.classificacao),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.verified_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${l10n.intelligenceConfiancaLabel}: '
                        '${resultado.confianca.round()}%',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(l10n.intelligenceAtualizadoAs(hora),
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CondicoesAtuais extends StatelessWidget {
  final IntelligenceResult resultado;
  const _CondicoesAtuais({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = resultado.conditions;
    final cards = <Widget>[
      if (c.sst != null)
        _cardCondicao(context, Icons.thermostat, l10n.intelligenceCondSst,
            '${c.sst!.toStringAsFixed(1)} °C'),
      if (c.correnteNos != null)
        _cardCondicao(context, Icons.water, l10n.intelligenceCondCorrente,
            '${c.correnteNos!.toStringAsFixed(1)} nós'),
      if (c.salinidadeUps != null)
        _cardCondicao(context, Icons.water_drop_outlined, l10n.salinidadeTitulo,
            '${c.salinidadeUps!.toStringAsFixed(1)} PSU'),
      if (c.ondaAlturaM != null)
        _cardCondicao(context, Icons.waves, l10n.intelligenceCondOndas,
            '${c.ondaAlturaM!.toStringAsFixed(1)} m'),
      if (c.swellAlturaM != null)
        _cardCondicao(context, Icons.tsunami_outlined, l10n.intelligenceCondSwell,
            '${c.swellAlturaM!.toStringAsFixed(1)} m'),
      if (c.ventoKmh != null)
        _cardCondicao(context, Icons.air, l10n.intelligenceCondVento,
            '${c.ventoKmh!.toStringAsFixed(0)} km/h'),
      if (c.mareAlturaM != null)
        _cardCondicao(context, Icons.waves_outlined, l10n.intelligenceCondMare,
            '${c.mareAlturaM!.toStringAsFixed(2)} m'),
      if (c.profundidadeM != null)
        _cardCondicao(context, Icons.terrain, l10n.intelligenceCondProfundidade,
            '${c.profundidadeM!.toStringAsFixed(0)} m'),
      if (c.clorofilaMgM3 != null)
        _cardCondicao(context, Icons.eco, l10n.intelligenceCondClorofila,
            '${c.clorofilaMgM3!.toStringAsFixed(2)} mg/m³'),
    ];

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.intelligenceCondicoesTitulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards,
        ),
      ],
    );
  }

  Widget _cardCondicao(
      BuildContext context, IconData icon, String titulo, String valor) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 6),
              Text(valor,
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(titulo,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstruturaTermica extends StatelessWidget {
  final IntelligenceResult resultado;
  const _EstruturaTermica({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final termoclina = resultado.thermocline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.intelligenceEstruturaTermicaTitulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (termoclina == null)
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.show_chart,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.intelligencePerfilIndisponivelTitulo,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(l10n.intelligencePerfilIndisponivelDescricao,
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${termoclina.profundidadeTermoclina.toStringAsFixed(0)} m',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(l10n.termoclinaProfundidadeLabel,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  GraficoPerfilTermico(
                    perfil: termoclina.perfil,
                    profundidadeTermoclinaM: termoclina.profundidadeTermoclina,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CardFatores extends StatelessWidget {
  final IntelligenceResult resultado;
  const _CardFatores({required this.resultado});

  Color _cor(IntelligenceFactorStatus status) => switch (status) {
        IntelligenceFactorStatus.favoravel => Colors.green,
        IntelligenceFactorStatus.neutro => Colors.amber.shade800,
        IntelligenceFactorStatus.desfavoravel => Colors.redAccent,
        IntelligenceFactorStatus.indisponivel => Colors.grey,
      };

  String _rotulo(AppLocalizations l10n, IntelligenceFactorStatus status) =>
      switch (status) {
        IntelligenceFactorStatus.favoravel => l10n.intelligenceFatorFavoravel,
        IntelligenceFactorStatus.neutro => l10n.intelligenceFatorNeutro,
        IntelligenceFactorStatus.desfavoravel => l10n.intelligenceFatorDesfavoravel,
        IntelligenceFactorStatus.indisponivel => l10n.intelligenceFatorIndisponivel,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.intelligenceFatoresTitulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final fator in resultado.factors) ...[
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.circle, size: 10, color: _cor(fator.status)),
                    title: Text(fator.nome),
                    trailing: Text(
                      fator.disponivel
                          ? '${fator.pontuacao!.round()} · ${_rotulo(l10n, fator.status)}'
                          : _rotulo(l10n, fator.status),
                      style: TextStyle(
                          color: _cor(fator.status), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CardExplicacao extends StatelessWidget {
  final IntelligenceResult resultado;
  const _CardExplicacao({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.intelligenceExplicacaoTitulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(resultado.explicacao, style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

class _CardBlueOceanAi extends StatelessWidget {
  const _CardBlueOceanAi();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(l10n.intelligenceAiTitulo,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(l10n.intelligenceAiTexto, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.intelligenceAiPreparando)),
                ),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text(l10n.intelligenceAiBotao),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
