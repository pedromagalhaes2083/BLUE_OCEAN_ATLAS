import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Os dois cards de comparação Sizígia × Quadratura da tela "Maré e Pesca
/// de Atum" — conteúdo fixo (a diferença física entre os dois regimes de
/// maré é sempre a mesma, não depende de dado de hoje), lado a lado no
/// desktop/tablet e empilhados no celular (ver item 14 do pedido:
/// "no celular, os cards devem passar para uma coluna").
class ComparacaoSizigiaQuadraturaWidget extends StatelessWidget {
  const ComparacaoSizigiaQuadraturaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final l10n = AppLocalizations.of(context);
      final estreito = constraints.maxWidth < 640;
      final cardSizigia = _CardRegimeMare(
        titulo: l10n.comparacaoSizigiaTitulo,
        emoji: '🌊',
        corPrincipal: Colors.orange.shade800,
        resumo: l10n.comparacaoSizigiaResumo,
        efeitos: [
          l10n.comparacaoSizigiaEfeito1,
          l10n.comparacaoSizigiaEfeito2,
          l10n.comparacaoSizigiaEfeito3,
          l10n.comparacaoSizigiaEfeito4,
          l10n.comparacaoSizigiaEfeito5,
        ],
        relacaoPesca: l10n.comparacaoSizigiaRelacaoPesca,
        potencial: l10n.comparacaoSizigiaPotencial,
      );
      final cardQuadratura = _CardRegimeMare(
        titulo: l10n.comparacaoQuadraturaTitulo,
        emoji: '🌊',
        corPrincipal: Colors.blueGrey.shade700,
        resumo: l10n.comparacaoQuadraturaResumo,
        efeitos: [
          l10n.comparacaoQuadraturaEfeito1,
          l10n.comparacaoQuadraturaEfeito2,
          l10n.comparacaoQuadraturaEfeito3,
          l10n.comparacaoQuadraturaEfeito4,
        ],
        relacaoPesca: l10n.comparacaoQuadraturaRelacaoPesca,
        potencial: l10n.comparacaoQuadraturaPotencial,
      );

      if (estreito) {
        return Column(children: [
          cardSizigia,
          const SizedBox(height: 12),
          cardQuadratura,
        ]);
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: cardSizigia),
            const SizedBox(width: 12),
            Expanded(child: cardQuadratura),
          ],
        ),
      );
    });
  }
}

class _CardRegimeMare extends StatelessWidget {
  final String titulo;
  final String emoji;
  final Color corPrincipal;
  final String resumo;
  final List<String> efeitos;
  final String relacaoPesca;
  final String potencial;

  const _CardRegimeMare({
    required this.titulo,
    required this.emoji,
    required this.corPrincipal,
    required this.resumo,
    required this.efeitos,
    required this.relacaoPesca,
    required this.potencial,
  });

  @override
  Widget build(BuildContext context) {
    final corRot = corRotulo(context);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: corPrincipal.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(titulo,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: corPrincipal)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(resumo,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: corRot)),
            const SizedBox(height: 12),
            ...efeitos.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Icon(Icons.circle, size: 5, color: corPrincipal),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(e,
                              style: TextStyle(fontSize: 12.5, color: corRot))),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).comparacaoRelacaoPescaTitulo,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: corRot)),
            const SizedBox(height: 6),
            Text(relacaoPesca,
                style: const TextStyle(fontSize: 12.5, height: 1.4)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: corPrincipal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.insights, size: 15, color: corPrincipal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        AppLocalizations.of(context)
                            .comparacaoPotencialInfluencia(potencial),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: corPrincipal)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).comparacaoRodape,
              style: TextStyle(fontSize: 10.5, color: corRot, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
