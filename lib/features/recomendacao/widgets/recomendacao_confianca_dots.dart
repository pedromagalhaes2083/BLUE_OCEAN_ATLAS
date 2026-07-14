import 'package:flutter/material.dart';

/// Indicador de confiança em pontos preenchidos (observado 1-3 nos dados
/// de exemplo da API).
class RecomendacaoConfiancaDots extends StatelessWidget {
  final int confianca;
  final int maximo;

  const RecomendacaoConfiancaDots({
    super.key,
    required this.confianca,
    this.maximo = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maximo, (i) {
        final preenchido = i < confianca;
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Icon(
            preenchido ? Icons.circle : Icons.circle_outlined,
            size: 8,
            color: preenchido ? Colors.blue : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}
