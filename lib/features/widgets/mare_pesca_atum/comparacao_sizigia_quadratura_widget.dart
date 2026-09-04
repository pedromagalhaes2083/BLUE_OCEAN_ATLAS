import 'package:flutter/material.dart';

import '../../../core/utils/cor_tema.dart';

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
      final estreito = constraints.maxWidth < 640;
      final cardSizigia = _CardRegimeMare(
        titulo: 'Maré de Sizígia',
        emoji: '🌊',
        corPrincipal: Colors.orange.shade800,
        resumo: 'Maior amplitude de maré',
        efeitos: const [
          'Maior variação do nível do mar',
          'Correntes de maré potencialmente mais intensas em determinadas regiões',
          'Maior transporte horizontal de água',
          'Maior mistura em ambientes onde a maré exerce forte influência',
          'Alteração na distribuição/concentração de organismos que servem de alimento aos peixes',
        ],
        relacaoPesca:
            'Em áreas onde as correntes de maré possuem influência significativa, '
            'períodos de maior amplitude podem aumentar a movimentação e a mistura '
            'da água, podendo alterar a distribuição de presas e criar condições '
            'favoráveis à atividade dos atuns.',
        potencial: 'ALTO',
      );
      final cardQuadratura = _CardRegimeMare(
        titulo: 'Maré de Quadratura',
        emoji: '🌊',
        corPrincipal: Colors.blueGrey.shade700,
        resumo: 'Menor amplitude de maré',
        efeitos: const [
          'Correntes de maré potencialmente menos intensas',
          'Menor variação do nível da água',
          'Menor influência da maré sobre a mistura em determinadas regiões',
          'Distribuição diferente de organismos e presas',
        ],
        relacaoPesca:
            'Durante a quadratura, a menor amplitude da maré pode resultar em menor '
            'influência das correntes de maré em determinadas áreas. Entretanto, '
            'isso não significa necessariamente menor atividade de atum, pois '
            'temperatura, frentes oceânicas, alimento, profundidade e outros '
            'fatores podem ser mais importantes.',
        potencial: 'MODERADO',
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
            Text('RELAÇÃO COM A PESCA DE ATUM',
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
                    child: Text('Potencial de influência: $potencial',
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
              'Representa a força potencial da influência da maré, não uma '
              'previsão direta de captura.',
              style: TextStyle(fontSize: 10.5, color: corRot, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
