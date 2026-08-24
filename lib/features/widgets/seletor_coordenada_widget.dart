import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/services/location_service.dart';

/// Seletor de coordenada por roletas (graus/minutos + hemisfério), com
/// botão opcional de "usar minha posição atual" — extraído de
/// `SolicitarCartaScreen` pra ser reaproveitado em qualquer tela que
/// precise de uma coordenada digitada à mão (ex: novo porto na Tábua de
/// Maré), em vez de cada uma reimplementar seu próprio par de `TextField`.
///
/// Chama [onAlterado] toda vez que a coordenada muda — inclusive uma vez
/// no primeiro frame, com o valor inicial — então quem usa o widget nunca
/// precisa perguntar "qual é o valor atual", só guardar o último que
/// recebeu.
class SeletorCoordenadaWidget extends StatefulWidget {
  final double? latitudeInicial;
  final double? longitudeInicial;
  final void Function(double latitude, double longitude) onAlterado;
  final bool mostrarBotaoPosicaoAtual;

  const SeletorCoordenadaWidget({
    super.key,
    this.latitudeInicial,
    this.longitudeInicial,
    required this.onAlterado,
    this.mostrarBotaoPosicaoAtual = true,
  });

  @override
  State<SeletorCoordenadaWidget> createState() => _SeletorCoordenadaWidgetState();
}

class _SeletorCoordenadaWidgetState extends State<SeletorCoordenadaWidget> {
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

  bool _obtendoPosicao = false;

  String get _latTexto => '$_latDeg° $_latMin\' $_latHemisferio';
  String get _lonTexto => '$_lonDeg° $_lonMin\' $_lonHemisferio';

  double get _latDecimal =>
      (_latHemisferio == 'S' ? -1 : 1) * (_latDeg + _latMin / 60);
  double get _lonDecimal =>
      (_lonHemisferio == 'W' ? -1 : 1) * (_lonDeg + _lonMin / 60);

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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.onAlterado(_latDecimal, _lonDecimal));
  }

  (int, int, String) _decimalParaGrausMinutos(double decimal,
      {required bool isLatitude}) {
    final hemisferio =
        isLatitude ? (decimal >= 0 ? 'N' : 'S') : (decimal >= 0 ? 'E' : 'W');

    decimal = decimal.abs();
    final deg = decimal.floor();
    final min = ((decimal - deg) * 60).round().clamp(0, 59);
    final degMax = isLatitude ? 90 : 180;
    return (deg.clamp(0, degMax), min, hemisferio);
  }

  void _notificar() => widget.onAlterado(_latDecimal, _lonDecimal);

  Future<void> _usarPosicaoAtual() async {
    setState(() => _obtendoPosicao = true);
    try {
      final posicao = await LocationService().getCurrentPosition();
      if (!mounted || posicao == null) return;
      _aplicarDecimal(posicao.latitude, isLatitude: true);
      _aplicarDecimal(posicao.longitude, isLatitude: false);
      _notificar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível obter a localização: $e')),
      );
    } finally {
      if (mounted) setState(() => _obtendoPosicao = false);
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
      fillColor: Theme.of(context).colorScheme.primary,
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              preview,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _wheel(
                            controller: degCtrl, itemCount: degMax + 1, onChanged: onDeg),
                      ),
                      const Text('°', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child:
                            _wheel(controller: minCtrl, itemCount: 60, onChanged: onMin),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _cardCoordenada(
          titulo: 'Latitude',
          preview: _latTexto,
          degMax: 90,
          degCtrl: _latDegCtrl,
          onDeg: (v) {
            setState(() => _latDeg = v);
            _notificar();
          },
          minCtrl: _latMinCtrl,
          onMin: (v) {
            setState(() => _latMin = v);
            _notificar();
          },
          hemisferio: _latHemisferio,
          opcoesHemisferio: const ['N', 'S'],
          onHemisferio: (v) {
            setState(() => _latHemisferio = v);
            _notificar();
          },
        ),
        const SizedBox(height: 16),
        _cardCoordenada(
          titulo: 'Longitude',
          preview: _lonTexto,
          degMax: 180,
          degCtrl: _lonDegCtrl,
          onDeg: (v) {
            setState(() => _lonDeg = v);
            _notificar();
          },
          minCtrl: _lonMinCtrl,
          onMin: (v) {
            setState(() => _lonMin = v);
            _notificar();
          },
          hemisferio: _lonHemisferio,
          opcoesHemisferio: const ['E', 'W'],
          onHemisferio: (v) {
            setState(() => _lonHemisferio = v);
            _notificar();
          },
        ),
        if (widget.mostrarBotaoPosicaoAtual) ...[
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _obtendoPosicao ? null : _usarPosicaoAtual,
            icon: const Icon(Icons.my_location),
            label: _obtendoPosicao
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('USAR MINHA POSIÇÃO ATUAL'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ],
      ],
    );
  }
}
