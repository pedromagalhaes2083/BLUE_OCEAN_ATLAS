import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../termoclina/domain/models/perfil_temperatura_ponto.dart';

/// Gráfico do perfil vertical de temperatura (temperatura × profundidade)
/// da tela de Termoclina — desenhado com [CustomPainter], mesmo padrão do
/// projeto pra gráficos simples (ver `GraficoMare24h`, "Maré e Pesca de
/// Atum"): o projeto não usa nenhuma lib de gráfico, e este dataset é
/// pequeno o bastante (poucos pontos de profundidade) pra não precisar
/// de uma.
///
/// Eixo Y é a profundidade, crescendo pra baixo (0 no topo — convenção de
/// "olhar a coluna d'água de cima"); eixo X é a temperatura. A faixa
/// sombreada marca onde o gradiente de temperatura entre dois pontos
/// consecutivos do próprio perfil é mais acentuado — só uma pista visual
/// de "olha, é aqui que a temperatura despenca", **não** um recálculo da
/// termoclina (o valor oficial, [profundidadeTermoclinaM], vem do
/// model/service e é marcado à parte, com uma linha tracejada).
class GraficoPerfilTermico extends StatelessWidget {
  final List<PerfilTemperaturaPonto> perfil;
  final double profundidadeTermoclinaM;

  const GraficoPerfilTermico({
    super.key,
    required this.perfil,
    required this.profundidadeTermoclinaM,
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
        height: 240,
        child: CustomPaint(
          painter: _PerfilTermicoPainter(
            perfil: perfil,
            profundidadeTermoclinaM: profundidadeTermoclinaM,
            corTexto: corRotulo(context),
            corDestaque: Theme.of(context).colorScheme.onSurface,
            textoTermoclina: l10n.termoclinaGraficoLegendaFaixa,
          ),
        ),
      ),
    );
  }
}

class _PerfilTermicoPainter extends CustomPainter {
  final List<PerfilTemperaturaPonto> perfil;
  final double profundidadeTermoclinaM;
  final Color corTexto;
  final Color corDestaque;
  final String textoTermoclina;

  _PerfilTermicoPainter({
    required this.perfil,
    required this.profundidadeTermoclinaM,
    required this.corTexto,
    required this.corDestaque,
    required this.textoTermoclina,
  });

  /// Faixa de profundidade [de, ate] onde o gradiente entre dois pontos
  /// consecutivos do perfil é o mais acentuado — só um destaque visual
  /// (ver doc da classe), calculado sempre a partir do perfil inteiro,
  /// nunca só da SST.
  (double de, double ate) get _faixaMaiorGradiente {
    var melhorIndice = 0;
    var melhorGradiente = 0.0;
    for (var i = 0; i < perfil.length - 1; i++) {
      final gradiente =
          (perfil[i].temperaturaC - perfil[i + 1].temperaturaC).abs() /
              (perfil[i + 1].profundidadeM - perfil[i].profundidadeM).clamp(0.01, double.infinity);
      if (gradiente > melhorGradiente) {
        melhorGradiente = gradiente;
        melhorIndice = i;
      }
    }
    return (perfil[melhorIndice].profundidadeM, perfil[melhorIndice + 1].profundidadeM);
  }

  @override
  void paint(Canvas canvas, Size size) {
    const margemEsquerda = 42.0;
    const margemDireita = 12.0;
    const margemTopo = 8.0;
    const margemBase = 22.0;
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

    // Faixa sombreada da termoclina (maior gradiente do próprio perfil).
    final (faixaDe, faixaAte) = _faixaMaiorGradiente;
    canvas.drawRect(
      Rect.fromLTRB(margemEsquerda, yDe(faixaDe), size.width - margemDireita, yDe(faixaAte)),
      Paint()..color = Colors.deepOrange.withValues(alpha: 0.10),
    );
    _texto(textoTermoclina, Colors.deepOrange.shade700, 9, bold: true)
        .paint(canvas, Offset(margemEsquerda + 4, yDe(faixaDe) + 2));

    // Grade horizontal (profundidade) com rótulo à esquerda.
    final gradePaint = Paint()
      ..color = corTexto.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    for (final p in profundidades) {
      final y = yDe(p);
      canvas.drawLine(Offset(margemEsquerda, y), Offset(size.width - margemDireita, y), gradePaint);
      _texto('${p.toStringAsFixed(0)}m', corTexto, 9)
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

    // Pontos + rótulo de temperatura de cada nível amostrado.
    for (final p in perfil) {
      final ponto = Offset(xDe(p.temperaturaC), yDe(p.profundidadeM));
      canvas.drawCircle(ponto, 3.5, Paint()..color = Colors.blue.shade700);
      _texto('${p.temperaturaC.toStringAsFixed(1)}°', corDestaque, 9)
          .paint(canvas, ponto + const Offset(6, -12));
    }

    // Linha tracejada na profundidade oficial da termoclina (vem do
    // model/service, não deste gráfico).
    final yOficial = yDe(profundidadeTermoclinaM.clamp(0, zMax));
    _tracejada(
      canvas,
      Offset(margemEsquerda, yOficial),
      Offset(size.width - margemDireita, yOficial),
      Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = 1.6,
    );
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
      oldDelegate.profundidadeTermoclinaM != profundidadeTermoclinaM;
}
