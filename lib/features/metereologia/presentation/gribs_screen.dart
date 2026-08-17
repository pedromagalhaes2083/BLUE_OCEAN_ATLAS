// ============================================================
// FLUTTER SCREEN - Design Claro + Filtro por Proximidade
// ============================================================
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:atlas/features/widgets/meteorology_widgets/current_card.dart';
import 'package:atlas/features/widgets/meteorology_widgets/wind_card.dart';
import 'package:atlas/features/widgets/position_card.dart';

class GribProcessorScreen extends StatefulWidget {
  const GribProcessorScreen({super.key});

  @override
  State<GribProcessorScreen> createState() => _GribProcessorScreenState();
}

class _GribProcessorScreenState extends State<GribProcessorScreen> {
  static const double _raioMaximoNm = 80.0; // ≈ 150 km (em milhas náuticas)

  bool loading = false;
  Map<String, dynamic>? resultadoVento;
  Map<String, dynamic>? resultadoCorrente;

  List<dynamic> dadosExibidosVento = [];
  List<dynamic> dadosExibidosCorrentes = [];

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

      if (!mounted) return;
      setState(() {
        resultadoVento = jsonDecode(ventoString);
        resultadoCorrente = jsonDecode(correnteString);
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
    const double raioMaximoNm = _raioMaximoNm;

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
    final bool carregamentoInicial = loading && resultadoVento == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        titleSpacing: 20,
        title: const Text('Meteorologia',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Recarregar dados',
            onPressed: loading ? null : carregarJsonDosAssets,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: carregamentoInicial
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando dados meteorológicos...',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: carregarJsonDosAssets,
              child: _buildConteudo(context),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        tooltip: 'Atualizar posição',
        onPressed: isLoadingPosition ? null : _getCurrentPosition,
        child: isLoadingPosition
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    final double distVento = _distanciaDoPrimeiro(dadosExibidosVento);
    final double distCorrente = _distanciaDoPrimeiro(dadosExibidosCorrentes);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        PositionCard(
          isLoadingPosition: isLoadingPosition,
          positionError: positionError,
          currentPosition: currentPosition,
          formatCoordinates: _formatCoordinates,
          onRefresh: _getCurrentPosition,
        ),
        if (currentPosition != null) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Dados num raio de ${_raioMaximoNm.toStringAsFixed(0)} mn da posição atual',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.air,
          label: 'Vento',
          color: const Color(0xFF3ECFF3),
          count: dadosExibidosVento.length,
        ),
        const SizedBox(height: 12),
        dadosExibidosVento.isEmpty
            ? const _EmptyDatasetCard(mensagem: 'Nenhum dado de vento por perto')
            : WindCard(dados: dadosExibidosVento, distancia: distVento),
        const SizedBox(height: 24),
        _SectionHeader(
          icon: Icons.waves,
          label: 'Correntes',
          color: Colors.blue,
          count: dadosExibidosCorrentes.length,
        ),
        const SizedBox(height: 12),
        dadosExibidosCorrentes.isEmpty
            ? const _EmptyDatasetCard(
                mensagem: 'Nenhum dado de correntes por perto')
            : CurrentCard(dados: dadosExibidosCorrentes, distancia: distCorrente),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        if (count > 0)
          Text(
            '$count ${count == 1 ? 'ponto' : 'pontos'}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}

class _EmptyDatasetCard extends StatelessWidget {
  final String mensagem;

  const _EmptyDatasetCard({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color(0xFFEDF1F3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.location_searching, color: Colors.grey.shade400, size: 28),
              const SizedBox(height: 8),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
