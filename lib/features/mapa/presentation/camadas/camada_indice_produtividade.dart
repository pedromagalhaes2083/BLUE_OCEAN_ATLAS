import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../../../metereologia/data/wave_forecast_repository.dart';
import '../../data/clorofila_repository.dart';
import '../../domain/models/indice_produtividade_blue_ocean.dart';
import '../../domain/models/nivel_produtividade.dart';
import 'camada_consulta_ponto.dart';

/// Índice de Produtividade Blue Ocean em pontos consultados — combina
/// clorofila-a e temperatura num único indicador (ver
/// [IndiceProdutividadeBlueOcean.calcular]). Sempre uma estimativa
/// heurística, nunca garantia de cardume. Estrela cheia pra diferenciar do
/// marcador de clorofila (folha) e da Inteligência (estrela contornada).
class CamadaIndiceProdutividade
    extends CamadaConsultaPonto<IndiceProdutividadeBlueOcean> {
  @override
  String get id => 'indice';

  @override
  String titulo(AppLocalizations l10n) => l10n.mapaIndiceProdutividadeTitulo;

  @override
  String tooltipAdicionar(AppLocalizations l10n) =>
      l10n.mapaAdicionarPontoIndice;

  @override
  String prefixoErro(AppLocalizations l10n) => l10n.mapaErroCalcularIndice;

  /// Busca clorofila e temperatura em paralelo e tolera a falha de uma das
  /// duas (ex.: SST fora de cobertura marinha, clorofila sem dado por
  /// nuvem): o índice sai só com o que conseguiu, nunca inventa o que
  /// faltou. Só lança se as duas falharem.
  @override
  Future<List<IndiceProdutividadeBlueOcean>> consultar(
      LatLng ponto, AppLocalizations l10n) async {
    double? clorofilaValor;
    DateTime? clorofilaData;
    double? temperaturaValor;
    Object? erro;
    var algumSucesso = false;

    await Future.wait([
      ClorofilaRepository()
          .buscarPontoOuAproximado(
              latitude: ponto.latitude, longitude: ponto.longitude)
          .then((r) {
        clorofilaValor = r.valorMgM3;
        clorofilaData = r.data;
        algumSucesso = true;
      }).catchError((e) => erro = e),
      WaveForecastRepository()
          .buscar(latitude: ponto.latitude, longitude: ponto.longitude)
          .then((r) {
        temperaturaValor = r.current?.seaSurfaceTemperature;
        algumSucesso = true;
      }).catchError((e) => erro = e),
    ]);

    if (!algumSucesso) throw erro ?? Exception(l10n.mapaErroCalcularIndice);

    return [
      IndiceProdutividadeBlueOcean.calcular(
        latitude: ponto.latitude,
        longitude: ponto.longitude,
        clorofilaMgM3: clorofilaValor,
        clorofilaData: clorofilaData,
        temperaturaC: temperaturaValor,
      ),
    ];
  }

  @override
  List<Widget> camadas(
          void Function(IndiceProdutividadeBlueOcean item) aoTocar) =>
      [
        MarkerLayer(
          markers: pontos
              .map((indice) => marcadorCircular(
                    ponto: LatLng(indice.latitude, indice.longitude),
                    cor: corNivelProdutividade(indice.nivel),
                    icone: Icons.auto_awesome,
                    aoTocar: () => aoTocar(indice),
                  ))
              .toList(),
        ),
      ];

  @override
  void mostrarDetalhe(BuildContext context, IndiceProdutividadeBlueOcean item,
      {required VoidCallback aoRemover}) {
    final l10n = AppLocalizations.of(context);
    mostrarDialogoDetalhePonto(
      context,
      titulo: titulo(l10n),
      aoRemover: aoRemover,
      conteudo: [
        resumoComCor(corNivelProdutividade(item.nivel), item.nivel.rotulo),
        const SizedBox(height: 8),
        Text(item.explicacao, style: const TextStyle(fontSize: 13)),
        if (item.clorofilaData != null) ...[
          const SizedBox(height: 8),
          Text(l10n.mapaIndiceDadosClorofilaData(
              DateFormat('dd/MM/yyyy').format(item.clorofilaData!))),
        ],
        const SizedBox(height: 4),
        Text(l10n.mapaIndiceFontes),
        const SizedBox(height: 12),
        Text(
          l10n.mapaIndiceDisclaimer,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
