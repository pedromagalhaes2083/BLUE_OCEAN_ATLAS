import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/config.dart';
import '../../../core/config/constantes.dart';
import '../../../core/config/limiares_alerta.dart';
import '../../../core/planos/plano_service.dart';
import '../../../core/planos/recurso_atlas.dart';
import '../../../core/services/street_map_cache_service.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/cor_tema.dart';
import '../../../core/utils/proximidade.dart';
import '../../../core/utils/severidade_condicoes.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../mapa/widgets/street_map_tile_provider.dart';
import '../../metereologia/data/previsao_tempo_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../domain/models/rota_planejada.dart';

/// Desvio lateral acima do qual a tela avisa "fora da rota" — meia milha
/// náutica de referência, não vem de nenhuma norma náutica específica, só
/// o suficiente pra distinguir ruído de GPS de um desvio de curso real.
const _desvioAvisoNauticas = 0.5;

/// Monta a URL WMS de um tile z/x/y usando a mesma matemática de bbox que
/// o `flutter_map` já usa internamente (`WMSTileLayerOptions.getUrl`) —
/// reaproveitada aqui só pra ter uma URL fechada que o cache em disco
/// (`StreetMapCacheService.camada`) possa buscar/gravar, já que
/// `TileLayer(wmsOptions:)` não expõe um `TileProvider` próprio pra
/// interceptar o fetch como o mapa de ruas já faz.
String _urlWms(WMSTileLayerOptions opcoes, int z, int x, int y) =>
    opcoes.getUrl(TileCoordinates(x, y, z), 256, false);

final _wmsProfundidade = WMSTileLayerOptions(
  baseUrl: 'https://geoserver.openseamap.org/geoserver/gwc/service/wms?',
  layers: const ['gebco2021:gebco_2021'],
  format: 'image/png',
  version: '1.1.1',
);
final _wmsContornos = WMSTileLayerOptions(
  baseUrl: 'https://depth.openseamap.org/geoserver/openseamap/wms?',
  layers: const ['openseamap:contour', 'openseamap:contour2'],
  format: 'image/png',
  version: '1.1.0',
);

/// Caches em disco das camadas do OpenSeaMap usadas aqui — instâncias
/// próprias (não a mesma do mapa de ruas), uma pasta por camada, pra não
/// misturar tile de fontes diferentes no mesmo cache (ver
/// `StreetMapCacheService.camada`). Guardadas no nível do arquivo (não por
/// tela) pra persistir entre navegações sem recriar a cada abertura.
final _cacheProfundidade = StreetMapCacheService.camada(
  subDir: 'profundidade_cache',
  urlBuilder: (z, x, y) => _urlWms(_wmsProfundidade, z, x, y),
);
final _cacheContornos = StreetMapCacheService.camada(
  subDir: 'contornos_cache',
  urlBuilder: (z, x, y) => _urlWms(_wmsContornos, z, x, y),
);
final _cacheSeamark = StreetMapCacheService.camada(
  subDir: 'seamark_cache',
  urlBuilder: (z, x, y) =>
      'https://tiles.openseamap.org/seamark/$z/$x/$y.png',
);

/// Condição do mar/tempo num ponto da rota — usado tanto pelo marcador
/// redondo estilo Waze no mapa (só os severos, ver [severo]) quanto pela
/// lista de pontos no painel retrátil (todos os pontos, severos ou não —
/// ver [_listaPontosRota]). [icone]/[descricao] ficam nulos quando o ponto
/// não cruza nenhum limiar configurado.
class _CondicaoPontoRota {
  final LatLng ponto;
  IconData? icone;
  String? descricao;

  _CondicaoPontoRota({required this.ponto});

  bool get severo => icone != null;
}

/// Navegação ao vivo sobre uma rota planejada ([RotaPlanejada]) — GPS
/// contínuo projetado sobre a rota (ver `projetarNaRota`) pra mostrar
/// quanto já foi percorrido, quanto falta e o desvio lateral do curso
/// planejado, atualizado a cada posição nova. Rota e viagem são vinculadas
/// antes de abrir essa tela (ver `MinhasRotasScreen._seguirRota`) — aqui só
/// se navega, não se escolhe a rota.
class NavegacaoRotaScreen extends StatefulWidget {
  final RotaPlanejada rota;

  const NavegacaoRotaScreen({super.key, required this.rota});

  @override
  State<NavegacaoRotaScreen> createState() => _NavegacaoRotaScreenState();
}

class _NavegacaoRotaScreenState extends State<NavegacaoRotaScreen> {
  final _mapController = MapController();
  StreamSubscription<Position>? _posicaoSub;
  LatLng? _posicaoAtual;
  double _rumo = 0;
  ProjecaoNaRota? _projecao;
  bool _primeiraPosicao = true;
  List<_CondicaoPontoRota> _condicoes = [];
  bool _alertasCarregados = false;

  /// Modo "seguir": recentraliza o mapa a cada posição nova, igual ao Modo
  /// Navegação do mapa principal. Desligado por padrão — forçar o
  /// recentralizar atrapalharia quem quer inspecionar outra parte do mapa
  /// enquanto a viagem continua (ver conversa), então é opt-in.
  bool _modoSeguir = false;

  /// Se as camadas do OpenSeaMap abaixo devem usar o cache em disco (ver
  /// [_cacheProfundidade]/[_cacheContornos]/[_cacheSeamark]) — espelha
  /// `Constantes.cacheCamadasOceanicas` (Configurações), "true" por
  /// padrão até o valor real carregar, pra já começar cacheando na
  /// primeira abertura em vez de esperar a leitura do disco.
  bool _cacheCamadasOceanicas = true;

  @override
  void initState() {
    super.initState();
    _carregarPreferenciaCache();
    _posicaoSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_aoReceberPosicao, onError: (e) {
      debugPrint('NavegacaoRotaScreen: erro no stream de GPS ($e)');
    });
  }

  Future<void> _carregarPreferenciaCache() async {
    final valor = await Config.obtem(Constantes.cacheCamadasOceanicas, 'true');
    if (!mounted) return;
    setState(() => _cacheCamadasOceanicas = valor == 'true');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `_carregarAlertas` usa `AppLocalizations.of(context)` — chamar isso
    // ainda dentro de `initState` derruba a função inteira com
    // "dependOnInheritedWidgetOfExactType... called before initState()
    // completed" (visto no log do dispositivo: toda tentativa de buscar
    // condição falhava silenciosamente nesse ponto, antes até de chegar
    // numa chamada de API — por isso nenhum alerta nunca aparecia).
    // `didChangeDependencies` já roda depois do `initState` terminar, com
    // o context totalmente registrado. `_alertasCarregados` evita rodar de
    // novo a cada dependência que mudar (ex: troca de tema/idioma).
    if (!_alertasCarregados) {
      _alertasCarregados = true;
      _carregarAlertas();
    }
  }

  /// Busca vento/onda/swell/corrente/temperatura em cada ponto da rota
  /// (mesmas fontes e limiares de `AnaliseRotaScreen`, pra não ter dois
  /// lugares discordando do que é "severo") e guarda a condição de TODOS
  /// os pontos, não só os severos: o marcador no mapa usa só os severos
  /// (ver [_CondicaoPontoRota.severo]), mas a lista de pontos no painel
  /// retrátil (ver [_listaPontosRota]) mostra a rota inteira. Roda em
  /// paralelo com o stream de GPS, sem travar a navegação ao vivo
  /// enquanto busca; melhor-esforço ponto a ponto, um ponto que falhar não
  /// derruba os outros (fica sem ícone, como se estivesse normal).
  /// Pontos buscados em paralelo por vez — rota com muitos pontos (cada um
  /// são 2 chamadas de API, vento+onda) disparando tudo de uma vez só
  /// estourava limite de taxa da API (visto no log do dispositivo: erro
  /// 429 em pontos de uma rota de 11 pontos = 22 chamadas simultâneas).
  static const _concorrenciaMaxima = 3;

  Future<void> _carregarAlertas() async {
    final pontos = widget.rota.pontos;
    setState(() =>
        _condicoes = [for (final p in pontos) _CondicaoPontoRota(ponto: p)]);

    if (!PlanoService.possui(RecursoAtlas.rotasAnaliseRota)) return;
    final l10n = AppLocalizations.of(context);
    final limiares = await LimiaresAlerta.carregar();

    for (var i = 0; i < _condicoes.length; i += _concorrenciaMaxima) {
      final lote = _condicoes.skip(i).take(_concorrenciaMaxima);
      await Future.wait(lote.map((c) async {
        try {
          final previsao = await PrevisaoTempoRepository()
              .buscar(latitude: c.ponto.latitude, longitude: c.ponto.longitude);
          final onda = await WaveForecastRepository()
              .buscar(latitude: c.ponto.latitude, longitude: c.ponto.longitude);

          final ventoKmh = previsao.atual?.velocidadeVento;
          final ondaAlturaM = onda.current?.waveHeight;
          final swellAlturaM = onda.current?.swellWaveHeight;
          final correnteKmh = onda.current?.oceanCurrentVelocity;
          final correnteNos =
              correnteKmh != null ? correnteKmh * 0.539957 : null;
          final temperaturaC = onda.current?.seaSurfaceTemperature;

          // Prioridade vento > onda/swell > corrente > temperatura quando
          // mais de uma condição dispara no mesmo ponto — só dá pra mostrar
          // um ícone/descrição por ponto.
          if (limiares.ventoAtivo &&
              ventoKmh != null &&
              ventoSevero(ventoKmh, limiares.ventoLimiarKmh)) {
            c.icone = Icons.air;
            c.descricao =
                '${l10n.metricaVento}: ${ventoKmh.toStringAsFixed(0)} km/h';
          } else if (limiares.ondaAtivo &&
              ((ondaAlturaM != null &&
                      alturaSevera(ondaAlturaM, limiares.ondaLimiarM)) ||
                  (swellAlturaM != null &&
                      alturaSevera(swellAlturaM, limiares.ondaLimiarM)))) {
            final altura = (ondaAlturaM != null &&
                    alturaSevera(ondaAlturaM, limiares.ondaLimiarM))
                ? ondaAlturaM
                : swellAlturaM!;
            c.icone = Icons.waves_outlined;
            c.descricao = '${l10n.metricaOnda}: ${altura.toStringAsFixed(1)} m';
          } else if (limiares.correnteAtivo &&
              correnteNos != null &&
              correnteSevera(correnteNos, limiares.correnteLimiarNos)) {
            c.icone = Icons.water_outlined;
            c.descricao =
                '${l10n.metricaCorrente}: ${correnteNos.toStringAsFixed(1)} nós';
          } else if (limiares.temperaturaAtivo &&
              temperaturaC != null &&
              temperaturaSevera(temperaturaC, limiares.temperaturaLimiarC)) {
            c.icone = Icons.thermostat_outlined;
            c.descricao =
                '${l10n.metricaAgua}: ${temperaturaC.toStringAsFixed(1)}°C';
          }
        } catch (e) {
          debugPrint('NavegacaoRotaScreen: erro buscando condições do ponto '
              '${c.ponto.latitude},${c.ponto.longitude} ($e)');
        }
        if (mounted) setState(() {});
      }));
    }
  }

  @override
  void dispose() {
    _posicaoSub?.cancel();
    super.dispose();
  }

  void _aoReceberPosicao(Position posicao) {
    if (!mounted) return;
    final pos = LatLng(posicao.latitude, posicao.longitude);
    setState(() {
      _posicaoAtual = pos;
      if (posicao.heading >= 0) _rumo = posicao.heading;
      _projecao = projetarNaRota(pos, widget.rota.pontos);
    });
    if (_primeiraPosicao) {
      _primeiraPosicao = false;
      _mapController.move(pos, 14);
    } else if (_modoSeguir) {
      // Mantém o zoom que o mestre já tinha escolhido — só recentraliza,
      // não força um nível de zoom novo a cada posição.
      _mapController.move(pos, _mapController.camera.zoom);
    }
  }

  void _alternarModoSeguir() {
    setState(() => _modoSeguir = !_modoSeguir);
    if (_modoSeguir && _posicaoAtual != null) {
      _mapController.move(_posicaoAtual!, _mapController.camera.zoom);
    }
  }

  /// Monta um link de rota do Google Maps com todos os pontos da rota
  /// planejada (origem, waypoints intermediários e destino) — quem recebe
  /// abre a mesma rota no mapa dele, não só um texto com coordenadas soltas.
  /// Tenta abrir direto no WhatsApp (`wa.me` sem contato fixo abre o
  /// seletor de conversa) e cai no menu de compartilhamento padrão do
  /// aparelho se o WhatsApp não estiver instalado — mesmo padrão de
  /// resiliência do botão SOS do Dashboard.
  Future<void> _compartilharRota() async {
    final l10n = AppLocalizations.of(context);
    final pontos = widget.rota.pontos;
    final origem = pontos.first;
    final destino = pontos.last;
    final waypoints = pontos.length > 2
        ? pontos
            .sublist(1, pontos.length - 1)
            .map((p) => '${p.latitude},${p.longitude}')
            .join('|')
        : null;

    final link = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': '${origem.latitude},${origem.longitude}',
      'destination': '${destino.latitude},${destino.longitude}',
      if (waypoints != null) 'waypoints': waypoints,
    }).toString();

    final mensagem = l10n.rotasCompartilharMensagem(widget.rota.nome, link);

    final whatsapp =
        Uri.parse('https://wa.me/?text=${Uri.encodeComponent(mensagem)}');
    final abriu =
        await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
    if (!abriu) await Share.share(mensagem);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projecao = _projecao;
    final foraDaRota =
        projecao != null && projecao.desvioNauticas > _desvioAvisoNauticas;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.rotasNavegarTelaTitulo} · ${widget.rota.nome}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.rotasCompartilharTooltip,
            onPressed: _compartilharRota,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.rota.pontos.first,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.blueocean.atlas',
                ),
                // Camadas do OpenSeaMap, sempre ligadas aqui (diferente do
                // mapa principal, onde são opcionais via CamadasPainel) —
                // numa tela de navegação de pesca, profundidade e marcas
                // náuticas são informação de segurança, não um extra pra
                // escolher. Mesmas URLs/parâmetros do `MapaWidget`, pra não
                // ter duas fontes de verdade pra isso. Com o cache ligado
                // (padrão, ver Configurações), passam pelo mesmo mecanismo
                // de disco-primeiro-rede-depois do mapa de ruas — ficam
                // disponíveis offline pra qualquer área já visitada.
                if (_cacheCamadasOceanicas) ...[
                  TileLayer(tileProvider: StreetMapTileProvider(_cacheProfundidade)),
                  TileLayer(tileProvider: StreetMapTileProvider(_cacheContornos)),
                  TileLayer(tileProvider: StreetMapTileProvider(_cacheSeamark)),
                ] else ...[
                  TileLayer(
                    wmsOptions: _wmsProfundidade,
                    userAgentPackageName: 'com.blueocean.atlas',
                  ),
                  TileLayer(
                    wmsOptions: _wmsContornos,
                    userAgentPackageName: 'com.blueocean.atlas',
                  ),
                  TileLayer(
                    urlTemplate:
                        'https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.blueocean.atlas',
                  ),
                ],
                PolylineLayer(polylines: [
                  Polyline(
                    points: widget.rota.pontos,
                    strokeWidth: 4,
                    color: Colors.purple,
                  ),
                ]),
                MarkerLayer(markers: [
                  Marker(
                    point: widget.rota.pontos.first,
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  Marker(
                    point: widget.rota.pontos.last,
                    width: 34,
                    height: 34,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.flag, color: Colors.red, size: 28),
                  ),
                  if (projecao != null)
                    Marker(
                      point: projecao.proximoWaypoint,
                      width: 26,
                      height: 26,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ]),
                if (_condicoes.any((c) => c.severo))
                  MarkerLayer(
                    markers: _condicoes
                        .where((c) => c.severo)
                        .map((c) => Marker(
                              point: c.ponto,
                              width: 30,
                              height: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(c.icone,
                                    color: Colors.white, size: 16),
                              ),
                            ))
                        .toList(),
                  ),
                if (_posicaoAtual != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: _posicaoAtual!,
                      width: 40,
                      height: 40,
                      child: Transform.rotate(
                        angle: _rumo * math.pi / 180,
                        child: Icon(
                          Icons.navigation,
                          color: foraDaRota ? Colors.orange : Colors.blue,
                          size: 36,
                        ),
                      ),
                    ),
                  ]),
              ],
            ),
          ),
          Positioned(
            right: 16,
            // Fixo perto do topo do mapa, não relativo ao painel — o
            // painel é retrátil (ver `_painelRetratil`) e pode ficar
            // expandido além de onde um offset fixo "acima do painel"
            // daria conta, cobrindo o botão. Aqui ele nunca é tapado,
            // não importa o quanto o painel esteja aberto.
            top: 16,
            child: FloatingActionButton.small(
              heroTag: 'modoSeguir',
              tooltip: l10n.rotasNavegarSeguirTooltip,
              backgroundColor: _modoSeguir
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              onPressed: _alternarModoSeguir,
              child: Icon(
                _modoSeguir ? Icons.my_location : Icons.location_searching,
                color: _modoSeguir ? Colors.white : null,
              ),
            ),
          ),
          _painelRetratil(l10n, projecao, foraDaRota),
        ],
      ),
    );
  }

  /// Painel inferior retrátil — começa pequeno, só com as métricas (igual
  /// antes), e arrasta pra cima pra revelar a lista de pontos da rota com
  /// suas condições/alertas (ver [_listaPontosRota]), sem sair da tela de
  /// navegação nem cobrir o mapa sozinho até o usuário pedir.
  Widget _painelRetratil(
    AppLocalizations l10n,
    ProjecaoNaRota? projecao,
    bool foraDaRota,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.22,
      minChildSize: 0.14,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: corRotulo(context).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _cartaoMetricas(l10n, projecao, foraDaRota),
              if (_condicoes.isNotEmpty) ...[
                const Divider(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.rotasPontosDaRotaTitulo(_condicoes.length),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 4),
                _listaPontosRota(l10n),
              ],
              SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
            ],
          ),
        );
      },
    );
  }

  Widget _listaPontosRota(AppLocalizations l10n) {
    return Column(
      children: [
        for (var i = 0; i < _condicoes.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _condicoes[i].severo
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                  child: _condicoes[i].severo
                      ? Icon(_condicoes[i].icone, color: Colors.white, size: 16)
                      : Text(
                          '${i + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatarCoordenadasDMSCompacta(
                          _condicoes[i].ponto.latitude,
                          _condicoes[i].ponto.longitude,
                        ),
                        style: TextStyle(fontSize: 12, color: corRotulo(context)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _condicoes[i].descricao ?? l10n.rotasPontoCondicaoNormal,
                        style: TextStyle(
                          fontWeight: _condicoes[i].severo
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _condicoes[i].severo ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Barra de progresso da rota estilo Google Maps/Waze: uma linha fina do
  /// início ao destino, com uma seta azul (posição atual) que desliza ao
  /// longo dela conforme [progresso] e um ponto vermelho fixo no fim
  /// (destino) — em vez da barra genérica preenchida, essa deixa claro que
  /// é uma seta navegando de um ponto a outro, igual à referência que o
  /// usuário mandou.
  Widget _barraProgressoRota(double progresso) {
    const tamanhoSeta = 20.0;
    const tamanhoDestino = 12.0;
    return SizedBox(
      height: tamanhoSeta,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final largura = constraints.maxWidth;
          final offsetSeta =
              (progresso.clamp(0.0, 1.0) * (largura - tamanhoSeta)).clamp(0.0, largura - tamanhoSeta);
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: tamanhoSeta / 2),
                color: corRotulo(context).withValues(alpha: 0.3),
              ),
              Positioned(
                right: 0,
                child: Container(
                  width: tamanhoDestino,
                  height: tamanhoDestino,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
              Positioned(
                left: offsetSeta,
                child: const Icon(Icons.play_arrow, color: Colors.blue, size: tamanhoSeta),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cartaoMetricas(
    AppLocalizations l10n,
    ProjecaoNaRota? projecao,
    bool foraDaRota,
  ) {
    if (_posicaoAtual == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(l10n.rotasNavegarAguardandoGps,
                style: TextStyle(color: corRotulo(context))),
          ],
        ),
      );
    }
    if (projecao == null) return const SizedBox.shrink();

    final restante =
        (projecao.distanciaTotalNauticas - projecao.distanciaPercorridaNauticas)
            .clamp(0.0, double.infinity);
    final progresso = projecao.progresso ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          _barraProgressoRota(progresso),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metrica(
                  l10n.rotasNavegarConcluido, '${(progresso * 100).round()}%'),
              _metrica(l10n.rotasNavegarRestante,
                  '${restante.toStringAsFixed(1)} mn'),
              _metrica(
                l10n.rotasNavegarDesvio,
                '${projecao.desvioNauticas.toStringAsFixed(2)} mn',
                destaque: foraDaRota,
              ),
            ],
          ),
          if (foraDaRota) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.rotasNavegarForaDaRota,
                    style: const TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _metrica(String titulo, String valor, {bool destaque = false}) {
    return Column(
      children: [
        Text(titulo, style: TextStyle(fontSize: 12, color: corRotulo(context))),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: destaque ? Colors.orange : null,
          ),
        ),
      ],
    );
  }
}
