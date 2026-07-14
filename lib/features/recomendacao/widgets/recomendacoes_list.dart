import 'package:flutter/material.dart';
import '../domain/models/recomendacao.dart';
import 'recomendacao_list_tile.dart';

/// Lista de recomendações ordenadas por score (maior primeiro), com
/// estado vazio tratado.
class RecomendacoesList extends StatelessWidget {
  final List<Recomendacao> recomendacoes;
  final void Function(Recomendacao)? onTap;

  const RecomendacoesList({
    super.key,
    required this.recomendacoes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recomendacoes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Nenhuma recomendação disponível',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final ordenadas = [...recomendacoes]
      ..sort((a, b) => b.score.compareTo(a.score));

    return Column(
      children: ordenadas
          .map((r) => RecomendacaoListTile(
                recomendacao: r,
                onTap: onTap != null ? () => onTap!(r) : null,
              ))
          .toList(),
    );
  }
}
