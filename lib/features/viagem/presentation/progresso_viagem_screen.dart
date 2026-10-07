import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../domain/models/viagem.dart';

/// Período padrão usado pra calcular o progresso quando a viagem não tem
/// [Viagem.dataTermino] (backend não enviou previsão) — pedido explícito do
/// usuário, não uma previsão real. A tela deixa isso claro (ver
/// [progressoViagemPrevisaoPadraoAviso]) em vez de mostrar como se fosse
/// uma data informada de verdade.
const _duracaoPadraoViagem = Duration(days: 30);

/// Progresso da viagem em andamento — compara o tempo já decorrido desde
/// [Viagem.dataInicio] com a previsão de término em [Viagem.dataTermino]
/// (sincronizada do backend, ver `ContextoViagemService`). Viagens locais
/// sem previsão de término (campo nulo) usam [_duracaoPadraoViagem] como
/// referência pro cálculo, deixado explícito na UI.
class ProgressoViagemScreen extends StatefulWidget {
  final Viagem viagem;

  const ProgressoViagemScreen({super.key, required this.viagem});

  @override
  State<ProgressoViagemScreen> createState() => _ProgressoViagemScreenState();
}

class _ProgressoViagemScreenState extends State<ProgressoViagemScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Reatualiza o tempo decorrido/restante periodicamente — a viagem não
    // muda de estado sozinha, só o relógio anda.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viagem = widget.viagem;
    final agora = DateTime.now();
    final decorrido = agora.difference(viagem.dataInicio);
    final previsaoReal = viagem.dataTermino;
    final previsaoParaCalculo =
        previsaoReal ?? viagem.dataInicio.add(_duracaoPadraoViagem);

    double? progresso;
    final total = previsaoParaCalculo.difference(viagem.dataInicio);
    if (total.inSeconds > 0) {
      progresso = (decorrido.inSeconds / total.inSeconds).clamp(0.0, 1.0);
    }
    final restante = previsaoParaCalculo.difference(agora);
    final atrasada = restante.isNegative;

    return Scaffold(
      appBar: AppBar(
        title: Text(viagem.nome?.isNotEmpty == true
            ? '${l10n.progressoViagemTelaTitulo} · ${viagem.nome}'
            : l10n.progressoViagemTelaTitulo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.progressoViagemIniciadaEm(_formatarData(viagem.dataInicio)),
            style: TextStyle(fontSize: 14, color: corRotulo(context)),
          ),
          const SizedBox(height: 28),
          Center(
            child: _anelProgresso(
              context,
              progresso: progresso,
              atrasada: atrasada,
            ),
          ),
          const SizedBox(height: 32),
          _linhaEstatistica(
            context,
            icone: Icons.timelapse,
            titulo: l10n.progressoViagemDecorrido,
            valor: _formatarDuracao(l10n, decorrido),
          ),
          const SizedBox(height: 12),
          _linhaEstatistica(
            context,
            icone: atrasada ? Icons.warning_amber : Icons.hourglass_bottom,
            titulo:
                atrasada ? l10n.progressoViagemAtrasada : l10n.progressoViagemRestante,
            valor: _formatarDuracao(l10n, restante),
            destaque: atrasada,
          ),
          const SizedBox(height: 12),
          _linhaEstatistica(
            context,
            icone: Icons.flag_outlined,
            titulo: l10n.progressoViagemPrevisaoTermino,
            valor: _formatarData(previsaoParaCalculo),
          ),
          if (previsaoReal == null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: corRotulo(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.progressoViagemPrevisaoPadraoAviso,
                    style: TextStyle(fontSize: 12, color: corRotulo(context)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _anelProgresso(
    BuildContext context, {
    required double? progresso,
    required bool atrasada,
  }) {
    final cor = atrasada
        ? Colors.orange
        : Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 14,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          // Sem previsão de término (ver doc da classe) não tem um total pra
          // calcular % — um `CircularProgressIndicator(value: null)` viraria
          // um spinner indeterminado girando sem parar, o que sugeriria
          // "carregando" em vez de "sem meta". Só desenha o arco quando há
          // [progresso] de verdade; sem ele, fica só o anel de fundo + ícone.
          if (progresso != null)
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: progresso,
                strokeWidth: 14,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(cor),
              ),
            ),
          if (progresso != null)
            Text(
              '${(progresso * 100).round()}%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            )
          else
            Icon(Icons.sailing, size: 48, color: cor),
        ],
      ),
    );
  }

  Widget _linhaEstatistica(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String valor,
    bool destaque = false,
  }) {
    final corDestaque = destaque ? Colors.orange : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icone, color: corDestaque ?? corRotulo(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(titulo, style: TextStyle(color: corRotulo(context))),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: corDestaque,
            ),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime d) {
    final dia = d.day.toString().padLeft(2, '0');
    final mes = d.month.toString().padLeft(2, '0');
    final hora = d.hour.toString().padLeft(2, '0');
    final minuto = d.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${d.year} $hora:$minuto';
  }

  /// Junta as duas maiores unidades (dias+horas, ou horas+minutos, ou só
  /// minutos) — mesmo espírito do `_formatarTempoDecorrido` do dashboard,
  /// só com uma unidade extra de precisão pra viagens de vários dias.
  String _formatarDuracao(AppLocalizations l10n, Duration d) {
    final abs = d.abs();
    if (abs.inDays >= 1) {
      final horas = abs.inHours.remainder(24);
      return horas > 0
          ? '${l10n.dashboardTempoDias(abs.inDays)} ${l10n.dashboardTempoHoras(horas)}'
          : l10n.dashboardTempoDias(abs.inDays);
    }
    if (abs.inHours >= 1) {
      final minutos = abs.inMinutes.remainder(60);
      return minutos > 0
          ? '${l10n.dashboardTempoHoras(abs.inHours)} ${l10n.dashboardTempoMinutos(minutos)}'
          : l10n.dashboardTempoHoras(abs.inHours);
    }
    return l10n.dashboardTempoMinutos(abs.inMinutes);
  }
}
