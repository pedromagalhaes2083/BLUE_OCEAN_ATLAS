import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/services/pontos_service.dart';
import '../../../../core/services/street_map_cache_service.dart';
import '../../../producao/domain/models/producao_registro.dart';
import '../../../recomendacao/domain/models/recomendacao.dart';
import '../../domain/models/ponto_marcado.dart';
import '../../widgets/dialogos_producao.dart';
import '../../widgets/street_map_tile_provider.dart';

// Camadas do flutter_map que só desenham dados recebidos — sem estado de
// tela. O `MapaWidget` decide quais entram e em que ordem (ver
// `_buildFlutterMap`); aqui fica só o "como desenha" de cada uma.

const _userAgent = 'com.blueocean.atlas';

/// Mapa de ruas (com cache offline) e as camadas do OpenSeaMap por cima.
///
/// - [profundidade]: sombreamento GEBCO via GeoServer do próprio
///   OpenSeaMap — dado batimétrico real, achado no código-fonte público do
///   site oficial (`OpenSeaMap/online_chart`). Fica abaixo das marcas
///   náuticas (símbolos precisam continuar visíveis por cima).
/// - [curvas]: isóbatas, do servidor GeoServer do projeto de profundidade.
/// - [infoNautica]: marcas, boias, faróis, portos — tiles transparentes que
///   só fazem sentido sobre o mapa de ruas (nunca sobre a carta carregada).
///   Atribuição: © OpenSeaMap contributors (rodapé do menu lateral).
List<Widget> camadasOpenSeaMap(
  StreetMapCacheService cache, {
  required bool profundidade,
  required bool curvas,
  required bool infoNautica,
}) {
  return [
    TileLayer(tileProvider: StreetMapTileProvider(cache)),
    if (profundidade)
      TileLayer(
        wmsOptions: WMSTileLayerOptions(
          baseUrl: 'https://geoserver.openseamap.org/geoserver/gwc/service/wms?',
          layers: const ['gebco2021:gebco_2021'],
          format: 'image/png',
          version: '1.1.1',
        ),
        userAgentPackageName: _userAgent,
      ),
    if (curvas)
      TileLayer(
        wmsOptions: WMSTileLayerOptions(
          baseUrl: 'https://depth.openseamap.org/geoserver/openseamap/wms?',
          layers: const ['openseamap:contour', 'openseamap:contour2'],
          format: 'image/png',
          version: '1.1.0',
        ),
        userAgentPackageName: _userAgent,
      ),
    if (infoNautica)
      TileLayer(
        urlTemplate: 'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
        userAgentPackageName: _userAgent,
      ),
  ];
}

/// Calor de produção — círculos proporcionais ao total em kg registrado
/// perto daquele ponto, em qualquer viagem.
Widget camadaCalorProducao(
  List<ClusterProducao> clusters,
  void Function(ClusterProducao cluster) aoTocar,
) {
  final maxKg = clusters.map((c) => c.totalKg).reduce((a, b) => a > b ? a : b);
  return MarkerLayer(
    markers: clusters.map((c) {
      final tamanho = maxKg <= 0
          ? 24.0
          : (24 + 36 * (c.totalKg / maxKg)).clamp(24.0, 60.0);
      return Marker(
        point: LatLng(c.lat, c.lon),
        width: tamanho,
        height: tamanho,
        child: GestureDetector(
          onTap: () => aoTocar(c),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

Widget _linha(List<LatLng> pontos, Color cor) => PolylineLayer(
      polylines: [Polyline(points: pontos, strokeWidth: 4, color: cor)],
    );

Widget _bolinha(Color cor, double tamanho) => Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );

/// Rota sendo planejada — linha roxa e pontos numerados na sequência.
List<Widget> camadasRotaPlanejada(List<LatLng> pontos) {
  return [
    if (pontos.length > 1) _linha(pontos, Colors.purple),
    if (pontos.isNotEmpty)
      MarkerLayer(
        markers: [
          for (final (indice, ponto) in pontos.indexed)
            Marker(
              point: ponto,
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${indice + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
  ];
}

/// Trilha ao vivo da viagem em andamento — azul (distinta da rota de
/// histórico, vermelha), com a última posição destacada.
List<Widget> camadasTrilhaViagem(List<LatLng> pontos) {
  return [
    if (pontos.length > 1) _linha(pontos, Colors.blue),
    if (pontos.isNotEmpty)
      MarkerLayer(
        markers: [
          Marker(
            point: pontos.last,
            width: 20,
            height: 20,
            child: _bolinha(Colors.blue, 20),
          ),
        ],
      ),
  ];
}

/// Rota do histórico de GPS — linha ligando os pontos na ordem
/// cronológica, ao estilo Waze/Google Maps, com início (verde) e fim
/// (bandeira).
List<Widget> camadasRotaHistorico(List<LatLng> rota) {
  return [
    if (rota.length > 1) _linha(rota, Colors.redAccent),
    if (rota.isNotEmpty)
      MarkerLayer(
        markers: [
          Marker(
            point: rota.first,
            width: 22,
            height: 22,
            child: _bolinha(Colors.green, 22),
          ),
          if (rota.length > 1)
            Marker(
              point: rota.last,
              width: 34,
              height: 34,
              alignment: Alignment.topCenter,
              child: const Icon(Icons.flag, color: Colors.red, size: 28),
            ),
        ],
      ),
  ];
}

/// Rota entre registros de produção — mesmo estilo da rota de histórico,
/// ligando onde cada captura foi feita (na ordem recebida), com o ícone de
/// cardume em cada captura.
List<Widget> camadasRotaProducao(
  List<ProducaoRegistro> registros,
  void Function(ProducaoRegistro registro) aoTocar,
) {
  final comPosicao = registros
      .where((r) => r.latitude != null && r.longitude != null)
      .toList();
  final rota =
      comPosicao.map((r) => LatLng(r.latitude!, r.longitude!)).toList();
  return [
    if (rota.length > 1) _linha(rota, Colors.deepOrange),
    if (registros.isNotEmpty)
      MarkerLayer(
        markers: comPosicao
            .map((registro) => Marker(
                  point: LatLng(registro.latitude!, registro.longitude!),
                  width: 32,
                  height: 32,
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () => aoTocar(registro),
                    child: Image.asset(
                      'assets/icons/icon_cardume_vermelho.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ))
            .toList(),
      ),
  ];
}

/// Pontos precisos: alfinete só — nome/detalhes só aparecem ao tocar, pra
/// não poluir o mapa com texto solto.
Widget camadaPontosPrecisos(
  List<PontoMapa> pontos,
  void Function(PontoMapa ponto) aoTocar,
) {
  return MarkerLayer(
    markers: pontos
        .map((p) => Marker(
              point: LatLng(p.latitude, p.longitude),
              width: 28,
              height: 28,
              child: GestureDetector(
                onTap: () => aoTocar(p),
                child: Center(child: _bolinha(Colors.orange, 14)),
              ),
            ))
        .toList(),
  );
}

/// Pontos de uma recomendação recebida — ícone de cardume.
Widget camadaPontosRecomendacao(
  List<PontoRecomendacao> pontos,
  void Function(PontoRecomendacao ponto) aoTocar,
) {
  return MarkerLayer(
    markers: pontos
        .map((p) => Marker(
              point: LatLng(p.latitude, p.longitude),
              width: 36,
              height: 36,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => aoTocar(p),
                child: Image.asset(
                  'assets/icons/icon_cardume.png',
                  width: 32,
                  height: 32,
                ),
              ),
            ))
        .toList(),
  );
}

/// Pontos marcados pelo mestre — alfinete na [cor] (roxo ao planejar rota,
/// quando tocar adiciona o ponto à rota em vez de abrir o detalhe).
Widget camadaPontosMarcados(
  List<PontoMarcado> pontos, {
  required Color cor,
  required void Function(PontoMarcado ponto) aoTocar,
}) {
  return MarkerLayer(
    markers: pontos
        .map((p) => Marker(
              point: LatLng(p.latitude, p.longitude),
              width: 36,
              height: 36,
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => aoTocar(p),
                child: Icon(Icons.push_pin, color: cor, size: 32),
              ),
            ))
        .toList(),
  );
}
