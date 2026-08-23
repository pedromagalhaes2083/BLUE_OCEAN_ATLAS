import 'package:flutter/material.dart';
import '../domain/models/recomendacao.dart';
import 'recomendacao_confianca_dots.dart';

/// Linha compacta de recomendação para uso em listas (ex: aba
/// "Recomendações" em `CartasScreen`). Sem `Card`/sombra própria — a lista
/// que a contém é quem separa os itens (ver [RecomendacoesList]), deixando
/// a rolagem mais leve do que uma pilha de cards com sombra individual.
class RecomendacaoListTile extends StatelessWidget {
  final Recomendacao recomendacao;
  final VoidCallback? onTap;

  const RecomendacaoListTile({
    super.key,
    required this.recomendacao,
    this.onTap,
  });

  Color get _corScore {
    final score = recomendacao.score;
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatarData(DateTime d) {
    final data =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
    final hora =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$data $hora';
  }

  @override
  Widget build(BuildContext context) {
    final r = recomendacao;
    final cor = _corScore;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Acento lateral colorido pela faixa do score, no lugar do
            // selo circular — a cor já comunica a faixa sem competir com
            // o texto por espaço/atenção.
            Container(
              width: 4,
              height: 40,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: cor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.titulo.isEmpty ? '(sem título)' : r.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RecomendacaoConfiancaDots(confianca: r.confianca),
                      if (r.criadoEm != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.schedule, size: 12, color: onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          _formatarData(r.criadoEm!),
                          style: TextStyle(
                              fontSize: 12, color: onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                  if (r.estimativaCapturaKg != null ||
                      (r.pontos != null && r.pontos!.isNotEmpty)) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (r.estimativaCapturaKg != null)
                          Text(
                            '${r.estimativaCapturaKg} kg',
                            style: TextStyle(
                                fontSize: 12, color: onSurfaceVariant),
                          ),
                        if (r.estimativaCapturaKg != null &&
                            r.pontos != null &&
                            r.pontos!.isNotEmpty)
                          const SizedBox(width: 8),
                        if (r.pontos != null && r.pontos!.isNotEmpty)
                          Text(
                            '${r.pontos!.length} pts',
                            style: TextStyle(
                                fontSize: 12, color: onSurfaceVariant),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${r.score.round()}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
