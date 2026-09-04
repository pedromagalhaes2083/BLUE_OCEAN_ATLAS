import 'package:flutter/material.dart';

import '../../../core/models/wave_forecast.dart';
import '../../../core/utils/cor_tema.dart';
import '../../metereologia/domain/models/previsao_tempo.dart';

/// Um bloco da timeline "Janela operacional" — sempre construído a partir
/// de dado real da hora em questão (maré, corrente, temperatura); só o
/// texto de observação é um template, escolhido pelo sinal real da maré
/// (subindo/descendo/parada) nesse horário — nunca afirma presença de
/// atum, só descreve a dinâmica da água (ver item 9 do pedido original).
class _BlocoJanela {
  final DateTime hora;
  final double? alturaMareM;
  final double? deltaMareM; // diferença pra 1h antes — define o texto
  final double? correnteMs;
  final double? temperaturaC;

  const _BlocoJanela({
    required this.hora,
    this.alturaMareM,
    this.deltaMareM,
    this.correnteMs,
    this.temperaturaC,
  });

  String get observacao {
    final delta = deltaMareM;
    if (delta == null) return 'Sem dado de maré suficiente para esse horário.';
    if (delta.abs() < 0.03) {
      return 'Período de estofa (maré parada). Corrente de maré tende a ficar fraca nesse horário.';
    }
    if (delta > 0) {
      return 'Período de enchente. Observar regiões de convergência e concentração de presas.';
    }
    return 'Período de vazante. Observar bordas de banco e canais onde a correnteza pode concentrar alimento.';
  }

  IconData get icone {
    final delta = deltaMareM;
    if (delta == null || delta.abs() < 0.03) return Icons.trending_flat;
    return delta > 0 ? Icons.trending_up : Icons.trending_down;
  }
}

/// Timeline horizontal das próximas ~18h, em blocos de 3h — cada um
/// resume maré/corrente/temperatura reais daquele horário, mais uma
/// observação operacional (nunca uma previsão de captura).
class JanelaOperacionalWidget extends StatelessWidget {
  final WaveForecast waveForecast;
  final PrevisaoTempo? previsaoTempo;

  const JanelaOperacionalWidget({
    super.key,
    required this.waveForecast,
    this.previsaoTempo,
  });

  List<_BlocoJanela> _montarBlocos() {
    final agora = DateTime.now();
    final horas = List.generate(7, (i) => agora.add(Duration(hours: i * 3)));

    WaveHourEntry? maisProximo(DateTime alvo) {
      final candidatos = waveForecast.hourly
          .where((e) => e.seaLevelHeightMsl != null)
          .toList();
      if (candidatos.isEmpty) return null;
      return candidatos.reduce((a, b) =>
          a.time.difference(alvo).abs() < b.time.difference(alvo).abs() ? a : b);
    }

    PrevisaoTempoHoraria? temperaturaProxima(DateTime alvo) {
      final lista = previsaoTempo?.horaria;
      if (lista == null || lista.isEmpty) return null;
      return lista.reduce((a, b) =>
          a.horario.difference(alvo).abs() < b.horario.difference(alvo).abs()
              ? a
              : b);
    }

    return horas.map((hora) {
      final entrada = maisProximo(hora);
      final anterior =
          entrada == null ? null : maisProximo(entrada.time.subtract(const Duration(hours: 1)));
      final delta = (entrada?.seaLevelHeightMsl != null && anterior?.seaLevelHeightMsl != null)
          ? entrada!.seaLevelHeightMsl! - anterior!.seaLevelHeightMsl!
          : null;

      return _BlocoJanela(
        hora: hora,
        alturaMareM: entrada?.seaLevelHeightMsl,
        deltaMareM: delta,
        correnteMs: entrada?.oceanCurrentVelocity,
        temperaturaC: temperaturaProxima(hora)?.temperatura,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final blocos = _montarBlocos();
    final corRot = corRotulo(context);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Janela operacional',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Próximas horas — maré, corrente e temperatura reais de cada horário.',
                style: TextStyle(fontSize: 11.5, color: corRot)),
            const SizedBox(height: 14),
            SizedBox(
              height: 178,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: blocos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => _CardBloco(bloco: blocos[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBloco extends StatelessWidget {
  final _BlocoJanela bloco;
  const _CardBloco({required this.bloco});

  @override
  Widget build(BuildContext context) {
    final corRot = corRotulo(context);
    final h = bloco.hora.hour.toString().padLeft(2, '0');
    final corIcone = bloco.deltaMareM == null
        ? corRot
        : (bloco.deltaMareM!.abs() < 0.03
            ? Colors.blueGrey
            : (bloco.deltaMareM! > 0 ? Colors.teal.shade700 : Colors.orange.shade800));

    return Container(
      width: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${h}h',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              Icon(bloco.icone, size: 16, color: corIcone),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 2,
            children: [
              if (bloco.alturaMareM != null)
                Text('${bloco.alturaMareM!.toStringAsFixed(2)} m',
                    style: TextStyle(fontSize: 11, color: corRot)),
              if (bloco.correnteMs != null)
                Text('${bloco.correnteMs!.toStringAsFixed(2)} m/s',
                    style: TextStyle(fontSize: 11, color: corRot)),
              if (bloco.temperaturaC != null)
                Text('${bloco.temperaturaC!.toStringAsFixed(1)}°C',
                    style: TextStyle(fontSize: 11, color: corRot)),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              bloco.observacao,
              style: const TextStyle(fontSize: 10.5, height: 1.3),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
