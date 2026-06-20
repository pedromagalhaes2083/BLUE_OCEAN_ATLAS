import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/services/mbtiles_service.dart';
import '../../../core/services/geotiff_service.dart';
import '../widgets/mbtiles_tile_provider.dart';

enum _MapMode { none, mbtiles, geotiff }

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MbtilesService _mbtiles = MbtilesService();
  final GeotiffService _geotiffService = GeotiffService();
  final MapController _mapController = MapController();

  _MapMode _mode = _MapMode.none;
  bool _loading = false;
  String? _fileName;
  String? _error;

  // Estado GeoTIFF
  GeotiffResult? _geotiff;

  // Estado MBTiles (zoom/center)
  double _minZoom = 0;
  double _maxZoom = 18;
  LatLng _center = const LatLng(-15.0, -50.0);
  double _zoom = 4;

  // GPS
  LatLng? _gpsPosition;

  @override
  void initState() {
    super.initState();
    _loadGpsPosition();
  }

  @override
  void dispose() {
    _mbtiles.close();
    super.dispose();
  }

  Future<void> _loadGpsPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(const Duration(seconds: 10));
      if (mounted) {
        setState(() => _gpsPosition = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {}
  }

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

  // ── MBTiles ────────────────────────────────────────────────────────────────

  Future<void> _openMbtiles(String path, String name) async {
    setState(() => _loading = true);
    try {
      // Fecha qualquer arquivo anterior
      await _mbtiles.close();
      await _mbtiles.open(path);
      final meta = await _mbtiles.getMetadata();

      if (meta.containsKey('center')) {
        final parts = meta['center']!.split(',').map(double.parse).toList();
        if (parts.length >= 2) {
          _center = LatLng(parts[1], parts[0]);
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

  // ── GeoTIFF ────────────────────────────────────────────────────────────────

  Future<void> _openGeotiff(String path, String name) async {
    setState(() => _loading = true);
    try {
      final result = await _geotiffService.load(path);

      // Fecha MBTiles se estava aberto
      await _mbtiles.close();

      final centerLat = (result.north + result.south) / 2;
      final centerLon = (result.east + result.west) / 2;

      setState(() {
        _mode = _MapMode.geotiff;
        _geotiff = result;
        _fileName = name;
        _center = LatLng(centerLat, centerLon);
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

  // ── GPS ────────────────────────────────────────────────────────────────────

  void _centerOnGps() {
    if (_gpsPosition != null) {
      _mapController.move(_gpsPosition!, _mapController.camera.zoom);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _fileName ?? 'Visualizador de Mapa',
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
            tooltip: 'Abrir arquivo',
            onPressed: _loading ? null : _pickFile,
          ),
        ],
      ),
      body: _mode != _MapMode.none ? _buildMap() : _buildEmpty(),
      floatingActionButton: _mode != _MapMode.none && _gpsPosition != null
          ? FloatingActionButton(
              onPressed: _centerOnGps,
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: _zoom,
        minZoom: _minZoom,
        maxZoom: _maxZoom,
        // Fundo azul-oceano quando não há tiles de base (modo GeoTIFF)
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
        if (_gpsPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _gpsPosition!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 36,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Nenhum arquivo carregado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Formatos suportados: .mbtiles  •  .tif / .tiff (WGS84)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            if (_error != null) ...[
              const SizedBox(height: 20),
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
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loading ? null : _pickFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Abrir arquivo'),
            ),
          ],
        ),
      ),
    );
  }
}
