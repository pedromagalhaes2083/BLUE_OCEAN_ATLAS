import 'package:flutter/material.dart';
import '../domain/models/recomendacao.dart';
import 'recomendacao_list_tile.dart';

/// Lista de recomendações ordenadas pela data de criação (mais recentes
/// primeiro), com estado vazio tratado.
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

    // Mais recentes primeiro; sem data de criação vai para o final.
    final ordenadas = [...recomendacoes]
      ..sort((a, b) {
        final dataA = a.criadoEm;
        final dataB = b.criadoEm;
        if (dataA == null && dataB == null) return 0;
        if (dataA == null) return 1;
        if (dataB == null) return -1;
        return dataB.compareTo(dataA);
      });

    return Column(
      children: [
        for (var i = 0; i < ordenadas.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          RecomendacaoListTile(
            recomendacao: ordenadas[i],
            onTap: onTap != null ? () => onTap!(ordenadas[i]) : null,
          ),
        ],
      ],
    );
  }
}
