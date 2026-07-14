import 'package:flutter/material.dart';

/// Selo circular com o score da recomendação, colorido por faixa
/// (assume escala 0-100, como observado nos dados de exemplo da API).
class RecomendacaoScoreBadge extends StatelessWidget {
  final num score;
  final double tamanho;

  const RecomendacaoScoreBadge({
    super.key,
    required this.score,
    this.tamanho = 44,
  });

  Color get _cor {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _cor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: _cor, width: 2),
      ),
      child: Text(
        '${score.round()}',
        style: TextStyle(
          color: _cor,
          fontWeight: FontWeight.bold,
          fontSize: tamanho * 0.36,
        ),
      ),
    );
  }
}
