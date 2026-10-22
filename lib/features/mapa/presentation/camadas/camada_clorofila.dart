import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/utils/coordenadas_format.dart';
import '../../../../core/utils/cor_tema.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../data/clorofila_repository.dart';
import '../../domain/models/leitura_clorofila.dart';
import '../../domain/models/nivel_produtividade.dart';
import 'camada_consulta_ponto.dart';

/// Clorofila-a (NOAA CoastWatch, ERDDAP) em pontos consultados — indicador
/// de produtividade biológica, nunca biomassa de peixe (ver
/// [LeituraClorofilaPonto]). "Sem dado" e erro de rede nunca viram valor
/// inventado. Cada ponto tem a cor da faixa da escala (Ruim/Bom/Ótimo/
/// Excelente, ver [corNivelProdutividade]).
class CamadaClorofila extends CamadaConsultaPonto<LeituraClorofilaPonto> {
  @override
  String get id => 'clorofila';

  @override
  String titulo(AppLocalizations l10n) => l10n.mapaClorofilaTitulo;

  @override
  String tooltipAdicionar(AppLocalizations l10n) =>
      l10n.mapaAdicionarPontoClorofila;

  @override
  String prefixoErro(AppLocalizations l10n) => l10n.mapaErroBuscarClorofila;

  @override
  Future<List<LeituraClorofilaPonto>> consultar(
          LatLng ponto, AppLocalizations l10n) async =>
      [
        await ClorofilaRepository().buscarPontoOuAproximado(
          latitude: ponto.latitude,
          longitude: ponto.longitude,
        ),
      ];

  @override
  List<Widget> camadas(void Function(LeituraClorofilaPonto item) aoTocar) => [
        MarkerLayer(
          markers: pontos.map((ponto) {
            final valor = ponto.valorMgM3;
            return marcadorCircular(
              ponto: LatLng(ponto.latitude, ponto.longitude),
              cor: valor != null
                  ? corNivelProdutividade(nivelClorofila(valor))
                  : Colors.grey.withValues(alpha: 0.7),
              icone: Icons.eco,
              aoTocar: () => aoTocar(ponto),
            );
          }).toList(),
        ),
      ];

  @override
  void mostrarDetalhe(BuildContext context, LeituraClorofilaPonto item,
      {required VoidCallback aoRemover}) {
    final l10n = AppLocalizations.of(context);
    final valor = item.valorMgM3;
    final nivel = valor != null ? nivelClorofila(valor) : null;
    mostrarDialogoDetalhePonto(
      context,
      titulo: titulo(l10n),
      aoRemover: aoRemover,
      conteudo: [
        if (nivel != null)
          resumoComCor(corNivelProdutividade(nivel), nivel.rotulo)
        else
          Text(
            l10n.mapaClorofilaSemDado,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 8),
        Text(l10n.mapaClorofilaData(DateFormat('dd/MM/yyyy').format(item.data))),
        // Veio do cache sem confirmar que é o produto mais recente (sem
        // rede) — ver ClorofilaRepository.buscarPontoOuAproximado.
        if (item.desatualizada)
          Text(
            l10n.intelligenceClorofilaDesatualizada,
            style: const TextStyle(color: Colors.orange),
          ),
        const SizedBox(height: 4),
        Text(l10n.mapaClorofilaFonte(item.source)),
        const SizedBox(height: 4),
        // Coordenada de onde o dado foi medido de verdade — sempre
        // mostrada, não só quando aproximado: o pixel do satélite tem ~2 km,
        // então nunca é exatamente o ponto tocado no mapa.
        Text(
          l10n.mapaClorofilaCoordenadaDado(
              formatarCoordenadasDMSCompacta(item.latitude, item.longitude)),
          style: TextStyle(fontSize: 12, color: corRotulo(context)),
        ),
        if (item.aproximado) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.mapaClorofilaAproximadoAviso,
                  style: const TextStyle(fontSize: 12, color: Colors.amber),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          l10n.mapaClorofilaDisclaimer,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
