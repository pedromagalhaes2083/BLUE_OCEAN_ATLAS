import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:atlas/core/services/location_service.dart';
import 'package:atlas/core/database/database_helper.dart';
import 'minhas_solicitacoes_screen.dart';

class SolicitarCartaScreen extends StatefulWidget {
  final DatabaseHelper dbHelper;

  /// Se informadas, as coordenadas já vêm preenchidas (ex: pedido feito a
  /// partir de um ponto marcado no mapa) em vez de começar em 0°/0'.
  final double? latitudeInicial;
  final double? longitudeInicial;

  const SolicitarCartaScreen({
    super.key,
    required this.dbHelper,
    this.latitudeInicial,
    this.longitudeInicial,
  });

  @override
  State<SolicitarCartaScreen> createState() => _SolicitarCartaScreenState();
}

class _SolicitarCartaScreenState extends State<SolicitarCartaScreen> {
  final LocationService _locationService = LocationService();

  // Latitude: grau (0-90) e minuto (0-59), hemisfério N/S.
  int _latDeg = 0;
  int _latMin = 0;
  String _latHemisferio = 'S';

  // Longitude: grau (0-180) e minuto (0-59), hemisfério E/W.
  int _lonDeg = 0;
  int _lonMin = 0;
  String _lonHemisferio = 'W';

  late final FixedExtentScrollController _latDegCtrl =
      FixedExtentScrollController(initialItem: _latDeg);
  late final FixedExtentScrollController _latMinCtrl =
      FixedExtentScrollController(initialItem: _latMin);
  late final FixedExtentScrollController _lonDegCtrl =
      FixedExtentScrollController(initialItem: _lonDeg);
  late final FixedExtentScrollController _lonMinCtrl =
      FixedExtentScrollController(initialItem: _lonMin);

  bool _isLoadingLocation = false;

  String get _latTexto => '$_latDeg° $_latMin\' $_latHemisferio';
  String get _lonTexto => '$_lonDeg° $_lonMin\' $_lonHemisferio';

  @override
  void initState() {
    super.initState();
    if (widget.latitudeInicial != null) {
      final (deg, min, hemis) =
          _decimalParaGrausMinutos(widget.latitudeInicial!, isLatitude: true);
      _latDeg = deg;
      _latMin = min;
      _latHemisferio = hemis;
    }
    if (widget.longitudeInicial != null) {
      final (deg, min, hemis) = _decimalParaGrausMinutos(
          widget.longitudeInicial!,
          isLatitude: false);
      _lonDeg = deg;
      _lonMin = min;
      _lonHemisferio = hemis;
    }
  }

  (int, int, String) _decimalParaGrausMinutos(double decimal,
      {required bool isLatitude}) {
    final hemisferio = isLatitude
        ? (decimal >= 0 ? 'N' : 'S')
        : (decimal >= 0 ? 'E' : 'W');

    decimal = decimal.abs();
    final deg = decimal.floor();
    final min = ((decimal - deg) * 60).round().clamp(0, 59);
    final degMax = isLatitude ? 90 : 180;
    return (deg.clamp(0, degMax), min, hemisferio);
  }

  Future<void> _getCurrentPosition() async {
    setState(() => _isLoadingLocation = true);

    try {
      Position? position = await _locationService.getCurrentPosition();
      if (!mounted) return;

      if (position != null) {
        _aplicarDecimal(position.latitude, isLatitude: true);
        _aplicarDecimal(position.longitude, isLatitude: false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Posição atual obtida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String message = e.toString().contains('negada permanentemente')
          ? 'Permissão de localização negada permanentemente. Ative nas configurações.'
          : 'Não foi possível obter a localização: $e';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
      );
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _aplicarDecimal(double decimal, {required bool isLatitude}) {
    final (deg, min, hemisferio) =
        _decimalParaGrausMinutos(decimal, isLatitude: isLatitude);

    setState(() {
      if (isLatitude) {
        _latDeg = deg;
        _latMin = min;
        _latHemisferio = hemisferio;
      } else {
        _lonDeg = deg;
        _lonMin = min;
        _lonHemisferio = hemisferio;
      }
    });

    const duracao = Duration(milliseconds: 300);
    if (isLatitude) {
      _latDegCtrl.animateToItem(_latDeg, duration: duracao, curve: Curves.easeOut);
      _latMinCtrl.animateToItem(_latMin, duration: duracao, curve: Curves.easeOut);
    } else {
      _lonDegCtrl.animateToItem(_lonDeg, duration: duracao, curve: Curves.easeOut);
      _lonMinCtrl.animateToItem(_lonMin, duration: duracao, curve: Curves.easeOut);
    }
  }

  Future<void> _solicitarCarta() async {
    try {
      await widget.dbHelper.insert('solicitacao_carta', {
        'latitude_texto': _latTexto,
        'longitude_texto': _lonTexto,
        'data_solicitacao': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação registrada! Veja em "Minhas Solicitações".'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retorna sucesso
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao solicitar carta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _latDegCtrl.dispose();
    _latMinCtrl.dispose();
    _lonDegCtrl.dispose();
    _lonMinCtrl.dispose();
    super.dispose();
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 38,
      useMagnifier: true,
      magnification: 1.15,
      diameterRatio: 1.1,
      onSelectedItemChanged: onChanged,
      children: List.generate(
        itemCount,
        (i) => Center(
          child: Text(
            i.toString().padLeft(2, '0'),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  Widget _hemisferioSeletor({
    required String valor,
    required List<String> opcoes,
    required ValueChanged<String> onChanged,
  }) {
    return ToggleButtons(
      direction: Axis.vertical,
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      fillColor: Colors.blue[800],
      constraints: const BoxConstraints(minWidth: 48, minHeight: 40),
      isSelected: opcoes.map((o) => o == valor).toList(),
      onPressed: (index) => onChanged(opcoes[index]),
      children: opcoes.map((o) => Text(o)).toList(),
    );
  }

  Widget _cardCoordenada({
    required String titulo,
    required String preview,
    required int degMax,
    required FixedExtentScrollController degCtrl,
    required ValueChanged<int> onDeg,
    required FixedExtentScrollController minCtrl,
    required ValueChanged<int> onMin,
    required String hemisferio,
    required List<String> opcoesHemisferio,
    required ValueChanged<String> onHemisferio,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              preview,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _wheel(
                            controller: degCtrl,
                            itemCount: degMax + 1,
                            onChanged: onDeg),
                      ),
                      const Text('°', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: _wheel(
                            controller: minCtrl,
                            itemCount: 60,
                            onChanged: onMin),
                      ),
                      const Text("'", style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      _hemisferioSeletor(
                        valor: hemisferio,
                        opcoes: opcoesHemisferio,
                        onChanged: onHemisferio,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Carta Náutica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Minhas solicitações',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    MinhasSolicitacoesScreen(dbHelper: widget.dbHelper),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Coordenada Geográfica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gire os seletores como no relógio para ajustar graus e minutos',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            _cardCoordenada(
              titulo: 'Latitude',
              preview: _latTexto,
              degMax: 90,
              degCtrl: _latDegCtrl,
              onDeg: (v) => setState(() => _latDeg = v),
              minCtrl: _latMinCtrl,
              onMin: (v) => setState(() => _latMin = v),
              hemisferio: _latHemisferio,
              opcoesHemisferio: const ['N', 'S'],
              onHemisferio: (v) => setState(() => _latHemisferio = v),
            ),
            const SizedBox(height: 16),
            _cardCoordenada(
              titulo: 'Longitude',
              preview: _lonTexto,
              degMax: 180,
              degCtrl: _lonDegCtrl,
              onDeg: (v) => setState(() => _lonDeg = v),
              minCtrl: _lonMinCtrl,
              onMin: (v) => setState(() => _lonMin = v),
              hemisferio: _lonHemisferio,
              opcoesHemisferio: const ['E', 'W'],
              onHemisferio: (v) => setState(() => _lonHemisferio = v),
            ),

            const SizedBox(height: 24),

            // Botão de Posição Atual
            ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getCurrentPosition,
              icon: const Icon(Icons.my_location),
              label: _isLoadingLocation
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('USAR MINHA POSIÇÃO ATUAL'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 32),

            // Botão Principal
            ElevatedButton(
              onPressed: _solicitarCarta,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'SOLICITAR CARTA NÁUTICA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
