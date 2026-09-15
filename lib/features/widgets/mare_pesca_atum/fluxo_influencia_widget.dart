import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../l10n/gen/app_localizations.dart';

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

  List<(IconData, String, String)> _etapas(AppLocalizations l10n) => [
        (Icons.nightlight_round, l10n.fluxoEtapa1Titulo, l10n.fluxoEtapa1Sub),
        (Icons.water, l10n.fluxoEtapa2Titulo, l10n.fluxoEtapa2Sub),
        (Icons.blur_on, l10n.fluxoEtapa3Titulo, l10n.fluxoEtapa3Sub),
        (Icons.scatter_plot, l10n.fluxoEtapa4Titulo, l10n.fluxoEtapa4Sub),
        (Icons.restaurant, l10n.fluxoEtapa5Titulo, l10n.fluxoEtapa5Sub),
        (Icons.set_meal, l10n.fluxoEtapa6Titulo, l10n.fluxoEtapa6Sub),
        (Icons.trending_up, l10n.fluxoEtapa7Titulo, l10n.fluxoEtapa7Sub),
      ];

  @override
  Widget build(BuildContext context) {
    final corRot = corRotulo(context);
    final l10n = AppLocalizations.of(context);
    final etapas = _etapas(l10n);
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
              Text(l10n.fluxoInfluenciaTitulo,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text(l10n.fluxoInfluenciaSubtitulo,
                style: TextStyle(fontSize: 11.5, color: corRot)),
            const SizedBox(height: 16),
            for (var i = 0; i < etapas.length; i++) ...[
              _linhaEtapa(corRot, etapas[i]),
              if (i < etapas.length - 1)
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
                l10n.fluxoRodape,
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
