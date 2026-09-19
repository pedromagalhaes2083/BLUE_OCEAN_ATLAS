import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';

/// Bússola circular simples — anel com os 360° marcados (traços maiores a
/// cada 30°, com o número do grau e as letras cardeais N/L/S/O nos 4
/// eixos) que gira sozinho conforme o [rumo] do aparelho, sempre deixando
/// o rumo atual alinhado com o ponteiro vermelho fixo no topo. No centro,
/// o valor atual em graus + a abreviação cardinal.
class CompassoCircular extends StatelessWidget {
  final double rumo;
  final double tamanho;

  const CompassoCircular({super.key, required this.rumo, this.tamanho = 130});

  double get _rumoNormalizado => ((rumo % 360) + 360) % 360;

  static String _abreviacaoCardinal(AppLocalizations l10n, double graus) {
    final indice = ((graus + 22.5) / 45).floor() % 8;
    return switch (indice) {
      0 => l10n.cardinalNorte,
      1 => l10n.cardinalNordeste,
      2 => l10n.cardinalLeste,
      3 => l10n.cardinalSudeste,
      4 => l10n.cardinalSul,
      5 => l10n.cardinalSudoeste,
      6 => l10n.cardinalOeste,
      _ => l10n.cardinalNoroeste,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rumo = _rumoNormalizado;
    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(tamanho, tamanho),
            painter: _CompassoCircularPainter(rumo: rumo, l10n: l10n),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_abreviacaoCardinal(l10n, rumo),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text('${rumo.round()}°',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompassoCircularPainter extends CustomPainter {
  final double rumo;
  final AppLocalizations l10n;

  const _CompassoCircularPainter({required this.rumo, required this.l10n});

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height / 2);
    final raio = size.width / 2;

    canvas.drawCircle(
        centro, raio, Paint()..color = Colors.black.withValues(alpha: 0.6));

    const raioTraco = 1.0; // fração do raio onde os traços começam (borda)
    final raioTextoCardeal = raio * 0.62;
    final raioTextoGrau = raio * 0.8;

    for (var grau = 0; grau < 360; grau += 10) {
      // Ângulo na tela: o rumo atual sempre fica alinhado com o topo
      // (ponteiro fixo), então cada marca desloca conforme a diferença
      // pro rumo atual.
      final anguloTela = (grau - rumo) * math.pi / 180;
      final direcao = Offset(math.sin(anguloTela), -math.cos(anguloTela));

      final cardeal = switch (grau) {
        0 => l10n.cardinalNorte,
        90 => l10n.cardinalLeste,
        180 => l10n.cardinalSul,
        270 => l10n.cardinalOeste,
        _ => null,
      };
      final maior = grau % 30 == 0;
      final comprimentoTraco = cardeal != null ? 16.0 : (maior ? 11.0 : 6.0);

      canvas.drawLine(
        centro + direcao * (raio * raioTraco),
        centro + direcao * (raio * raioTraco - comprimentoTraco),
        Paint()
          ..color = Colors.white.withValues(alpha: cardeal != null ? 0.9 : 0.4)
          ..strokeWidth = cardeal != null ? 2 : 1,
      );

      if (maior) {
        final texto = cardeal ?? '$grau';
        final tp = TextPainter(
          text: TextSpan(
            text: texto,
            style: TextStyle(
              color: grau == 0
                  ? Colors.redAccent.shade100
                  : (cardeal != null ? Colors.white : Colors.white60),
              fontSize: cardeal != null ? 13 : 9,
              fontWeight: cardeal != null ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final raioTexto = cardeal != null ? raioTextoCardeal : raioTextoGrau;
        final pos = centro + direcao * raioTexto;
        tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Ponteiro fixo no topo, apontando pro centro.
    final ponteiro = Path()
      ..moveTo(centro.dx, 6)
      ..lineTo(centro.dx - 6, 18)
      ..lineTo(centro.dx + 6, 18)
      ..close();
    canvas.drawPath(ponteiro, Paint()..color = Colors.redAccent);
  }

  @override
  bool shouldRepaint(covariant _CompassoCircularPainter oldDelegate) =>
      oldDelegate.rumo != rumo;
}
