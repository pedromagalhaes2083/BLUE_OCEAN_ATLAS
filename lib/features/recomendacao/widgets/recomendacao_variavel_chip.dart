import 'package:flutter/material.dart';
import '../domain/models/recomendacao.dart';

/// Selo com uma variável ambiental (vento, corrente, clorofila, onda,
/// temperatura) amostrada em um ponto da recomendação.
class RecomendacaoVariavelChip extends StatelessWidget {
  final VariavelValor variavel;

  const RecomendacaoVariavelChip({super.key, required this.variavel});

  @override
  Widget build(BuildContext context) {
    final tipo = variavel.tipo;
    final label = tipo != null
        ? '${tipo.label}: ${variavel.valor.toStringAsFixed(2)} ${tipo.unidade}'
        : 'Var. ${variavel.variavel}: ${variavel.valor.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tipo?.icone ?? Icons.help_outline,
              size: 14, color: Colors.blueGrey),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
