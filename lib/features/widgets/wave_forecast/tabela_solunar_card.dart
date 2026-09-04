import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/tabela_solunar.dart';

/// Card da tabela solunar — períodos de maior/menor atividade de
/// alimentação dos peixes (ver `core/utils/tabela_solunar.dart`), já
/// filtrados só pro dia de hoje.
/// Uso: TabelaSolunarCard(periodos: calcularPeriodosSolunares(dias, desde: hoje))
class TabelaSolunarCard extends StatelessWidget {
  final List<PeriodoSolunar> periodos;

  const TabelaSolunarCard({super.key, required this.periodos});

  @override
  Widget build(BuildContext context) {
    if (periodos.isEmpty) return const SizedBox.shrink();

    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCard = Color.alphaBlend(
      const Color(0xFFFFF3E0).withValues(alpha: escuro ? 0.18 : 1.0),
      Theme.of(context).cardColor,
    );

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      color: corCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.set_meal_outlined,
                    color: Colors.deepOrange, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Tabela Solunar',
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Períodos de maior atividade de alimentação, segundo a posição da lua',
              style: TextStyle(fontSize: 11, color: corRotulo(context)),
            ),
            const SizedBox(height: 14),
            ...periodos.map((p) => _LinhaPeriodo(periodo: p)),
          ],
        ),
      ),
    );
  }
}

class _LinhaPeriodo extends StatelessWidget {
  final PeriodoSolunar periodo;

  const _LinhaPeriodo({required this.periodo});

  @override
  Widget build(BuildContext context) {
    final maior = periodo.tipo == TipoPeriodoSolunar.maior;
    final cor = maior ? Colors.deepOrange : Colors.deepOrange.shade300;

    String hm(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            maior ? Icons.star : Icons.star_border,
            size: 16,
            color: cor,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 84,
            child: Text(
              periodo.tipo.label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: cor),
            ),
          ),
          Text(
            '${hm(periodo.inicio)} – ${hm(periodo.fim)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
