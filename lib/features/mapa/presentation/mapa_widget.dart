import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/database/database_helper.dart';
import '../../../core/services/mbtiles_service.dart';
import '../../../core/services/geotiff_service.dart';
import '../../../core/services/pontos_service.dart';
import '../../../core/utils/coordenadas_format.dart';
import '../../../core/utils/proximidade.dart';
import '../../metereologia/data/profundidade_repository.dart';
import '../../metereologia/data/wave_forecast_repository.dart';
import '../../metereologia/domain/models/leitura_profundidade.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../domain/models/ponto_marcado.dart';
import '../widgets/mbtiles_tile_provider.dart';
import '../widgets/meteorologia_sheet.dart';

const _bundledAsset = 'assets/cartas/OUTPUT_FILE.mbtiles';
const _pontosAsset = 'assets/json/posicoes/Routing3.json';

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

  const MapaWidget({
    super.key,
    this.recomendacao,
    this.rota,
    this.margemZoom = 2,
  });

  @override
  State<MapaWidget> createState() => MapaWidgetState();
}

class MapaWidgetState extends State<MapaWidget> {
  final MbtilesService _mbtiles = MbtilesService();
  final GeotiffService _geotiffService = GeotiffService();
  final PontosService _pontosService = PontosService();
  final MapController _mapController = MapController();

  List<PontoMapa> _pontos = [];

  _MapMode _mode = _MapMode.none;
  bool _loading = false;
  String? _fileName;
  String? _error;

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
    super.dispose();
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

  void _alternarModoMarcarPonto() {
    setState(() {
      _modoMarcarPonto = !_modoMarcarPonto;
      if (_modoMarcarPonto) {
        _centroMira = _mapController.camera.center;
      }
    });
  }

  Future<void> _confirmarPontoMarcado() async {
    final novoPonto = PontoMarcado(
      latitude: _centroMira.latitude,
      longitude: _centroMira.longitude,
      dataCriacao: DateTime.now(),
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
        ),
      ];
      _modoMarcarPonto = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ponto marcado: '
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
        title: const Row(
          children: [
            Icon(Icons.push_pin, color: Colors.green),
            SizedBox(width: 8),
            Text('Ponto marcado'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LinhaInfoPonto(
                icon: Icons.explore_outlined,
                label: 'Coordenadas',
                valor: formatarCoordenadasDMSCompacta(
                    ponto.latitude, ponto.longitude),
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

  // ── Arquivo externo (opcional) ─────────────────────────────────────────────

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (!mounted) return;
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final name = result.files.single.name;
    final lower = path.toLowerCase();

    if (lower.endsWith('.mbtiles')) {
      await _openMbtiles(path, name);
    } else if (lower.endsWith('.tif') || lower.endsWith('.tiff')) {
      await _openGeotiff(path, name);
    } else {
      setState(
          () => _error = 'Formato não suportado.\nUse .mbtiles, .tif ou .tiff');
    }
  }

  Future<void> _openMbtiles(String path, String name) async {
    setState(() => _loading = true);
    try {
      await _mbtiles.open(path);
      final meta = await _mbtiles.getMetadata();
      _applyMetadata(meta);
      if (!mounted) return;
      setState(() {
        _mode = _MapMode.mbtiles;
        _geotiff = null;
        _fileName = name;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preencherComCarta();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao abrir MBTiles: $e';
        _loading = false;
      });
    }
  }

  Future<void> _openGeotiff(String path, String name) async {
    setState(() => _loading = true);
    try {
      final result = await _geotiffService.load(path);
      await _mbtiles.close();
      if (!mounted) return;
      setState(() {
        _mode = _MapMode.geotiff;
        _geotiff = result;
        _fileName = name;
        _chartBounds = null;
        _center = LatLng(
          (result.north + result.south) / 2,
          (result.east + result.west) / 2,
        );
        _minZoom = 0;
        _maxZoom = 22;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds(
              LatLng(result.south, result.west),
              LatLng(result.north, result.east),
            ),
            padding: const EdgeInsets.all(24),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
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
          if (_modoMarcarPonto) ..._buildOverlayMarcarPonto(),
          if (!_modoMarcarPonto && _mode != _MapMode.none && _gpsPosition != null)
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
                  widget.recomendacao != null
                      ? widget.recomendacao!.titulo.isEmpty
                          ? 'Recomendação'
                          : widget.recomendacao!.titulo
                      : widget.rota != null
                          ? 'Rota do histórico'
                          : _fileName ?? 'Mapa',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                ),
              IconButton(
                icon: Icon(
                  _modoMarcarPonto ? Icons.close : Icons.add_location_alt,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip:
                    _modoMarcarPonto ? 'Cancelar marcação' : 'Marcar um ponto',
                onPressed: _alternarModoMarcarPonto,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.folder_open,
                    color: Colors.white, size: 20),
                tooltip: 'Carregar outro arquivo',
                onPressed: _loading ? null : _pickFile,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGpsButton() {
    return Positioned(
      right: 12,
      bottom: 12,
      child: FloatingActionButton.small(
        onPressed: _centerOnGps,
        child: const Icon(Icons.directions_boat),
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
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        backgroundColor: const Color(0xFF1B3A5C),
        // Trava o pan dentro da carta carregada — combinado com o zoom
        // mínimo ajustado em `_preencherComCarta`, evita que sobre borda
        // vazia (fundo escuro) visível em qualquer direção.
        cameraConstraint: _chartBounds != null
            ? CameraConstraint.contain(bounds: _chartBounds!)
            : const CameraConstraint.unconstrained(),
        onPositionChanged: (camera, hasGesture) {
          if (_modoMarcarPonto) {
            setState(() => _centroMira = camera.center);
          }
        },
      ),
      children: [
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
        // Pontos precisos: widget 14x14 centralizado exatamente na coordenada
        if (_pontos.isNotEmpty)
          MarkerLayer(
            markers: _pontos
                .map((p) => Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 14,
                      height: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ))
                .toList(),
          ),
        // Labels: flutuam à direita do ponto, sem exigir precisão pixel-perfect
        if (_pontos.isNotEmpty)
          MarkerLayer(
            markers: _pontos
                .map((p) => Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 150,
                      height: 22,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: GestureDetector(
                          onTap: () => MeteorologiaSheet.show(context, p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
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
        if (_pontosRecomendacao.isNotEmpty) ...[
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
          // Coordenadas: flutuam à direita do ponto.
          MarkerLayer(
            markers: _pontosRecomendacao
                .map((p) => Marker(
                      point: p,
                      width: 150,
                      height: 22,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            formatarCoordenadasDMSCompacta(
                                p.latitude, p.longitude),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
        if (_pontosMarcados.isNotEmpty) ...[
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
          // Coordenadas: flutuam à direita do ponto.
          MarkerLayer(
            markers: _pontosMarcados
                .map((p) => Marker(
                      point: LatLng(p.latitude, p.longitude),
                      width: 150,
                      height: 22,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            formatarCoordenadasDMSCompacta(
                                p.latitude, p.longitude),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
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
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        if (carregando)
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Text(
            valor,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
      ],
    );
  }
}
