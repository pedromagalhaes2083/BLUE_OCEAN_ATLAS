import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/mbtiles_service.dart';
import '../../../core/services/geotiff_service.dart';
import '../../../core/services/pontos_service.dart';
import '../../recomendacao/domain/models/recomendacao.dart';
import '../widgets/mbtiles_tile_provider.dart';
import '../widgets/meteorologia_sheet.dart';

const _bundledAsset = 'assets/cartas/OUTPUT_FILE.mbtiles';
const _pontosAsset = 'assets/json/posicoes/Routing3.json';

enum _MapMode { none, mbtiles, geotiff }

class MapaScreen extends StatefulWidget {
  /// Se informada, os pontos dessa recomendação são exibidos como
  /// marcadores sobre a carta, com o mapa centralizado neles.
  final Recomendacao? recomendacao;

  const MapaScreen({super.key, this.recomendacao});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
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
  LatLng _center = const LatLng(-15.0, -50.0);
  double _zoom = 4;

  LatLng? _gpsPosition;

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

  void _focarRecomendacao() {
    final pontos = _pontosRecomendacao;
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
      setState(() {
        _mode = _MapMode.mbtiles;
        _fileName = _bundledAsset.split('/').last;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pontosRecomendacao.isNotEmpty) {
          _focarRecomendacao();
        } else {
          _mapController.move(_center, _zoom);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar carta: $e';
        _loading = false;
      });
    }
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
          permission == LocationPermission.deniedForever) return;

      // Mostra a última posição conhecida imediatamente (cache do sistema)
      final last = await Geolocator.getLastKnownPosition();
      if (last != null && mounted) {
        setState(() => _gpsPosition = LatLng(last.latitude, last.longitude));
      }

      // Atualiza com fix fresco em segundo plano
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 30));
      if (mounted) {
        setState(() => _gpsPosition = LatLng(fresh.latitude, fresh.longitude));
      }
    } catch (_) {}
  }

  void _centerOnGps() {
    if (_gpsPosition != null) {
      _mapController.move(_gpsPosition!, _mapController.camera.zoom);
    }
  }

  // ── Arquivo externo (opcional) ─────────────────────────────────────────────

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
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
      setState(() {
        _mode = _MapMode.mbtiles;
        _geotiff = null;
        _fileName = name;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_center, _zoom);
      });
    } catch (e) {
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
      setState(() {
        _mode = _MapMode.geotiff;
        _geotiff = result;
        _fileName = name;
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
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // ── Metadados ──────────────────────────────────────────────────────────────

  void _applyMetadata(Map<String, String> meta) {
    if (meta.containsKey('center')) {
      final parts = meta['center']!.split(',').map(double.parse).toList();
      if (parts.length >= 2) {
        _center = LatLng(parts[1], parts[0]); // lon,lat → LatLng(lat,lon)
        if (parts.length >= 3) _zoom = parts[2];
      }
    } else if (meta.containsKey('bounds')) {
      final b = meta['bounds']!.split(',').map(double.parse).toList();
      if (b.length == 4) {
        _center = LatLng((b[1] + b[3]) / 2, (b[0] + b[2]) / 2);
      }
    }
    _minZoom = double.tryParse(meta['minzoom'] ?? '') ?? 0;
    _maxZoom = double.tryParse(meta['maxzoom'] ?? '') ?? 18;
    _zoom = _zoom.clamp(_minZoom, _maxZoom);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recomendacao != null
              ? widget.recomendacao!.titulo.isEmpty
                  ? 'Recomendação'
                  : widget.recomendacao!.titulo
              : _fileName ?? 'Carregando carta...',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Carregar outro arquivo',
            onPressed: _loading ? null : _pickFile,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _mode != _MapMode.none && _gpsPosition != null
          ? FloatingActionButton(
              onPressed: _centerOnGps,
              child: const Icon(Icons.directions_boat),
            )
          : null,
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

    return _buildMap();
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: _zoom,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        backgroundColor: const Color(0xFF1B3A5C),
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
                  Icons.directions_boat,
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
                        Icons.tips_and_updates,
                        color: Colors.deepOrange,
                        size: 32,
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
