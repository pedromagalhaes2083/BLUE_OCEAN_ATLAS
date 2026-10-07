import 'package:flutter/material.dart';

/// Forma de onda de uma nota de áudio do diário de bordo — desenha
/// [amplitudes] (já reamostradas pro número fixo de barras, ver
/// `DiarioBordoScreen._numBarrasOnda`) como barras verticais, coloridas até
/// [progresso] (0 a 1) na cor "tocada" e o resto na cor "restante". Mesmo
/// padrão visual de players de áudio tipo WhatsApp — mas aqui as barras
/// refletem a amplitude real capturada durante a gravação, nunca um
/// padrão decorativo inventado (ver doc de `DiarioBordoEntrada.amplitudes`
/// pra quando isso não está disponível).
class FormaDeOnda extends StatelessWidget {
  final List<double> amplitudes;
  final double progresso;
  final double altura;

  const FormaDeOnda({
    super.key,
    required this.amplitudes,
    required this.progresso,
    this.altura = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: altura,
      child: CustomPaint(
        painter: _FormaDeOndaPainter(
          amplitudes: amplitudes,
          progresso: progresso,
          corTocada: Theme.of(context).colorScheme.primary,
          corRestante:
              Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _FormaDeOndaPainter extends CustomPainter {
  final List<double> amplitudes;
  final double progresso;
  final Color corTocada;
  final Color corRestante;

  _FormaDeOndaPainter({
    required this.amplitudes,
    required this.progresso,
    required this.corTocada,
    required this.corRestante,
  });

  // Altura mínima de cada barra (mesmo em silêncio/amplitude 0) — uma
  // barra totalmente invisível ali passaria a impressão de um "buraco" no
  // desenho em vez de um trecho só mais quieto.
  static const _alturaMinimaFracao = 0.12;

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final quantidade = amplitudes.length;
    final larguraBarra = size.width / quantidade;
    final larguraTraco = larguraBarra * 0.6;
    final barraTocadaAte = (progresso.clamp(0.0, 1.0) * quantidade).floor();

    for (var i = 0; i < quantidade; i++) {
      final amplitude = amplitudes[i].clamp(0.0, 1.0);
      final alturaBarra =
          size.height * (_alturaMinimaFracao + amplitude * (1 - _alturaMinimaFracao));
      final x = i * larguraBarra + (larguraBarra - larguraTraco) / 2;
      final y = (size.height - alturaBarra) / 2;

      final paint = Paint()
        ..color = i < barraTocadaAte ? corTocada : corRestante
        ..strokeWidth = larguraTraco
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x + larguraTraco / 2, y),
        Offset(x + larguraTraco / 2, y + alturaBarra),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FormaDeOndaPainter oldDelegate) =>
      oldDelegate.amplitudes != amplitudes ||
      oldDelegate.progresso != progresso ||
      oldDelegate.corTocada != corTocada;
}
