import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../termoclina/domain/models/perfil_temperatura_ponto.dart';

/// Gráfico do perfil vertical de temperatura (temperatura × profundidade)
/// da tela de Termoclina — desenhado com [CustomPainter], mesmo padrão do
/// projeto pra gráficos simples (ver `GraficoMare24h`, "Maré e Pesca de
/// Atum").
///
/// Eixo Y é a profundidade, crescendo pra baixo (0 no topo — convenção de
/// "olhar a coluna d'água de cima"); eixo X é a temperatura. Enxuto de
/// propósito: uma grade fixa de poucas linhas (não uma por ponto do
/// perfil — a fonte real, RFROM/Argo, pode trazer dezenas de níveis, o que
/// deixaria a grade e os rótulos ilegíveis), sem rótulo de temperatura em
/// cada ponto (só a curva + os marcadores já mostram a forma do perfil), e
/// uma única linha tracejada com um rótulo pra profundidade oficial da
/// termoclina (vem do model/service, [profundidadeTermoclinaM] — nunca
/// recalculada aqui).
class GraficoPerfilTermico extends StatelessWidget {
  final List<PerfilTemperaturaPonto> perfil;
  final double profundidadeTermoclinaM;
  final double? temperaturaNaTermoclinaC;

  const GraficoPerfilTermico({
    super.key,
    required this.perfil,
    required this.profundidadeTermoclinaM,
    this.temperaturaNaTermoclinaC,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (perfil.length < 2) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(l10n.termoclinaGraficoSemDado,
              style: TextStyle(color: corRotulo(context), fontStyle: FontStyle.italic)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        height: 220,
        child: CustomPaint(
          painter: _PerfilTermicoPainter(
            perfil: perfil,
            profundidadeTermoclinaM: profundidadeTermoclinaM,
            temperaturaNaTermoclinaC: temperaturaNaTermoclinaC,
            corTexto: corRotulo(context),
            rotuloTermoclina: l10n.termoclinaGraficoLegendaFaixa,
          ),
        ),
      ),
    );
  }
}

class _PerfilTermicoPainter extends CustomPainter {
  final List<PerfilTemperaturaPonto> perfil;
  final double profundidadeTermoclinaM;
  final double? temperaturaNaTermoclinaC;
  final Color corTexto;
  final String rotuloTermoclina;

  _PerfilTermicoPainter({
    required this.perfil,
    required this.profundidadeTermoclinaM,
    required this.temperaturaNaTermoclinaC,
    required this.corTexto,
    required this.rotuloTermoclina,
  });

  static const _divisoesGrade = 4;

  @override
  void paint(Canvas canvas, Size size) {
    const margemEsquerda = 38.0;
    const margemDireita = 12.0;
    const margemTopo = 8.0;
    const margemBase = 18.0;
    final larguraGrafico = size.width - margemEsquerda - margemDireita;
    final alturaGrafico = size.height - margemTopo - margemBase;

    final temperaturas = perfil.map((p) => p.temperaturaC).toList();
    final profundidades = perfil.map((p) => p.profundidadeM).toList();
    final tMin = temperaturas.reduce((a, b) => a < b ? a : b) - 0.5;
    final tMax = temperaturas.reduce((a, b) => a > b ? a : b) + 0.5;
    final zMax = profundidades.reduce((a, b) => a > b ? a : b);

    double xDe(double temperatura) =>
        margemEsquerda + (temperatura - tMin) / (tMax - tMin) * larguraGrafico;
    double yDe(double profundidade) =>
        margemTopo + (profundidade / zMax) * alturaGrafico;

    // Grade horizontal fixa (poucas linhas, não uma por ponto do perfil —
    // ver doc da classe) com rótulo de profundidade à esquerda.
    final gradePaint = Paint()
      ..color = corTexto.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (var i = 0; i <= _divisoesGrade; i++) {
      final profundidade = zMax * i / _divisoesGrade;
      final y = yDe(profundidade);
      canvas.drawLine(Offset(margemEsquerda, y), Offset(size.width - margemDireita, y), gradePaint);
      _texto('${profundidade.toStringAsFixed(0)}m', corTexto, 9)
          .paint(canvas, Offset(2, y - 6));
    }

    // Curva do perfil (temperatura × profundidade).
    final linha = Path()..moveTo(xDe(perfil[0].temperaturaC), yDe(perfil[0].profundidadeM));
    for (var i = 1; i < perfil.length; i++) {
      linha.lineTo(xDe(perfil[i].temperaturaC), yDe(perfil[i].profundidadeM));
    }
    canvas.drawPath(
      linha,
      Paint()
        ..color = Colors.blue.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Marcadores dos níveis amostrados, sem rótulo por ponto (a curva já
    // mostra a forma do perfil) — preenchido quando é um dado medido de
    // verdade (SST/RFROM), só contorno quando é do modelo estimado (ver
    // `PerfilTemperaturaPonto.medido`).
    for (final p in perfil) {
      final ponto = Offset(xDe(p.temperaturaC), yDe(p.profundidadeM));
      if (p.medido) {
        canvas.drawCircle(ponto, 3.0, Paint()..color = Colors.blue.shade700);
      } else {
        canvas.drawCircle(
          ponto,
          3.0,
          Paint()
            ..color = Colors.blue.shade700
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      }
    }

    // Linha tracejada + rótulo único na profundidade oficial da termoclina
    // (vem do model/service, nunca recalculada aqui).
    final yOficial = yDe(profundidadeTermoclinaM.clamp(0, zMax));
    _tracejada(
      canvas,
      Offset(margemEsquerda, yOficial),
      Offset(size.width - margemDireita, yOficial),
      Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 1.6,
    );
    final temperaturaTexto = temperaturaNaTermoclinaC != null
        ? ' · ${temperaturaNaTermoclinaC!.toStringAsFixed(1)}°'
        : '';
    _texto('$rotuloTermoclina$temperaturaTexto', Colors.deepOrange.shade700, 10,
            bold: true)
        .paint(canvas, Offset(margemEsquerda + 4, yOficial - 14));
  }

  void _tracejada(Canvas canvas, Offset inicio, Offset fim, Paint paint) {
    const tamanhoTraco = 5.0;
    final distancia = (fim - inicio).distance;
    if (distancia == 0) return;
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
  bool shouldRepaint(covariant _PerfilTermicoPainter oldDelegate) =>
      oldDelegate.perfil != perfil ||
      oldDelegate.profundidadeTermoclinaM != profundidadeTermoclinaM ||
      oldDelegate.temperaturaNaTermoclinaC != temperaturaNaTermoclinaC;
}
