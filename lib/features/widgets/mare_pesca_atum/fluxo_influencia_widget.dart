import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';

/// Seção "Fluxo de Influência" ("Por que isso importa para o atum?") — a cadeia de influência
/// Maré → Corrente → Mistura/Transporte → Nutrientes/Presas → Alimento →
/// Comportamento → Potencial de pesca, em formato de fluxo vertical.
///
/// Conteúdo estático e educativo — não deriva de dado nenhum, só ilustra a
/// cadeia causal que justifica por que o resto da tela olha pra maré. O
/// texto de rodapé deixa explícito que é uma cadeia de INFLUÊNCIA, não uma
/// relação determinística (ver item 5 do pedido original).
class FluxoInfluenciaWidget extends StatelessWidget {
  const FluxoInfluenciaWidget({super.key});

  static const _etapas = [
    (Icons.nightlight_round, 'Maré', 'Sizígia ou quadratura'),
    (Icons.water, 'Correntes', 'Mais ou menos intensas'),
    (Icons.blur_on, 'Mistura / transporte de água', 'Movimentação da coluna d\'água'),
    (Icons.scatter_plot, 'Distribuição de nutrientes e presas', 'Onde o alimento se concentra'),
    (Icons.restaurant, 'Concentração de alimento', 'Disponibilidade pro atum'),
    (Icons.set_meal, 'Comportamento dos atuns', 'Deslocamento e agregação'),
    (Icons.trending_up, 'Potencial de atividade de pesca', 'Um indicador entre vários'),
  ];

  @override
  Widget build(BuildContext context) {
    final corRot = corRotulo(context);
    final escuro = Theme.of(context).brightness == Brightness.dark;
    final corCard = Color.alphaBlend(
      const Color(0xFFF1F8E9).withValues(alpha: escuro ? 0.18 : 1.0),
      Theme.of(context).cardColor,
    );

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: corCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.route, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              const Text('Fluxo de Influência',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text('Por que isso importa para o atum?',
                style: TextStyle(fontSize: 11.5, color: corRot)),
            const SizedBox(height: 16),
            for (var i = 0; i < _etapas.length; i++) ...[
              _linhaEtapa(corRot, _etapas[i]),
              if (i < _etapas.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Icon(Icons.arrow_downward, size: 16, color: corRot),
                ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Essa é uma cadeia de influência possível, não uma relação '
                'determinística: cada etapa depende de fatores locais (batimetria, '
                'topografia, regime de correntes da região) que a maré sozinha não '
                'explica.',
                style: TextStyle(fontSize: 11.5, color: corRot, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaEtapa(Color corRot, (IconData, String, String) etapa) {
    final (icone, titulo, sub) = etapa;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 17, color: Colors.green.shade800),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(sub, style: TextStyle(fontSize: 11, color: corRot)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
