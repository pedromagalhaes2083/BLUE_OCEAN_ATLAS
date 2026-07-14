import 'package:flutter/material.dart';
import '../domain/models/recomendacao.dart';
import 'recomendacao_ponto_card.dart';

/// Lista vertical dos pontos amostrados de uma recomendação, cada um com
/// data de recebimento, coordenada e variáveis ambientais.
class RecomendacaoPontosList extends StatelessWidget {
  final List<PontoRecomendacao> pontos;
  final DateTime? dataRecebimento;

  const RecomendacaoPontosList({
    super.key,
    required this.pontos,
    this.dataRecebimento,
  });

  @override
  Widget build(BuildContext context) {
    if (pontos.isEmpty) return const SizedBox.shrink();

    return Column(
      children: pontos
          .map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RecomendacaoPontoCard(
                  ponto: p,
                  dataRecebimento: dataRecebimento,
                ),
              ))
          .toList(),
    );
  }
}
