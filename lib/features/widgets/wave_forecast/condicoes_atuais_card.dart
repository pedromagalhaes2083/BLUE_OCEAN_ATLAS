import 'package:flutter/material.dart';
import '../../../core/models/wave_forecast.dart';
import '../../../core/utils/cor_tema.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Card único com as condições atuais do mar: altura/período de onda,
/// corrente (velocidade + direção), swell, direção da onda e a previsão
/// horária — tudo no mesmo container visual (substitui as antigas
/// WaveSummaryCard + SwellInfoRow + OceanCurrentRow + WaveHourlyTimeline).
/// Uso: CondicoesAtuaisCard(forecast: forecast)
class CondicoesAtuaisCard extends StatelessWidget {
  final WaveForecast forecast;

  const CondicoesAtuaisCard({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final entry = forecast.current;
    if (entry == null) return const SizedBox.shrink();

    final proximas = forecast.upcoming;

    // Mesma técnica de `BaseMeteorologyCard._corResolvida` — funde a cor
    // pastel de identidade do card como tinta translúcida sobre o
    // `cardColor` do tema, em vez do literal puro (que ficava um bloco
    // claro cego em cima do tema escuro).
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCard = Color.alphaBlend(
      const Color(0xFFEDF1F3).withValues(alpha: escuro ? 0.18 : 1.0),
      Theme.of(context).cardColor,
    );
    final corRot = corRotulo(context);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      color: corCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, entry, corRot),
                const SizedBox(height: 20),
                _buildAlturaECorrente(context, entry, corRot),
                if (entry.swellWaveHeight != null) ...[
                  const SizedBox(height: 16),
                  _divider(),
                  const SizedBox(height: 12),
                  _buildSwellEDirecao(context, entry, corRot),
                ],
              ],
            ),
          ),
          if (proximas.isNotEmpty) ...[
            _divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: _buildTimeline(context, entry, proximas, corRot),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.withValues(alpha: 0.25), height: 1);

  Widget _buildHeader(BuildContext context, WaveHourEntry entry, Color corRot) {
    final d = entry.time.day.toString().padLeft(2, '0');
    final mo = entry.time.month.toString().padLeft(2, '0');
    return Row(
      children: [
        const Icon(Icons.waves, color: Colors.blueGrey, size: 18),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context).ondaCondicoesAtuais,
          style: const TextStyle(
              color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text('$d/$mo', style: TextStyle(color: corRot, fontSize: 12)),
      ],
    );
  }

  Widget _buildAlturaECorrente(BuildContext context, WaveHourEntry entry, Color corRot) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildAltura(context, entry, corRot)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VerticalDivider(
                color: Colors.grey.withValues(alpha: 0.25), width: 1),
          ),
          Expanded(child: _buildCorrente(context, entry, corRot)),
        ],
      ),
    );
  }

  Widget _buildAltura(BuildContext context, WaveHourEntry entry, Color corRot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).ondaAlturaTitulo,
            style: TextStyle(
                color: corRot,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              entry.waveHeight.toStringAsFixed(2),
              style: TextStyle(
                  color: _heightColor(entry.waveHeight),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: Text('m',
                  style: TextStyle(
                      color: corRot,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        Text(
          _heightLabel(context, entry.waveHeight),
          style: TextStyle(
              color: _heightColor(entry.waveHeight),
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(AppLocalizations.of(context)
                .ondaPeriodo(entry.wavePeriod.toStringAsFixed(1)),
            style: TextStyle(color: corRot, fontSize: 12)),
      ],
    );
  }

  Widget _buildCorrente(BuildContext context, WaveHourEntry entry, Color corRot) {
    final velocidade = entry.oceanCurrentVelocity;
    final direcao = entry.oceanCurrentDirection;
    final l10n = AppLocalizations.of(context);

    if (velocidade == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.ondaCorrenteTitulo,
              style: TextStyle(
                  color: corRot,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(l10n.ondaSemDados, style: TextStyle(color: corRot, fontSize: 13)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ondaCorrenteTitulo,
            style: TextStyle(
                color: corRot,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (velocidade * 0.539957).toStringAsFixed(1),
                        style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            height: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text('nós',
                            style: TextStyle(
                                color: corRot,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  if (direcao != null)
                    Text('$direcao°',
                        style: TextStyle(color: corRot, fontSize: 12)),
                ],
              ),
            ),
            if (direcao != null)
              Transform.rotate(
                angle: direcao * 3.14159265 / 180.0,
                child: Icon(Icons.navigation,
                    color: Colors.blue.shade700, size: 32),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwellEDirecao(BuildContext context, WaveHourEntry entry, Color corRot) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.waves, size: 15, color: corRot),
            const SizedBox(width: 6),
            Text(
              '${l10n.ondaSwellPrefixo} ${entry.swellWaveHeight!.toStringAsFixed(2)} m'
              '${entry.swellWavePeriod != null ? ' · ${entry.swellWavePeriod!.toStringAsFixed(1)} s' : ''}'
              '${entry.swellWaveDirection != null ? ' · ${entry.swellWaveDirection}°' : ''}',
              style: TextStyle(
                  color: corRot, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined, size: 15, color: corRot),
            const SizedBox(width: 6),
            Text(l10n.ondaDirecaoOnda(entry.waveDirection),
                style: TextStyle(
                    color: corRot, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, WaveHourEntry current,
      List<WaveHourEntry> proximas, Color corRot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, size: 14, color: corRot),
            const SizedBox(width: 6),
            Text(AppLocalizations.of(context).ventoPrevisaoHoraria,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: corRot)),
            const Spacer(),
            Text('${proximas.length}h',
                style: TextStyle(fontSize: 11, color: corRot)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: proximas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => _HourChip(
              entry: proximas[i],
              isCurrent: proximas[i].time == current.time,
            ),
          ),
        ),
      ],
    );
  }

  Color _heightColor(double h) {
    if (h < 0.5) return Colors.green.shade600;
    if (h < 1.0) return Colors.lightGreen.shade700;
    if (h < 2.0) return Colors.amber.shade800;
    if (h < 3.0) return Colors.orange.shade800;
    return Colors.redAccent.shade700;
  }

  String _heightLabel(BuildContext context, double h) {
    final l10n = AppLocalizations.of(context);
    if (h < 0.5) return l10n.ondaAlturaCalmo;
    if (h < 1.0) return l10n.ondaAlturaLeve;
    if (h < 2.0) return l10n.ondaAlturaModerado;
    if (h < 3.0) return l10n.ondaAlturaAgitado;
    if (h < 4.0) return l10n.ondaAlturaMuitoAgitado;
    return l10n.ondaAlturaTempestuoso;
  }
}

class _HourChip extends StatelessWidget {
  final WaveHourEntry entry;
  final bool isCurrent;

  const _HourChip({required this.entry, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final h = entry.time.hour.toString().padLeft(2, '0');
    final m = entry.time.minute.toString().padLeft(2, '0');
    final corRot = corRotulo(context);
    final corValor = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFBBDEFB) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? Colors.blueAccent : Colors.grey.withValues(alpha: 0.2),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$h:$m',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isCurrent ? Colors.blue.shade900 : corRot)),
          Transform.rotate(
            angle: entry.directionRadians,
            child: Icon(Icons.navigation,
                size: 16, color: isCurrent ? Colors.blue.shade900 : Colors.blueGrey),
          ),
          Column(
            children: [
              Text(entry.waveHeight.toStringAsFixed(2),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.black87 : corValor,
                      height: 1)),
              Text('m',
                  style: TextStyle(
                      fontSize: 9,
                      color: isCurrent ? Colors.blue.shade900 : corRot)),
            ],
          ),
          Text('${entry.wavePeriod.toStringAsFixed(1)}s',
              style: TextStyle(
                  fontSize: 10,
                  color: isCurrent ? Colors.blue.shade900 : corRot)),
        ],
      ),
    );
  }
}
