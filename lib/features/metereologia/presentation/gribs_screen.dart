// ============================================================
// FLUTTER SCREEN - Design Claro + Filtro por Proximidade
// ============================================================
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:atlas/features/widgets/meteorology_widgets/chlorophyll_widgets.dart';
import 'package:atlas/features/widgets/meteorology_widgets/current_card.dart';
import 'package:atlas/features/widgets/meteorology_widgets/wind_card.dart';
import 'package:atlas/features/widgets/position_card.dart';

class GribProcessorScreen extends StatefulWidget {
  const GribProcessorScreen({super.key});

  @override
  State<GribProcessorScreen> createState() => _GribProcessorScreenState();
}

class _GribProcessorScreenState extends State<GribProcessorScreen> {
  bool loading = false;
  Map<String, dynamic>? resultadoVento;
  Map<String, dynamic>? resultadoCorrente;
  Map<String, dynamic>? resultadoClorofila;

  List<dynamic> dadosExibidosVento = [];
  List<dynamic> dadosExibidosCorrentes = [];
  List<dynamic> dadosExibidosClorofila = [];

  bool loadingClorofila = false;
  String? erroClorofila;
  // Posição
  Position? currentPosition;
  bool isLoadingPosition = false;
  String? positionError;

  // ============================================================
  // CARREGAR JSONs
  // ============================================================
  Future<void> carregarJsonDosAssets() async {
    setState(() => loading = true);
    try {
      final ventoString = await rootBundle.loadString('assets/json/vento.json');
      final correnteString =
          await rootBundle.loadString('assets/json/correntes.json');
      final clorofilaString =
          await rootBundle.loadString('assets/json/clorofila.json');

      if (!mounted) return;
      setState(() {
        resultadoVento = jsonDecode(ventoString);
        resultadoCorrente = jsonDecode(correnteString);
        resultadoClorofila = jsonDecode(clorofilaString);
      });

      _aplicarFiltro(); // Atualiza as listas filtradas
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar JSON: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // ============================================================
  // CALCULAR DISTÂNCIA
  // ============================================================
  double _calcularDistanciaMilhasNauticas(
      double lat1, double lon1, double lat2, double lon2) {
    const double raioTerraMilhasNauticas = 3440.065; // 6371 km ÷ 1.852
    double dLat = (lat2 - lat1) * math.pi / 180;
    double dLon = (lon2 - lon1) * math.pi / 180;
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return raioTerraMilhasNauticas * c;
  }

  // ============================================================
  // APLICAR FILTRO + ORDENAR POR PROXIMIDADE
  // ============================================================
  void _aplicarFiltro() {
    if (currentPosition == null) {
      setState(() {});
      return;
    }

    final double userLat = currentPosition!.latitude;
    final double userLon = currentPosition!.longitude;
    const double raioMaximoNm = 80.0; // ≈ 150 km (em milhas náuticas)

    // VENTO
    if (resultadoVento != null) {
      List<dynamic> vento = List.from(resultadoVento!['dados'] ?? []);

      vento = vento.where((item) {
        double dist = _calcularDistanciaMilhasNauticas(
            userLat, userLon, item['latitude'], item['longitude']);
        return dist <= raioMaximoNm;
      }).toList();

      vento.sort((a, b) {
        double distA = _calcularDistanciaMilhasNauticas(
            userLat, userLon, a['latitude'], a['longitude']);
        double distB = _calcularDistanciaMilhasNauticas(
            userLat, userLon, b['latitude'], b['longitude']);
        return distA.compareTo(distB);
      });

      dadosExibidosVento = vento.take(50).toList();
    }

    // CORRENTES
    if (resultadoCorrente != null) {
      List<dynamic> correntes = List.from(resultadoCorrente!['dados'] ?? []);

      correntes = correntes.where((item) {
        double dist = _calcularDistanciaMilhasNauticas(
            userLat, userLon, item['latitude'], item['longitude']);
        return dist <= raioMaximoNm;
      }).toList();

      correntes.sort((a, b) {
        double distA = _calcularDistanciaMilhasNauticas(
            userLat, userLon, a['latitude'], a['longitude']);
        double distB = _calcularDistanciaMilhasNauticas(
            userLat, userLon, b['latitude'], b['longitude']);
        return distA.compareTo(distB);
      });

      dadosExibidosCorrentes = correntes.take(50).toList();
    }

    // CLOROFILA
    if (resultadoClorofila != null) {
      List<dynamic> clorofila = List.from(resultadoClorofila!['dados'] ?? []);

      clorofila = clorofila.where((item) {
        double dist = _calcularDistanciaMilhasNauticas(
            userLat, userLon, item['latitude'], item['longitude']);
        return dist <= raioMaximoNm;
      }).toList();

      clorofila.sort((a, b) {
        double distA = _calcularDistanciaMilhasNauticas(
            userLat, userLon, a['latitude'], a['longitude']);
        double distB = _calcularDistanciaMilhasNauticas(
            userLat, userLon, b['latitude'], b['longitude']);
        return distA.compareTo(distB);
      });

      dadosExibidosClorofila =
          clorofila.take(50).map((e) => Map<String, dynamic>.from(e)).toList();
    }

    setState(() {});
  }

  // ============================================================
  // OBTER POSIÇÃO
  // ============================================================
  Future<void> _getCurrentPosition() async {
    setState(() {
      isLoadingPosition = true;
      positionError = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => positionError = "❌ Localização está desativada");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() => positionError = "❌ Permissão de localização negada");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        currentPosition = position;
      });

      _aplicarFiltro(); // Atualiza lista e card principal
    } catch (e) {
      if (!mounted) return;
      setState(() => positionError = "❌ Erro: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoadingPosition = false);
    }
  }

  String _formatCoordinates(double lat, double lon) {
    String formatDMS(double value, bool isLatitude) {
      String direction =
          isLatitude ? (value >= 0 ? 'N' : 'S') : (value >= 0 ? 'E' : 'W');
      value = value.abs();
      int degrees = value.floor();
      double minutesDecimal = (value - degrees) * 60;
      int minutes = minutesDecimal.floor();
      double seconds = (minutesDecimal - minutes) * 60;
      return '$degrees° ${minutes.toString().padLeft(2, '0')}\' ${seconds.toStringAsFixed(0).padLeft(2, '0')}" $direction';
    }

    return '${formatDMS(lat, true)}\n${formatDMS(lon, false)}';
  }

// Helper para não repetir o cálculo de distância
  double _distanciaDoPrimeiro(List<dynamic> lista) {
    if (lista.isEmpty || currentPosition == null) return 0;
    final item = lista.first;
    return _calcularDistanciaMilhasNauticas(
      currentPosition!.latitude,
      currentPosition!.longitude,
      item['latitude'],
      item['longitude'],
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    carregarJsonDosAssets();
  }

  @override
  Widget build(BuildContext context) {
    // Calcula distâncias uma vez
    double distVento = _distanciaDoPrimeiro(dadosExibidosVento);
    double distCorrente = _distanciaDoPrimeiro(dadosExibidosCorrentes);
    final clorofilaDataset = ChlorophyllDataset.fromRawList(
      dadosExibidosClorofila,
      originLat: currentPosition?.latitude,
      originLon: currentPosition?.longitude,
    );
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: const Text('METEOROLOGIA - GRIBS',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading
                ? null
                : () {
                    carregarJsonDosAssets();
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PositionCard(
              isLoadingPosition: isLoadingPosition,
              positionError: positionError,
              currentPosition: currentPosition,
              formatCoordinates: _formatCoordinates,
            ),
            const SizedBox(height: 16),
            WindCard(dados: dadosExibidosVento, distancia: distVento),
            const SizedBox(height: 16),
            CurrentCard(dados: dadosExibidosCorrentes, distancia: distCorrente),
            const SizedBox(height: 16),
            ChlorophyllCard(dataset: clorofilaDataset),
            const SizedBox(height: 16),
            ChlorophyllNearbyList(dataset: clorofilaDataset),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _getCurrentPosition,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
