import 'package:flutter/material.dart';

/// Indicador de rumo (graus da bússola do aparelho) — um bloco quadrado de
/// cantos arredondados, no mesmo padrão visual do botão de menu (ver
/// `MapaWidget._buildTopBar`), exibindo só o valor em graus.
class CompassoCircular extends StatelessWidget {
  final double rumo;
  final double tamanho;

  const CompassoCircular({super.key, required this.rumo, this.tamanho = 56});

  double get _rumoNormalizado => ((rumo % 360) + 360) % 360;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: tamanho,
        height: tamanho,
        child: Center(
          child: Text(
            '${_rumoNormalizado.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
