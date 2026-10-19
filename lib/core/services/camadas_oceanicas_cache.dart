import 'package:flutter_map/flutter_map.dart';

import 'street_map_cache_service.dart';

/// Monta a URL WMS de um tile z/x/y usando a mesma matemática de bbox que o
/// `flutter_map` já usa internamente (`WMSTileLayerOptions.getUrl`) —
/// reaproveitada aqui só pra ter uma URL fechada que o cache em disco
/// (`StreetMapCacheService.camada`) possa buscar/gravar, já que
/// `TileLayer(wmsOptions:)` não expõe um `TileProvider` próprio pra
/// interceptar o fetch como o mapa de ruas já faz.
String _urlWms(WMSTileLayerOptions opcoes, int z, int x, int y) =>
    opcoes.getUrl(TileCoordinates(x, y, z), 256, false);

final wmsProfundidadeOceanica = WMSTileLayerOptions(
  baseUrl: 'https://geoserver.openseamap.org/geoserver/gwc/service/wms?',
  layers: const ['gebco2021:gebco_2021'],
  format: 'image/png',
  version: '1.1.1',
);
final wmsContornosOceanicos = WMSTileLayerOptions(
  baseUrl: 'https://depth.openseamap.org/geoserver/openseamap/wms?',
  layers: const ['openseamap:contour', 'openseamap:contour2'],
  format: 'image/png',
  version: '1.1.0',
);

/// Caches em disco das camadas do OpenSeaMap (profundidade GEBCO, isóbatas,
/// marcas náuticas) — compartilhados entre qualquer tela que mostre essas
/// camadas (`NavegacaoRotaScreen`, "Baixar região" do mapa principal), uma
/// pasta por camada, pra não misturar tile de fontes diferentes no mesmo
/// cache (ver `StreetMapCacheService.camada`). Instâncias no nível do
/// arquivo — uma só por camada no app inteiro, não uma por tela — pra
/// tiles baixados numa tela (ex: "Baixar região") já servirem offline na
/// outra (ex: Navegação de Rota) sem duplicar nada em disco.
final cacheProfundidadeOceanica = StreetMapCacheService.camada(
  subDir: 'profundidade_cache',
  urlBuilder: (z, x, y) => _urlWms(wmsProfundidadeOceanica, z, x, y),
);
final cacheContornosOceanicos = StreetMapCacheService.camada(
  subDir: 'contornos_cache',
  urlBuilder: (z, x, y) => _urlWms(wmsContornosOceanicos, z, x, y),
);
final cacheSeamarkOceanico = StreetMapCacheService.camada(
  subDir: 'seamark_cache',
  urlBuilder: (z, x, y) => 'https://tiles.openseamap.org/seamark/$z/$x/$y.png',
);
