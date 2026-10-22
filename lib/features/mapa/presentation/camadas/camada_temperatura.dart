import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/models/sst_ponto.dart';
import '../../../../core/utils/coordenadas_format.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../metereologia/data/wave_forecast_repository.dart';
import '../../widgets/legenda_grade_temperatura.dart' show corGradeTemperatura;
import 'camada_consulta_ponto.dart';

/// Temperatura da superfície do mar (SST) em pontos consultados — cada
/// ponto vira um quadrado colorido estilo mapa de calor, com o valor em
/// cima a partir de [zoomMinimoRotulo].
class CamadaTemperatura extends CamadaConsultaPonto<SstPonto> {
  /// Lado do quadrado desenhado, em graus — só um tamanho visual (a
  /// consulta é sempre de um ponto único), próximo da resolução de 0,25°
  /// dos modelos meteorológicos que o app já usa em outros lugares.
  static const espacamento = 0.25;

  /// Abaixo disso as células ficam pequenas demais e os números se
  /// atropelam; a cor de fundo continua aparecendo em qualquer zoom.
  static const zoomMinimoRotulo = 8.0;

  /// Atualizado pelo mapa conforme o zoom (ver [zoomMinimoRotulo]).
  bool rotulosVisiveis = true;

  @override
  String get id => 'temperatura';

  @override
  String titulo(AppLocalizations l10n) => l10n.mapaTemperaturaTitulo;

  @override
  String tooltipAdicionar(AppLocalizations l10n) =>
      l10n.mapaAdicionarPontoTemperatura;

  @override
  String prefixoErro(AppLocalizations l10n) => l10n.mapaErroBuscarTemperatura;

  @override
  Future<List<SstPonto>> consultar(LatLng ponto, AppLocalizations l10n) =>
      WaveForecastRepository().buscarGrade([ponto]);

  /// A temperatura não abre diálogo depois da consulta — o valor já aparece
  /// no quadrado; só confirma com uma mensagem rápida.
  @override
  void aposConsultar(BuildContext context, List<SstPonto> novos,
      void Function(SstPonto item) abrirDetalhe) {
    final l10n = AppLocalizations.of(context);
    final valor = novos.isNotEmpty ? novos.first.temperaturaC : null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(valor != null
            ? l10n.mapaTemperaturaResultado(valor.toStringAsFixed(1))
            : l10n.mapaTemperaturaSemDado),
      ),
    );
  }

  /// Menor e maior temperatura entre os pontos, pra escala de cor.
  (double min, double max)? get _minMax {
    final temperaturas = pontos.map((p) => p.temperaturaC).whereType<double>();
    if (temperaturas.isEmpty) return null;
    return (
      temperaturas.reduce((a, b) => a < b ? a : b),
      temperaturas.reduce((a, b) => a > b ? a : b),
    );
  }

  /// Um quadrado colorido por célula (`PolygonLayer`) com o valor em cima
  /// (`MarkerLayer`) — os dois juntos formam a grade estilo mapa de calor.
  @override
  List<Widget> camadas(void Function(SstPonto item) aoTocar) {
    final comTemperatura = pontos.where((p) => p.temperaturaC != null).toList();
    final minMax = _minMax;
    if (comTemperatura.isEmpty || minMax == null) return const [];
    final (min, max) = minMax;
    const meiaCelula = espacamento / 2;

    return [
      PolygonLayer(
        polygons: comTemperatura.map((p) {
          final cor = corGradeTemperatura(p.temperaturaC!, min, max);
          return Polygon(
            points: [
              LatLng(p.latitude - meiaCelula, p.longitude - meiaCelula),
              LatLng(p.latitude - meiaCelula, p.longitude + meiaCelula),
              LatLng(p.latitude + meiaCelula, p.longitude + meiaCelula),
              LatLng(p.latitude + meiaCelula, p.longitude - meiaCelula),
            ],
            color: cor.withValues(alpha: 0.55),
            borderColor: Colors.white.withValues(alpha: 0.4),
            borderStrokeWidth: 1,
          );
        }).toList(),
      ),
      // Alvo de toque por ponto — sempre presente (mesmo com o rótulo
      // escondido em zoom baixo), pra ver o valor exato e remover.
      MarkerLayer(
        markers: comTemperatura
            .map((p) => Marker(
                  point: LatLng(p.latitude, p.longitude),
                  width: 44,
                  height: 32,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => aoTocar(p),
                    child: rotulosVisiveis
                        ? Center(
                            child: Text(
                              '${p.temperaturaC!.toStringAsFixed(0)}°',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : const SizedBox.expand(),
                  ),
                ))
            .toList(),
      ),
    ];
  }

  @override
  void mostrarDetalhe(BuildContext context, SstPonto item,
      {required VoidCallback aoRemover}) {
    final l10n = AppLocalizations.of(context);
    final valor = item.temperaturaC;
    mostrarDialogoDetalhePonto(
      context,
      titulo: titulo(l10n),
      aoRemover: aoRemover,
      conteudo: [
        Text(
          valor != null
              ? l10n.mapaTemperaturaResultado(valor.toStringAsFixed(1))
              : l10n.mapaTemperaturaSemDado,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          formatarCoordenadasDMSCompacta(item.latitude, item.longitude),
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}
