import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/gps/amostra_gps.dart';
import '../../../core/gps/filtro_posicao_exibicao.dart';
import '../../../core/planos/recurso_atlas.dart';
import '../../../core/services/geo_png_helper.dart';
import '../../../core/services/mbtiles_service.dart';
import '../../../core/services/geotiff_service.dart';
import '../../../core/services/pontos_service.dart';
import '../../../core/services/street_map_cache_service.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/erro_amigavel.dart';
import '../../../core/utils/proximidade.dart';
import '../../../core/utils/perf_log.dart';
import '../../producao/domain/especies_comuns.dart';
import '../../producao/domain/models/producao_registro.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import 'camadas/camada_clorofila.dart';
import 'camadas/camada_consulta_ponto.dart';
import 'camadas/camada_indice_produtividade.dart';
import 'camadas/camada_intelligence.dart';
import 'camadas/camada_temperatura.dart';
import 'camadas/camadas_mapa.dart';
import '../domain/models/ponto_marcado.dart';
import '../../rotas/domain/models/rota_planejada.dart';
import 'meus_pontos_screen.dart';
import '../widgets/barco_navegacao_3d.dart';
import '../widgets/detalhe_ponto_marcado.dart';
import '../widgets/dialogo_info_mapa.dart';
import '../widgets/dialogo_ponto_recomendacao.dart';
import '../widgets/dialogos_producao.dart';
import '../widgets/compasso_circular.dart';
import '../widgets/download_regiao_dialog.dart';
import '../widgets/mbtiles_tile_provider.dart';
import '../widgets/menu_lateral_mapa.dart';
import '../widgets/meteorologia_sheet.dart';
import '../widgets/painel_reticulo.dart';
import '../../../l10n/gen/app_localizations.dart';

const _bundledAsset = 'assets/cartas/OUTPUT_FILE.mbtiles';
const _pontosAsset = 'assets/json/posicoes/Routing3.json';

/// Sobreposição opcional: um PNG georreferenciado (retângulo alinhado aos
/// eixos, sem rotação) exibido por cima da carta MBTiles/mapa de ruas —
/// por exemplo uma carta batimétrica ou uma área de interesse recortada.
///
/// O usuário escolhe o arquivo pelo seletor de arquivos e os bounds
/// (sudoeste/nordeste) são lidos automaticamente do metadado `geo_bounds`
/// embutido no PNG (ver [GeoPngHelper]). Esses valores só entram em jogo
/// como fallback, caso o PNG selecionado não tenha esse metadado.
const _overlaySudoesteFallback = LatLng(-3.0, -40.0);
const _overlayNordesteFallback = LatLng(-2.8, -39.8);

enum _MapMode { none, mbtiles, geotiff }

/// Mapa interativo completo — carta offline (MBTiles/GeoTIFF), pontos,
/// posição GPS e marcação manual de pontos.
///
/// Autocontido: todos os controles (trocar arquivo, marcar ponto,
/// centralizar no GPS) ficam sobrepostos ao mapa em vez de dependerem de
/// um `Scaffold`/`AppBar`, para que o mesmo widget possa ser usado em tela
/// cheia ([MapaScreen]) ou embutido dentro de outra tela (ex: Dashboard).
class MapaWidget extends StatefulWidget {
  /// Se informada, os pontos dessa recomendação são exibidos como
  /// marcadores sobre a carta, com o mapa centralizado neles.
  final Recomendacao? recomendacao;

  /// Se informada, os pontos são ligados por uma linha (estilo
  /// Waze/Google Maps) sobre a carta — usado para exibir uma rota de
  /// histórico de GPS, com o mapa centralizado nela.
  final List<LatLng>? rota;

  /// Margem extra de zoom aplicada por cima do encaixe calculado pelas
  /// bordas norte/sul da carta (ver [MapaWidgetState._preencherComCarta]).
  final double margemZoom;

  /// Se true, inicia o mapa em modo de planejamento de rota: toques no mapa
  /// vão adicionando pontos em sequência, que podem ser salvos como uma
  /// rota planejada (ver `MinhasRotasScreen`) — diferente de [rota], que só
  /// exibe uma linha já pronta (histórico de GPS).
  final bool modoPlanejarRota;

  /// Se informado, cada registro com coordenada vira um marcador individual
  /// no mapa (onde a captura foi feita) e, havendo 2 ou mais, uma linha os
  /// liga em ordem cronológica — estilo Waze — com a opção de salvar esse
  /// trajeto como uma rota planejada. Vem de `ProducaoHistoricoScreen`.
  final List<ProducaoRegistro>? producaoPontos;

  /// Se informada (junto com [modoPlanejarRota]), a tela abre já com os
  /// pontos e o nome dessa rota preenchidos, e "Salvar rota" atualiza o
  /// registro existente em vez de criar um novo — usada por "Editar rota"
  /// em `MinhasRotasScreen`.
  final RotaPlanejada? rotaParaEditar;

  /// Se true (padrão — usado na aba Mapa em tela cheia): mantém os streams
  /// contínuos de GPS/bússola rodando, mostra a bússola sempre visível e
  /// usa o barco 3D (BarcoNavegacao3d, via WebView) como marcador de
  /// posição. Se false (usado no preview compacto embutido no Dashboard,
  /// ver DashboardScreen): nada disso roda — só um marcador estático leve
  /// (ícone) na posição atual — evita pagar o custo de bateria/CPU de uma
  /// WebView 3D e sensores de alta frequência numa tela que só mostra um
  /// resumo do mapa, não é usada pra navegar de verdade.
  final bool navegacaoTempoReal;

  const MapaWidget({
    super.key,
    this.recomendacao,
    this.rota,
    this.margemZoom = 2,
    this.modoPlanejarRota = false,
    this.producaoPontos,
    this.rotaParaEditar,
    this.navegacaoTempoReal = true,
  });

  @override
  State<MapaWidget> createState() => MapaWidgetState();
}

class MapaWidgetState extends State<MapaWidget> with WidgetsBindingObserver {
  final MbtilesService _mbtiles = MbtilesService();
  final PontosService _pontosService = PontosService();
  final StreetMapCacheService _streetCache = StreetMapCacheService();
  final MapController _mapController = MapController();

  List<PontoMapa> _pontos = [];

  _MapMode _mode = _MapMode.none;
  bool _loading = false;
  String? _error;

  /// Alterna entre a carta náutica carregada (MBTiles/GeoTIFF) e o mapa de
  /// ruas (OpenStreetMap, com cache próprio pra uso offline depois de
  /// baixado — ver [StreetMapCacheService]). Começa ligado (Open Sea) —
  /// pré-selecionado por padrão, ver [SeletorTipoMapa].
  bool _camadaRuas = true;

  GeotiffResult? _geotiff;

  double _minZoom = 0;
  double _maxZoom = 18;

  /// Bounds geográficos da carta carregada (MBTiles) — usados para travar o
  /// zoom mínimo e o pan de forma que a carta sempre preencha a área
  /// visível do mapa, sem deixar borda vazia aparecendo.
  LatLngBounds? _chartBounds;
  LatLng _center = const LatLng(-15.0, -50.0);
  double _zoom = 4;

  // ValueNotifier pelo mesmo motivo de _navegacaoRumoNotifier: um
  // setState() a cada leitura do GPS refazia o build() inteiro do mapa
  // (26 camadas, painéis, menu lateral) só pra mover o barco. Só a camada
  // do barco escuta a posição; setState() fica pra quando ela passa a
  // existir (o botão de GPS depende disso). Getter/setter mantêm o resto do
  // código lendo/escrevendo `_gpsPosition` como antes.
  final ValueNotifier<LatLng?> _gpsPositionNotifier = ValueNotifier(null);
  LatLng? get _gpsPosition => _gpsPositionNotifier.value;
  set _gpsPosition(LatLng? valor) => _gpsPositionNotifier.value = valor;

  /// Triagem das posições que movem o marcador da embarcação (ver
  /// [_aplicarPosicaoGps]).
  final FiltroPosicaoExibicao _filtroGps = FiltroPosicaoExibicao();

  // ── Menu lateral (todas as funções antes espalhadas na barra de topo) ────
  bool _menuLateralAberto = false;

  // ── Marcar ponto manualmente ─────────────────────────────────────────────
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _modoMarcarPonto = false;
  // Muda a cada quadro enquanto o usuário arrasta o mapa nos modos com
  // retículo (marcar ponto, consultar temperatura/clorofila, planejar rota)
  // — só o texto da coordenada escuta (ver PainelReticulo), em vez de
  // um setState() por quadro reconstruindo o mapa inteiro durante o gesto.
  final ValueNotifier<LatLng> _centroMiraNotifier =
      ValueNotifier(const LatLng(-15.0, -50.0));
  LatLng get _centroMira => _centroMiraNotifier.value;
  set _centroMira(LatLng valor) => _centroMiraNotifier.value = valor;
  List<PontoMarcado> _pontosMarcados = [];
  final TextEditingController _nomePontoController = TextEditingController();

  // ── Camadas de consulta por ponto (ver camadas/) ─────────────────────────
  // Cada uma no seu arquivo; consultadas com o mesmo retículo de "Marcar um
  // ponto" (usa o mesmo _centroMira) — ver _alternarCamada.
  final _camadaTemperatura = CamadaTemperatura();
  final _camadaClorofila = CamadaClorofila();
  final _camadaIndice = CamadaIndiceProdutividade();
  final _camadaIntelligence = CamadaIntelligence();

  /// Ordem de desenho no mapa e de empilhamento dos botões "+".
  late final List<CamadaConsultaPonto> _camadasConsulta = [
    _camadaTemperatura,
    _camadaClorofila,
    _camadaIndice,
    _camadaIntelligence,
  ];

  /// Camada com o retículo aberto pra escolher onde consultar, ou null.
  CamadaConsultaPonto? _consultaPontoAtiva;
  bool _consultandoPonto = false;

  // ── Planejar rota manualmente ────────────────────────────────────────────
  List<LatLng> _pontosRotaPlanejada = [];
  final TextEditingController _nomeRotaController = TextEditingController();
  bool _salvandoRota = false;

  // ── Calor de produção ────────────────────────────────────────────────────
  bool _mostrarProducao = false;
  bool _carregandoProducao = false;
  List<ClusterProducao> _producaoClusters = [];

  // ── Informações náuticas (OpenSeaMap) ────────────────────────────────────
  // Tiles públicos de marcas náuticas/boias/faróis/portos (transparentes,
  // sobrepostos ao mapa de ruas) — só faz sentido junto do OpenStreetMap
  // (_camadaRuas), nunca sobre a carta MBTiles/GeoTIFF carregada. Ligado
  // por padrão junto com _camadaRuas — selecionar "Open Sea" liga as três
  // camadas de uma vez (ver [SeletorTipoMapa]), então o estado inicial
  // acompanha isso em vez de abrir desligado e exigir um toque extra.
  bool _mostrarInfoNautica = true;

  // ── Profundidade / Curvas de profundidade (OpenSeaMap depth project) ────
  // WMS de verdade do próprio projeto de profundidade do OpenSeaMap — dado
  // batimétrico real (GEBCO), não inventado. Achados direto no código-fonte
  // público do `online_chart` do OpenSeaMap em 2026-09 (ver comentário na
  // camada, mais abaixo, com a fonte). Ligado por padrão — ver nota de
  // [_mostrarInfoNautica] acima.
  bool _mostrarProfundidade = true;
  bool _mostrarCurvasProfundidade = true;


  // ── Trilha ao vivo da viagem em andamento ────────────────────────────────
  // Diferente de `widget.rota` (uma trilha estática passada de fora, ex: a
  // tela de Histórico de Localizações) — esta consulta a viagem em
  // andamento (status = 'em_andamento') e o próprio histórico gravado por
  // `LocationTrackingService` periodicamente, atualizando sozinha enquanto
  // a camada estiver ligada, pra acompanhar o trajeto em tempo real (dentro
  // do intervalo de gravação) sem precisar sair do mapa.
  bool _mostrarTrilhaViagem = false;
  List<LatLng> _pontosTrilhaViagem = [];
  Timer? _trilhaViagemTimer;

  // ── Modo Navegação (vista estilo Waze, course-up + inclinação) ──────────
  // GPS e bússola passam a atualizar continuamente (em vez do fix único de
  // _loadGpsPosition) e o mapa recentraliza + gira sozinho a cada
  // atualização, mantendo o rumo sempre "pra cima" da tela. O efeito de
  // inclinação 3D (ver _buildBody) e o modelo 3D do barco (ver
  // BarcoNavegacao3d) só aparecem enquanto esse modo estiver ativo — o
  // barco fica parado no centro da tela, é o mapa por baixo dele que gira.
  static const double _zoomModoNavegacao = 17;
  bool _modoNavegacao = false;

  // ValueNotifier em vez de campo simples + setState: o rumo muda a cada
  // evento do sensor (pode ser bem frequente) e só a bússola/o barco 3D
  // precisam repintar quando ele muda — não a árvore inteira do mapa
  // (FlutterMap com suas dezenas de camadas condicionais). Um setState()
  // aqui recalcularia esse build() inteiro a cada leitura do sensor, que é
  // o maior custo de CPU do recurso; com ValueListenableBuilder (ver
  // build()/BarcoNavegacao3d), só os widgets pequenos que exibem o rumo
  // repintam.
  final ValueNotifier<double> _navegacaoRumoNotifier = ValueNotifier(0);
  double get _navegacaoRumo => _navegacaoRumoNotifier.value;

  StreamSubscription<Position>? _navegacaoPosicaoSub;
  StreamSubscription<CompassEvent>? _navegacaoBussolaSub;

  // Bússola do aparelho (magnetômetro) ligada por padrão — pode ser
  // desligada (ver _alternarBussola, no menu lateral) pra quem prefere
  // não depender dela (interferência magnética perto de motor/metal é
  // comum em embarcação). Desligada, o rumo passa a vir só do giroscópio
  // (ver _iniciarGiroscopio) — sem referência absoluta ao norte, mas sem
  // sofrer com desvio magnético, só integra o quanto o aparelho girou.
  bool _bussolaAtiva = true;
  StreamSubscription<GyroscopeEvent>? _giroscopioSub;
  DateTime? _ultimaLeituraGiroscopio;

  // Enquanto o usuário está arrastando/dando pinça no mapa, pausa a
  // reorbitação do barco 3D (ver onPositionChanged, mais abaixo, e
  // BarcoNavegacao3d.pausado) — evita competir por frame com o gesto (o
  // pan/zoom fica mais fluido) e algo "brigando" visualmente com o dedo do
  // usuário. `hasGesture` do próprio flutter_map já distingue isso de
  // movimento programático (ex.: nosso moveAndRotate do Modo Navegação),
  // então não corre o risco de ficar "travado" pausado por engano.
  static const Duration _debounceFimMovimentoMapa = Duration(milliseconds: 200);
  bool _usuarioMovendoMapa = false;
  Timer? _timerFimMovimentoMapa;

  // Throttle bruto antes mesmo de filtrar — o sensor de bússola pode
  // emitir a uma taxa bem mais alta do que o olho percebe (dependendo do
  // aparelho); processar cada leitura (mesmo só o filtro EMA) é trabalho
  // desperdiçado. Descarta leituras que chegam antes desse intervalo.
  static const Duration _intervaloMinimoBussola = Duration(milliseconds: 80);
  DateTime? _ultimaLeituraBussolaProcessada;

  // Filtro de suavização do rumo — o sensor de bússola do aparelho chega
  // "ruidoso" (variações de vários graus entre uma leitura e outra), o que
  // fazia o barco 3D/o mapa tremerem a cada evento. Faz uma média móvel
  // exponencial (EMA) em cima do vetor (seno, cosseno) do ângulo — não do
  // ângulo em si — pra suavizar sem quebrar na virada de 359°→0°.
  double? _rumoFiltradoSeno;
  double? _rumoFiltradoCosseno;

  // Limiar antes de girar o mapa de verdade no Modo Navegação (ver uso em
  // _iniciarBussolaEPosicaoContinuas) — girar é um repaint caro do canvas
  // inteiro, então só vale reaplicar quando a diferença é perceptível.
  static const double _limiarGirarMapa = 1.0;
  double _ultimoRumoAplicadoAoMapa = 0;

  double _diferencaAngular(double a, double b) {
    var diferenca = (a - b) % 360;
    if (diferenca > 180) diferenca = 360 - diferenca;
    return diferenca.abs();
  }

  double _suavizarRumo(double rumoBruto) {
    const alfa = 0.15; // 0–1: menor = mais suave (e mais "atrasado")
    final rad = rumoBruto * math.pi / 180;
    final seno = math.sin(rad);
    final cosseno = math.cos(rad);
    _rumoFiltradoSeno = _rumoFiltradoSeno == null
        ? seno
        : _rumoFiltradoSeno! + alfa * (seno - _rumoFiltradoSeno!);
    _rumoFiltradoCosseno = _rumoFiltradoCosseno == null
        ? cosseno
        : _rumoFiltradoCosseno! + alfa * (cosseno - _rumoFiltradoCosseno!);
    final grausSuavizados =
        math.atan2(_rumoFiltradoSeno!, _rumoFiltradoCosseno!) * 180 / math.pi;
    return (grausSuavizados + 360) % 360;
  }

  // ── Sobreposição de imagem (PNG georreferenciado) ────────────────────────
  bool _overlayAtiva = false;
  bool _overlayValidada = false;
  bool _overlayCarregando = false;
  double _overlayOpacidade = 0.8;
  File? _overlayFile;
  LatLngBounds? _overlayBounds;

  /// PNG georreferenciado que pode vir junto de uma recomendação
  /// (`Recomendacao.cartaNauticaUrl`) — baixado e sobreposto automaticamente
  /// quando presente, com os bounds lidos do metadado `geo_bounds` embutido
  /// no próprio arquivo (mesmo mecanismo de [GeoPngHelper] usado na
  /// sobreposição manual). Diferente da sobreposição manual, essa não tem
  /// toggle — some sozinha quando a tela não é mais sobre uma recomendação.
  Uint8List? _recomendacaoOverlayBytes;
  LatLngBounds? _recomendacaoOverlayBounds;

  /// Pontos amostrados da recomendação, na mesma ordem retornada pela API —
  /// sem pontos individuais mas com centroide, vira um único ponto
  /// sintético (sem variáveis) só pra manter o marcador tocável no mapa.
  List<PontoRecomendacao> get _pontosRecomendacaoDetalhados {
    final r = widget.recomendacao;
    if (r == null) return [];
    if (r.pontos != null && r.pontos!.isNotEmpty) return r.pontos!;
    if (r.centroide != null) {
      return [
        PontoRecomendacao(
          latitude: r.centroide!.latitude,
          longitude: r.centroide!.longitude,
          variaveis: const [],
        ),
      ];
    }
    return [];
  }

  /// Pontos da recomendação a exibir sobre a carta (vazio se nenhuma).
  List<LatLng> get _pontosRecomendacao => _pontosRecomendacaoDetalhados
      .map((p) => LatLng(p.latitude, p.longitude))
      .toList();

  /// Pontos da rota de histórico a exibir sobre a carta (vazio se nenhuma).
  List<LatLng> get _rota => widget.rota ?? [];

  /// Coordenadas dos registros de produção recebidos, na mesma ordem em que
  /// chegaram (o chamador — `ProducaoHistoricoScreen` — já manda em ordem
  /// cronológica) — usadas tanto pra desenhar a linha quanto pra salvar como
  /// rota planejada.
  List<LatLng> get _rotaProducao => (widget.producaoPontos ?? [])
      .where((r) => r.latitude != null && r.longitude != null)
      .map((r) => LatLng(r.latitude!, r.longitude!))
      .toList();

  void _focarPontos(List<LatLng> pontos) {
    if (pontos.isEmpty) return;
    if (pontos.length == 1) {
      _mapController.move(pontos.first, 10);
    } else {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(pontos),
          padding: const EdgeInsets.all(48),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGpsPosition();
    _loadBundledChart();
    _loadPontos();
    _carregarPontosMarcados();
    _carregarOverlayRecomendacao();
    // Bússola/GPS contínuos (o "coração" pesado do recurso — WebView 3D,
    // sensor de alta frequência) só rodam quando esse mapa é o de verdade
    // (aba Mapa/tela cheia). O preview compacto embutido no Dashboard (ver
    // MapaWidget.navegacaoTempoReal) não precisa disso — evita rodar dois
    // conjuntos de streams/uma WebView 3D extra sempre que o app abre.
    if (widget.navegacaoTempoReal) {
      WidgetsBinding.instance.addObserver(this);
      _iniciarBussolaEPosicaoContinuas();
    }

    final rotaEditando = widget.rotaParaEditar;
    if (rotaEditando != null) {
      _pontosRotaPlanejada = List.of(rotaEditando.pontos);
      _nomeRotaController.text = rotaEditando.nome;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focarPontos(_pontosRotaPlanejada);
      });
    }
    if (widget.modoPlanejarRota) {
      // Sincroniza o retículo com o centro real do mapa assim que ele
      // termina de montar (e, se estiver editando uma rota existente,
      // depois do _focarPontos acima já ter enquadrado os pontos) — sem
      // isso, o retículo ficaria parado no valor padrão até o primeiro
      // gesto do usuário (ver onPositionChanged/_buildOverlayPlanejarRota).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _centroMira = _mapController.camera.center);
        }
      });
    }
  }

  /// Baixa e aplica o PNG georreferenciado da recomendação atual, se houver
  /// (`Recomendacao.cartaNauticaUrl`) — mesma leitura de bounds embutidos no
  /// arquivo usada na sobreposição manual (ver [GeoPngHelper]). Falha
  /// silenciosamente (só um aviso) em vez de travar o mapa: a recomendação
  /// continua utilizável sem a sobreposição se o download ou o PNG falhar.
  ///
  /// A URL vem de um bucket S3 — normalmente uma URL assinada com validade
  /// curta (o backend não expõe o bucket publicamente). Uma recomendação
  /// vinda do cache offline (ver [RecomendacaoRepository]) pode carregar
  /// uma URL já vencida, daí o tratamento específico pra 403/404 abaixo,
  /// em vez de só repetir o HTTP status cru.
  Future<void> _carregarOverlayRecomendacao() async {
    final url = widget.recomendacao?.cartaNauticaUrl;
    if (url == null || url.isEmpty) return;

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 403 || response.statusCode == 404) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context).mapaCartaRecomendacaoIndisponivel)),
        );
        return;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Download falhou: HTTP ${response.statusCode}');
      }
      final bytes = response.bodyBytes;
      final bounds = await GeoPngHelper.readBoundsFromBytes(bytes);

      if (!mounted) return;
      setState(() {
        _recomendacaoOverlayBytes = bytes;
        _recomendacaoOverlayBounds = bounds;
      });
    } catch (e) {
      debugPrint('⚠️ Não foi possível aplicar o PNG da recomendação: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(mensagemErroAmigavel(e,
                prefixo: AppLocalizations.of(context).mapaErroCarregarCartaRecomendacao))),
      );
    }
  }

  /// Suspende GPS/bússola enquanto o app está em segundo plano (tela
  /// bloqueada, outro app em primeiro plano) e retoma ao voltar — sem
  /// isso, os streams continuavam rodando (e a WebView do barco 3D viva)
  /// mesmo com o usuário nem olhando pro aparelho, gastando bateria à toa.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.navegacaoTempoReal) return;
    if (state == AppLifecycleState.paused) {
      _pararBussolaEPosicaoContinuas();
    } else if (state == AppLifecycleState.resumed) {
      if (_navegacaoPosicaoSub == null && _navegacaoBussolaSub == null) {
        _iniciarBussolaEPosicaoContinuas();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trilhaViagemTimer?.cancel();
    _timerFimMovimentoMapa?.cancel();
    _pararBussolaEPosicaoContinuas();
    _navegacaoRumoNotifier.dispose();
    _gpsPositionNotifier.dispose();
    _centroMiraNotifier.dispose();
    _mbtiles.close();
    _nomePontoController.dispose();
    _nomeRotaController.dispose();
    // Sem isso, o AnimationController interno do MapController (usado nas
    // animações de pan/zoom) ficava vivo depois da tela fechar (auditoria
    // de 2026-09).
    _mapController.dispose();
    super.dispose();
  }

  // ── Planejar rota manualmente ────────────────────────────────────────────

  /// Adiciona o ponto onde o retículo está apontando (_centroMira) —
  /// mesmo padrão de precisão de "Marcar um ponto"/consultas (ver
  /// _buildOverlayPlanejarRota), em vez do toque direto no mapa de antes
  /// (impreciso — o dedo cobre o ponto exato, sem controle fino).
  void _adicionarPontoRotaPlanejada() {
    setState(() =>
        _pontosRotaPlanejada = [..._pontosRotaPlanejada, _centroMira]);
  }

  void _desfazerUltimoPontoRota() {
    if (_pontosRotaPlanejada.isEmpty) return;
    setState(() {
      _pontosRotaPlanejada = _pontosRotaPlanejada.sublist(
        0,
        _pontosRotaPlanejada.length - 1,
      );
    });
  }

  /// Grava uma rota planejada (`rota_planejada` + `rota_planejada_ponto`) a
  /// partir de uma lista de pontos já ordenada — usado tanto pela rota
  /// desenhada à mão quanto pela rota entre registros de produção.
  Future<void> _persistirRotaPlanejada(
    String nome,
    List<LatLng> pontos, {
    String? embarcacaoId,
    int? viagemId,
  }) async {
    final rotaId = await _dbHelper.insert('rota_planejada', {
      'nome': nome,
      'data_criacao': DateTime.now().toIso8601String(),
      'embarcacao_id': embarcacaoId,
      'viagem_id': viagemId,
    });
    for (var i = 0; i < pontos.length; i++) {
      final p = pontos[i];
      await _dbHelper.insert('rota_planejada_ponto', {
        'rota_planejada_id': rotaId,
        'latitude': p.latitude,
        'longitude': p.longitude,
        'ordem': i,
      });
    }
  }

  /// Atualiza uma rota já existente: apaga os pontos antigos e grava os
  /// novos na ordem atual, e atualiza o nome — mesma tabela, mesmo id, só
  /// não recria o registro (preserva `data_criacao` original).
  Future<void> _atualizarRotaPlanejada(
    int rotaId,
    String nome,
    List<LatLng> pontos,
  ) async {
    await _dbHelper.update('rota_planejada', {'nome': nome}, id: rotaId);
    await _dbHelper.deleteWhere(
      'rota_planejada_ponto',
      where: 'rota_planejada_id = ?',
      whereArgs: [rotaId],
    );
    for (var i = 0; i < pontos.length; i++) {
      final p = pontos[i];
      await _dbHelper.insert('rota_planejada_ponto', {
        'rota_planejada_id': rotaId,
        'latitude': p.latitude,
        'longitude': p.longitude,
        'ordem': i,
      });
    }
  }

  Future<void> _salvarRotaPlanejada() async {
    final nome = _nomeRotaController.text.trim();
    if (nome.isEmpty || _pontosRotaPlanejada.length < 2) return;

    setState(() => _salvandoRota = true);
    try {
      final rotaEditando = widget.rotaParaEditar;
      if (rotaEditando != null) {
        await _atualizarRotaPlanejada(
            rotaEditando.id!, nome, _pontosRotaPlanejada);
      } else {
        await _persistirRotaPlanejada(nome, _pontosRotaPlanejada);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvandoRota = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).mapaErroSalvarRota('$e'))),
      );
    }
  }

  // ── Carta bundled ──────────────────────────────────────────────────────────

  Future<void> _loadBundledChart() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _mbtiles.openFromAsset(_bundledAsset);
      final meta = await _mbtiles.getMetadata();
      _applyMetadata(meta);
      if (!mounted) return;
      setState(() {
        _mode = _MapMode.mbtiles;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pontosRecomendacao.isNotEmpty) {
          _focarPontos(_pontosRecomendacao);
        } else if (_rota.isNotEmpty) {
          _focarPontos(_rota);
        } else if (_rotaProducao.isNotEmpty) {
          _focarPontos(_rotaProducao);
        } else {
          _preencherComCarta();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(context).mapaErroCarregarCarta('$e');
        _loading = false;
      });
    }
  }

  /// Ajusta a câmera com base nas bordas superior (norte) e inferior (sul)
  /// da carta: calcula o zoom em que a altura da carta bate exatamente com
  /// a altura do mapa na tela e centraliza nesse ponto. Como o zoom é
  /// definido só pela altura, a carta sempre encosta em cima e embaixo, e
  /// fica horizontalmente centralizada (cortando as laterais se sobrar).
  void _preencherComCarta() {
    if (_chartBounds == null) {
      _mapController.move(_center, _zoom);
      return;
    }

    final bounds = _chartBounds!;
    final camera = _mapController.camera;
    final longitudeCentro = bounds.center.longitude;

    final pontoNorte =
        camera.project(LatLng(bounds.north, longitudeCentro), camera.zoom);
    final pontoSul =
        camera.project(LatLng(bounds.south, longitudeCentro), camera.zoom);
    final alturaCartaPx = (pontoSul.y - pontoNorte.y).abs();
    final alturaMapaPx = camera.nonRotatedSize.y;

    if (alturaCartaPx <= 0 || alturaMapaPx <= 0) {
      _mapController.move(_center, _zoom);
      return;
    }

    final escala = alturaMapaPx / alturaCartaPx;
    final zoomAjustado = (camera.getScaleZoom(escala) + widget.margemZoom)
        .clamp(_minZoom, _maxZoom);

    _mapController.move(_gpsPosition ?? bounds.center, zoomAjustado);
    if (zoomAjustado > _minZoom) {
      setState(() => _minZoom = zoomAjustado);
    }
  }

  /// Recentraliza no GPS assim que a posição chega, caso o mapa já tenha
  /// sido carregado antes do fix ficar disponível (a carta usa o centro
  /// geográfico como fallback nesse meio-tempo).
  void _recentralizarNoGps(LatLng pos) {
    if (_mode == _MapMode.none) return;
    if (_pontosRecomendacao.isNotEmpty ||
        _rota.isNotEmpty ||
        _rotaProducao.isNotEmpty) {
      return;
    }
    _mapController.move(pos, _mapController.camera.zoom);
  }

  // ── Pontos JSON ────────────────────────────────────────────────────────────

  Future<void> _loadPontos() async {
    try {
      final pontos = await _pontosService.loadFromAsset(_pontosAsset);
      if (mounted) setState(() => _pontos = pontos);
    } catch (_) {
      // Arquivo ausente ou mal-formado — não bloqueia o mapa
    }
  }

  // ── GPS ────────────────────────────────────────────────────────────────────

  Future<void> _loadGpsPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // Mostra a última posição conhecida imediatamente (cache do sistema) —
      // só se ainda for recente e confiável (ver _filtroGps): uma posição
      // de horas atrás não pode aparecer como a embarcação "agora".
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) _aplicarPosicaoGps(last, recentralizar: true);

      // Atualiza com fix fresco em segundo plano
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 30));
      if (mounted) _aplicarPosicaoGps(fresh, recentralizar: true);
    } catch (_) {}
  }

  /// Move o marcador da embarcação só pra posições aprovadas pelo
  /// [_filtroGps] (inválidas, imprecisas, antigas ou saltos implausíveis
  /// ficam de fora — o marcador fica na última posição confiável). Devolve
  /// a posição aplicada, ou null se foi descartada.
  LatLng? _aplicarPosicaoGps(Position posicao, {bool recentralizar = false}) {
    if (!_filtroGps.aceitar(AmostraGps.dePosition(posicao))) return null;
    final pos = LatLng(posicao.latitude, posicao.longitude);
    if (_gpsPosition == null) {
      setState(() => _gpsPosition = pos); // primeira posição: mostra o botão
    } else {
      _gpsPosition = pos; // só a camada do barco reconstrói
    }
    if (recentralizar) _recentralizarNoGps(pos);
    return pos;
  }

  void _centerOnGps() {
    if (_gpsPosition != null) {
      _mapController.move(_gpsPosition!, _mapController.camera.zoom);
    }
  }

  // ── Marcar ponto manualmente ─────────────────────────────────────────────

  Future<void> _carregarPontosMarcados() async {
    final maps = await _dbHelper.query('ponto_marcado');
    if (!mounted) return;
    setState(() {
      _pontosMarcados = maps.map(PontoMarcado.fromMap).toList();
    });
  }

  // ── Calor de produção ────────────────────────────────────────────────────

  Future<void> _alternarProducao() async {
    if (_mostrarProducao) {
      setState(() => _mostrarProducao = false);
      return;
    }
    setState(() {
      _mostrarProducao = true;
      _carregandoProducao = _producaoClusters.isEmpty;
    });
    if (_producaoClusters.isNotEmpty) return;

    final registros = await _dbHelper.queryWhere(
      'producao_registro',
      where: 'latitude IS NOT NULL AND longitude IS NOT NULL',
    );
    if (!mounted) return;
    final especieNaoInformada = AppLocalizations.of(context).mapaEspecieNaoInformada;

    // Agrupa registros próximos (~100m) somando o total em kg, pra não
    // sobrepor um marcador em cima do outro quando há vários registros na
    // mesma pescaria.
    final grupos = <String, ClusterProducao>{};
    for (final r in registros) {
      final lat = (r['latitude'] as num).toDouble();
      final lon = (r['longitude'] as num).toDouble();
      final kg = (r['quantidade_kg'] as num).toDouble();
      final especieNormalizada =
          normalizarEspecie(r['especie'] as String? ?? '');
      final especie =
          especieNormalizada.isEmpty ? especieNaoInformada : especieNormalizada;
      final chave =
          '${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';

      final registro = ProducaoRegistro.fromMap(r);
      final existente = grupos[chave];
      if (existente == null) {
        grupos[chave] = ClusterProducao(
          lat: lat,
          lon: lon,
          totalKg: kg,
          porEspecie: {especie: kg},
          registros: [registro],
        );
      } else {
        existente.totalKg += kg;
        existente.porEspecie.update(
          especie,
          (v) => v + kg,
          ifAbsent: () => kg,
        );
        existente.registros.add(registro);
      }
    }

    if (!mounted) return;
    setState(() {
      _producaoClusters = grupos.values.toList();
      _carregandoProducao = false;
    });
  }

  // ── Informações náuticas (OpenSeaMap) ────────────────────────────────────

  void _alternarInfoNautica() {
    setState(() => _mostrarInfoNautica = !_mostrarInfoNautica);
  }

  // ── Profundidade / Curvas de profundidade (OpenSeaMap depth project) ────

  void _alternarProfundidade() {
    setState(() => _mostrarProfundidade = !_mostrarProfundidade);
  }

  void _alternarCurvasProfundidade() {
    setState(() => _mostrarCurvasProfundidade = !_mostrarCurvasProfundidade);
  }

  // ── Trilha ao vivo da viagem em andamento ────────────────────────────────

  /// Liga/desliga a camada. Ligar já busca a trilha na hora e passa a
  /// atualizar sozinha a cada 60s (best-effort — o intervalo de gravação
  /// real de `LocationTrackingService` costuma ser bem maior, então a
  /// atualização só reflete pontos novos quando eles realmente chegarem no
  /// banco; a busca a cada 60s só garante que a linha aparece assim que o
  /// próximo ponto for gravado, sem exigir sair e voltar ao mapa).
  void _alternarTrilhaViagem() {
    if (_mostrarTrilhaViagem) {
      _trilhaViagemTimer?.cancel();
      _trilhaViagemTimer = null;
      setState(() {
        _mostrarTrilhaViagem = false;
        _pontosTrilhaViagem = [];
      });
      return;
    }
    setState(() => _mostrarTrilhaViagem = true);
    _carregarTrilhaViagem();
    _trilhaViagemTimer = Timer.periodic(
        const Duration(seconds: 60), (_) => _carregarTrilhaViagem());
  }

  Future<void> _carregarTrilhaViagem() async {
    try {
      final viagens = await DatabaseHelper.instance.queryWhere(
        'viagem',
        where: 'status = ?',
        whereArgs: ['em_andamento'],
      );
      if (!mounted) return;
      if (viagens.isEmpty) {
        _trilhaViagemTimer?.cancel();
        _trilhaViagemTimer = null;
        setState(() {
          _mostrarTrilhaViagem = false;
          _pontosTrilhaViagem = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context).mapaTrilhaSemViagemAtiva)),
        );
        return;
      }

      final viagemId = viagens.first['id'] as int;
      // Só posições válidas: uma suspeita (salto de GPS) desenharia um
      // "espinho" na trilha até um ponto onde a embarcação nunca esteve.
      final historico = await DatabaseHelper.instance.queryWhere(
        'localizacao_historico',
        where: 'viagem_id = ? AND validacao = ?',
        whereArgs: [viagemId, 'valida'],
        orderBy: 'data_hora ASC',
      );
      if (!mounted) return;
      setState(() {
        _pontosTrilhaViagem = historico
            .map((item) => LatLng(
                  (item['latitude'] as num).toDouble(),
                  (item['longitude'] as num).toDouble(),
                ))
            .toList();
      });
    } catch (e) {
      debugPrint('Erro ao carregar trilha da viagem em andamento: $e');
    }
  }

  // ── Bússola/GPS contínuos + Modo Navegação (vista estilo Waze) ──────────

  /// Assina os streams contínuos de GPS e bússola assim que o mapa abre —
  /// bem diferente do fix único de _loadGpsPosition. Roda o tempo todo que
  /// a tela do mapa estiver aberta (não só no Modo Navegação), porque o
  /// CompassoCircular fica sempre visível — ver build(). O Modo Navegação
  /// (_modoNavegacao) só liga/desliga o recentralizar/girar/inclinar o
  /// mapa em cima desses mesmos dados, sem controlar os streams em si.
  void _iniciarBussolaEPosicaoContinuas() {
    _navegacaoBussolaSub = FlutterCompass.events?.listen((evento) {
      // Giroscópio no comando (ver _iniciarGiroscopio/_alternarBussola) —
      // ignora a leitura do magnetômetro até a bússola ser religada. O
      // stream continua assinado (não cancelado) só pra já ter leitura
      // fresca pronta assim que voltar a ser usado.
      if (!_bussolaAtiva) return;
      final rumoBruto = evento.heading;
      if (rumoBruto == null || !mounted) return;
      final agora = DateTime.now();
      if (_ultimaLeituraBussolaProcessada != null &&
          agora.difference(_ultimaLeituraBussolaProcessada!) <
              _intervaloMinimoBussola) {
        return;
      }
      _ultimaLeituraBussolaProcessada = agora;
      _aplicarNovoRumo(_suavizarRumo(rumoBruto));
    });

    _assinarPosicaoStream(precisaoAlta: _modoNavegacao);
    if (!_bussolaAtiva) _iniciarGiroscopio();
  }

  /// Usado tanto pela bússola (magnetômetro) quanto pelo giroscópio (ver
  /// _iniciarGiroscopio) — atualiza o rumo mostrado/usado pelo barco 3D e,
  /// no Modo Navegação, gira o mapa (com o mesmo limiar anti-repaint
  /// desnecessário de antes).
  void _aplicarNovoRumo(double rumo) {
    // Sem setState — só os widgets inscritos no ValueNotifier (bússola,
    // barco 3D) repintam (ver campo _navegacaoRumoNotifier).
    _navegacaoRumoNotifier.value = rumo;
    // No Modo Navegação, girar o mapa é um repaint do canvas inteiro
    // (tiles + todas as camadas), bem mais caro que só atualizar o
    // ValueNotifier acima — só vale a pena girar de fato quando a
    // diferença é perceptível, senão fica girando por frações de grau a
    // cada leitura suavizada do sensor à toa.
    if (_modoNavegacao &&
        _diferencaAngular(rumo, _ultimoRumoAplicadoAoMapa) >=
            _limiarGirarMapa) {
      _ultimoRumoAplicadoAoMapa = rumo;
      _mapController.moveAndRotate(
          _mapController.camera.center, _mapController.camera.zoom, -rumo);
    }
  }

  /// Liga/desliga a bússola do aparelho (magnetômetro) — ver
  /// [_bussolaAtiva]. Desligada, o rumo do barco passa a vir da integração
  /// do giroscópio (sem referência absoluta ao norte, mas imune a
  /// interferência magnética).
  void _alternarBussola() {
    final ligando = !_bussolaAtiva;
    setState(() => _bussolaAtiva = ligando);
    if (ligando) {
      _pararGiroscopio();
    } else {
      _iniciarGiroscopio();
    }
  }

  /// Integra a velocidade angular do giroscópio (rad/s, eixo Z — o eixo
  /// "certo" quando o aparelho é segurado na horizontal, tela pra cima,
  /// como se estivesse lendo uma bússola de verdade) pra ir acumulando um
  /// rumo a partir de onde a bússola parou. Não tem referência absoluta ao
  /// norte — só o quanto o aparelho girou desde então —, então tende a
  /// "derivar" (desviar aos poucos) quanto mais tempo passa sem religar a
  /// bússola; é a troca aceita ao preferir não depender do magnetômetro.
  void _iniciarGiroscopio() {
    _ultimaLeituraGiroscopio = null;
    _giroscopioSub = gyroscopeEventStream().listen((evento) {
      if (!mounted) return;
      final agora = DateTime.now();
      final anterior = _ultimaLeituraGiroscopio;
      _ultimaLeituraGiroscopio = agora;
      if (anterior == null) return; // primeira leitura só calibra o relógio
      final dt = agora.difference(anterior).inMicroseconds / 1e6;
      final grausGirados = evento.z * 180 / math.pi * dt;
      final novoRumo = ((_navegacaoRumo + grausGirados) % 360 + 360) % 360;
      _aplicarNovoRumo(novoRumo);
    });
  }

  void _pararGiroscopio() {
    _giroscopioSub?.cancel();
    _giroscopioSub = null;
    _ultimaLeituraGiroscopio = null;
  }

  /// (Re)assina o stream de posição — accuracy/distanceFilter variam
  /// conforme o Modo Navegação (ver _alternarModoNavegacao): alta precisão
  /// só faz diferença de verdade enquanto o mapa está seguindo a
  /// embarcação de perto; fora disso, uma amostragem mais econômica já
  /// basta pro marcador/bússola sempre visíveis, e gasta menos GPS/bateria.
  void _assinarPosicaoStream({required bool precisaoAlta}) {
    _navegacaoPosicaoSub?.cancel();
    _navegacaoPosicaoSub = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: precisaoAlta ? LocationAccuracy.high : LocationAccuracy.medium,
        distanceFilter: precisaoAlta ? 3 : 10,
      ),
    ).listen((posicao) {
      if (!mounted) return;
      final pos = _aplicarPosicaoGps(posicao);
      if (pos != null && _modoNavegacao) {
        _mapController.moveAndRotate(pos, _zoomModoNavegacao, -_navegacaoRumo);
      }
    }, onError: (e) {
      debugPrint('Erro no stream de GPS/bússola do mapa: $e');
    });
  }

  /// Cancela os streams de GPS/bússola — usado tanto no dispose() quanto
  /// ao suspender enquanto o app vai pro segundo plano (ver
  /// didChangeAppLifecycleState), pra não gastar GPS/sensor/bateria com a
  /// tela do mapa fora de vista. _iniciarBussolaEPosicaoContinuas() religa
  /// tudo do zero quando o app volta.
  void _pararBussolaEPosicaoContinuas() {
    _navegacaoPosicaoSub?.cancel();
    _navegacaoBussolaSub?.cancel();
    _navegacaoPosicaoSub = null;
    _navegacaoBussolaSub = null;
    _pararGiroscopio();
    // Na volta (app reaberto), a embarcação pode ter andado bastante —
    // comparar com a posição de antes da pausa marcaria a nova como salto.
    _filtroGps.reiniciar();
  }

  /// Liga/desliga só o comportamento de "seguir": recentralizar/girar o
  /// mapa a cada atualização (course-up, mesma convenção do Waze/Google
  /// Maps) e a inclinação 3D (ver _buildBody). Os streams de GPS/bússola
  /// em si já estão rodando desde que o mapa abriu (ver
  /// _iniciarBussolaEPosicaoContinuas) — desligar aqui só devolve o mapa
  /// pro norte-pra-cima, sem parar de alimentar o CompassoCircular.
  void _alternarModoNavegacao() {
    final ligando = !_modoNavegacao;
    setState(() => _modoNavegacao = ligando);
    // Sobe a precisão do GPS só enquanto navegando de verdade (ver
    // _assinarPosicaoStream) — economiza fora desse modo.
    if (_navegacaoPosicaoSub != null) {
      _assinarPosicaoStream(precisaoAlta: ligando);
    }
    if (ligando && _gpsPosition != null) {
      _ultimoRumoAplicadoAoMapa = _navegacaoRumo;
      _mapController.moveAndRotate(
          _gpsPosition!, _zoomModoNavegacao, -_navegacaoRumo);
    } else if (!ligando) {
      _mapController.rotate(0);
    }
  }

  // ── Camadas de consulta por ponto ────────────────────────────────────────
  // Temperatura, clorofila, índice de produtividade e Inteligência Oceânica
  // funcionam igual (ver CamadaConsultaPonto, em camadas/): cada uma no seu
  // arquivo diz o que busca e como desenha; aqui só a orquestração comum.

  /// Liga/desliga a camada. Ligar abre o retículo (ver
  /// [_buildOverlayConsultaPonto]) só se ainda não há ponto consultado — a
  /// busca acontece ao confirmar ([_confirmarConsultaPonto]); com pontos,
  /// ligar só os reexibe (mais um ponto é pelo botão "+").
  void _alternarCamada(CamadaConsultaPonto camada) {
    if (_consultaPontoAtiva == camada) {
      setState(() => _consultaPontoAtiva = null);
      return;
    }
    if (camada.visivel) {
      setState(() => camada.visivel = false);
      return;
    }
    if (camada.temPontos) {
      setState(() => camada.visivel = true);
    } else {
      _iniciarConsulta(camada);
    }
  }

  /// Abre o retículo pra consultar mais um ponto da camada, sem mexer nos
  /// que já estão marcados.
  void _iniciarConsulta(CamadaConsultaPonto camada) {
    _fecharMenuLateral();
    setState(() {
      _consultaPontoAtiva = camada;
      _centroMira = _mapController.camera.center;
    });
  }

  /// A [camada] está com uma consulta em andamento (spinner no menu).
  bool _consultando(CamadaConsultaPonto camada) =>
      _consultandoPonto && _consultaPontoAtiva == camada;

  void _mostrarDetalheCamada(CamadaConsultaPonto camada, Object? item) {
    camada.mostrarDetalhe(context, item,
        aoRemover: () => setState(() => camada.remover(item)));
  }

  /// Botões "+" das camadas visíveis, empilhados sem sobrepor um ao outro
  /// (antes cada botão calculava a própria altura, e com Índice e
  /// Inteligência ligados os dois ficavam no mesmo lugar).
  List<Widget> _buildBotoesAdicionarPonto() {
    final l10n = AppLocalizations.of(context);
    final visiveis = _camadasConsulta.where((c) => c.visivel).toList();
    return [
      for (var i = 0; i < visiveis.length; i++)
        Positioned(
          right: 12,
          bottom: 140.0 + 64 * i,
          child: FloatingActionButton(
            heroTag: 'adicionarPonto_${visiveis[i].id}',
            onPressed: () => _iniciarConsulta(visiveis[i]),
            tooltip: visiveis[i].tooltipAdicionar(l10n),
            child: const Icon(Icons.add),
          ),
        ),
    ];
  }

  // ── Seletor de posição pra consultar temperatura/clorofila ───────────────
  // Mesmo reticulado/cartão de "Marcar um ponto" (ver
  // [_buildOverlayMarcarPonto]) — pedido explícito: "exibir o seletor de
  // posição exatamente igual ao de criar uma posição, e a partir da
  // posição selecionada buscar a informação seja como clorofila ou
  // temperatura".

  Widget _buildOverlayConsultaPonto() {
    final camada = _consultaPontoAtiva;
    if (camada == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return PainelReticulo(
      centro: _centroMiraNotifier,
      instrucao: l10n.mapaConsultarPontoInstrucao(camada.titulo(l10n)),
      acaoSecundaria: OutlinedButton(
        onPressed: _consultandoPonto
            ? null
            : () => setState(() => _consultaPontoAtiva = null),
        child: Text(l10n.cancelar),
      ),
      acaoPrincipal: botaoConfirmarReticulo(
        rotulo: l10n.mapaConsultarBotao,
        onPressed: _confirmarConsultaPonto,
        ocupado: _consultandoPonto,
      ),
    );
  }

  /// Consulta a camada do retículo aberto no ponto mirado, acrescenta o
  /// resultado aos pontos que ela já tinha e mostra o que a camada define
  /// (ver CamadaConsultaPonto.aposConsultar). Erro vira mensagem amigável.
  Future<void> _confirmarConsultaPonto() async {
    final camada = _consultaPontoAtiva;
    if (camada == null) return;
    final ponto = _centroMira;
    final l10n = AppLocalizations.of(context);

    setState(() => _consultandoPonto = true);
    try {
      final novos = await camada.consultar(ponto, l10n);
      if (!mounted) return;
      setState(() {
        camada.adicionar(novos);
        _consultaPontoAtiva = null;
      });
      camada.aposConsultar(
          context, novos, (item) => _mostrarDetalheCamada(camada, item));
    } catch (e) {
      if (!mounted) return;
      setState(() => _consultaPontoAtiva = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              mensagemErroAmigavel(e, prefixo: camada.prefixoErro(l10n))),
        ),
      );
    } finally {
      if (mounted) setState(() => _consultandoPonto = false);
    }
  }

  // ── Menu lateral ──────────────────────────────────────────────────────────
  // Um único lugar pra tudo que antes era um ícone solto na barra de topo
  // (marcar ponto, baixar região, sobreposição) e o que já vivia no painel
  // de camadas — pedido explícito: "colocar todas as opções dos toggle em
  // um menu lateral específico", em vez de ícones espalhados.

  void _abrirMenuLateral() => setState(() => _menuLateralAberto = true);
  void _fecharMenuLateral() => setState(() => _menuLateralAberto = false);

  Widget _buildMenuLateral() {
    final l10n = AppLocalizations.of(context);
    return MenuLateralMapa(
      aberto: _menuLateralAberto,
      aoFechar: _fecharMenuLateral,
      titulo: l10n.mapaMenuTitulo,
      rodape: l10n.mapaAtribuicao,
      itens: [
        if (!widget.modoPlanejarRota) ...[
          const Divider(height: 1),
          ListTile(
            leading: Icon(_modoMarcarPonto ? Icons.close : Icons.add_location_alt),
            title: Text(_modoMarcarPonto
                ? l10n.mapaCancelarMarcacao
                : l10n.mapaMarcarPonto),
            dense: true,
            onTap: () {
              _alternarModoMarcarPonto();
              _fecharMenuLateral();
            },
          ),
        ],
        const Divider(height: 1),
        TituloSecaoMenu(l10n.mapaNavegacaoTitulo),
        ItemMenuToggle(
          icone: _bussolaAtiva ? Icons.explore : Icons.explore_off,
          titulo: l10n.mapaBussolaTitulo,
          subtitulo: _bussolaAtiva ? null : l10n.mapaBussolaDesligadaSubtitulo,
          ativo: _bussolaAtiva,
          onTap: _alternarBussola,
        ),
        const Divider(height: 1),
        TituloSecaoMenu(l10n.mapaCamadasTitulo),
        SeletorTipoMapa(
          camadaRuas: _camadaRuas,
          tituloCarta: l10n.mapaCartaNauticaCarregadaTitulo,
          tituloRuas: l10n.mapaCamadaRuasTitulo,
          aoEscolherCarta: () => setState(() => _camadaRuas = false),
          // Escolher "Open Sea" já liga as três camadas dele de uma vez
          // (informações náuticas, profundidade, isóbatas) — antes precisava
          // ligar o Mapa de Ruas e depois cada uma à mão. Continuam
          // desligáveis individualmente depois.
          aoEscolherRuas: () => setState(() {
            _camadaRuas = true;
            _mostrarInfoNautica = true;
            _mostrarProfundidade = true;
            _mostrarCurvasProfundidade = true;
          }),
        ),
        const SizedBox(height: 8),
        ItemMenuToggle(
          icone: Icons.anchor,
          titulo: l10n.mapaCamadaNauticaTitulo,
          subtitulo: l10n.mapaCamadaNauticaSubtitulo,
          ativo: _mostrarInfoNautica,
          onTap: !_camadaRuas ? null : _alternarInfoNautica,
        ),
        ItemMenuToggle(
          icone: Icons.layers,
          titulo: l10n.mapaCamadaProfundidadeTitulo,
          subtitulo: l10n.mapaCamadaProfundidadeSubtitulo,
          ativo: _mostrarProfundidade,
          onTap: !_camadaRuas ? null : _alternarProfundidade,
        ),
        ItemMenuToggle(
          icone: Icons.timeline,
          titulo: l10n.mapaCamadaCurvasTitulo,
          subtitulo: l10n.mapaCamadaCurvasSubtitulo,
          ativo: _mostrarCurvasProfundidade,
          onTap: !_camadaRuas ? null : _alternarCurvasProfundidade,
        ),
        ItemMenuToggle(
          icone: Icons.route,
          titulo: l10n.mapaCamadaTrilhaViagemTitulo,
          subtitulo: l10n.mapaCamadaTrilhaViagemSubtitulo,
          ativo: _mostrarTrilhaViagem,
          onTap: _alternarTrilhaViagem,
          recurso: RecursoAtlas.mapaTrilhaViagem,
        ),
        _itemCamadaConsulta(_camadaTemperatura, Icons.thermostat,
            recurso: RecursoAtlas.mapaSst),
        _itemCamadaConsulta(_camadaClorofila, Icons.water_drop,
            subtitulo: l10n.mapaClorofilaSubtitulo,
            recurso: RecursoAtlas.mapaClorofila),
        ItemMenuToggle(
          icone: Icons.local_fire_department,
          titulo: l10n.mapaCamadaProducaoTitulo,
          ativo: _mostrarProducao,
          onTap: _alternarProducao,
          carregando: _carregandoProducao,
        ),
        ItemMenuToggle(
          icone: Icons.image_outlined,
          titulo: l10n.mapaCamadaOverlayTitulo,
          subtitulo: l10n.mapaCamadaOverlaySubtitulo,
          ativo: _overlayAtiva,
          onTap: _overlayCarregando
              ? null
              : () => _alternarOverlay(!_overlayAtiva),
          carregando: _overlayCarregando,
        ),
        if (_overlayAtiva || _overlayValidada)
          ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 72, right: 16),
            title: Text(l10n.mapaEscolherImagem),
            onTap: _overlayCarregando ? null : _abrirDialogoSelecionarOverlay,
          ),
        const Divider(height: 1),
        _itemCamadaConsulta(_camadaIndice, Icons.auto_awesome,
            subtitulo: l10n.mapaIndiceProdutividadeSubtitulo,
            recurso: RecursoAtlas.mapaIndiceProdutividade),
        _itemCamadaConsulta(_camadaIntelligence, Icons.auto_awesome_outlined,
            subtitulo: l10n.mapaIntelligenceSubtitulo,
            recurso: RecursoAtlas.intelligenceOceanica),
        if (_camadaRuas) ...[
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l10n.mapaBaixarRegiao),
            dense: true,
            onTap: () {
              _abrirDownloadRegiao();
              _fecharMenuLateral();
            },
          ),
        ],
      ],
    );
  }

  /// Toggle de uma camada de consulta por ponto — liga/desliga, spinner
  /// durante a consulta.
  Widget _itemCamadaConsulta(CamadaConsultaPonto camada, IconData icone,
      {String? subtitulo, RecursoAtlas? recurso}) {
    return ItemMenuToggle(
      icone: icone,
      titulo: camada.titulo(AppLocalizations.of(context)),
      subtitulo: subtitulo,
      ativo: camada.visivel,
      onTap: () => _alternarCamada(camada),
      carregando: _consultando(camada),
      recurso: recurso,
    );
  }

  // ── Sobreposição de imagem ───────────────────────────────────────────────

  /// Liga/desliga a camada de sobreposição. Na primeira vez que é ligada
  /// (ou depois de [_trocarOverlay]), abre o seletor de arquivos para o
  /// usuário escolher o PNG georreferenciado.
  Future<void> _alternarOverlay(bool ativa) async {
    if (!ativa) {
      setState(() => _overlayAtiva = false);
      return;
    }
    if (_overlayValidada) {
      setState(() => _overlayAtiva = true);
      return;
    }
    await _abrirDialogoSelecionarOverlay();
  }

  /// Explica o que vai acontecer e, se confirmado, abre o seletor de
  /// arquivos para escolher o PNG georreferenciado.
  Future<void> _abrirDialogoSelecionarOverlay() async {
    final l10n = AppLocalizations.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.layers, color: Colors.lightBlue),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.mapaOverlayDialogTitulo)),
          ],
        ),
        content: Text(l10n.mapaOverlayDialogTexto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelar),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.mapaSelecionarImagem),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await _selecionarArquivoOverlay();
  }

  /// Abre o seletor de arquivos, lê os bounds embutidos no PNG escolhido
  /// (metadado `geo_bounds`, ver [GeoPngHelper]) e ativa a sobreposição.
  ///
  /// Se o PNG não tiver o metadado, cai no retângulo fixo configurado em
  /// [_overlaySudoesteFallback]/[_overlayNordesteFallback] em vez de
  /// impedir o uso — mas avisa o usuário do motivo.
  Future<void> _selecionarArquivoOverlay() async {
    setState(() => _overlayCarregando = true);
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png'],
      );
      final caminho = resultado?.files.single.path;
      if (caminho == null) {
        if (mounted) setState(() => _overlayCarregando = false);
        return;
      }

      final arquivo = File(caminho);
      LatLngBounds bounds;
      try {
        bounds = await GeoPngHelper.readBounds(arquivo);
      } catch (e) {
        bounds = LatLngBounds(
            _overlaySudoesteFallback, _overlayNordesteFallback);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).mapaOverlayFallback('$e'))),
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _overlayFile = arquivo;
        _overlayBounds = bounds;
        _overlayAtiva = true;
        _overlayValidada = true;
        _overlayCarregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _overlayCarregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).mapaErroSelecionarImagem('$e'))),
      );
    }
  }

  void _alternarModoMarcarPonto() {
    setState(() {
      _modoMarcarPonto = !_modoMarcarPonto;
      if (_modoMarcarPonto) {
        _centroMira = _mapController.camera.center;
      } else {
        _nomePontoController.clear();
      }
    });
  }

  Future<void> _confirmarPontoMarcado() async {
    final nome = _nomePontoController.text.trim();
    final novoPonto = PontoMarcado(
      latitude: _centroMira.latitude,
      longitude: _centroMira.longitude,
      dataCriacao: DateTime.now(),
      nome: nome.isEmpty ? null : nome,
    );
    final id = await _dbHelper.insert('ponto_marcado', novoPonto.toMap());
    if (!mounted) return;

    setState(() {
      _pontosMarcados = [
        ..._pontosMarcados,
        PontoMarcado(
          id: id,
          latitude: novoPonto.latitude,
          longitude: novoPonto.longitude,
          dataCriacao: novoPonto.dataCriacao,
          nome: novoPonto.nome,
        ),
      ];
      _modoMarcarPonto = false;
      _nomePontoController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).mapaPontoMarcadoConfirmacao(
            novoPonto.nome ??
                formatarCoordenadasDMSCompacta(
                    novoPonto.latitude, novoPonto.longitude),
          ),
        ),
      ),
    );
  }

  /// Mesmo layout/ações de um ponto marcado que `MeusPontosScreen` usa na
  /// lista (ver `DetalhePontoMarcado`/`abrirCardFlutuantePonto`) — antes
  /// esta tela tinha seu próprio `AlertDialog` com um subconjunto menor de
  /// ações (sem "Maré e Pesca aqui"/"Inteligência"); agora as duas
  /// mostram o mesmo card, não importa se o toque veio da lista ou de um
  /// marcador no mapa.
  void _mostrarInfoPontoMarcado(PontoMarcado ponto) {
    final navegacao = _distanciaERumoDoGps(ponto.latitude, ponto.longitude);
    abrirCardFlutuantePonto(
      context,
      DetalhePontoMarcado(
        ponto: ponto,
        distanciaNm: navegacao?.distanciaNm,
        rumoGraus: navegacao?.rumoGraus,
        producao: null,
        formatarDataHora: formatarDataHoraPonto,
        onRemovido: () async {
          if (ponto.id != null) {
            await _dbHelper.delete('ponto_marcado', id: ponto.id!);
          }
          if (!mounted) return;
          setState(() => _pontosMarcados.remove(ponto));
        },
      ),
    );
  }

  /// Detalhe de um ponto de recomendação (ver
  /// `mostrarDetalhePontoRecomendacao`), com distância/rumo do GPS atual.
  void _mostrarInfoPontoRecomendacao(PontoRecomendacao ponto) {
    final navegacao = _distanciaERumoDoGps(ponto.latitude, ponto.longitude);
    mostrarDetalhePontoRecomendacao(
      context,
      ponto: ponto,
      dbHelper: _dbHelper,
      criadoEm: widget.recomendacao?.criadoEm,
      distanciaNm: navegacao?.distanciaNm,
      rumoGraus: navegacao?.rumoGraus,
    );
  }

  /// Distância (mn) e rumo verdadeiro (0–360°) do GPS atual até o ponto;
  /// nulo enquanto não há fixo de GPS.
  ({double distanciaNm, double rumoGraus})? _distanciaERumoDoGps(
      double latitude, double longitude) {
    final gps = _gpsPosition;
    if (gps == null) return null;
    final distanciaNm = calcularDistanciaNauticas(
        gps.latitude, gps.longitude, latitude, longitude);
    var rumoGraus = Geolocator.bearingBetween(
        gps.latitude, gps.longitude, latitude, longitude);
    if (rumoGraus < 0) rumoGraus += 360;
    return (distanciaNm: distanciaNm, rumoGraus: rumoGraus);
  }

  // ── Metadados ──────────────────────────────────────────────────────────────

  void _applyMetadata(Map<String, String> meta) {
    _chartBounds = null;
    final boundsRaw = meta['bounds'];
    if (boundsRaw != null) {
      final b = boundsRaw.split(',').map(double.parse).toList();
      if (b.length == 4) {
        // bounds no formato MBTiles: west,south,east,north
        _chartBounds = LatLngBounds(LatLng(b[1], b[0]), LatLng(b[3], b[2]));
      }
    }

    if (meta.containsKey('center')) {
      final parts = meta['center']!.split(',').map(double.parse).toList();
      if (parts.length >= 2) {
        _center = LatLng(parts[1], parts[0]); // lon,lat → LatLng(lat,lon)
        if (parts.length >= 3) _zoom = parts[2];
      }
    } else if (_chartBounds != null) {
      _center = _chartBounds!.simpleCenter;
    }

    _minZoom = double.tryParse(meta['minzoom'] ?? '') ?? 0;
    _maxZoom = double.tryParse(meta['maxzoom'] ?? '') ?? 18;
    _zoom = _zoom.clamp(_minZoom, _maxZoom);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    PerfLog.contar('mapa.build');
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(child: _buildBody()),
          // Bússola sempre visível (não só no Modo Navegação) — canto
          // esquerdo, compacta, no mesmo nível do botão de menu (canto
          // direito, ver _buildTopBar), sem competir com o resto da tela.
          // Só existe no mapa "de verdade" (ver widget.navegacaoTempoReal)
          // e enquanto a bússola do aparelho estiver ligada — desligada
          // (ver _alternarBussola), o rumo vem do giroscópio, sem
          // referência ao norte, então o valor em graus deixa de fazer
          // sentido mostrado como bússola.
          if (_mode != _MapMode.none &&
              widget.navegacaoTempoReal &&
              _bussolaAtiva)
            Positioned(
              top: 8,
              left: 8,
              // ValueListenableBuilder: só esse badge repinta a cada
              // leitura do sensor, não a tela inteira (ver
              // _navegacaoRumoNotifier).
              child: ValueListenableBuilder<double>(
                valueListenable: _navegacaoRumoNotifier,
                builder: (context, rumo, _) =>
                    CompassoCircular(rumo: rumo, tamanho: 44),
              ),
            ),
          if (_mode != _MapMode.none) _buildTopBar(),
          if (_overlayAtiva && !_modoMarcarPonto && !widget.modoPlanejarRota)
            _buildOverlayOpacidadeControl(),
          if (_modoMarcarPonto) _buildOverlayMarcarPonto(),
          if (_consultaPontoAtiva != null) _buildOverlayConsultaPonto(),
          if (widget.modoPlanejarRota) _buildOverlayPlanejarRota(),
          if (!_modoMarcarPonto &&
              !widget.modoPlanejarRota &&
              _mode != _MapMode.none)
            _buildMeusPontosButton(),
          if (!_modoMarcarPonto &&
              !widget.modoPlanejarRota &&
              _mode != _MapMode.none &&
              _gpsPosition != null)
            _buildGpsButton(),
          if (!_modoMarcarPonto &&
              !widget.modoPlanejarRota &&
              _mode != _MapMode.none &&
              widget.navegacaoTempoReal)
            _buildModoNavegacaoButton(),
          if (!_modoMarcarPonto &&
              !widget.modoPlanejarRota &&
              _consultaPontoAtiva == null)
            ..._buildBotoesAdicionarPonto(),
          // Por cima de tudo — inclusive do scrim que fecha ao tocar fora.
          _buildMenuLateral(),
        ],
      ),
    );
  }

  /// Compacta num botão só no canto (sem nome de arquivo/título) — o
  /// resto do que já morou aqui (trocar carta, camadas etc.) mora só no
  /// menu lateral mesmo (ver _buildMenuLateral). Fica no canto oposto ao
  /// CompassoCircular, pra não competir com ele (ver build()).
  Widget _buildTopBar() {
    final l10n = AppLocalizations.of(context);
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading || _carregandoProducao || _consultandoPonto)
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
              ),
            // Enquanto marcando um ponto, um jeito rápido de cancelar sem
            // abrir o menu lateral inteiro — todo o resto (inclusive
            // iniciar a marcação) mora só lá agora (ver _buildMenuLateral).
            if (!widget.modoPlanejarRota && _modoMarcarPonto)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 22),
                tooltip: l10n.mapaCancelarMarcacao,
                onPressed: _alternarModoMarcarPonto,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            if (!widget.modoPlanejarRota)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 22),
                tooltip: l10n.mapaMenuDoMapaTooltip,
                onPressed: _abrirMenuLateral,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
          ],
        ),
      ),
    );
  }

  void _abrirDownloadRegiao() {
    final camera = _mapController.camera;
    showDialog(
      context: context,
      builder: (_) => DownloadRegiaoDialog(
        bounds: camera.visibleBounds,
        zoomAtual: camera.zoom.round(),
      ),
    );
  }

  Widget _buildGpsButton() {
    return Positioned(
      right: 12,
      bottom: 12,
      child: FloatingActionButton(
        onPressed: _centerOnGps,
        child: const Icon(Icons.directions_boat),
      ),
    );
  }

  /// Liga/desliga o Modo Navegação (ver _alternarModoNavegacao) — empilhado
  /// acima do botão de "Meus Pontos", pra ficar junto dos outros controles
  /// de posição/GPS.
  Widget _buildModoNavegacaoButton() {
    return Positioned(
      right: 12,
      bottom: 140,
      child: FloatingActionButton(
        heroTag: 'modoNavegacaoFab',
        backgroundColor: _modoNavegacao ? Colors.blue[700] : null,
        onPressed: _alternarModoNavegacao,
        tooltip: AppLocalizations.of(context).mapaModoNavegacaoTooltip,
        child: Icon(
            _modoNavegacao ? Icons.navigation : Icons.navigation_outlined),
      ),
    );
  }

  /// Abre "Meus Pontos" — lista com todos os pontos marcados manualmente e
  /// os de todas as recomendações juntos, empilhado logo acima do botão de
  /// GPS pra não competir com ele.
  Widget _buildMeusPontosButton() {
    return Positioned(
      right: 12,
      bottom: 76,
      child: FloatingActionButton(
        heroTag: 'meusPontosFab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MeusPontosScreen()),
        ),
        tooltip: AppLocalizations.of(context).mapaMeusPontosTooltip,
        child: const Icon(Icons.pin_drop),
      ),
    );
  }

  /// Barra compacta com um slider pra ajustar a opacidade da sobreposição
  /// em tempo real, enquanto ela está ligada.
  Widget _buildOverlayOpacidadeControl() {
    return Positioned(
      // Abaixo da bússola/botão de menu, que agora ficam nos cantos (ver
      // build()/_buildTopBar()).
      top: 64,
      left: 8,
      right: 8,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.opacity, color: Colors.white, size: 18),
              Expanded(
                child: Slider(
                  value: _overlayOpacidade,
                  onChanged: (v) => setState(() => _overlayOpacidade = v),
                ),
              ),
              Text(
                '${(_overlayOpacidade * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Carregando carta bundled pela primeira vez
    if (_loading && _mode == _MapMode.none) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).mapaCarregandoCarta),
          ],
        ),
      );
    }

    // Erro ao carregar bundled (sem nenhum arquivo aberto)
    if (_error != null && _mode == _MapMode.none) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadBundledChart,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).dashboardTentarNovamente),
              ),
            ],
          ),
        ),
      );
    }

    if (_modoNavegacao) {
      // Truque de perspectiva (CSS-3D-like) só visual — a carta em si
      // continua sendo o mesmo mapa 2D de sempre, só "deitado" pra dar a
      // sensação de câmera de navegação (efeito Waze/Google Maps),
      // combinado com o giro course-up já aplicado via moveAndRotate (ver
      // _alternarModoNavegacao). ClipRect evita que a área rotacionada
      // vaze pra fora dos limites do card.
      return ClipRect(
        // Transform.scale por fora (2D puro, sobre o resultado já
        // projetado) em vez de dentro da mesma matriz 3D — misturar escala
        // com a entrada de perspectiva na mesma matriz altera o
        // aprofundamento em Z e a perspectiva "cancela" boa parte do
        // aumento. Aqui só aumenta o retângulo já inclinado, ancorado na
        // base, pra preencher o vazio que a inclinação deixa acima da
        // carta (o topo recua e encolhe).
        child: Transform.scale(
          scale: 1.8,
          alignment: Alignment.bottomCenter,
          child: Transform(
            // Pivô na base — o "perto" (onde a embarcação está, perto do
            // barco 3D sobreposto) fica ancorado no tamanho normal; é o
            // "longe" (topo, horizonte) que recua e encolhe. Ângulo
            // negativo é o que produz esse sentido (positivo faz o
            // oposto: a base encolhe e o topo fica cheio).
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateX(-0.6),
            child: _buildFlutterMap(),
          ),
        ),
      );
    }
    return _buildFlutterMap();
  }

  Widget _buildFlutterMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: _zoom,
        // A carta náutica tem limites próprios (definidos no arquivo
        // carregado); o mapa de ruas cobre o mundo todo, sem essas
        // restrições.
        minZoom: _camadaRuas ? 1 : _minZoom,
        maxZoom: _camadaRuas ? 19 : _maxZoom,
        backgroundColor: const Color(0xFF1B3A5C),
        // Trava o pan dentro da carta carregada — combinado com o zoom
        // mínimo ajustado em `_preencherComCarta`, evita que sobre borda
        // vazia (fundo escuro) visível em qualquer direção.
        cameraConstraint: !_camadaRuas && _chartBounds != null
            ? CameraConstraint.contain(bounds: _chartBounds!)
            : const CameraConstraint.unconstrained(),
        onPositionChanged: (camera, hasGesture) {
          // Move o reticulado tanto em "Marcar um ponto" quanto no seletor
          // de consulta de temperatura/clorofila (mesmo widget, ver
          // _buildOverlayConsultaPonto) e agora também ao planejar rota
          // (ver _buildOverlayPlanejarRota) — todos usam _centroMira.
          if (_modoMarcarPonto ||
              _consultaPontoAtiva != null ||
              widget.modoPlanejarRota) {
            _centroMira = camera.center; // sem setState: ver _centroMiraNotifier
          }
          if (_camadaTemperatura.visivel) {
            final rotulosVisiveis =
                camera.zoom >= CamadaTemperatura.zoomMinimoRotulo;
            if (rotulosVisiveis != _camadaTemperatura.rotulosVisiveis) {
              setState(
                  () => _camadaTemperatura.rotulosVisiveis = rotulosVisiveis);
            }
          }
          // Só pausa o barco 3D em gesto de verdade do usuário — não em
          // mudança programática (ex.: nosso moveAndRotate do Modo
          // Navegação), que `hasGesture` já exclui.
          if (hasGesture) {
            if (!_usuarioMovendoMapa) {
              setState(() => _usuarioMovendoMapa = true);
            }
            _timerFimMovimentoMapa?.cancel();
            _timerFimMovimentoMapa = Timer(_debounceFimMovimentoMapa, () {
              if (mounted) setState(() => _usuarioMovendoMapa = false);
            });
          }
        },
      ),
      children: [
        if (_camadaRuas)
          ...camadasOpenSeaMap(
            _streetCache,
            profundidade: _mostrarProfundidade,
            curvas: _mostrarCurvasProfundidade,
            infoNautica: _mostrarInfoNautica,
          )
        else ...[
          if (_mode == _MapMode.mbtiles)
            TileLayer(
              tileProvider: MbtilesTileProvider(_mbtiles),
            ),
          if (_mode == _MapMode.geotiff && _geotiff != null)
            OverlayImageLayer(
              overlayImages: [
                OverlayImage(
                  bounds: LatLngBounds(
                    LatLng(_geotiff!.south, _geotiff!.west),
                    LatLng(_geotiff!.north, _geotiff!.east),
                  ),
                  imageProvider: MemoryImage(_geotiff!.imageBytes),
                ),
              ],
            ),
        ],
        // Sobreposição de imagem — PNG escolhido pelo usuário, com bounds
        // lidos do metadado `geo_bounds` embutido no arquivo (ver
        // GeoPngHelper), por cima da carta base (MBTiles/ruas) e por baixo
        // dos marcadores.
        if (_overlayAtiva && _overlayFile != null && _overlayBounds != null)
          OverlayImageLayer(
            overlayImages: [
              OverlayImage(
                bounds: _overlayBounds!,
                imageProvider: FileImage(_overlayFile!),
                opacity: _overlayOpacidade,
              ),
            ],
          ),
        // PNG georreferenciado que veio junto da recomendação
        // (`cartaNauticaUrl`), aplicado nas coordenadas do próprio arquivo —
        // ver `_carregarOverlayRecomendacao`.
        if (_recomendacaoOverlayBytes != null &&
            _recomendacaoOverlayBounds != null)
          OverlayImageLayer(
            overlayImages: [
              OverlayImage(
                bounds: _recomendacaoOverlayBounds!,
                imageProvider: MemoryImage(_recomendacaoOverlayBytes!),
              ),
            ],
          ),
        if (_mostrarProducao && _producaoClusters.isNotEmpty)
          camadaCalorProducao(
            _producaoClusters,
            (c) => mostrarDetalheGrupoProducao(context, c),
          ),
        // Camadas de consulta por ponto (temperatura, clorofila, índice,
        // Inteligência — ver camadas/), na ordem de _camadasConsulta.
        for (final camada in _camadasConsulta)
          if (camada.visivel && camada.temPontos)
            ...camada.camadas((item) => _mostrarDetalheCamada(camada, item)),
        if (widget.modoPlanejarRota) ...camadasRotaPlanejada(_pontosRotaPlanejada),
        // Atualiza sozinha enquanto a camada estiver ligada (ver
        // _alternarTrilhaViagem).
        if (_mostrarTrilhaViagem) ...camadasTrilhaViagem(_pontosTrilhaViagem),
        ...camadasRotaHistorico(_rota),
        // Ordem cronológica recebida de ProducaoHistoricoScreen.
        ...camadasRotaProducao(
          widget.producaoPontos ?? const [],
          (registro) => mostrarDetalheRegistroProducao(context, registro),
        ),
        // Pontos precisos: detalhes no MeteorologiaSheet ao tocar.
        if (_pontos.isNotEmpty)
          camadaPontosPrecisos(
              _pontos, (p) => MeteorologiaSheet.show(context, p)),
        // Barco 3D como marcador de posição — preso à coordenada real do
        // mundo (não fixo na tela) em qualquer modo, pra sempre refletir a
        // posição de verdade, mesmo se o usuário arrastar o mapa. No Modo
        // Navegação, o mapa recentraliza sozinho a cada atualização de GPS
        // (ver _alternarModoNavegacao), então o marcador acaba ficando
        // perto do centro de qualquer jeito — só que sem "travar" nada.
        // A bússola do dispositivo (sempre ativa, ver
        // _iniciarBussolaEPosicaoContinuas) orbita a câmera ao redor do
        // modelo em qualquer modo, 2D ou Modo Navegação — sem mover o
        // ícone em si (ver BarcoNavegacao3d). No preview compacto do
        // Dashboard (navegacaoTempoReal=false) usa só um ícone estático —
        // nada de WebView/3D ali (ver doc de MapaWidget.navegacaoTempoReal).
        //
        // Só esta camada escuta a posição (ver _gpsPositionNotifier). O
        // barco vai como `child` do builder: mover o marcador não recria o
        // WebView 3D.
        if (_gpsPosition != null)
          ValueListenableBuilder<LatLng?>(
            valueListenable: _gpsPositionNotifier,
            builder: (context, posicao, barco) => posicao == null
                ? const SizedBox.shrink()
                : MarkerLayer(
                    markers: [
                      Marker(
                        point: posicao,
                        width: 70,
                        height: 70,
                        child: barco!,
                      ),
                    ],
                  ),
            // RepaintBoundary: isola os repaints da WebView 3D (que muda a
            // cada frame da transição de orbita) do resto do canvas do mapa
            // (tiles, outras camadas) — sem isso, cada atualização do barco
            // força o Skia a considerar repintar a composição inteira junto.
            child: widget.navegacaoTempoReal
                ? RepaintBoundary(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _navegacaoRumoNotifier,
                      builder: (context, rumo, _) => BarcoNavegacao3d(
                        rumo: rumo,
                        tamanho: 70,
                        pausado: _usuarioMovendoMapa,
                      ),
                    ),
                  )
                : const Icon(Icons.directions_boat_filled,
                    color: Colors.blueAccent, size: 32),
          ),
        if (_pontosRecomendacaoDetalhados.isNotEmpty)
          camadaPontosRecomendacao(
              _pontosRecomendacaoDetalhados, _mostrarInfoPontoRecomendacao),
        if (_pontosMarcados.isNotEmpty)
          camadaPontosMarcados(
            _pontosMarcados,
            cor: widget.modoPlanejarRota ? Colors.purple : Colors.green,
            // Planejando rota: tocar um ponto marcado adiciona ele (com a
            // coordenada exata, sem depender de acertar o toque no mapa) em
            // vez de abrir o detalhe — que não faz sentido nesse modo.
            aoTocar: widget.modoPlanejarRota
                ? (p) => setState(() => _pontosRotaPlanejada = [
                      ..._pontosRotaPlanejada,
                      LatLng(p.latitude, p.longitude),
                    ])
                : _mostrarInfoPontoMarcado,
          ),
      ],
    );
  }

  // ── Overlay do modo "marcar ponto" ───────────────────────────────────────

  Widget _buildOverlayMarcarPonto() {
    final l10n = AppLocalizations.of(context);
    return PainelReticulo(
      centro: _centroMiraNotifier,
      instrucao: l10n.mapaApontarCentro,
      campos: [
        TextField(
          controller: _nomePontoController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.mapaNomeLocalLabel,
            hintText: l10n.mapaNomeLocalHint,
            isDense: true,
          ),
        ),
      ],
      acaoSecundaria: OutlinedButton(
        onPressed: _alternarModoMarcarPonto,
        child: Text(l10n.cancelar),
      ),
      acaoPrincipal: botaoConfirmarReticulo(
        rotulo: l10n.mapaMarcarPontoBotao,
        onPressed: _confirmarPontoMarcado,
      ),
    );
  }

  // ── Overlay do modo "planejar rota" ──────────────────────────────────────

  /// Retículo roxo pra diferenciar de "Marcar um ponto"/consultas; "Adicionar
  /// ponto" usa a posição real apontada, não onde o dedo tocou a tela.
  Widget _buildOverlayPlanejarRota() {
    final l10n = AppLocalizations.of(context);
    final pontos = _pontosRotaPlanejada.length;
    final podeSalvar =
        pontos >= 2 && _nomeRotaController.text.trim().isNotEmpty;
    return PainelReticulo(
      centro: _centroMiraNotifier,
      corReticulo: Colors.purple,
      alinhamento: CrossAxisAlignment.start,
      instrucao: pontos == 0
          ? l10n.mapaRotaTocarPrimeiroPonto
          : l10n.mapaRotaPontosAdicionados(pontos),
      campos: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _adicionarPontoRotaPlanejada,
            icon: const Icon(Icons.add_location_alt),
            label: Text(l10n.mapaRotaAdicionarPontoBotao),
          ),
        ),
        TextField(
          controller: _nomeRotaController,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.mapaNomeRotaLabel,
            hintText: l10n.mapaNomeRotaHint,
            isDense: true,
          ),
        ),
      ],
      acaoSecundaria: OutlinedButton(
        onPressed: pontos == 0 ? null : _desfazerUltimoPontoRota,
        child: Text(l10n.mapaDesfazerUltimo),
      ),
      acaoPrincipal: botaoConfirmarReticulo(
        rotulo: widget.rotaParaEditar != null
            ? l10n.mapaSalvarAlteracoes
            : l10n.mapaSalvarRota,
        onPressed: podeSalvar ? _salvarRotaPlanejada : null,
        ocupado: _salvandoRota,
      ),
    );
  }
}
