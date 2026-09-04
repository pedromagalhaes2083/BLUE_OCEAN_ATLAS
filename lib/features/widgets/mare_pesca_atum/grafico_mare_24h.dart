import 'package:flutter/material.dart';

import '../../../core/models/wave_forecast.dart';
import '../../../core/utils/cor_tema.dart';

/// Ponto de dado plotado no gráfico — só o que realmente veio da API
/// (altura de maré sempre; corrente só quando o modelo marinho cobre o
/// ponto, ver [WaveHourEntry.oceanCurrentVelocity]).
class _PontoGrafico {
  final DateTime hora;
  final double alturaM;
  final double? correnteMs;
  const _PontoGrafico({required this.hora, required this.alturaM, this.correnteMs});
}

/// Gráfico de 24h da tela "Maré e Pesca de Atum": altura da maré (curva
/// principal), preamar/baixa-mar marcadas, linha vertical "Agora" e, se
/// disponível, a velocidade de corrente como uma trilha de pontos abaixo
/// da curva. Rolagem horizontal própria (não estica a tela) e tooltip ao
/// tocar num ponto — desenhado com [CustomPainter] porque o projeto não
/// usa nenhuma lib de gráfico (ver decisão registrada na conversa).
class GraficoMare24h extends StatefulWidget {
  final WaveForecast forecast;
  final List<MareEvento> eventos;

  const GraficoMare24h({super.key, required this.forecast, required this.eventos});

  @override
  State<GraficoMare24h> createState() => _GraficoMare24hState();
}

class _GraficoMare24hState extends State<GraficoMare24h> {
  int? _indiceSelecionado;

  List<_PontoGrafico> get _pontos {
    final agora = DateTime.now();
    final limite = agora.add(const Duration(hours: 24));
    return widget.forecast.hourly
        .where((e) =>
            e.seaLevelHeightMsl != null &&
            e.time.isAfter(agora.subtract(const Duration(hours: 1))) &&
            e.time.isBefore(limite))
        .map((e) => _PontoGrafico(
            hora: e.time,
            alturaM: e.seaLevelHeightMsl!,
            correnteMs: e.oceanCurrentVelocity))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final pontos = _pontos;
    final corRot = corRotulo(context);

    if (pontos.length < 3) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text('Dado indisponível para o gráfico de 24h',
              style: TextStyle(color: corRot, fontStyle: FontStyle.italic)),
        ),
      );
    }

    const larguraPorHora = 46.0;
    final largura = pontos.length * larguraPorHora;
    final selecionado =
        _indiceSelecionado != null && _indiceSelecionado! < pontos.length
            ? pontos[_indiceSelecionado!]
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selecionado != null) _tooltip(corRot, selecionado),
        if (selecionado != null) const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: GestureDetector(
            onTapDown: (d) => _selecionar(d.localPosition.dx, largura, pontos.length),
            onPanUpdate: (d) => _selecionar(d.localPosition.dx, largura, pontos.length),
            child: SizedBox(
              width: largura,
              height: 200,
              child: CustomPaint(
                painter: _MarePainter(
                  pontos: pontos,
                  eventos: widget.eventos,
                  indiceSelecionado: _indiceSelecionado,
                  corTexto: corRot,
                  corDestaque: Theme.of(context).colorScheme.onSurface,
                  temCorrente: pontos.any((p) => p.correnteMs != null),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selecionar(double dx, double largura, int total) {
    final larguraPorHora = largura / total;
    final indice = (dx / larguraPorHora).floor().clamp(0, total - 1);
    setState(() => _indiceSelecionado = indice);
  }

  Widget _tooltip(Color corRot, _PontoGrafico p) {
    final h = p.hora.hour.toString().padLeft(2, '0');
    final m = p.hora.minute.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text('$h:$m',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 12),
          Text('${p.alturaM.toStringAsFixed(2)} m',
              style: const TextStyle(fontSize: 13, color: Colors.teal)),
          if (p.correnteMs != null) ...[
            const SizedBox(width: 12),
            Text('${p.correnteMs!.toStringAsFixed(2)} m/s',
                style: TextStyle(fontSize: 13, color: Colors.blue.shade700)),
          ],
        ],
      ),
    );
  }
}

class _MarePainter extends CustomPainter {
  final List<_PontoGrafico> pontos;
  final List<MareEvento> eventos;
  final int? indiceSelecionado;
  final Color corTexto;
  final Color corDestaque;
  final bool temCorrente;

  _MarePainter({
    required this.pontos,
    required this.eventos,
    required this.indiceSelecionado,
    required this.corTexto,
    required this.corDestaque,
    required this.temCorrente,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final alturaGrafico = temCorrente ? size.height - 46 : size.height - 26;
    final min = pontos.map((p) => p.alturaM).reduce((a, b) => a < b ? a : b);
    final max = pontos.map((p) => p.alturaM).reduce((a, b) => a > b ? a : b);
    final faixa = (max - min).abs() < 0.05 ? 0.05 : (max - min);

    final dx = size.width / pontos.length;
    double xDe(int i) => dx * i + dx / 2;
    double yDe(double altura) =>
        8 + alturaGrafico - ((altura - min) / faixa) * (alturaGrafico - 16);

    // Linhas de grade horizontais (min/meio/max).
    final gradePaint = Paint()
      ..color = corTexto.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (final altura in [min, (min + max) / 2, max]) {
      final y = yDe(altura);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gradePaint);
      _texto('${altura.toStringAsFixed(1)}m', corTexto, 9)
          .paint(canvas, Offset(2, y - 11));
    }

    // Área preenchida sob a curva.
    final area = Path()..moveTo(xDe(0), yDe(pontos[0].alturaM));
    for (var i = 1; i < pontos.length; i++) {
      area.lineTo(xDe(i), yDe(pontos[i].alturaM));
    }
    area.lineTo(xDe(pontos.length - 1), 8 + alturaGrafico);
    area.lineTo(xDe(0), 8 + alturaGrafico);
    area.close();
    canvas.drawPath(
      area,
      Paint()
        ..color = Colors.teal.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // Curva da maré.
    final linha = Path()..moveTo(xDe(0), yDe(pontos[0].alturaM));
    for (var i = 1; i < pontos.length; i++) {
      linha.lineTo(xDe(i), yDe(pontos[i].alturaM));
    }
    canvas.drawPath(
      linha,
      Paint()
        ..color = Colors.teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Trilha de corrente, se disponível — pontos abaixo do gráfico
    // principal, mais intensos (cor mais forte) quanto maior a velocidade.
    if (temCorrente) {
      final maxCorrente = pontos
          .where((p) => p.correnteMs != null)
          .map((p) => p.correnteMs!)
          .fold(0.0, (a, b) => a > b ? a : b);
      final yFaixa = alturaGrafico + 20;
      for (var i = 0; i < pontos.length; i++) {
        final v = pontos[i].correnteMs;
        if (v == null) continue;
        final intensidade = maxCorrente <= 0 ? 0.3 : (v / maxCorrente).clamp(0.15, 1.0);
        canvas.drawCircle(
          Offset(xDe(i), yFaixa),
          2 + intensidade * 3,
          Paint()..color = Colors.blue.withValues(alpha: 0.4 + intensidade * 0.5),
        );
      }
      _texto('Corrente', corTexto, 9).paint(canvas, Offset(0, yFaixa - 20));
    }

    // Eventos de preamar/baixa-mar — marca o ponto mais próximo no eixo X.
    for (final evento in eventos) {
      final indice = _indiceMaisProximo(evento.time);
      if (indice == null) continue;
      final x = xDe(indice);
      final y = yDe(pontos[indice].alturaM);
      final alta = evento.tipo == TipoMare.alta;
      canvas.drawCircle(
          Offset(x, y), 4, Paint()..color = alta ? Colors.teal.shade700 : Colors.blueGrey);
      final h = evento.time.hour.toString().padLeft(2, '0');
      final m = evento.time.minute.toString().padLeft(2, '0');
      _texto('$h:$m', alta ? Colors.teal.shade700 : Colors.blueGrey, 9)
          .paint(canvas, Offset(x - 12, alta ? y - 22 : y + 8));
    }

    // Linha "Agora" — o primeiro ponto da série é sempre a hora atual (ver
    // [_GraficoMare24hState._pontos]).
    final xAgora = xDe(0);
    final agoraPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    _tracejada(canvas, Offset(xAgora, 0), Offset(xAgora, 8 + alturaGrafico), agoraPaint);
    _texto('Agora', Colors.redAccent, 10, bold: true).paint(canvas, Offset(xAgora + 4, 0));

    // Seleção (toque).
    if (indiceSelecionado != null && indiceSelecionado! < pontos.length) {
      final x = xDe(indiceSelecionado!);
      canvas.drawLine(Offset(x, 8), Offset(x, 8 + alturaGrafico),
          Paint()..color = corDestaque.withValues(alpha: 0.3)..strokeWidth = 1);
      canvas.drawCircle(Offset(x, yDe(pontos[indiceSelecionado!].alturaM)), 4.5,
          Paint()..color = corDestaque);
    }

    // Rótulos de hora no eixo X, a cada 3 pontos.
    for (var i = 0; i < pontos.length; i += 3) {
      final h = pontos[i].hora.hour.toString().padLeft(2, '0');
      _texto('${h}h', corTexto, 9)
          .paint(canvas, Offset(xDe(i) - 8, size.height - 14));
    }
  }

  int? _indiceMaisProximo(DateTime instante) {
    if (pontos.isEmpty) return null;
    var melhorIndice = 0;
    var melhorDiferenca = pontos[0].hora.difference(instante).abs();
    for (var i = 1; i < pontos.length; i++) {
      final diferenca = pontos[i].hora.difference(instante).abs();
      if (diferenca < melhorDiferenca) {
        melhorDiferenca = diferenca;
        melhorIndice = i;
      }
    }
    // Só marca se o ponto mais próximo realmente representa esse evento
    // (dentro de meia hora) — evento fora da janela dos 24h plotados não
    // deve aparecer grudado numa borda.
    if (melhorDiferenca > const Duration(minutes: 40)) return null;
    return melhorIndice;
  }

  void _tracejada(Canvas canvas, Offset inicio, Offset fim, Paint paint) {
    const tamanhoTraco = 5.0;
    final distancia = (fim - inicio).distance;
    final direcao = (fim - inicio) / distancia;
    var percorrido = 0.0;
    while (percorrido < distancia) {
      final de = inicio + direcao * percorrido;
      final ate = inicio + direcao * (percorrido + tamanhoTraco).clamp(0, distancia);
      canvas.drawLine(de, ate, paint);
      percorrido += tamanhoTraco * 2;
    }
  }

  TextPainter _texto(String texto, Color cor, double tamanho, {bool bold = false}) {
    return TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
            color: cor, fontSize: tamanho, fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  bool shouldRepaint(covariant _MarePainter oldDelegate) =>
      oldDelegate.indiceSelecionado != indiceSelecionado ||
      oldDelegate.pontos != pontos;
}
