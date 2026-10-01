import 'package:flutter/material.dart';

import '../../../core/config/calibracao_intelligence.dart';
import '../../../core/planos/plano_service.dart';
import '../../../core/planos/recurso_atlas.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../widgets/recurso_protegido.dart';

/// Tela pra ajustar a calibração do "Índice de Inteligência Oceânica" —
/// hoje um índice de favorabilidade para presença de atum (ver
/// `IntelligenceEngine`/`CalibracaoIntelligence`), com pesos e faixas
/// pré-configurados a partir de um prompt de especialista em oceanografia
/// pesqueira, mas ajustáveis aqui. Três eixos por fator:
///
/// - **Peso**: importância relativa no score final.
/// - **Faixa ideal**: intervalo (min–max) que dá nota máxima
///   ("Excelente" no prompt original) — um [RangeSlider], não um valor só,
///   já que os fatores originais são faixas, não um ponto único.
/// - **Margem**: até quanto além da faixa ideal ainda dá nota parcial
///   ("Moderada") antes de virar "Baixa" — ver doc de
///   [CalibracaoIntelligence] pra onde isso simplifica uma margem
///   assimétrica do prompt original.
///
/// Mesmo padrão visual/de persistência da versão anterior desta tela: um
/// card por fator, salvando a cada mudança, sem botão "Salvar" separado.
class IntelligenceCalibracaoScreen extends StatefulWidget {
  const IntelligenceCalibracaoScreen({super.key});

  @override
  State<IntelligenceCalibracaoScreen> createState() =>
      _IntelligenceCalibracaoScreenState();
}

class _IntelligenceCalibracaoScreenState
    extends State<IntelligenceCalibracaoScreen> {
  CalibracaoIntelligence _calibracao = CalibracaoIntelligence.padrao;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final calibracao = await CalibracaoIntelligence.carregar();
    if (!mounted) return;
    setState(() {
      _calibracao = calibracao;
      _carregando = false;
    });
  }

  Future<void> _atualizar(CalibracaoIntelligence novo) async {
    setState(() => _calibracao = novo);
    await novo.salvar();
  }

  /// Só atualiza o estado local, sem gravar — usado no `onChanged` do
  /// slider (dispara a cada pixel arrastado). A gravação de verdade fica
  /// pro `onChangeEnd` (ver [_atualizar]).
  void _atualizarLocal(CalibracaoIntelligence novo) {
    setState(() => _calibracao = novo);
  }

  Future<void> _restaurarPadrao() async {
    await _atualizar(CalibracaoIntelligence.padrao);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              AppLocalizations.of(context).intelligenceCalibracaoRestauradoAviso)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.intelligenceCalibracaoTitulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: l10n.intelligenceCalibracaoRestaurarPadrao,
            onPressed: _carregando ? null : _restaurarPadrao,
          ),
        ],
      ),
      body: !PlanoService.possui(RecursoAtlas.intelligenceOceanica)
          ? CardUpgradePlano.telaCheia(context, RecursoAtlas.intelligenceOceanica)
          : _carregando
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      l10n.intelligenceCalibracaoDescricao,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    _CardFator(
                      icon: Icons.thermostat,
                      titulo: l10n.intelligenceCondSst,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoTemperatura,
                      idealMin: _calibracao.temperaturaIdealMinC,
                      idealMax: _calibracao.temperaturaIdealMaxC,
                      margem: _calibracao.temperaturaMargemC,
                      faixaMin: 10,
                      faixaMax: 35,
                      faixaDivisoes: 50,
                      unidade: '°C',
                      casasDecimais: 1,
                      margemMax: 5,
                      margemDivisoes: 20,
                      onPesoChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(pesoTemperatura: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoTemperatura: v)),
                      onIdealChanged: (min, max) => _atualizarLocal(_calibracao
                          .copyWith(
                              temperaturaIdealMinC: min,
                              temperaturaIdealMaxC: max)),
                      onIdealChangedFim: (min, max) => _atualizar(_calibracao
                          .copyWith(
                              temperaturaIdealMinC: min,
                              temperaturaIdealMaxC: max)),
                      onMargemChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(temperaturaMargemC: v)),
                      onMargemChangedFim: (v) => _atualizar(
                          _calibracao.copyWith(temperaturaMargemC: v)),
                    ),
                    const SizedBox(height: 12),
                    _CardFator(
                      icon: Icons.water_drop_outlined,
                      titulo: l10n.salinidadeTitulo,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoSalinidade,
                      idealMin: _calibracao.salinidadeIdealMinUps,
                      idealMax: _calibracao.salinidadeIdealMaxUps,
                      margem: _calibracao.salinidadeMargemUps,
                      faixaMin: 30,
                      faixaMax: 40,
                      faixaDivisoes: 50,
                      unidade: 'PSU',
                      casasDecimais: 1,
                      margemMax: 2,
                      margemDivisoes: 20,
                      onPesoChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(pesoSalinidade: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoSalinidade: v)),
                      onIdealChanged: (min, max) => _atualizarLocal(_calibracao
                          .copyWith(
                              salinidadeIdealMinUps: min,
                              salinidadeIdealMaxUps: max)),
                      onIdealChangedFim: (min, max) => _atualizar(_calibracao
                          .copyWith(
                              salinidadeIdealMinUps: min,
                              salinidadeIdealMaxUps: max)),
                      onMargemChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(salinidadeMargemUps: v)),
                      onMargemChangedFim: (v) => _atualizar(
                          _calibracao.copyWith(salinidadeMargemUps: v)),
                    ),
                    const SizedBox(height: 12),
                    _CardFator(
                      icon: Icons.eco,
                      titulo: l10n.intelligenceCondClorofila,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoClorofila,
                      idealMin: _calibracao.clorofilaIdealMinMgM3,
                      idealMax: _calibracao.clorofilaIdealMaxMgM3,
                      margem: _calibracao.clorofilaMargemMgM3,
                      faixaMin: 0,
                      faixaMax: 0.5,
                      faixaDivisoes: 50,
                      unidade: 'mg/m³',
                      casasDecimais: 2,
                      margemMax: 0.2,
                      margemDivisoes: 20,
                      onPesoChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(pesoClorofila: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoClorofila: v)),
                      onIdealChanged: (min, max) => _atualizarLocal(_calibracao
                          .copyWith(
                              clorofilaIdealMinMgM3: min,
                              clorofilaIdealMaxMgM3: max)),
                      onIdealChangedFim: (min, max) => _atualizar(_calibracao
                          .copyWith(
                              clorofilaIdealMinMgM3: min,
                              clorofilaIdealMaxMgM3: max)),
                      onMargemChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(clorofilaMargemMgM3: v)),
                      onMargemChangedFim: (v) => _atualizar(
                          _calibracao.copyWith(clorofilaMargemMgM3: v)),
                    ),
                    const SizedBox(height: 12),
                    _CardFator(
                      icon: Icons.water,
                      titulo: l10n.intelligenceCondCorrente,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoCorrente,
                      idealMin: _calibracao.correnteIdealMinNos,
                      idealMax: _calibracao.correnteIdealMaxNos,
                      margem: _calibracao.correnteMargemNos,
                      faixaMin: 0,
                      faixaMax: 3,
                      faixaDivisoes: 30,
                      unidade: 'nós',
                      casasDecimais: 1,
                      margemMax: 1.5,
                      margemDivisoes: 15,
                      onPesoChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(pesoCorrente: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoCorrente: v)),
                      onIdealChanged: (min, max) => _atualizarLocal(_calibracao
                          .copyWith(
                              correnteIdealMinNos: min,
                              correnteIdealMaxNos: max)),
                      onIdealChangedFim: (min, max) => _atualizar(_calibracao
                          .copyWith(
                              correnteIdealMinNos: min,
                              correnteIdealMaxNos: max)),
                      onMargemChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(correnteMargemNos: v)),
                      onMargemChangedFim: (v) => _atualizar(
                          _calibracao.copyWith(correnteMargemNos: v)),
                    ),
                    const SizedBox(height: 12),
                    _CardFator(
                      icon: Icons.terrain,
                      titulo: l10n.intelligenceCondProfundidade,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoBatimetria,
                      idealMin: _calibracao.batimetriaIdealMinM,
                      idealMax: _calibracao.batimetriaIdealMaxM,
                      margem: _calibracao.batimetriaMargemM,
                      faixaMin: 0,
                      faixaMax: 4000,
                      faixaDivisoes: 40,
                      unidade: 'm',
                      casasDecimais: 0,
                      margemMax: 1500,
                      margemDivisoes: 30,
                      onPesoChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(pesoBatimetria: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoBatimetria: v)),
                      onIdealChanged: (min, max) => _atualizarLocal(_calibracao
                          .copyWith(
                              batimetriaIdealMinM: min,
                              batimetriaIdealMaxM: max)),
                      onIdealChangedFim: (min, max) => _atualizar(_calibracao
                          .copyWith(
                              batimetriaIdealMinM: min,
                              batimetriaIdealMaxM: max)),
                      onMargemChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(batimetriaMargemM: v)),
                      onMargemChangedFim: (v) => _atualizar(
                          _calibracao.copyWith(batimetriaMargemM: v)),
                    ),
                  ],
                ),
    );
  }
}

class _CardFator extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final CalibracaoIntelligence calibracao;

  final double peso;
  final ValueChanged<double> onPesoChanged;
  final ValueChanged<double> onPesoChangedFim;

  final double idealMin;
  final double idealMax;
  final double faixaMin;
  final double faixaMax;
  final int faixaDivisoes;
  final String unidade;
  final int casasDecimais;
  final void Function(double min, double max) onIdealChanged;
  final void Function(double min, double max) onIdealChangedFim;

  final double margem;
  final double margemMax;
  final int margemDivisoes;
  final ValueChanged<double> onMargemChanged;
  final ValueChanged<double> onMargemChangedFim;

  const _CardFator({
    required this.icon,
    required this.titulo,
    required this.calibracao,
    required this.peso,
    required this.onPesoChanged,
    required this.onPesoChangedFim,
    required this.idealMin,
    required this.idealMax,
    required this.faixaMin,
    required this.faixaMax,
    required this.faixaDivisoes,
    required this.unidade,
    required this.casasDecimais,
    required this.onIdealChanged,
    required this.onIdealChangedFim,
    required this.margem,
    required this.margemMax,
    required this.margemDivisoes,
    required this.onMargemChanged,
    required this.onMargemChangedFim,
  });

  static const _pesoMin = 0.0;
  static const _pesoMax = 60.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final participacao = calibracao.participacao(peso);
    final faixaValores = RangeValues(
      idealMin.clamp(faixaMin, faixaMax),
      idealMax.clamp(faixaMin, faixaMax),
    );
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(titulo,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(l10n.intelligenceCalibracaoPesoLabel,
                      style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                ),
                Expanded(
                  child: Slider(
                    value: peso.clamp(_pesoMin, _pesoMax),
                    min: _pesoMin,
                    max: _pesoMax,
                    divisions: 60,
                    label: peso.toStringAsFixed(0),
                    onChanged: onPesoChanged,
                    onChangeEnd: onPesoChangedFim,
                  ),
                ),
                SizedBox(
                  width: 68,
                  child: Text(
                    '${peso.toStringAsFixed(0)} (${participacao.toStringAsFixed(0)}%)',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(l10n.intelligenceCalibracaoFaixaIdealLabel,
                      style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                ),
                Expanded(
                  child: RangeSlider(
                    values: faixaValores,
                    min: faixaMin,
                    max: faixaMax,
                    divisions: faixaDivisoes,
                    labels: RangeLabels(
                      faixaValores.start.toStringAsFixed(casasDecimais),
                      faixaValores.end.toStringAsFixed(casasDecimais),
                    ),
                    onChanged: (v) => onIdealChanged(v.start, v.end),
                    onChangeEnd: (v) => onIdealChangedFim(v.start, v.end),
                  ),
                ),
                SizedBox(
                  width: 68,
                  child: Text(
                    '${faixaValores.start.toStringAsFixed(casasDecimais)}–'
                    '${faixaValores.end.toStringAsFixed(casasDecimais)} $unidade',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(l10n.intelligenceCalibracaoMargemLabel,
                      style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                ),
                Expanded(
                  child: Slider(
                    value: margem.clamp(0, margemMax),
                    min: 0,
                    max: margemMax,
                    divisions: margemDivisoes,
                    label: '±${margem.toStringAsFixed(casasDecimais)}',
                    onChanged: onMargemChanged,
                    onChangeEnd: onMargemChangedFim,
                  ),
                ),
                SizedBox(
                  width: 68,
                  child: Text(
                    '±${margem.toStringAsFixed(casasDecimais)} $unidade',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
