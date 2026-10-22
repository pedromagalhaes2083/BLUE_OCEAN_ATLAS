import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../../../intelligence/data/intelligence_repository.dart';
import '../../../intelligence/domain/models/intelligence_result.dart';
import '../../../intelligence/presentation/intelligence_screen.dart';
import 'camada_consulta_ponto.dart';

/// Inteligência Oceânica em pontos consultados — score 0–100 por ponto
/// (ver `IntelligenceEngine`), nunca probabilidade de pesca. O
/// `IntelligenceRepository` já tolera falha parcial das fontes; só lança se
/// nenhuma respondeu.
class CamadaIntelligence extends CamadaConsultaPonto<IntelligenceResult> {
  @override
  String get id => 'intelligence';

  @override
  String titulo(AppLocalizations l10n) => l10n.mapaIntelligenceTitulo;

  @override
  String tooltipAdicionar(AppLocalizations l10n) =>
      l10n.mapaAdicionarPontoIntelligence;

  @override
  String prefixoErro(AppLocalizations l10n) => l10n.mapaErroCalcularIntelligence;

  @override
  Future<List<IntelligenceResult>> consultar(
          LatLng ponto, AppLocalizations l10n) async =>
      [
        await IntelligenceRepository().avaliarPonto(
          latitude: ponto.latitude,
          longitude: ponto.longitude,
        ),
      ];

  /// Mesma faixa de `RecomendacaoScoreBadge` (≥80 verde, ≥50 laranja, senão
  /// vermelho), pra um score 0–100 ler igual em qualquer lugar do app.
  static Color corDoScore(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  List<Widget> camadas(void Function(IntelligenceResult item) aoTocar) => [
        MarkerLayer(
          markers: pontos
              .map((resultado) => marcadorCircular(
                    ponto: LatLng(resultado.latitude, resultado.longitude),
                    cor: corDoScore(resultado.score),
                    icone: Icons.auto_awesome_outlined,
                    aoTocar: () => aoTocar(resultado),
                  ))
              .toList(),
        ),
      ];

  @override
  void mostrarDetalhe(BuildContext context, IntelligenceResult item,
      {required VoidCallback aoRemover}) {
    final l10n = AppLocalizations.of(context);
    mostrarDialogoDetalhePonto(
      context,
      titulo: titulo(l10n),
      aoRemover: aoRemover,
      conteudo: [
        resumoComCor(
          corDoScore(item.score),
          '${item.score.round()}/100 · '
                  '${item.confianca.round()}% ${l10n.intelligenceConfiancaLabel}'
              .toLowerCase(),
        ),
        const SizedBox(height: 8),
        Text(item.explicacao, style: const TextStyle(fontSize: 13)),
      ],
      acoesExtras: (dialogo) => [
        TextButton(
          onPressed: () {
            Navigator.pop(dialogo);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IntelligenceScreen(
                  latitude: item.latitude,
                  longitude: item.longitude,
                ),
              ),
            );
          },
          child: Text(l10n.mapaIntelligenceVerDetalhes),
        ),
      ],
    );
  }
}
