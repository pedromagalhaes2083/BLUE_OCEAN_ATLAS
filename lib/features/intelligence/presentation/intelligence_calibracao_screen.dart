import 'package:flutter/material.dart';

import '../../../core/config/calibracao_intelligence.dart';
import '../../../core/planos/plano_service.dart';
import '../../../core/planos/recurso_atlas.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../widgets/recurso_protegido.dart';

/// Tela pra ajustar os dois eixos de calibração do cálculo da
/// "Inteligência Oceânica" (ver `IntelligenceEngine`/
/// `CalibracaoIntelligence`) — por fator: **peso** (importância relativa
/// no score) e **quantidade ideal** (o valor que dá nota máxima àquele
/// fator, ex: qual SST é considerada ideal). Mesmo padrão visual/de
/// persistência de `AlertaConfigScreen` (`LimiaresAlerta`): um card por
/// fator, salvando a cada mudança, sem botão "Salvar" separado.
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
                      peso: _calibracao.pesoSst,
                      ideal: _calibracao.sstIdealC,
                      idealMin: 15,
                      idealMax: 32,
                      idealDivisoes: 34,
                      idealUnidade: '°C',
                      idealCasasDecimais: 1,
                      onPesoChanged: (v) =>
                          _atualizarLocal(_calibracao.copyWith(pesoSst: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoSst: v)),
                      onIdealChanged: (v) =>
                          _atualizarLocal(_calibracao.copyWith(sstIdealC: v)),
                      onIdealChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(sstIdealC: v)),
                    ),
                    const SizedBox(height: 12),
                    _CardFator(
                      icon: Icons.water,
                      titulo: l10n.intelligenceCondCorrente,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoCorrente,
                      ideal: _calibracao.correnteIdealNos,
                      idealMin: 0.1,
                      idealMax: 2.0,
                      idealDivisoes: 19,
                      idealUnidade: 'nós',
                      idealCasasDecimais: 1,
                      onPesoChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(pesoCorrente: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoCorrente: v)),
                      onIdealChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(correnteIdealNos: v)),
                      onIdealChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(correnteIdealNos: v)),
                    ),
                    const SizedBox(height: 12),
                    _CardFator(
                      icon: Icons.eco,
                      titulo: l10n.intelligenceCondClorofila,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoClorofila,
                      ideal: _calibracao.clorofilaIdealMgM3,
                      idealMin: 0.05,
                      idealMax: 0.5,
                      idealDivisoes: 45,
                      idealUnidade: 'mg/m³',
                      idealCasasDecimais: 2,
                      onPesoChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(pesoClorofila: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoClorofila: v)),
                      onIdealChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(clorofilaIdealMgM3: v)),
                      onIdealChangedFim: (v) => _atualizar(
                          _calibracao.copyWith(clorofilaIdealMgM3: v)),
                    ),
                    const SizedBox(height: 12),
                    _CardFator(
                      icon: Icons.waves,
                      titulo: l10n.intelligenceCondOndas,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoOndas,
                      ideal: _calibracao.ondaIdealM,
                      idealMin: 0.2,
                      idealMax: 2.0,
                      idealDivisoes: 18,
                      idealUnidade: 'm',
                      idealCasasDecimais: 1,
                      onPesoChanged: (v) =>
                          _atualizarLocal(_calibracao.copyWith(pesoOndas: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoOndas: v)),
                      onIdealChanged: (v) =>
                          _atualizarLocal(_calibracao.copyWith(ondaIdealM: v)),
                      onIdealChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(ondaIdealM: v)),
                    ),
                    const SizedBox(height: 12),
                    _CardFator(
                      icon: Icons.air,
                      titulo: l10n.intelligenceCondVento,
                      calibracao: _calibracao,
                      peso: _calibracao.pesoVento,
                      ideal: _calibracao.ventoIdealKmh,
                      idealMin: 2,
                      idealMax: 30,
                      idealDivisoes: 28,
                      idealUnidade: 'km/h',
                      idealCasasDecimais: 0,
                      onPesoChanged: (v) =>
                          _atualizarLocal(_calibracao.copyWith(pesoVento: v)),
                      onPesoChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(pesoVento: v)),
                      onIdealChanged: (v) => _atualizarLocal(
                          _calibracao.copyWith(ventoIdealKmh: v)),
                      onIdealChangedFim: (v) =>
                          _atualizar(_calibracao.copyWith(ventoIdealKmh: v)),
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

  final double ideal;
  final double idealMin;
  final double idealMax;
  final int idealDivisoes;
  final String idealUnidade;
  final int idealCasasDecimais;
  final ValueChanged<double> onIdealChanged;
  final ValueChanged<double> onIdealChangedFim;

  const _CardFator({
    required this.icon,
    required this.titulo,
    required this.calibracao,
    required this.peso,
    required this.onPesoChanged,
    required this.onPesoChangedFim,
    required this.ideal,
    required this.idealMin,
    required this.idealMax,
    required this.idealDivisoes,
    required this.idealUnidade,
    required this.idealCasasDecimais,
    required this.onIdealChanged,
    required this.onIdealChangedFim,
  });

  static const _pesoMin = 0.0;
  static const _pesoMax = 60.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final participacao = calibracao.participacao(peso);
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
                  child: Text(l10n.intelligenceCalibracaoIdealLabel,
                      style: TextStyle(fontSize: 12, color: onSurfaceVariant)),
                ),
                Expanded(
                  child: Slider(
                    value: ideal.clamp(idealMin, idealMax),
                    min: idealMin,
                    max: idealMax,
                    divisions: idealDivisoes,
                    label:
                        '${ideal.toStringAsFixed(idealCasasDecimais)} $idealUnidade',
                    onChanged: onIdealChanged,
                    onChangeEnd: onIdealChangedFim,
                  ),
                ),
                SizedBox(
                  width: 68,
                  child: Text(
                    '${ideal.toStringAsFixed(idealCasasDecimais)} $idealUnidade',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
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
