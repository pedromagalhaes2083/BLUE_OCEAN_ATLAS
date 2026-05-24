// ============================================================
// FLUTTER SCREEN - Design Claro + Filtro por Proximidade
// ============================================================
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

class GribProcessorScreen extends StatefulWidget {
  const GribProcessorScreen({super.key});

  @override
  State<GribProcessorScreen> createState() => _GribProcessorScreenState();
}

class _GribProcessorScreenState extends State<GribProcessorScreen> {
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
  // CARREGAR JSON
  // ============================================================
  Future<void> carregarJsonDosAssets() async {
    setState(() => loading = true);

    try {
      // ====================================================
      // VENTO
      // ====================================================

      final String ventoString =
          await rootBundle.loadString('assets/json/vento.json');

      final Map<String, dynamic> ventoJson = jsonDecode(ventoString);

      // ====================================================
      // CORRENTES
      // ====================================================

      final String correnteString =
          await rootBundle.loadString('assets/json/correntes.json');

      final Map<String, dynamic> correnteJson = jsonDecode(correnteString);

      setState(() {
        resultadoVento = ventoJson;
        resultadoCorrente = correnteJson;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar JSON: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  // ============================================================
  // CALCULAR DISTÂNCIA
  // ============================================================
  double _calcularDistanciaKm(
      double lat1, double lon1, double lat2, double lon2) {
    const double raioTerra = 6371;
    double dLat = (lat2 - lat1) * math.pi / 180;
    double dLon = (lon2 - lon1) * math.pi / 180;
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return raioTerra * c;
  }

  // ============================================================
  // APLICAR FILTRO + ORDENAR POR PROXIMIDADE
  // ============================================================
  void _aplicarFiltro() {
    // =====================================================
    // VENTO
    // =====================================================

    if (resultadoVento != null) {
      List<dynamic> vento = List.from(resultadoVento!['dados'] ?? []);

      if (currentPosition != null) {
        vento.sort((a, b) {
          double distA = _calcularDistanciaKm(
            currentPosition!.latitude,
            currentPosition!.longitude,
            a['latitude'],
            a['longitude'],
          );

          double distB = _calcularDistanciaKm(
            currentPosition!.latitude,
            currentPosition!.longitude,
            b['latitude'],
            b['longitude'],
          );

          return distA.compareTo(distB);
        });
      }

      dadosExibidosVento = vento.take(50).toList();
    }

    // =====================================================
    // CORRENTES
    // =====================================================

    if (resultadoCorrente != null) {
      List<dynamic> correntes = List.from(resultadoCorrente!['dados'] ?? []);

      if (currentPosition != null) {
        correntes.sort((a, b) {
          double distA = _calcularDistanciaKm(
            currentPosition!.latitude,
            currentPosition!.longitude,
            a['latitude'],
            a['longitude'],
          );

          double distB = _calcularDistanciaKm(
            currentPosition!.latitude,
            currentPosition!.longitude,
            b['latitude'],
            b['longitude'],
          );

          return distA.compareTo(distB);
        });
      }

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
        setState(() => positionError = "❌ Localização está desativada");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => positionError = "❌ Permissão de localização negada");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        currentPosition = position;
      });

      _aplicarFiltro(); // Atualiza lista e card principal
    } catch (e) {
      setState(() => positionError = "❌ Erro: ${e.toString()}");
    } finally {
      setState(() => isLoadingPosition = false);
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

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    carregarJsonDosAssets();
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: loading ? null : carregarJsonDosAssets),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Position Card
            _buildPositionCard(),

            const SizedBox(height: 16),

            // Card Vento
            _buildVentoCard(),

            const SizedBox(height: 16),
            // Card Correntes
            _buildCorrenteCard(),
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

  // ==================== CARD PRINCIPAL ====================
  Widget _buildCorrenteCard() {
    if (dadosExibidosCorrentes.isEmpty) {
      return Card(
        color: const Color.fromARGB(255, 237, 239, 243),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text(
              'Carregando correntes marítimas...',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    final item = dadosExibidosCorrentes.first;

    final double velocidade = (item['velocidade'] ?? 0).toDouble();

    final double direcao = (item['direcao'] ?? 0).toDouble();

    final double temperatura = (item['temperatura_agua'] ?? 0).toDouble();

    final double salinidade = (item['salinidade'] ?? 0).toDouble();

    final double u = (item['u_corrente'] ?? 0).toDouble();

    final double v = (item['v_corrente'] ?? 0).toDouble();

    final double distancia = currentPosition != null
        ? _calcularDistanciaKm(
            currentPosition!.latitude,
            currentPosition!.longitude,
            item['latitude'],
            item['longitude'],
          )
        : 0;

    return Card(
      elevation: 8,
      color: const Color(0xFFEAF4FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================
            // TÍTULO
            // =========================================

            Row(
              children: const [
                Icon(
                  Icons.waves,
                  color: Colors.blue,
                  size: 34,
                ),
                SizedBox(width: 12),
                Text(
                  'Correntes Marítimas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================================
            // VELOCIDADE PRINCIPAL
            // =========================================

            Center(
              child: Column(
                children: [
                  Text(
                    velocidade.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'nós',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.navigation,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${direcao.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =========================================
            // INFORMAÇÕES
            // =========================================

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoColumn(
                  Icons.thermostat,
                  'Água',
                  '${temperatura.toStringAsFixed(1)}°C',
                ),
                _infoColumn(
                  Icons.opacity,
                  'Salinidade',
                  '${salinidade.toStringAsFixed(1)} PSU',
                ),
                _infoColumn(
                  Icons.location_on,
                  'Distância',
                  '${distancia.toStringAsFixed(1)} km',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // =========================================
            // COMPONENTES VETORIAIS
            // =========================================

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'Componentes Vetoriais',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'U',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            u.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'V',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            v.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================================
            // COORDENADAS
            // =========================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    'Coordenadas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item['latitude'].toStringAsFixed(2)}°, '
                    '${item['longitude'].toStringAsFixed(2)}°',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVentoCard() {
    if (dadosExibidosVento.isEmpty) {
      return Card(
        color: const Color.fromARGB(255, 237, 239, 243),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Padding(
          padding: EdgeInsets.all(40),
          child: Center(
              child:
                  Text('Carregando dados...', style: TextStyle(fontSize: 18))),
        ),
      );
    }

    final item = dadosExibidosVento.first;
    final double velocidade = (item['velocidade'] ?? 0).toDouble();
    final double direcao = (item['direcao'] ?? 0).toDouble();
    final double tmp2m = (item['tmp2m'] ?? 0).toDouble() - 273.15;
    final double distancia = currentPosition != null
        ? _calcularDistanciaKm(currentPosition!.latitude,
            currentPosition!.longitude, item['latitude'], item['longitude'])
        : 0;

    return Card(
      color: const Color.fromARGB(255, 237, 239, 243),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(velocidade.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 62, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Text('nós', style: TextStyle(fontSize: 24)),
              ],
            ),
            Text('${direcao.toStringAsFixed(0)}°',
                style: const TextStyle(fontSize: 22, color: Colors.red)),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoColumn(Icons.thermostat, 'Temperatura',
                    '${tmp2m.toStringAsFixed(1)}°C'),
                _infoColumn(Icons.location_on, 'Distância',
                    '${distancia.toStringAsFixed(1)} km'),
                _infoColumn(Icons.place, 'Coordenadas',
                    '${item['latitude'].toStringAsFixed(2)}°,\n${item['longitude'].toStringAsFixed(2)}°'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 15), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildPositionCard() {
    // (seu método original mantido)
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color.fromARGB(255, 237, 239, 243),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('📍 Posição Atual',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (isLoadingPosition)
                const CircularProgressIndicator()
              else if (positionError != null)
                Text(positionError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center)
              else if (currentPosition != null)
                Text(
                    _formatCoordinates(
                        currentPosition!.latitude, currentPosition!.longitude),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Toque no botão para atualizar',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
