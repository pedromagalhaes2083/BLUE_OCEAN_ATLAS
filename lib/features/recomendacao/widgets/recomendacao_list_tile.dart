import 'package:flutter/material.dart';
import '../domain/models/recomendacao.dart';
import 'recomendacao_confianca_dots.dart';
import 'recomendacao_score_badge.dart';

/// Item compacto de recomendação para uso em listas (ex: dashboard).
class RecomendacaoListTile extends StatelessWidget {
  final Recomendacao recomendacao;
  final VoidCallback? onTap;

  const RecomendacaoListTile({
    super.key,
    required this.recomendacao,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = recomendacao;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: RecomendacaoScoreBadge(score: r.score, tamanho: 38),
        title: Text(
          r.titulo.isEmpty ? '(sem título)' : r.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            RecomendacaoConfiancaDots(confianca: r.confianca),
            if (r.estimativaCapturaKg != null) ...[
              const SizedBox(width: 8),
              Text(
                '${r.estimativaCapturaKg} kg',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        trailing: r.pontos != null && r.pontos!.isNotEmpty
            ? Text(
                '${r.pontos!.length} pts',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              )
            : null,
      ),
    );
  }
}
