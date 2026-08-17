import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/services/geo_png_helper.dart';
import '../../../core/services/mbtiles_service.dart';
import '../../cartas/presentation/solicitar_cartas_screen.dart';
import '../../../core/services/geotiff_service.dart';
import '../../../core/services/pontos_service.dart';
import '../../../core/services/street_map_cache_service.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/proximidade.dart';
import '../../metereologia/data/profundidade_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../../metereologia/domain/models/leitura_profundidade.dart';
import '../../producao/domain/especies_comuns.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../domain/models/ponto_marcado.dart';
import '../widgets/download_regiao_dialog.dart';
import '../widgets/mbtiles_tile_provider.dart';
import '../widgets/meteorologia_sheet.dart';
import '../widgets/street_map_tile_provider.dart';

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

  const MapaWidget({
    super.key,
    this.recomendacao,
    this.rota,
    this.margemZoom = 2,
    this.modoPlanejarRota = false,
  });

  @override
  State<MapaWidget> createState() => MapaWidgetState();
}

class MapaWidgetState extends State<MapaWidget> {
  final MbtilesService _mbtiles = MbtilesService();
  final PontosService _pontosService = PontosService();
  final StreetMapCacheService _streetCache = StreetMapCacheService();
  final MapController _mapController = MapController();

  List<PontoMapa> _pontos = [];

  _MapMode _mode = _MapMode.none;
  bool _loading = false;
  String? _fileName;
  String? _error;

  /// Alterna entre a carta náutica carregada (MBTiles/GeoTIFF) e o mapa de
  /// ruas (OpenStreetMap, com cache próprio pra uso offline depois de
  /// baixado — ver [StreetMapCacheService]).
  bool _camadaRuas = false;

  GeotiffResult? _geotiff;

  double _minZoom = 0;
  double _maxZoom = 18;

  /// Bounds geográficos da carta carregada (MBTiles) — usados para travar o
  /// zoom mínimo e o pan de forma que a carta sempre preencha a área
  /// visível do mapa, sem deixar borda vazia aparecendo.
  LatLngBounds? _chartBounds;
  LatLng _center = const LatLng(-15.0, -50.0);
  double _zoom = 4;

  LatLng? _gpsPosition;

  // ── Marcar ponto manualmente ─────────────────────────────────────────────
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _modoMarcarPonto = false;
  LatLng _centroMira = const LatLng(-15.0, -50.0);
  List<PontoMarcado> _pontosMarcados = [];
  final TextEditingController _nomePontoController = TextEditingController();

  // ── Planejar rota manualmente ────────────────────────────────────────────
  List<LatLng> _pontosRotaPlanejada = [];
  final TextEditingController _nomeRotaController = TextEditingController();
  bool _salvandoRota = false;

  // ── Calor de produção ────────────────────────────────────────────────────
  bool _mostrarProducao = false;
  bool _carregandoProducao = false;
  List<_ClusterProducao> _producaoClusters = [];

  // ── Sobreposição de imagem (PNG georreferenciado) ────────────────────────
  bool _overlayAtiva = false;
  bool _overlayValidada = false;
  bool _overlayCarregando = false;
  double _overlayOpacidade = 0.8;
  File? _overlayFile;
  LatLngBounds? _overlayBounds;

  /// Pontos da recomendação a exibir sobre a carta (vazio se nenhuma).
  List<LatLng> get _pontosRecomendacao {
    final r = widget.recomendacao;
    if (r == null) return [];
    if (r.pontos != null && r.pontos!.isNotEmpty) {
      return r.pontos!.map((p) => LatLng(p.latitude, p.longitude)).toList();
    }
    if (r.centroide != null) {
      return [LatLng(r.centroide!.latitude, r.centroide!.longitude)];
    }
    return [];
  }

  /// Pontos da rota de histórico a exibir sobre a carta (vazio se nenhuma).
  List<LatLng> get _rota => widget.rota ?? [];

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
  }

  @override
  void dispose() {
    _mbtiles.close();
    _nomePontoController.dispose();
    _nomeRotaController.dispose();
    super.dispose();
  }

  // ── Planejar rota manualmente ────────────────────────────────────────────

  void _desfazerUltimoPontoRota() {
    if (_pontosRotaPlanejada.isEmpty) return;
    setState(() {
      _pontosRotaPlanejada = _pontosRotaPlanejada.sublist(
        0,
        _pontosRotaPlanejada.length - 1,
      );
    });
  }

  Future<void> _salvarRotaPlanejada() async {
    final nome = _nomeRotaController.text.trim();
    if (nome.isEmpty || _pontosRotaPlanejada.length < 2) return;

    setState(() => _salvandoRota = true);
    try {
      final rotaId = await _dbHelper.insert('rota_planejada', {
        'nome': nome,
        'data_criacao': DateTime.now().toIso8601String(),
      });
      for (var i = 0; i < _pontosRotaPlanejada.length; i++) {
        final p = _pontosRotaPlanejada[i];
        await _dbHelper.insert('rota_planejada_ponto', {
          'rota_planejada_id': rotaId,
          'latitude': p.latitude,
          'longitude': p.longitude,
          'ordem': i,
        });
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvandoRota = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar rota: $e')),
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
        _fileName = _bundledAsset.split('/').last;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pontosRecomendacao.isNotEmpty) {
          _focarPontos(_pontosRecomendacao);
        } else if (_rota.isNotEmpty) {
          _focarPontos(_rota);
        } else {
          _preencherComCarta();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar carta: $e';
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
    if (_pontosRecomendacao.isNotEmpty || _rota.isNotEmpty) return;
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

      // Mostra a última posição conhecida imediatamente (cache do sistema)
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        final pos = LatLng(last.latitude, last.longitude);
        setState(() => _gpsPosition = pos);
        _recentralizarNoGps(pos);
      }

      // Atualiza com fix fresco em segundo plano
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 30));
      if (mounted) {
        final pos = LatLng(fresh.latitude, fresh.longitude);
        setState(() => _gpsPosition = pos);
        _recentralizarNoGps(pos);
      }
    } catch (_) {}
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

    // Agrupa registros próximos (~100m) somando o total em kg, pra não
    // sobrepor um marcador em cima do outro quando há vários registros na
    // mesma pescaria.
    final grupos = <String, _ClusterProducao>{};
    for (final r in registros) {
      final lat = (r['latitude'] as num).toDouble();
      final lon = (r['longitude'] as num).toDouble();
      final kg = (r['quantidade_kg'] as num).toDouble();
      final especieNormalizada =
          normalizarEspecie(r['especie'] as String? ?? '');
      final especie =
          especieNormalizada.isEmpty ? 'Não informado' : especieNormalizada;
      final chave =
          '${lat.toStringAsFixed(3)},${lon.toStringAsFixed(3)}';

      final existente = grupos[chave];
      if (existente == null) {
        grupos[chave] = _ClusterProducao(
          lat: lat,
          lon: lon,
          totalKg: kg,
          porEspecie: {especie: kg},
        );
      } else {
        existente.totalKg += kg;
        existente.porEspecie.update(
          especie,
          (v) => v + kg,
          ifAbsent: () => kg,
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _producaoClusters = grupos.values.toList();
      _carregandoProducao = false;
    });
  }

  List<Marker> _buildMarcadoresProducao() {
    final maxKg = _producaoClusters
        .map((c) => c.totalKg)
        .reduce((a, b) => a > b ? a : b);
    return _producaoClusters.map((c) {
      final tamanho = maxKg <= 0
          ? 24.0
          : (24 + 36 * (c.totalKg / maxKg)).clamp(24.0, 60.0);
      return Marker(
        point: LatLng(c.lat, c.lon),
        width: tamanho,
        height: tamanho,
        child: GestureDetector(
          onTap: () => _mostrarInfoProducao(c),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _mostrarInfoProducao(_ClusterProducao cluster) {
    final especies = cluster.porEspecie.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${cluster.totalKg.toStringAsFixed(1)} kg no total',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatarCoordenadasDMSCompacta(cluster.lat, cluster.lon),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Divider(height: 20),
              ...especies.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key),
                      Text('${e.value.toStringAsFixed(1)} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
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
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.layers, color: Colors.lightBlue),
            SizedBox(width: 8),
            Expanded(child: Text('Sobreposição PNG')),
          ],
        ),
        content: const Text(
          'Escolha, na galeria de fotos do dispositivo, um PNG '
          'georreferenciado (com o metadado "geo_bounds" embutido) para '
          'exibir sobre a carta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Selecionar imagem'),
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
            SnackBar(content: Text('$e Usando área padrão do app.')),
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
        SnackBar(content: Text('Erro ao selecionar imagem: $e')),
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
          novoPonto.nome != null
              ? 'Ponto marcado: ${novoPonto.nome}'
              : 'Ponto marcado: '
                  '${formatarCoordenadasDMSCompacta(novoPonto.latitude, novoPonto.longitude)}',
        ),
      ),
    );
  }

  void _mostrarInfoPontoMarcado(PontoMarcado ponto) {
    double? distanciaNm;
    double? rumoGraus;
    final gps = _gpsPosition;
    if (gps != null) {
      distanciaNm = calcularDistanciaNauticas(
        gps.latitude,
        gps.longitude,
        ponto.latitude,
        ponto.longitude,
      );
      rumoGraus = Geolocator.bearingBetween(
        gps.latitude,
        gps.longitude,
        ponto.latitude,
        ponto.longitude,
      );
      if (rumoGraus < 0) rumoGraus += 360;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.push_pin, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ponto.nome?.isNotEmpty == true ? ponto.nome! : 'Ponto marcado',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LinhaInfoPonto(
                icon: Icons.explore_outlined,
                label: 'Coordenadas',
                valor:
                    formatarCoordenadasDMS(ponto.latitude, ponto.longitude),
              ),
              const Divider(height: 20),
              _LinhaInfoPonto(
                icon: Icons.event_outlined,
                label: 'Marcado em',
                valor: _formatarDataHora(ponto.dataCriacao),
              ),
              if (distanciaNm != null && rumoGraus != null) ...[
                const Divider(height: 20),
                _LinhaInfoPonto(
                  icon: Icons.social_distance_outlined,
                  label: 'Distância',
                  valor: '${distanciaNm.toStringAsFixed(1)} mn',
                ),
                const SizedBox(height: 8),
                _LinhaInfoPonto(
                  icon: Icons.navigation_outlined,
                  label: 'Rumo',
                  valor: '${rumoGraus.toStringAsFixed(0)}°',
                ),
              ],
              const Divider(height: 20),
              _DadosOceanicosPonto(
                latitude: ponto.latitude,
                longitude: ponto.longitude,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SolicitarCartaScreen(
                    dbHelper: _dbHelper,
                    latitudeInicial: ponto.latitude,
                    longitudeInicial: ponto.longitude,
                  ),
                ),
              );
            },
            child: const Text('Solicitar Carta'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (ponto.id != null) {
                await _dbHelper.delete('ponto_marcado', id: ponto.id!);
              }
              if (!mounted) return;
              setState(() => _pontosMarcados.remove(ponto));
            },
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static String _formatarDataHora(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$d/$mo/${dt.year}  $h:$mi';
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(child: _buildBody()),
          if (_mode != _MapMode.none) _buildTopBar(),
          if (_overlayAtiva && !_modoMarcarPonto && !widget.modoPlanejarRota)
            _buildOverlayOpacidadeControl(),
          if (_modoMarcarPonto) ..._buildOverlayMarcarPonto(),
          if (widget.modoPlanejarRota) _buildOverlayPlanejarRota(),
          if (!_modoMarcarPonto &&
              !widget.modoPlanejarRota &&
              _mode != _MapMode.none &&
              _gpsPosition != null)
            _buildGpsButton(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.modoPlanejarRota
                      ? 'Nova Rota Planejada'
                      : widget.recomendacao != null
                          ? widget.recomendacao!.titulo.isEmpty
                              ? 'Recomendação'
                              : widget.recomendacao!.titulo
                          : widget.rota != null
                              ? 'Rota do histórico'
                              : _camadaRuas
                                  ? 'Mapa de Ruas (OpenStreetMap)'
                                  : _fileName ?? 'Mapa',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              if (_loading || _carregandoProducao)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                ),
              if (!widget.modoPlanejarRota)
                IconButton(
                  icon: Icon(
                    _modoMarcarPonto ? Icons.close : Icons.add_location_alt,
                    color: Colors.white,
                    size: 22,
                  ),
                  tooltip: _modoMarcarPonto
                      ? 'Cancelar marcação'
                      : 'Marcar um ponto',
                  onPressed: _alternarModoMarcarPonto,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              if (_camadaRuas)
                IconButton(
                  icon: const Icon(Icons.download,
                      color: Colors.white, size: 22),
                  tooltip: 'Baixar região para uso offline',
                  onPressed: _abrirDownloadRegiao,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              IconButton(
                icon: Icon(
                  _camadaRuas ? Icons.map : Icons.explore,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: _camadaRuas ? 'Ver carta náutica' : 'Ver mapa de ruas',
                onPressed: () => setState(() => _camadaRuas = !_camadaRuas),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
              if (!widget.modoPlanejarRota)
                IconButton(
                  icon: Icon(
                    Icons.local_fire_department,
                    color: _mostrarProducao ? Colors.orangeAccent : Colors.white,
                    size: 22,
                  ),
                  tooltip: _mostrarProducao
                      ? 'Esconder calor de produção'
                      : 'Ver calor de produção',
                  onPressed: _alternarProducao,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              if (!widget.modoPlanejarRota)
                GestureDetector(
                  onLongPress:
                      _overlayCarregando ? null : _abrirDialogoSelecionarOverlay,
                  child: IconButton(
                    icon: _overlayCarregando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(
                            Icons.layers,
                            color: _overlayAtiva
                                ? Colors.lightBlueAccent
                                : Colors.white,
                            size: 22,
                          ),
                    tooltip: _overlayAtiva
                        ? 'Esconder sobreposição (segure para trocar a imagem)'
                        : 'Ver sobreposição (segure para escolher a imagem)',
                    onPressed: _overlayCarregando
                        ? null
                        : () => _alternarOverlay(!_overlayAtiva),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
            ],
          ),
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

  /// Barra compacta com um slider pra ajustar a opacidade da sobreposição
  /// em tempo real, enquanto ela está ligada.
  Widget _buildOverlayOpacidadeControl() {
    return Positioned(
      top: 56,
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando carta náutica...'),
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
                label: const Text('Tentar novamente'),
              ),
            ],
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
          if (_modoMarcarPonto) {
            setState(() => _centroMira = camera.center);
          }
        },
        onTap: widget.modoPlanejarRota
            ? (_, ponto) => setState(
                () => _pontosRotaPlanejada = [..._pontosRotaPlanejada, ponto])
            : null,
      ),
      children: [
        if (_camadaRuas)
          TileLayer(tileProvider: StreetMapTileProvider(_streetCache))
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
        // Calor de produção — círculos proporcionais ao total em kg
        // registrado perto daquele ponto, em qualquer viagem.
        if (_mostrarProducao && _producaoClusters.isNotEmpty)
          MarkerLayer(markers: _buildMarcadoresProducao()),
        // Rota sendo planejada manualmente — cada toque no mapa adiciona um
        // ponto numerado em sequência.
        if (widget.modoPlanejarRota && _pontosRotaPlanejada.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _pontosRotaPlanejada,
                strokeWidth: 4,
                color: Colors.purple,
              ),
            ],
          ),
        if (widget.modoPlanejarRota && _pontosRotaPlanejada.isNotEmpty)
          MarkerLayer(
            markers: _pontosRotaPlanejada.asMap().entries.map((entry) {
              final indice = entry.key;
              final ponto = entry.value;
              return Marker(
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
              );
            }).toList(),
          ),
        // Rota do histórico de GPS — linha ligando os pontos na ordem
        // cronológica, ao estilo Waze/Google Maps, sobre a carta náutica.
        if (_rota.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _rota,
                strokeWidth: 4,
                color: Colors.redAccent,
              ),
            ],
          ),
        if (_rota.isNotEmpty)
          MarkerLayer(
            markers: [
              Marker(
                point: _rota.first,
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
              if (_rota.length > 1)
                Marker(
                  point: _rota.last,
                  width: 34,
                  height: 34,
                  alignment: Alignment.topCenter,
                  child: const Icon(Icons.flag, color: Colors.red, size: 28),
                ),
            ],
          ),
        // Pontos precisos: alfinete só — nome/detalhes só aparecem ao tocar
        // (ver MeteorologiaSheet), pra não poluir o mapa com texto solto.
        if (_pontos.isNotEmpty)
          MarkerLayer(
            markers: _pontos
                .map((p) => Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 28,
                      height: 28,
                      child: GestureDetector(
                        onTap: () => MeteorologiaSheet.show(context, p),
                        child: Center(
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        if (_gpsPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _gpsPosition!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.navigation,
                  color: Colors.blue,
                  size: 36,
                ),
              ),
            ],
          ),
        if (_pontosRecomendacao.isNotEmpty)
          MarkerLayer(
            markers: _pontosRecomendacao
                .map((p) => Marker(
                      point: p,
                      width: 36,
                      height: 36,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.deepOrange,
                        size: 32,
                      ),
                    ))
                .toList(),
          ),
        if (_pontosMarcados.isNotEmpty)
          MarkerLayer(
            markers: _pontosMarcados
                .map((p) => Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 36,
                      height: 36,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => _mostrarInfoPontoMarcado(p),
                        child: const Icon(
                          Icons.push_pin,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  // ── Overlay do modo "marcar ponto" ───────────────────────────────────────

  List<Widget> _buildOverlayMarcarPonto() {
    return [
      // Retículo fixo no centro do mapa — não se move com o mapa.
      const IgnorePointer(
        child: Center(
          child: Icon(
            Icons.add,
            size: 44,
            color: Colors.red,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
      ),
      Positioned(
        left: 12,
        right: 12,
        bottom: 12,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Aponte o centro do mapa para o local desejado',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  formatarCoordenadasDMSCompacta(
                      _centroMira.latitude, _centroMira.longitude),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nomePontoController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome do local (opcional)',
                    hintText: 'Ex: Poço do Camurupim',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _alternarModoMarcarPonto,
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _confirmarPontoMarcado,
                        icon: const Icon(Icons.check),
                        label: const Text('Marcar ponto'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  // ── Overlay do modo "planejar rota" ──────────────────────────────────────

  Widget _buildOverlayPlanejarRota() {
    final pontos = _pontosRotaPlanejada.length;
    final podeSalvar =
        pontos >= 2 && _nomeRotaController.text.trim().isNotEmpty;
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pontos == 0
                    ? 'Toque no mapa para adicionar o primeiro ponto'
                    : '$pontos ponto${pontos == 1 ? '' : 's'} adicionado${pontos == 1 ? '' : 's'} — toque para continuar',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nomeRotaController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Nome da rota',
                  hintText: 'Ex: Pesqueiro do Camurupim',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: pontos == 0 ? null : _desfazerUltimoPontoRota,
                      child: const Text('Desfazer último'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (!podeSalvar || _salvandoRota)
                          ? null
                          : _salvarRotaPlanejada,
                      icon: _salvandoRota
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Salvar rota'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um agrupamento de registros de produção próximos entre si (~100m),
/// somados por espécie — usado pela camada de calor de produção no mapa.
class _ClusterProducao {
  final double lat;
  final double lon;
  double totalKg;
  final Map<String, double> porEspecie;

  _ClusterProducao({
    required this.lat,
    required this.lon,
    required this.totalKg,
    required this.porEspecie,
  });
}

/// Busca e exibe batimetria (profundidade) e temperatura da superfície do
/// mar (SST) para um ponto marcado — chamadas assíncronas a APIs externas
/// (OpenTopoData e Open-Meteo Marine), então carrega em segundo plano
/// depois do diálogo já estar aberto com os dados síncronos.
class _DadosOceanicosPonto extends StatefulWidget {
  final double latitude;
  final double longitude;

  const _DadosOceanicosPonto({
    required this.latitude,
    required this.longitude,
  });

  @override
  State<_DadosOceanicosPonto> createState() => _DadosOceanicosPontoState();
}

class _DadosOceanicosPontoState extends State<_DadosOceanicosPonto> {
  bool _carregandoProfundidade = true;
  bool _carregandoTemperatura = true;
  LeituraProfundidade? _profundidade;
  double? _temperatura;

  @override
  void initState() {
    super.initState();
    _carregarProfundidade();
    _carregarTemperatura();
  }

  Future<void> _carregarProfundidade() async {
    try {
      final resultado = await ProfundidadeRepository().buscarPonto(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (!mounted) return;
      setState(() {
        _profundidade = resultado;
        _carregandoProfundidade = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregandoProfundidade = false);
    }
  }

  Future<void> _carregarTemperatura() async {
    try {
      final forecast = await WaveForecastRepository().buscar(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (!mounted) return;
      setState(() {
        _temperatura = forecast.current?.seaSurfaceTemperature;
        _carregandoTemperatura = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregandoTemperatura = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LinhaInfoPonto(
          icon: Icons.waves_outlined,
          label: 'Profundidade',
          valor: _valorProfundidade(),
          carregando: _carregandoProfundidade,
        ),
        const SizedBox(height: 8),
        _LinhaInfoPonto(
          icon: Icons.thermostat_outlined,
          label: 'Temperatura (SST)',
          valor: _temperatura != null
              ? '${_temperatura!.toStringAsFixed(1)}°C'
              : '—',
          carregando: _carregandoTemperatura,
        ),
      ],
    );
  }

  String _valorProfundidade() {
    final p = _profundidade;
    if (p == null) return '—';
    if (!p.emAgua) return 'Em terra';
    return '${p.profundidadeMetros.toStringAsFixed(0)} m';
  }
}

/// Linha "ícone + rótulo + valor" usada no diálogo de detalhes de um ponto
/// marcado (coordenadas, data, distância, rumo, profundidade, temperatura).
class _LinhaInfoPonto extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final bool carregando;

  const _LinhaInfoPonto({
    required this.icon,
    required this.label,
    required this.valor,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const SizedBox(width: 12),
        Expanded(
          child: carregando
              ? const Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Text(
                  valor,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
        ),
      ],
    );
  }
}
