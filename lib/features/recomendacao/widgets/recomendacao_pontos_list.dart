import 'package:flutter/material.dart';
import '../domain/models/recomendacao.dart';
import 'recomendacao_ponto_card.dart';

/// Lista vertical dos pontos amostrados de uma recomendação, cada um com
/// data de recebimento, coordenada e variáveis ambientais. Sempre visível
/// (sem recolher atrás de um ExpansionTile); acima de [_maxVisiveis]
/// pontos, a lista ganha altura fixa e rola por dentro em vez de esticar
/// o card indefinidamente.
class RecomendacaoPontosList extends StatelessWidget {
  final List<PontoRecomendacao> pontos;
  final DateTime? dataRecebimento;

  const RecomendacaoPontosList({
    super.key,
    required this.pontos,
    this.dataRecebimento,
  });

  static const _maxVisiveis = 3;
  static const _alturaItem = 96.0;

  @override
  Widget build(BuildContext context) {
    if (pontos.isEmpty) return const SizedBox.shrink();

    final lista = ListView.separated(
      shrinkWrap: true,
      physics: pontos.length > _maxVisiveis
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: pontos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => RecomendacaoPontoCard(
        ponto: pontos[i],
        dataRecebimento: dataRecebimento,
      ),
    );

    if (pontos.length <= _maxVisiveis) return lista;

    return SizedBox(
      height: _alturaItem * _maxVisiveis,
      child: Scrollbar(child: lista),
    );
  }
}
